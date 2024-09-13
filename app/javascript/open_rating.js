document.addEventListener('turbo:load', function() {
  var openRatingModalButton = document.getElementById('openRatingModalButton');
  var ratingModalElement = document.getElementById('ratingModal');

  if (openRatingModalButton && ratingModalElement) {
    var ratingModal = new bootstrap.Modal(ratingModalElement);

    openRatingModalButton.addEventListener('click', function() {
      ratingModal.show();
    });
  }
});
