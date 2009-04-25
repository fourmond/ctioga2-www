class SVNAuthor < Tags::DefaultTag

  infos( :name => 'Tag/SVNAuthor',
         :summary => 
         "Queries Subversion to know who last modified the file")

  register_tag 'svnAuthor'

  param 'authorNames', {}, "A hash specifying the correspondance" +
    "svn login -> Real name. "
  param 'defaultName', "??", "What to display if no one was found"

  def process_tag( tag, chain )
    info = `svn info #{chain.last.node_info[:src]} 2>/dev/null`
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
