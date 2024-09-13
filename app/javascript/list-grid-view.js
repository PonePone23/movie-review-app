function showlist() {
  var listView = document.querySelector('.list-view');
  var gridView = document.querySelector('.grid-view');
  var listIcon = document.querySelector('.icon-l');
  var gridIcon = document.querySelector('.icon-g');
  listView.classList.remove('hidden')
  gridView.classList.add('hidden')
  gridIcon.classList.remove('active-lg')
  listIcon.classList.add('active-lg')
}
function showgrid() {
  var listView = document.querySelector('.list-view');
  var gridView = document.querySelector('.grid-view');
  var listIcon = document.querySelector('.icon-l');
  var gridIcon = document.querySelector('.icon-g');
  gridView.classList.remove('hidden')
  listView.classList.add('hidden')
  listIcon.classList.remove('active-lg')
  gridIcon.classList.add('active-lg')
}
