class ReleasesController < ApplicationController

  def new
    tool = Tool.find params[:tool_id]
    not_found unless tool
    @release = Release.new tool: tool
    render template: 'releases/edit'
  end

  def create
    unauthorized if current_user.has_role? :guest
    tool = Tool.find params[:tool_id]
    not_found unless tool

    release = Release.new params.require(:release).permit!
    release.tool = tool
    release.save

    release.copy_download_files!

    redirect_to user_tool_path(release.tool.owner.username, release.tool.slug)
  end


  def edit
    @release = Release.find params[:id]
    unauthorized if current_user != @release.tool.owner
  end


  def update
    unauthorized if current_user.has_role? :guest
    tool = Tool.find params[:tool_id]
    not_found unless tool

    release = Release.find params[:id]
    release.update params.require(:release).permit!

    release.copy_download_files!

    redirect_to user_tool_path(release.tool.owner.username, release.tool.slug)
  end


  def destroy
    release = Release.find params[:id]
    unauthorized if current_user != release.tool.owner

    release.destroy!
    redirect_back fallback_location: user_tool_path(release.tool.owner.username, release.tool.slug)
  end


  def download
    release = Release.find params[:id]
    not_found unless release
    unauthorized if current_user != release.tool.owner

    release.download_count += 1
    release.update_record_without_timestamping

    send_file File.join(release.download_path, params[:filename])
  end

end
