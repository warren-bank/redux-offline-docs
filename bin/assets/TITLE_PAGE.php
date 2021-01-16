<html>
<head>
  <style>
.purple {
  color: #764abc;
}
.purple-bg {
  background-color: #764abc;
  color: #fff;
  padding: 0.15em;
}
.rounded {
  border-radius: 0.5em;
}
.center {
  text-align: center;
}
.inline {
  display: inline-block;
}
body, h1, h2, h3, img {
  margin: 0;
  padding: 0;
}
body {
  font-family: sans-serif;
  font-size: 60px;
  font-weight: bold;
  color: #000;
  background-color: #fff;
  padding: 1em;
  overflow-x: hidden;
}
h1 {
  font-size: 2em;
  line-height: 1.15em;
  text-shadow: 0.05em 0.05em #999;
}
h1.purple {
  text-shadow: 0.05em 0.05em #333;
}
img {
  max-width: 50%;
  height: auto;
}
h2 {
  font-size: 1.5em;
  line-height: 1.15em;
}
h3 {
  font-size: 1em;
  line-height: 1.15em;
}
.inline + .inline {
  vertical-align: text-bottom;
}
  </style>
</head>
<body>
  <h1 class="inline purple">Redux</h1>
  <h3 class="inline purple-bg rounded">v<?=$argv[1]?></h3>
  <h1>Documentation</h1>
  <br /><br /><br />
  <div class="center">
    <img src="https://github.com/reduxjs/redux/raw/v4.0.5/logo/logo.png" />
    <h1>Redux</h1>
    <br /><br /><br /><br /><br /><br />
    <h2>Redux Official<br>Documentation</h2>
  </div>
</body>
</html>
