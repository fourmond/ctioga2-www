# examples.rb: a Webgen plugin to display examples
# 
# This file is copyright 2011, 2013 by Vincent Fourmond, and can be used and
# redistributed under the same terms as webgen version 0.4 itself.

# @todo There are a lot of things to refactor here

class CTiogaCmdlineTag < Tags::DefaultTag

  infos( :name => 'Tag/CTiogaCmdline',
         :summary => 
         "A ctioga command line and the corresponding image.")

  register_tag 'ctCmdline'

  param 'file', false, "The file containing the command-line"
  param 'alt', false, 'The alternative text'
  # @todo implement that
  param 'image', true, "Whether the image should be displayed and linked or not"
  param 'cls', 'examples-cmdline', "The class used for the <pre> elements"
  param 'cmdbase', "/doc/commands.html", 'The base URL for commands links. False to deactivate'
  
  set_mandatory 'file', true

  CTiogaCommands = YAML.load(`ctioga2 --list-commands /format yaml`)

  begin
    # Indexing on command-line-switches
    a = {}
    for k,v in CTiogaCommands
      a[v['long_option']] = v
    end
    CTiogaSwitches = a
    b = {}
    for k,v in CTiogaCommands
      if v['short_option']
        b[v['short_option']] = v
      end
    end
    CTiogaShortSwitches = b
  end

  # Hook at the end of the pre stuff...
  def pre_end(tag, chain)
    return ""
  end

  # Registers the file onto a global registry
  def register_file(thumb, pid, chain)
    db = {}
    if File.exists? 'index.yaml'
      db = YAML.load(IO.readlines('index.yaml').join())
    end

    page = File::basename(chain.last.node_info[:src], ".page") + ".html"
    root_node = chain.first.resolve_node("/index.html")
    base = File::dirname(root_node.route_to(chain.last))

    thmb = "#{base}/#{thumb}"
    db[thmb] = "#{base}/#{page}##{pid}"

    File.open("index.yaml", "w") do |f|
      f.write(db.to_yaml)
    end
  end

  def process_tag( tag, chain )
    if cmdline = param('file')
      base = cmdline.gsub(/\.ct2(-sh)?$/, '')
      image = base + ".png"
      alt = param('alt') || ""
      thumb = base + '.thumb.png'
      id_base = "#{File::basename(image,'.png')}"
      filename = File.join( chain.first.parent.node_info[:src], cmdline ) 
      register_file(thumb, "pre-#{id_base}", chain)
      return "</p><pre class='#{param('cls')}' id='pre-#{id_base}'>\n" +
        begin
          link_commands(IO.readlines(filename).join, chain)
        rescue Exception => e
          "<b>IO problem reading file #{cmdline}: #{e.inspect}</b>"
        end  + "</pre>#{pre_end(tag, chain)}" +
        "<p class='example-image'>\n" +
        "<a href=\"#{image}\" id=\"img-#{id_base}\">" +
        "<img src=\"#{thumb}\" class='thumbnail' alt=\"#{alt}\"/></a>"
    else
      return "Ourgh"
    end
  end

  def escape_HTML!(str)
    str.gsub!(">", "&gt;")
    str.gsub!("<", "&lt;")
  end

  def purify_description(desc)
    desc.gsub(/\{\w+:([^}]+)\}/) do 
      $1
    end
  end

  # Transforms commands into links to the appropriate point in the
  # documentation.
  def link_commands(string, chain)
    base = param('cmdbase')
    if base
      cmdlocation = resolve_path(base, chain)
      
      # Now, we need to be a little more subtle...
      escape_HTML!(string)

      string.gsub!(/(\s)-(\w)/) do 
        init = $1
        switch = $2
        cmd = CTiogaShortSwitches[switch]
        if cmd
          desc = purify_description(cmd['short_description'])
          "#{init}<a href=\"#{cmdlocation}#command-#{cmd['name']}\" title=\"#{desc}\">-#{switch}</a>"
        else
          "#{init}-#{switch}"
        end
      end

      return string.gsub(/--(\S+)/) do 
        switch = $1
        cmd = CTiogaSwitches[switch]
        if cmd
          desc = purify_description(cmd['short_description'])
          "<a href=\"#{cmdlocation}#command-#{cmd['name']}\" title=\"#{desc}\">--#{switch}</a>"
        else
          "--#{switch}"
        end
      end
    else
      return string
    end
  end

  def resolve_path(uri, chain )
    dest_node = chain.first.resolve_node( uri )
    chain.last.route_to(dest_node)
  end

  
