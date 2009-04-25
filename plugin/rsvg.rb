# rsvg.rb: a Webgen File Handler to convert rsvg into PNG
# thumbnails of PDF files.
# 
# This file is copyright 2009 by Vincent Fourmond, and can be used and
# redistributed under the same terms as webgen itself.


class RSvgFileHandler < FileHandlers::DefaultHandler
  
  infos( :name => 'File/RSVG',
         :author => 'Vincent Fourmond <vincent.fourmond@9online.fr>',
         :summary => "Converts .rsvg files to PNG images"
         )

  param 'paths', ['**/*.rsvg'], 'The path patterns which match the '
  'RSVG files that should get converted by this handler.'
  
  param 'verbose', true, "Display information about files as they "+
    "are regenerated"
  
  def initialize( plugin_manager )
    super
    param( 'paths' ).each {|path| register_path_pattern( path ) }
  end
  
  def create_node( path, parent, meta_info )
    name = File.basename(path, ".rsvg") 

    p = Node.new( parent, "#{name}.png" )
    p['title'] = "#{name}.png"
    p.node_info[:src] = path
    p.node_info[:processor] = self

    # I return only the last node created, but it looks like both nodes are
    # copied.
    return p
  end
  
  def write_node(node)
    n = node.node_info
    cmdline = "erb #{n[:src]} | convert - #{node.full_path}"
    log(:debug) {"cmdline: #{cmdline}"}
    system cmdline
  end

end  
