function calculateTotalFileSize() {
  var files = document.getElementById('file_select').files;
  var totalSize = 0;
  var length = files.length;
  for(var i = 0; i < files.length; i++) {
    totalSize += files[i].size;
  }
  document.getElementById('sum-file-size').innerText = normalizeSize(totalSize);
  return totalSize / 1000;
}

function checkUploadAbility(totalSize) {
  var button = document.getElementById('upload-button');
  var sizeLabel = document.getElementById('sum-file-size');
  if (totalSize > 25000) {
    button.classList.add('hidden');
    sizeLabel.classList.add('alerted');
  } else {
    button.classList.remove('hidden');
    sizeLabel.classList.remove('alerted');
  }
}

function normalizeSize(byteSize) {
  var size = Math.floor(byteSize / 1000);
  if (size > 1000) {
    return Math.floor(size / 1000) + ' MB';
  }
  return size + ' kB';
}

function upload() {
  var progressbar = document.getElementById('progressbar');
  var statusbar = document.getElementById('status');
  var uploadButton = document.getElementById('upload-button');
  var cancelButton = document.getElementById('cancel-button');
  var formData = new FormData(document.getElementById('file_upload_form'));
  progressbar.classList.add('progress-bar-warning');
  var xhr = new XMLHttpRequest();
  xhr.open('POST', '/upload', true);
  xhr.onload = function() {
    if (xhr.status === 200) {
      uploadButton.classList.remove('hidden');
      cancelButton.classList.add('hidden');
      statusbar.innerHTML = '<a class="btn btn-success" href= ' + xhr.responseText + ' style="width: 100%;">Скачать архив</a>';
    } else {
      statusbar.innerHTML = 'Ошибка';
    }
  }
  xhr.upload.onprogress = function(event) {
    var loadedKb = Math.floor(event.loaded / 1000);
    var totalKb = Math.floor(event.total / 1000);
    var percentage = Math.floor((loadedKb / totalKb) * 100);
    progressbar.style.width = percentage + '%';
    progressbar.innerText = percentage + '%';
    statusbar.innerText = loadedKb + '/' + totalKb;
  }
  xhr.upload.onload = function() {
    progressbar.classList.remove('progress-bar-warning');
    progressbar.classList.add('progress-bar-success');
    statusbar.innerHTML = 'Загружено. Обработка...';
  }
  xhr.upload.onerror = function() {
    statusbar.innerHTML = 'Ошибка';
  }
  xhr.send(formData);

  function cancel(e) {
    xhr.abort();
    cancelButton.classList.add('hidden');
    uploadButton.classList.remove('hidden');
    e.target.removeEventListener(e.type, arguments.callee);
    statusbar.innerHTML = 'Остановлено';
  }
  cancelButton.addEventListener('click', cancel);
  uploadButton.classList.add('hidden');
  cancelButton.classList.remove('hidden');
}

window.onload = function() {
  document.getElementById('file_select').addEventListener('change', function(event) {
    var totalSize = calculateTotalFileSize();
    checkUploadAbility(totalSize);
  }, false);

  document.getElementById('upload-button').addEventListener('click', function(event) {
    event.preventDefault();
    upload();
  }, false);
}
