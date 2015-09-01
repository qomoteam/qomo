#= require jquery-fine-uploader

within 'datastore', 'upload', ->
  endpoint = $('#uploader').data 'endpoint'
  uploader = $('#uploader').fineUploader
    request:
      inputName: 'file'
      filenameParam: 'filename'
      endpoint: endpoint
      params:
        dir: gon.dir
        authenticity_token: gon.token
    autoUpload: false
    editFilename:
      enabled: true

  $('#trigger-upload').click ->
    uploader.fineUploader 'uploadStoredFiles'
