document.addEventListener('DOMContentLoaded', function() {
  var starContainers = document.querySelectorAll('.star-container');

  starContainers.forEach(function(container) {
    var starId = container.querySelector('span.fa-star').id;
    var rating = parseInt(starId.split('-')[1]); // Parse rating from ID
    container.addEventListener('mouseover', function () {
      hoverRating(rating);
    });

    container.addEventListener('mouseout', function() {
      resetRating();
    });
  });
});

function submitRating(rating) {

  for (let i = 1; i <= rating; i++) {
    let star = document.getElementById(`star-${i}`);
    star.classList.add('checked');
    star.classList.remove('unchecked')
  }

  document.getElementById('rating-select').value = rating;
  document.getElementById('rating-form').submit();
}
function hoverRating(rating) {

  var label = document.getElementById("rating-description");
  switch (rating) {
    case 1:
      label.innerText = "Poor";
      break;
    case 2:
      label.innerText = "Fair";
      break;
    case 3:
      label.innerText = "Average";
      break;
    case 4:
      label.innerText = "Good";
      break;
    case 5:
      label.innerText = "Excellent";
      break;
    default:
      label.innerText = "hello";
      break;
  }

}
function resetRating() {
  var label = document.getElementById("rating-description");
    label.innerText = "";
}
