function previewImage(input) {
  const preview = document.getElementById('preview-image');
  const file = input.files[0];
  const reader = new FileReader();

  reader.onloadend = function() {
    preview.src = reader.result;
    preview.style.display = 'block';
  }

  if (file) {
    reader.readAsDataURL(file);
  } else {
    preview.src = "";
    preview.style.display = 'none'; // Hide the preview if no file is selected
  }
}
