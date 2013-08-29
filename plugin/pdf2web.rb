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

  param 'paths', ['**/*.pdf', '**/*.ct2', '**/*.gplt',
                  '**/*.ct2-sh'], 'The path patterns which match the '
  'PDF files that should get converted by this handler.'
  
  param 'thumbsize', '400x200', "The size of the thumbnail"
  param 'pngsize', '1200x600', "The size of the PNG image produced"
  param 'density', 250, "The -density parameter of convert"
  param 'verbose', true, "Display information about files as they "+
    "are regenerated"
  param 'trim', false, "Whether to remove the borders of the pictures"
  param 'ctstyle', "-r 9cmx6cm", "Additional styling command for ctioga2"
  
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
          "CTIOGA2_PRE='#{param('ctstyle')}' DISPLAY='' ctioga2 -f #{name}.ct2"
        system "touch -r #{source} #{path}"
      end
    elsif path =~ /\.ct2-sh$/   # Shell script
      name = File.basename(path, ".ct2-sh")
      source = path.dup
      path.gsub!(/\.ct2-sh$/, '.pdf')
      if !File.exist?(path) || File.mtime(source) > File.mtime(path)
        puts "Regenerating #{path} from #{source}" if param("verbose")
        system "cd #{File.dirname(source)}; " +
          "CTIOGA2_PRE='#{param('ctstyle')}' CTIOGA2_POST='--name \"#{name}\"' DISPLAY='' sh #{name}.ct2-sh"
        system "touch -r #{source} #{path}"
      end
    elsif path =~ /\.gplt$/   # Gnuplot script
      name = File.basename(path, ".gplt")
      source = path.dup
      path.gsub!(/\.gplt$/, '.pdf')
      
      if !File.exist?(path) || File.mtime(source) > File.mtime(path)
        puts "Regenerating #{path} from #{source}" if param("verbose")

        file = File::basename(source)
        Dir::chdir(File::dirname(source)) do
          gnuplot = IO.popen("gnuplot", 
                             "w")
          gnuplot.puts "set term pdf size 9cm,6cm"
          gnuplot.puts "set output '#{path}'"
          gnuplot.puts IO.readlines(file).join('')
        end
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
        " -resize #{n[:size]} #{node.full_path}"
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
