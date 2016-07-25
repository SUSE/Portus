$(document).ready(function() {
    $('.collapse').on('show.bs.collapse', function(sender) {
        var parent = sender.target.previousElementSibling;
        parent.classList.add('active');
    });
    $('.collapse').on('hide.bs.collapse', function(sender) {
        var parent = sender.target.previousElementSibling;
        parent.classList.remove('active');
    });
})