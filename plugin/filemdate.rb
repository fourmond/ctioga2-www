class FileMDateTag < Tags::DefaultTag

  infos( :name => 'Tag/FileMDate',
         :summary => 
         "Prints out the date of last modification of the current file")

  register_tag 'mDate'

  param 'format', '%d/%m/%Y %H:%M', 'The format of the date (same options as Time#strftime).'

  def process_tag( tag, chain )
    return File.mtime( chain.last.node_info[:src] ).strftime(param('format'))
  end

end
