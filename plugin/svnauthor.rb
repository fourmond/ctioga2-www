require 'time'

class SVNAuthor < Tags::DefaultTag

  infos( :name => 'Tag/SVNAuthor',
         :summary => 
         "Queries Subversion to know who last modified the file")

  register_tag 'svnAuthor'

  param 'authorNames', {}, "A hash specifying the correspondance" +
    "svn login -> Real name. "
  param 'defaultName', "??", "What to display if no one was found"

  def process_tag( tag, chain )
    if File.exists? '.svn'
      svn = "svn"
    else
      svn = "git svn"
    end

    info = `#{svn} info #{chain.last.node_info[:src]} 2>/dev/null`
    if info =~/Last Changed Author:\s*(\w*)/
      name = $1
    else
      name = param('defaultName')
    end
    if param('authorNames').key? name
      name = param('authorNames')[name]
    end
    return name
  end

end

class SVNDateTag < Tags::DefaultTag

  infos( :name => 'Tag/SVNDate',
         :summary => 
         "Prints out the date of last modification of the current file")

  register_tag 'mDate'

  param 'format', '%d/%m/%Y %H:%M', 'The format of the date (same options as Time#strftime).'

  def process_tag( tag, chain )

    file = chain.last.node_info[:src]
    info = `git log -n 1 #{file} 2>/dev/null`
    time = if info =~/Date:\s*(.*)/
             Time.parse($1)
           else
             File.mtime(file)
           end

    return time.strftime(param('format'))
  end

end
