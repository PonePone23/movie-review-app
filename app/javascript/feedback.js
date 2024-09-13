$(document).on('submit', '#new_feedback', function(e) {
  e.preventDefault(); // Prevent default form submission

  var formData = $(this).serialize(); // Serialize form data

  // Disable the submit button
  $('.feedback-btn').prop('disabled', true);

  // Show the "Submitting feedback..." message
  $('#feedback_notice').text('Submitting feedback...').show();
  $('#loading-spinner').show();

  $.ajax({
    type: 'POST',
    url: $(this).attr('action'),
    data: formData,
    success: function(response) {
      // Clear any existing error messages
      $('#name-error').empty();
      $('#email-error').empty();
      $('#message-error').empty();

      if (response.success) {
        // If feedback submission is successful, show the message
          alert('Thank you for your feedback!');
        // Clear form fields
        $('#new_feedback')[0].reset();

        // Hide the feedback submission notice
        $('#feedback_notice').hide();
      } else {
        // If there are errors in the submission
        // Display error messages for each field
        if (response.errors.name) {
          $('#name-error').html(response.errors.name.join(', '));
        }
        if (response.errors.email) {
          $('#email-error').html(response.errors.email.join(', '));
        }
        if (response.errors.message) {
          $('#message-error').html(response.errors.message.join(', '));
        }

        // Hide the "Submitting feedback..." message
        $('#feedback_notice').hide();
      }
    },
    error: function(xhr, status, error) {
      console.error(xhr.responseText); // Handle AJAX errors

      // Hide the "Submitting feedback..." message
      $('#feedback_notice').hide();
    },
    complete: function () {
      $('#loading-spinner').hide();
      // Enable the submit button after the request is complete
      $('.feedback-btn').prop('disabled', false);
    }
  });
});
