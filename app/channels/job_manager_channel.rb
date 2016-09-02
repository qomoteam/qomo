# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class JobManagerChannel < ApplicationCable::Channel

  def subscribed
    stream_from "job_manager_#{params[:uid]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
