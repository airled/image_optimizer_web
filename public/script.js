window.onload = function() {
  document.getElementById('file_upload_form').addEventListener('submit', function(e) {
    event.preventDefault();
    var formData = new FormData(document.getElementById('file_upload_form'));
    var progress = document.getElementById('progress');
    var progressbar = document.getElementById('progressbar');
    var statusbar = document.getElementById('status');
    var xhr = new XMLHttpRequest();
    xhr.open('POST', '/upload', true);
    xhr.onload = function() {
      if (xhr.status === 200) {
        statusbar.innerHTML = '<a class="btn btn-danger" href= ' + xhr.responseText + ' style="width: 100%;">Скачать архив</a>';
      } else {
        statusbar.innerHTML = 'Ошибка';
      }
    };

    xhr.upload.onprogress = function(event) {
      var percentage = Math.floor((event.loaded / event.total) * 100);
      progressbar.style.width = percentage + '%';
      progressbar.innerText = percentage + '%';
    }
    xhr.upload.onload = function() {
      statusbar.innerHTML = 'Обработка...';
    }
    xhr.upload.onerror = function() {
      statusbar.innerHTML = 'Ошибка';
    }
    xhr.send(formData);
  }, false);
}
