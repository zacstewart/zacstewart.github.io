---
layout: default
title: 'Meow: A Growl Work-Alike for jQuery'
---
<link rel="stylesheet" href="http://zacstewart.com/Meow/jquery.meow.css">
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.6.2/jquery.min.js"></script>
<script src="http://zacstewart.com/Meow/jquery.meow.js"></script>
<script src="meow_demo.js"></script>

# jQuery Meow

jQuery Meow mimics Growl notications. It supports all jQuery events and you can
bind it to various sources for message input making it ideal for form
validation, Rails flash notices, or a replacement for the `alert()` box.

## Example

<textarea id="example-input">Enter a message for the global meow network</textarea>
<button id="example-button">Click me</button>

## Usage

```javascript
var options = {
  title: 'Meow Example',
  message: 'Hello, World!',
};

$.meow(options);
```

## Get it!

[Download the source](https://github.com/zacstewart/Meow/archives/master) from
GitHub, or just [hotlink](http://zacstewart.com/Meow/) the JavaScript
and CSS files to always have the latest version.

## Options

| Key                 | Type             | Default   | Description                                                                                                                                                                                            |
| ------------------- | ---------------- | --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| message             | String, Object   | null      | Either a string or a jQuery selected element. If it's an element, Meow will use its value, innerHTML or innerText depending on its type.                                                               |
| title               | String           | null      | If a string is given, the meow's title will reflect it. However, if you do no set this and use a selector element in `message`, it will default to the `title` attribute of that element if available. |
| icon                | String           | null      | Sets the image URL for the icon                                                                                                                                                                        |
| duration            | Number           | 5000      | Sets the duration of of the meow in milliseconds. Any positive, numeric value (including `Infinity`) is acceptable.                                                                                    |
| sticky              | Boolean          | false     | Sets the meow to never time out. Has the same effect as setting duration to `Infinity`.                                                                                                                |
| closeable           | Boolean          | true      | Determines whether the meow will have a close (&times;) button. If `false`, yout must rely on the duration timeout to remove the meow.                                                                 |
| beforeCreateFirst   | Function         | null      | Gets called just before the first meow on the screen is created.                                                                                                                                       |
| beforeCreate        | Function         | null      | Gets called just before any meow is created.                                                                                                                                                           |
| afterCreate         | Function         | null      | Gets called right after a meow is created.                                                                                                                                                             |
| onTimeout           | Function         | null      | Gets called whenever a meow times out.                                                                                                                                                                 |
| beforeDestroy       | Function         | null      | Gets called just before a meow gets destroyed.                                                                                                                                                         |
| afterDestroy        | Function         | null      | Gets called right after a meow gets destroyed.                                                                                                                                                         |
| afterDestroyLast    | Function         | null      | Gets called after the last meow on the screen is destroyed.                                                                                                                                            |
