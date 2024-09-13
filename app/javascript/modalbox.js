document.addEventListener("turbo:load", function() {
  var myModalElement = document.getElementById('myModal'); // Define myModalElement
  if (myModalElement) {
    var myModal = new bootstrap.Modal(myModalElement);
    var closeModalButton = document.querySelector('#myModal .modal-header button.close');
    var commentDescription = document.getElementById("comment_description");
    function removeErrorMessage() {
      var errorParagraph = document.querySelector('#comment_form .text-danger');
      if (errorParagraph) {
        errorParagraph.remove();
      }
    }
    
    var openModel = document.getElementById('openModalButton')
    if (openModel) {
      openModel.addEventListener('click', function () {
        myModal.show();
        commentDescription.value = "";
        removeErrorMessage();
      });
    }

    closeModalButton.addEventListener('click', function () {
      myModal.hide();
      commentDescription.value = "";
      removeErrorMessage();
    });

    myModal._element.addEventListener('hide.bs.modal', function () {
      commentDescription.value = "";
      removeErrorMessage();
    });
  }
});
