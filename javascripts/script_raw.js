var activeAjaxes = 0;
var imageLinks = [];
var ajaxQueue = [];
var ajaxQueueStep = 1;

function disableAllInputs() {
  document.querySelectorAll('input').forEach(function(elem) {
    elem.setAttribute('disabled', 'disabled');
  });
}

function enableAllInputs() {
  document.querySelectorAll('input').forEach(function(elem) {
    elem.removeAttribute('disabled', 'disabled');
  });
}

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

function sendFile(file, number, imageParams) {
  var formData = new FormData();
  formData.append('file', file, file.name);
  Object.keys(imageParams).forEach(function(key) {
    formData.append(key, imageParams[key]);
  });
  var xhr = new XMLHttpRequest();
  xhr.open('POST', '/upload', true);
  var progressbar = document.getElementById('progress-bar-' + number);
  var statusbar = document.getElementById('status-bar-' + number);
  xhr.upload.onprogress = function(event) {
    var loadedKb = Math.floor(event.loaded / 1000);
    var totalKb = Math.floor(event.total / 1000);
    var percentage = Math.floor((loadedKb / totalKb) * 100);
    progressbar.style.width = percentage + '%';
    progressbar.innerText = percentage + '%';
    statusbar.innerHTML = file.name + ' | ' + loadedKb + '/' + totalKb;
  }
  xhr.upload.onerror = function() {
    progressbar.innerHTML = 'Ошибка';
  }
  xhr.upload.onload = function() {
    progressbar.classList.remove('progress-bar-warning');
    progressbar.classList.add('progress-bar-primary', 'progress-bar-striped', 'active');
    progressbar.innerHTML = 'Загружено. Обработка...';
  }
  xhr.onload = function() {
    if (xhr.status === 200) {
      response = JSON.parse(xhr.responseText);
      progressbar.classList.remove('progress-bar-primary', 'progress-bar-striped', 'active');
      progressbar.classList.add('progress-bar-success');
      progressbar.innerHTML = '<a target="_blank" href= ' + response.link + ' style="width: 100%; color: white;">Скачать (' + response.diff + '%)' + '</a>';
      activeAjaxes--;
      imageLinks.push(response.link);
      if (activeAjaxes == 0) {
        document.getElementById('imageLinksInput').value = JSON.stringify(imageLinks);
        document.getElementById('download-zip').classList.remove('hidden');
        enableAllInputs();
      }
    } else {
      progressbar.classList.remove('progress-bar-primary', 'progress-bar-striped', 'active');
      progressbar.classList.add('progress-bar-danger');
      progressbar.innerHTML = 'Ошибка';
    }
    runNextFromAjaxQueue();
  }
  xhr.send(formData);
}

function determineResizeType() {
  var resize = '';
  var inputs = document.getElementsByTagName('input');
  var inputCounter = 0;
  while (resize === '' && inputCounter < inputs.length) {
    if (inputs[inputCounter].type === 'radio' && inputs[inputCounter].checked) {
      resize = inputs[inputCounter].value;
    }
    inputCounter++;
  }
  return resize;
}

function runNextFromAjaxQueue() {
  for (var i = 0; i < ajaxQueueStep; ++i) {
    if (ajaxQueue.length !== 0) {
      nextFile = ajaxQueue.shift();
      sendFile(nextFile.file, nextFile.position, nextFile.params);    
    }
  }
}

function startUpload() {
  var files = document.getElementById('file_select').files;
  var imageHandleParams = {
    quality: document.getElementById('quality').value,
    resize:  determineResizeType(),
    width:   document.getElementById('resize-width').value,
    height:  document.getElementById('resize-height').value
  }
  for (var i = 0; i < files.length; ++i) {
    activeAjaxes++;
    var progressBarCode = '<div class="row progress-wrapper"><div class="col-md-6"><div class="progress"><div id="progress-bar-' + i + '" class="progress-bar progress-bar-warning" role="progressbar" aria-valuemin="0" aria-valuemax="100"></div></div></div><div id="status-bar-' + i + '" class="col-md-6">Ожидание очереди...</div></div>'
    document.getElementById('file_upload_form').insertAdjacentHTML('beforeend', progressBarCode);
    ajaxQueue.push({file: files[i], position: i, params: imageHandleParams});
  }
  runNextFromAjaxQueue();
}

function clearWidthAndHeight() {
  document.getElementById('resize-width').value = '';
  document.getElementById('resize-height').value = '';
}

function clearCurrentResults() {
  imageLinks = [];
  ajaxQueue = [];
  activeAjaxes = 0;
  document.getElementById('download-zip').classList.add('hidden');
  document.querySelectorAll('.progress-wrapper').forEach(function(elem) {
    elem.remove();
  });
}

window.onload = function() {
  document.getElementById('file_select').addEventListener('change', function(event) {
    clearCurrentResults();
    var totalSize = calculateTotalFileSize();
    checkUploadAbility(totalSize);
  }, false);

  document.getElementById('upload-button').addEventListener('click', function(event) {
    event.preventDefault();
    document.getElementById('upload-button').classList.add('hidden');
    disableAllInputs();
    startUpload();
  }, false);

  document.getElementById('change-size-no').addEventListener('click', function() {
    clearWidthAndHeight();
  }, false);
}
