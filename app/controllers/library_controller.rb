class LibraryController < ApplicationController

  def index
    @records = Filerecord.library
  end


  def filetree
    dir = params[:dir]
    if !dir.blank?
      username = dir.split(':')[0][1..-1]
      path = dir.split(':')[1..-1].join('/')
      owner = User.find_by_username username
      tree = Datastore.new(owner.id, Config.dir_users).list(path).collect do |e|
        {
            text: e.name,
            id: "@#{owner.username}:#{e.path}",
            children: e.directory?,
            #TODO remove frontend html class
            icon: e.directory? ? 'fa fa-folder' : 'fa fa-file-o',
            type: e.directory? ? 'dir' : 'file'
        }
      end
    else
      tree = Filerecord.library.collect do |record|
        {
            text: record.name,
            rid: record.id,
            id: "@#{record.owner.username}:#{record.path}",
            children: record.meta.directory?,
            #TODO remove frontend html class
            icon: record.meta.directory? ? 'fa fa-folder' : 'fa fa-file-o',
            type: record.meta.directory? ? 'dir' : 'file'
        }
      end
    end


    render json: tree.sort_by { |e| [e[:type], e[:text].downcase]}
  end

end
