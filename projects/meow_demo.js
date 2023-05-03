$(document).ready(function () {
  $('#example-button').click(function () {
    $.meow({
      message: $('#example-input'),
      title: 'Hello, World',
      icon: 'http://zacstewart.com/Meow/nyan-cat.gif'
    });
  });
});
