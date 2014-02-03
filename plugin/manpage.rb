# Tag/Manpage, a plugin for webgen to include a
# manual page inside a webgen page
# Copyright 2007 by Vincent Fourmond

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA



class ManPageTag < Tags::DefaultTag

  infos( :name => 'Tag/Manpage',
         :summary => 
         "Include a Unix manual page",
         :author => "Vincent Fourmond <vincent.fourmond@9online.fr>")

  register_tag 'manpage'

  param 'manpage', false, "The manual page"
  param 'downgrade', 1 , "Takes headers (h1, h2...) down the hierarchy"
  param 'stripRules', true , "Whether to remove hr tags"

  set_mandatory 'manpage', true

  def process_tag( tag, chain )

    if manpage = param('manpage')
      dg = param('downgrade')
      if param('stripRules') 
        stripRE = /<\/?(html|body|hr)>/
      else
        stripRE = /<\/?(html|body)>/
      end
      begin
        f = IO.popen("man -Thtml #{manpage}", "r")
        output = "<div class='manpage'>\n"
        header = false
        for l in f
          if l =~ /<head>/i
            header = true
          elsif l =~ /<\/head>/i
            header = false
          end
          if not header
            l.gsub!(stripRE,'')
            if dg && dg > 0
              l.gsub!(/<(\/?)h(\d+)(.*?)>/) do 
                "<#{$1}h#{$2.to_i + dg}#{$3}>"
              end
            end
            output += l
          end
        end
        output += "</div>\n"
        return output
      rescue Exception => e
        return "Problem reading #{manpage}: #{e.to_s}"
      end
    end
    
    "Invalid manual page"
  end

end

