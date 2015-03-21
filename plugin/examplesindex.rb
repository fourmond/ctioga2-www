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

# For the CGI::escape
require 'cgi'

class ImageIndex < FileHandlers::DefaultHandler
  
  infos( :name => 'File/ImageIndex',
         :author => 'Vincent Fourmond <vincent.fourmond@9online.fr>',
         :summary => "Index of the code corresponding to images"
         )

  param 'paths', ['**/index.yaml'], 
  'The path of the index (in YAML format).'

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

  def quote(str)
    return str.gsub(/\\/, '\\\\').gsub(/"/, '\"').gsub("\n", '\n')
  end
  
  def write_node(node)
    n = node.node_info
    begin
      items = YAML.load(File::open(n[:src]))
    rescue Exception => e
      return
    end
    
    # p items
    it = items['text']
    
    out = File::open(node.full_path, "w")
    
    out.puts "var idx = {};"
    
    for k, v in it
      idx = GraphIndex.sanitize_id(k)
      out.puts "idx[\"#{idx}\"] = \"#{quote(v)}\";"
    end
    out.close
  end

end  