end


class CTiogaCmdfileTag < CTiogaCmdlineTag

  infos( :name => 'Tag/CTiogaCmdfile',
         :summary => 
         "A ctioga command file and the corresponding image.")

  register_tag 'ctCmdfile'
  param 'cls', 'examples-cmdfile', "The class used for the <pre> elements"
  param 'file', false, "The file containing the command-line"

  set_mandatory 'file', true


  # Hook at the end of the pre stuff...
  def pre_end(tag, chain)
    return "<p class='download-link'><a href='#{param('file')}'>Download command file</a></p>"
  end

  # Transforms commands into links to the appropriate point in the
  # documentation.
  def link_commands(string, chain)
    base = param('cmdbase')
    if base
      cmdlocation = resolve_path(base, chain)
      escape_HTML!(string)
      return string.gsub(/^(\s*)([^ ()\n\t]+)(\(|\s+)/) do 
        pre = $1
        command = $2
        sep = $3
        cmd = CTiogaCommands[command]
        if cmd
          desc = purify_description(cmd['short_description'])
          a = "#{pre}<a href=\"#{cmdlocation}#command-#{command}\" title=\"#{desc}\">#{command}</a>#{sep}"
        else
          "#{pre}#{command}#{sep}"
        end
      end
    else
      return string
    end
  end


end

class CTiogaSwitchTag < Tags::DefaultTag

  infos( :name => 'Tag/CTiogaSwitch',
         :summary => 
         "A link to  ctioga command.")

  register_tag 'cmd'

  param 'switch', false, "The command"
  param 'cmdbase', "/doc/commands.html", 'The base URL for commands links. False to deactivate'
  
  set_mandatory 'switch', true

  def purify_description(desc)
    desc.gsub(/\{\w+:([^}]+)\}/) do 
      $1
    end
  end

  def process_tag( tag, chain )
    # @todo maybe the plugin should detect if it is a short or long
    # switch or a command.
    if switch = param('switch')
      switch.gsub!(/^\s*(--)?\s*/,'')    # Remove the leading dashes
      switch.gsub!(/\s*$/,'')    # Remove the leading dashes
      cmd = CTiogaCmdlineTag::CTiogaSwitches[switch]
      base = param('cmdbase')
      cmdlocation = resolve_path(base, chain)
      if cmd
        desc = purify_description(cmd['short_description'])
        return "<code><a href=\"#{cmdlocation}#command-#{cmd['name']}\" title=\"#{desc}\">--#{switch}</a></code>"
      else
        return "<code>--#{switch}</code>"
      end
    end
  end

  def resolve_path(uri, chain )
    dest_node = chain.first.resolve_node( uri )
    chain.last.route_to(dest_node)
  end
end

class CTiogaCommandTag < CTiogaSwitchTag

  infos( :name => 'Tag/CTiogaCommand',
         :summary => 
         "A link to  ctioga command.")


  register_tag 'command'

  param 'switch', false, "The command"
  set_mandatory 'switch', true


  def process_tag( tag, chain )
    a = super(tag, chain)
    if a
      return a.gsub('--', '')
    end
  end

end

