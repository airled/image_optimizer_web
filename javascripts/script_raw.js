var imageLinks = [];
var ajaxQueue = [];
var ajaxQueueStep = 1;

var fileSelectLabel = document.getElementById('file-select-label');
var uploadButton = document.getElementById('upload-button');

function calculateTotalFileSize() {
  var files = document.getElementById('file_select').files;
  var totalSize = 0;
  var fileQuantity = files.length;
  for(var i = 0; i < fileQuantity; i++) {
    totalSize += files[i].size;
  }
  document.getElementById('sum-file-size').innerText = normalizeSize(totalSize);
  document.getElementById('file-select-label-text').innerHTML = 'Выбрано файлов: ' + fileQuantity;
  return totalSize / 1000;
}

function reduceFilename(name) {
  if (name.length > 28) {
    return (name.slice(0, 13) + '...' + name.slice(-13));
  }
  return name;
}

function checkUploadAbility(totalSize) {
  var sizeLabel = document.getElementById('sum-file-size');
  var fileQuantity = document.getElementById('file_select').files.length;
  if (totalSize > 25000 || totalSize <= 0) {
    uploadButton.classList.add('hidden');
    sizeLabel.classList.add('alerted');
    fileSelectLabel.classList.remove('btn-warning', 'btn-success');
    fileSelectLabel.classList.add('btn-danger');
  } else {
    fileSelectLabel.classList.remove('btn-warning', 'btn-danger');
    fileSelectLabel.classList.add('btn-success');
    uploadButton.classList.remove('hidden');
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

function buildImageLink(response) {
  return '<a target="_blank" href= ' + response.link +
         ' style="display: block; width: 100%; color: white;">Скачать (' +
         response.diff +
         '%)</a>'
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
  var statusText = document.getElementById('status-text-' + number);
  xhr.upload.onprogress = function(event) {
    var loadedKb = Math.floor(event.loaded / 1000);
    var totalKb = Math.floor(event.total / 1000);
    var percentage = Math.floor((loadedKb / totalKb) * 100);
    progressbar.style.width = percentage + '%';
    progressbar.innerText = percentage + '%';
    statusText.innerHTML = loadedKb + '/' + totalKb + ' Kb';
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
      progressbar.innerHTML = buildImageLink(response);
      imageLinks.push(response.link);
    } else {
      progressbar.classList.remove('progress-bar-primary', 'progress-bar-striped', 'active');
      progressbar.classList.add('progress-bar-danger');
      progressbar.innerHTML = 'Ошибка';
    }
    if (ajaxQueue.length == 0) {
      document.getElementById('imageLinksInput').value = JSON.stringify(imageLinks);
      document.getElementById('download-zip').classList.remove('hidden');
      uploadButton.classList.remove('hidden');
      uploadButton.removeAttribute('disabled', 'disabled');
    } else {
      runNextFromAjaxQueue();
    }
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
    var progressBarCode =
      '<div class="row progress-wrapper"><div class="col-xs-4" id="status-bar-' + i + '" title="' + files[i].name + '">' + reduceFilename(files[i].name) + '</div><div class="col-xs-3" id="status-text-' + i + '">В очереди</div><div class="col-xs-5"><div class="progress"><div id="progress-bar-' + i + '" class="progress-bar progress-bar-warning" role="progressbar" aria-valuemin="0" aria-valuemax="100"></div></div></div></div>'
    document.getElementById('download-zip').insertAdjacentHTML('beforebegin', progressBarCode);
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

  uploadButton.addEventListener('click', function(event) {
    event.preventDefault();
    clearCurrentResults();
    uploadButton.setAttribute('disabled', 'disabled');
    startUpload();
  }, false);

  document.getElementById('change-size-no').addEventListener('click', function() {
    clearWidthAndHeight();
  }, false);

  document.getElementById('quality-range').addEventListener('input', function(event) {
    var newValue = event.target.value;
    document.getElementById('quality').value = newValue;
  }, false);

  document.getElementById('quality').addEventListener('keyup', function(event) {
    var newValue = event.target.value;
    document.getElementById('quality-range').value = newValue;
  }, false);

  document.getElementById('quality').addEventListener('change', function(event) {
    var newValue = event.target.value;
    document.getElementById('quality-range').value = newValue;
  }, false);
}
