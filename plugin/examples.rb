class CTiogaCmdlineTag < Tags::DefaultTag

  infos( :name => 'Tag/CTiogaCmdline',
         :summary => 
         "A ctioga command line and the corresponding image.")

  register_tag 'ctCmdline'

  param 'file', false, "The file containing the command-line"
  param 'alt', false, 'The alternative text'
  param 'cls', 'examples-cmdline', "The class used for the <pre> elements"
  # Todo: make that relocatable ?
  param 'cmdbase', "/doc/commands.html", 'The base URL for commands links. False to deactivate'
  
  set_mandatory 'file', true

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
          link_commands(IO.readlines(filename).join)
        rescue
          "<b>IO problem reading file #{cmdline}</b>"
        end  + "</pre>" +
        "<p class='example-image'>\n" +
        "<a href=\"#{image}\" id=\"img-#{id_base}\">" +
        "<img src=\"#{thumb}\" alt=\"#{alt}\"/></a>"
    else
      return "Ourgh"
    end
  end

  # Transforms commands into links to the appropriate point in the
  # documentation.
  def link_commands(string)
    base = param('cmdbase')
    if base
      # TODO: also process single letter options, though it is
      # significantly more difficult.
      return string.gsub(/--(\S+)/) do 
        a = "<a href=\"#{base}#command-#{$1}\">--#{$1}</a>"
      end
    else
      return string
    end
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

  # Transforms commands into links to the appropriate point in the
  # documentation.
  def link_commands(string)
    base = param('cmdbase')
    if base
      return string.gsub(/([^ ()\n\t]+)\(/) do 
        a = "<a href=\"#{base}#command-#{$1}\">#{$1}</a>("
      end
    else
      return string
    end
  end


end
