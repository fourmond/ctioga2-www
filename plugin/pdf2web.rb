# pdf2web.rb: a Webgen File Handler plugin to create
# thumbnails of PDF files.
# 
# This file is copyright 2007 by Vincent Fourmond, and can be used and
# redistributed under the same terms as webgen itself.


class PDF2WebHandler < FileHandlers::DefaultHandler
  
  infos( :name => 'File/PDF2Web',
         :author => 'Vincent Fourmond <vincent.fourmond@9online.fr>',
         :summary => "Makes PNG and thumbnails from PDF files"
         )

  param 'paths', ['**/*.pdf', '**/*.ct2', 
                  '**/*.ct2-sh'], 'The path patterns which match the '
  'PDF files that should get converted by this handler.'
  
  param 'thumbsize', 200, "The size of the thumbnail"
  param 'pngsize', 900, "The size of the PNG image produced"
  param 'density', 250, "The -density parameter of convert"
  param 'verbose', true, "Display information about files as they "+
    "are regenerated"
  param 'trim', false, "Whether to remove the borders of the pictures"
  
  def initialize( plugin_manager )
    super
    param( 'paths' ).each {|path| register_path_pattern( path ) }
  end
  
  def create_node( path, parent, meta_info )
    if path =~ /\.ct2$/
      name = File.basename(path, ".ct2")
      source = path.dup
      path.gsub!(/\.ct2$/, '.pdf')
      if !File.exist?(path) || File.mtime(source) > File.mtime(path)
        puts "Regenerating #{path} from #{source}" if param("verbose")
        system "cd #{File.dirname(source)}; " +
          "DISPLAY='' ctioga2 -f #{name}.ct2"
        system "touch -r #{source} #{path}"
      end
    elsif path =~ /\.ct2-sh$/   # Shell script
      name = File.basename(path, ".ct2-sh")
      source = path.dup
      path.gsub!(/\.ct2-sh$/, '.pdf')
      if !File.exist?(path) || File.mtime(source) > File.mtime(path)
        puts "Regenerating #{path} from #{source}" if param("verbose")
        system "cd #{File.dirname(source)}; " +
          "CTIOGA2_POST='--name \"#{name}\"' DISPLAY='' sh #{name}.ct2-sh"
        system "touch -r #{source} #{path}"
      end
    else

      name = File.basename(path, ".pdf") # Remove a .pdf if it is present.
    end

    # Thumbnail
    t = Node.new( parent, "#{name}.thumb.png" )
    t['title'] = "#{name}.thumb.png"
    t.node_info[:src] = path
    t.node_info[:processor] = self
    t.node_info[:size] = param('thumbsize')
    t.node_info[:density] = param('density')
    t.node_info[:trim] = param('trim')

    p = Node.new( parent, "#{name}.png" )
    p['title'] = "#{name}.png"
    p.node_info[:src] = path
    p.node_info[:processor] = self
    p.node_info[:size] = param('pngsize')
    p.node_info[:density] = param('density')
    p.node_info[:trim] = param('trim')

    # I return only the last node created, but it looks like both nodes are
    # copied.
    return p
  end
  
  def write_node(node)
    if @plugin_manager['Core/FileHandler'].file_modified?( node.node_info[:src], node.full_path )
      n = node.node_info
      cmdline = "pdftoppm -r #{n[:density]} #{n[:src]} | convert ppm:- " +
        if n[:trim]; " -trim"; else ""; end +
        " -resize #{n[:size]}x#{n[:size]} #{node.full_path}"
      if param('verbose') 
        puts "Running convert to get #{node.path}"
      end
      log(:debug) {"cmdline: #{cmdline}"}
      system cmdline
    else
      if param('verbose') 
        puts "Skipping regeneration of #{node.path}"
      end
    end
  end

end  

# class GnuplotHandler < FileHandlers::DefaultHandler
  
#   infos( :name => 'File/Gnuplot',
#          :author => 'Vincent Fourmond <vincent.fourmond@9online.fr>',
#          :summary => "Makes PNG and thumbnails from gnuplot source"
#          )

#   param 'paths', ['**/*.gnuplot'], 'The path patterns that match the '
#   'gnuplot files that should get converted by this handler.'
  
#   param 'thumbsize', 200, "The size of the thumbnail"
#   param 'pngsize', 700, "The size of the PNG image produced"
#   param 'fullsize', 800, "The full size to which the image is rendered " +
#     "before resizing (for antialias)"
#   param 'verbose', true, "Display information about files as they "+
#     "are regenerated"
#   param 'trim', false, "Whether to remove the borders of the pictures"
#   param 'fontpath', "/var/lib/defoma/fontconfig.d/B/", 
#   "The font path"
#   param 'font', "Bitstream-Vera-Sans", "The font used. Make sure that it "+
#     "is reachable in the font path"
#   param 'fontsize', 14, "The font size"
  
#   def initialize( plugin_manager )
#     super
#     param( 'paths' ).each {|path| register_path_pattern( path ) }
#   end
  
#   def create_node( path, parent, meta_info )
#     name = File.basename(path, ".gnuplot") # Remove a .pdf if it is present.

#     # Thumbnail
#     t = Node.new( parent, "#{name}.thumb.png" )
#     t['title'] = "#{name}.thumb.png"
#     t.node_info[:src] = path
#     t.node_info[:processor] = self
#     t.node_info[:size] = param('thumbsize')

#     p = Node.new( parent, "#{name}.png" )
#     p['title'] = "#{name}.png"
#     p.node_info[:src] = path
#     p.node_info[:processor] = self
#     p.node_info[:size] = param('pngsize')


#     # I return only the last node created, but it looks like both nodes are
#     # copied.
#     return p
#   end
  
#   def write_node(node)
#     if @plugin_manager['Core/FileHandler'].file_modified?(node.node_info[:src], 
#                                                           node.full_path )
#       n = node.node_info
#       # First, we create the .png file
#       gnuplot = IO.popen("sh -c 'GDFONTPATH=#{param 'fontpath'} gnuplot'", 
#                          "w")
#       gnuplot.puts "set term png size #{param('fullsize')}," +
#         "#{param('fullsize')} font '#{param('font')}' #{param('fontsize')}"
#       gnuplot.puts "set output '| convert png:- -resize " +
#         "#{n[:size]}x#{n[:size]} #{node.full_path}'"
#       gnuplot.puts IO.readlines(n[:src]).join('')
#       if param('verbose') 
#         puts "Running gnuplot to get #{node.path}"
#       end
#       gnuplot.close

#     else
#       if param('verbose') 
#         puts "Skipping regeneration of #{node.path}"
#       end
#     end
#   end

# end  
