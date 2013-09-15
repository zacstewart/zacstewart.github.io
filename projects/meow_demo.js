$(document).ready(function () {
  $('#example-button').click(function () {
    $.meow({
      message: $('#example-input'),
    title: 'Hello, World',
    icon: 'http://zacstewart.github.com/Meow/nyan-cat.gif'
    });
  });
});
