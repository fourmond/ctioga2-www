# examples.rb: a Webgen plugin to display examples
# 
# This file is copyright 2011 by Vincent Fourmond, and can be used and
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

  def process_tag( tag, chain )
    if cmdline = param('file')
      base = cmdline.gsub(/\.ct2(-sh)?$/, '')
      image = base + ".png"
      alt = param('alt') || ""
      thumb = base + '.thumb.png'
      id_base = "#{File::basename(image,'.png')}"
      filename = File.join( chain.first.parent.node_info[:src], cmdline ) 
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
      return string.gsub(/([^ ()\n\t]+)(\(|\s+)/) do 
        command = $1
        sep = $2
        cmd = CTiogaCommands[command]
        if cmd
          desc = purify_description(cmd['short_description'])
          a = "<a href=\"#{cmdlocation}#command-#{command}\" title=\"#{desc}\">#{command}</a>#{sep}"
        else
          "#{command}#{sep}"
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
