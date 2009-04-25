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

# TODO
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
      result << converter.to_html
      result << "\n<p class=\"news-footer\">"
      result << "Posted on <span class=\"news-date\">#{date}</span>"
      result << " by <span class=\"news-author\">#{post[:author]}</span> "
      result << "<a href=\"http://rubyforge.org/forum/forum.php?forum_id=#{post[:id]}\">Comments</a></p>"
      nb += 1
    end
    return result
  end

end