class CTiogaFight < CTiogaCmdfileTag

  infos( :name => 'Tag/CTiogaFight',
         :summary => 
         "ctioga vs gnuplot")

  register_tag 'fight'
  param 'file', false, "The file containing the command-line"

  set_mandatory 'file', true




  def process_tag( tag, chain )
    if base = param('file')

      # We maintain a YAML database of the completion status of the
      # conversion from gnuplot to ctioga2 of the examples.
      #
      # We have a hash containing the base name of the files (ie the
      # name of the page) => hash for the argument => (true = ok,
      # string (missing something), false = not implemented at all)


      radix = File::basename(base)
      str = "<h3  class='fight'>Example: <code>#{radix}</code></h3>"
      image_gplt = base + "-gnuplot.png"
      thumb_gplt = base + '-gnuplot.thumb.png'
      
      image_ct2 = base + "-ct2.png"
      thumb_ct2 = base + '-ct2.thumb.png'
      id_base = base
      file_base = File.join( chain.first.parent.node_info[:src], base ) 

      file_gplt = "#{file_base}-gnuplot.gplt"
      file_ct2 = "#{file_base}-ct2.ct2"

      ct2_lines = begin 
                    IO.readlines(file_ct2)
                  rescue
                    nil
                  end

      begin
        db = {}
        if File.exists? 'fight.yaml'
          db = YAML.load(IO.readlines('fight.yaml').join())
        end
        
        # Update the database:
        db_base = File::basename(chain.last.node_info[:src], ".page")
        db[db_base] ||= {}
        local_db = db[db_base]
        if ct2_lines == nil
          local_db[radix] = false
        else
          ms = true
          for l in ct2_lines
            if l =~ /^#\s*missing\s*:\s*(.*)/
              ms = $1
              break
            end
          end
          local_db[radix] = ms
        end

        File.open("fight.yaml", "w") do |f|
          f.write(db.to_yaml)
        end
      end

      if ct2_lines
        register_file(thumb_ct2, "pre-#{radix}-ct2", chain)
      end

      # Gnuplot code first:
      str << "<h4 class='fight'>Gnuplot code <a href='#{file_gplt}'>(download)</a></h4>\n" 
      str << "<pre class='examples-gnuplot'>\n"
      str << begin 
               IO.readlines(file_gplt).join
             rescue
               "<strong>could not read file #{file_gplt}</strong>"
             end
      str <<  "</pre>"
      str << "<h4  class='fight'><code>ctioga2</code> code <a href='#{file_ct2}'>(download)</a></h4>\n" 
      str << begin 
               "<pre class='examples-cmdfile' id='pre-#{radix}-ct2'>\n" + 
                 link_commands(IO.readlines(file_ct2).join, chain) +
                 "</pre>"
             rescue
               "<strong>code missing, probably due to missing features in <code>ctioga2</code></strong>"
             end
      str <<
        "<table class='fight' >"
      str << "<tr><td class='example-image'>Gnuplot</td><td class='example-image'><code>ctioga2</code></td></tr>"
      str << "<tr><td class='example-image'><a href=\"#{image_gplt}\">" +
        "<img src=\"#{thumb_gplt}\" class='thumbnail' alt=\"\"/></a></td>" +
        "<td class='example-image'><a href=\"#{image_ct2}\">" +
        "<img src=\"#{thumb_ct2}\" class='thumbnail' alt=\"\"/></a></td>" +
        "</tr></table>"
      return str
    else
      return "Ourgh"
    end
  end

end

class FightStats < Tags::DefaultTag

  infos( :name => 'Tag/FightStats',
         :summary => 
         "A link to a fight page, with statistics")

  register_tag 'fightstats'

  param 'target', false, "The target page"
  set_mandatory 'target', true


  def process_tag( tag, chain )
    if target = param('target')
      db = {}
      if File.exists? 'fight.yaml'
        db = YAML.load(IO.readlines('fight.yaml').join())
      end

      stats = ""
      if db[target]
        tot = 0
        compl = 0
        partial = 0
        miss = 0
        for k, v in db[target]
          tot += 1
          if v == false
            miss += 1
          elsif String === v
            partial += 1
          else
            compl += 1
          end
        end

        stats = "(#{tot} examples, #{compl} complete, #{partial} partial and #{miss} missing)"
      end

      return stats
    end
    ""
  end

end

class GraphIndex < Tags::DefaultTag

  infos( :name => 'Tag/Index',
         :summary => 
         "Index of all graphs")

  register_tag 'gindex'

  param 'target', false, "The target page"
  set_mandatory 'target', true


  def process_tag( tag, chain )
    db = {}
    if File.exists? 'index.yaml'
      db = YAML.load(IO.readlines('index.yaml').join())
    end
    
    str = ""
    for tmb in db.keys.sort
      tg = db[tmb]
      str << "<a href='#{tg}'><img src=\"#{tmb}\" class='thumbnail' /></a>\n"
    end
    return str
  end
end
