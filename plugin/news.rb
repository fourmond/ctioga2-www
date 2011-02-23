# news.rb: a webgen 0.4 plugin to display news items
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

class NewsTag < Tags::DefaultTag

  infos( :name => 'Tag/News',
         :summary => "Display Rubyforge news from a YAML file")

  register_tag 'news'

  param 'file', nil, "The news file"
  param 'number', nil, "The maximum number of elements to display"

  def process_tag( tag, chain )
    begin
      posts = YAML.load(File::open(param('file')))
    rescue Exception => e
      return "Error opening news file #{param('file')}: #{e}"
    end
    # Now, build the news... 
    nb = 1
    result = ""
    number = param('number')
    for post in posts
      break if (number && nb > number)
      result << "\n<h3 class=\"news\">#{post[:title]}</h3>\n"
      date = if post[:date].respond_to? :strftime
               post[:date].strftime("%Y/%m/%d %H:%M")
             else
               post[:date]
             end
      converter = RedCloth.new(post[:contents])
      converter.hard_breaks = false 
      result << converter.to_html.gsub(' target="_new"','')
      result << "\n<p class=\"news-footer\">"
      result << "Posted on <span class=\"news-date\">#{date}</span>"
      result << " by <span class=\"news-author\">#{post[:author]}</span> "
      result << "<a href=\"http://rubyforge.org/forum/forum.php?forum_id=#{post[:id]}\">Comments</a></p>"
      nb += 1
    end
    return result
  end

end

class NewsFeed < FileHandlers::DefaultHandler
  
  infos( :name => 'File/NewsFeed',
         :author => 'Vincent Fourmond <vincent.fourmond@9online.fr>',
         :summary => "Transform news into a real XML feed"
         )

  param 'paths', ['**/news.yaml'], 
  'The path of the news files (in YAML format).'
  param 'title', 'News about ctioga2', "The title of the feed"
  param 'link', "http://ctioga2.rubyforge.org", "The link from the description"
  param 'description', "All news about ctioga2", "Description"
  param 'verbose', false, "Whether to be verbose or quiet"

  def initialize( plugin_manager )
    super
    param( 'paths' ).each {|path| register_path_pattern( path ) }
  end
  
  def create_node( path, parent, meta_info )
    name = File.basename(path, ".yaml")

    # Thumbnail
    n = Node.new( parent, "#{name}.xml" )
    n['title'] = "#{name}.xml"
    n.node_info[:src] = path
    n.node_info[:processor] = self
    return n
  end
  
  def write_node(node)
    if @plugin_manager['Core/FileHandler'].file_modified?( node.node_info[:src], node.full_path )
      n = node.node_info
      begin
        posts = YAML.load(File::open(n[:src]))
      rescue Exception => e
        return
      end
      date_string = 
      out = File::open(node.full_path, "w")
      out.puts "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<rss version=\"2.0\">"
      out.puts "<channel><title>#{param('title')}</title>"
      out.puts "<link>#{param('link')}</link>"
      out.puts "<description>#{param('description')}</description>"
      out.puts "<lastBuildDate>#{Time.now.rfc2822}</lastBuildDate>"
      out.puts "<pubDate>#{Time.now.rfc2822}</pubDate>"

      # Now the posts
      for post in posts
        out.puts "<item>"
        out.puts "<title>#{CGI::escapeHTML(post[:title])}</title>"
        converter = RedCloth.new(post[:contents])
        converter.hard_breaks = false 
        out.puts "<description>#{CGI::escapeHTML(converter.to_html)}</description>"
        out.puts "<link>http://rubyforge.org/forum/forum.php?forum_id=#{post[:id]}</link>"
        out.puts "<guid isPermaLink=\"true\">http://rubyforge.org/forum/forum.php?forum_id=#{post[:id]}</guid>"

        out.puts "<pubDate>#{post[:date].rfc2822}</pubDate>"
        out.puts "<author>#{CGI::escapeHTML(post[:author])}</author>"
        out.puts "</item>"
      end


      
      
      out.puts "</channel>\n</rss>"
      out.close
    else
      if param('verbose') 
        puts "Skipping regeneration of #{node.path}"
      end
    end
  end

end  
