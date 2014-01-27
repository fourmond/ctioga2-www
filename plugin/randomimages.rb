# randomimages.rb: a webgen 0.4 plugin for random images
# This program is copyright 2009 by Vincent Fourmond.

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301
# USA

# For the RFC spec.
require 'time'

# For the CGI::escape
require 'cgi'

class RandomImages < FileHandlers::DefaultHandler
  
  infos( :name => 'File/RandomImages',
         :author => 'Vincent Fourmond <vincent.fourmond@9online.fr>',
         :summary => "An array of random contents (images)"
         )

  param 'paths', ['**/random.yaml'], 
  'The path of the random images files (in YAML format).'

  def initialize( plugin_manager )
    super
    param( 'paths' ).each {|path| register_path_pattern( path ) }
  end
  
  def create_node( path, parent, meta_info )
    name = File.basename(path, ".yaml")

    n = Node.new( parent, "#{name}.js" )
    n['title'] = "#{name}.js"
    n.node_info[:src] = path
    n.node_info[:processor] = self
    return n
  end

  def html_of(item)
    if item.key? :html
      return item[:html]
    else
      url, example = item[:link].split(/#(pre-)?/)
      url.gsub!(/^\//,"")
      p [item[:link], url, example]
      plot = File::dirname(url) + "/plots/#{example}.thumb.png"
      return <<"EOD"
<h3>#{CGI::escapeHTML(item[:title])}</h3><p class="center">
<a href='$$#{url}#pre-#{example}'><img class='thumbnail' width='210' src='$$#{plot}' alt='' /></a></p>
<p>#{item[:description]}
<a href='$$#{url}#pre-#{example}'>(see code)</a></p>
EOD
    end
  end

  def quote(str)
    return str.gsub(/"/, '\"').gsub("\n", '\n')
  end
  
  def write_node(node)
    n = node.node_info
    begin
      items = YAML.load(File::open(n[:src]))
    rescue Exception => e
      p e
      return
    end
    
    # p items
    
    out = File::open(node.full_path, "w")
    
    out.puts "var random_items = new Array();"
    
    i = 0
    for it in items
      out.puts "random_items[#{i}] = \"#{quote(html_of(it))}\""
      i += 1
    end
    out.close
  end

end  
