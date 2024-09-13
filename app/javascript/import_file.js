document.addEventListener('DOMContentLoaded', function() {
  document.getElementById('file-input').addEventListener('change', function() {
    document.getElementById('import-form').submit();
  });
});
