function previewImage(input) {
  var preview = document.getElementById('preview-image');
  var reader = new FileReader();
  reader.onload = function (e) {
    preview.src = e.target.result;
    preview.classList.add("adjust-img")

  };
  reader.readAsDataURL(input.files[0]);
}
