class ExampleLinkTag < Tags::DefaultTag

  infos( :name => 'Tag/ExampleLink',
         :summary => 
         "Prints out the date of last modification of the current file")

  register_tag 'example'

  param 'dir', 'plots', 'The subdirectory of the images'
  param 'location', nil, 'The link to the example'
  
  set_mandatory 'location', true


  def process_tag( tag, chain )
    link = param('location')
    url, example = link.split(/#(pre-)?/)
    url = resolve_path(url, chain)
    plot = File::dirname(url) + "/" + param('dir') + "/#{example}.thumb.png"
    return "<a href='#{url}#pre-#{example}'><img src='#{plot}' alt=''></a>"
  end

  private

  def resolve_path(uri, chain )
    dest_node = chain.first.resolve_node( uri )
    chain.last.route_to(dest_node)
  end


end

class DOILinkTag < Tags::DefaultTag

  infos( :name => 'Tag/DOILink',
         :summary => 
         "Prints out the date of last modification of the current file")

  register_tag 'doilink'

  param 'image', nil, 'Image'
  param 'doi', nil, "Linked DOI"
  
  set_mandatory 'location', true


  def process_tag( tag, chain )
    img = param('image')
    doi = param('doi') 
    url = resolve_path(img, chain)
    img = "<img src='#{url}' alt='#{doi}' title='#{doi}' />"
    if doi
      return "<a href='http://dx.doi.org/#{doi}'>#{img}</a>"
    else
      return img
    end
  end

  private

  def resolve_path(uri, chain )
    dest_node = chain.first.resolve_node( uri )
    chain.last.route_to(dest_node)
  end


end
