//= require redactor/redactor.min
//= require redactor/_plugins/alignment/alignment.min
//= require redactor/_plugins/imagemanager/imagemanager.min
//= require redactor/_plugins/table/table.min
//= require redactor/_plugins/video/video.min

  document.addEventListener("turbolinks:load", function() {
    var csrf_token = $('meta[name=csrf-token]').attr('content');
    var csrf_param = $('meta[name=csrf-param]').attr('content');
    var params = {};
    if (csrf_param !== undefined && csrf_token !== undefined) {
        params[csrf_param] = csrf_token;
    }
    $R('.redactor', {
      styles: false,
      plugins: ['alignment', 'video', 'imagemanager', 'table'],
      imageResizable: true,
      imagePosition: true,
      imageManagerJson: '/pictures',
      imageUpload: '/pictures',
      imageData: params,
      clipboardUploadUrl: '/pictures',
      clipboardData: params
    })
  })
