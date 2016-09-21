$ ->
  if gon.user_signed_in
    App.job_manager = App.cable.subscriptions.create {channel: 'JobManagerChannel', uid: gon.uid},
      connected: ->
      disconnected: ->

      received: (data) ->
        if app.controller == 'workspaces' and app.action == 'show'
          updateJobStatus()

        if app.controller == 'jobs' and app.action == 'show'
          if gon.job_id == data.job_id
            window.location.reload()

