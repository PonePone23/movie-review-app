document.addEventListener("turbo:load", function() {
  const dropZone = document.getElementById('drop-zone');

  ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
    dropZone.addEventListener(eventName, preventDefaults, false);
  });

  function preventDefaults(e) {
    e.preventDefault();
    e.stopPropagation();
  }

  dropZone.addEventListener('drop', handleDrop, false);

  function handleDrop(e) {
    let dt = e.dataTransfer;
    let files = dt.files;

    handleFiles(files);
  }

  function handleFiles(files) {
    // Assuming only one file is being handled
    const file = files[0];
    const imageType = /image.*/;

    if (file.type.match(imageType)) {
      const reader = new FileReader();

      reader.onload = function() {
        const img = document.getElementById('preview-image');
        img.src = reader.result;
        img.style.display = 'block';
      };

      reader.readAsDataURL(file);
    } else {
      alert('Please upload an image file.');
    }
  }

  document.getElementById('drop-zone').addEventListener('click', function() {
    document.getElementById('image').click();
  });

  document.getElementById('image').addEventListener('change', function() {
    const file = this.files[0];
    handleFiles([file]);
  });
});
