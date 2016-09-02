$ ->
  if (gon.user_signed_in)
    App.job_manager = App.cable.subscriptions.create {channel: 'JobManagerChannel', uid: gon.uid},
      connected: ->

      disconnected: ->

      received: (data) ->
        updateJobStatus()

