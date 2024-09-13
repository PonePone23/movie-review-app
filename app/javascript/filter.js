// JavaScript for handling button clicks and filtering carousels
$(document).ready(function() {
    // Function to show genre carousel and hide year carousel
  function showGenreCarousel() {
    var viewportWidth = window.innerWidth;
        if(viewportWidth<=576) {
            $('#genreCarousel').hide();
            $('#genre').show();
            $('#yearCarousel').hide();
            $('#year').hide();
        } else {
            $('#genreCarousel').show(); // Show the carousel for desktop
            $('#genre').hide(); // Hide the genre specific to mobile
            $('#yearCarousel').hide(); // Assuming yearCarousel is specific to mobile
            $('#year').hide();
        }
    }

    // Function to show year carousel and hide genre carousel
    function showYearCarousel() {
      var viewportWidth = window.innerWidth;
      if (viewportWidth <= 576) {
        $('#yearCarousel').hide();
        $('#year').show();
        $('#genreCarousel').hide();
        $("#genre").hide();
      } else {
        $('#yearCarousel').show();
        $('#year').hide();
        $('#genreCarousel').hide();
        $("#genre").hide();
      }
    }

    // Initially show the genre carousel and hide the year carousel
    showGenreCarousel();

    // Genre button click event handler
    $('#GenreModel').click(function() {
      showGenreCarousel();
    });

    // Year button click event handler
    $('#YearModel').click(function() {
      showYearCarousel();
    });

    // Click event handler for Genre dropdown item
    $('#GenreModel').click(function() {
      $('#GenreModel').addClass('active');
      $('#YearModel').removeClass('active');
    });

    // Click event handler for Year dropdown item
    $('#YearModel').click(function() {
      $('#YearModel').addClass('active');
      $('#GenreModel').removeClass('active');
    });

    // Initially set the dropdown button text to "Genre"
    $('#dropdownMenuButton').text('Genre');

    // Click event handler for Genre dropdown item
    $('#GenreModel').click(function() {
      // Change the dropdown button text to "Genre" when Genre is clicked
      $('#dropdownMenuButton').text('Genre');
    });

    // Click event handler for Year dropdown item
    $('#YearModel').click(function() {
      // Change the dropdown button text to "Year" when Year is clicked
      $('#dropdownMenuButton').text('Year');
    });

});

