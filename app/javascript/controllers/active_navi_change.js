 document.addEventListener("DOMContentLoaded", function() {
    const navLinks = document.querySelectorAll('.nav-link');
    navLinks.forEach(function(link) {
      link.addEventListener("click", function(event) {
        navLinks.forEach(function(link) {
          link.parentElement.classList.remove('active');
        });
        event.target.parentElement.classList.add('active');
      });
    });
  });
