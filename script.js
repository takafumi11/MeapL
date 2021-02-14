
  $(function () {
    $('.nav_toggle').on('click', function () {
      $('body').toggleClass('open');
    });
    $('.gloval_nav nav ul li a').on('click', function () {
      $('body').removeClass('open');
    });
  });