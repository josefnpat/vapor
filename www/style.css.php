<?php
  header("Content-type: text/css; charset: UTF-8");

  $color = array();
  $color['black'] = "#000000";
  $color['black_highlight'] = "#333333";

  $color['blue'] = "#84c2ed";
  $color['blue_highlight'] = "#a2c5f1";

  $color['red'] = "#ed8484";
  $color['red_highlight'] = "#fe9daa";
  $color['red_reflection'] = "#fa836d";

  $color['steel'] = "#5a5a5a";
  $color['steel_highlight'] = "#7a7a7a";

  $color['copper'] = "#5a4e3e";
  $color['copper_highlight'] = "#e49455";

?>

@import url(http://fonts.googleapis.com/css?family=Open+Sans);

body {
  background-color: <?php echo $color['steel_highlight']; ?>;
  color: <?php echo $color['blue']; ?>;
  font-family: 'Open Sans', sans-serif;
  padding: 0px;
  margin: 0px;
}

a:link, a:active {
  color: <?php echo $color['red']; ?>;
}
a:hover {
  color: <?php echo $color['red_highlight']; ?>;
}
a:visited {
  color: <?php echo $color['red_reflection']; ?>;
}

h1, h2, h3, h4 {
  color: <?php echo $color['copper_highlight']; ?>;
}

.wrapper {
  width: 920px;
  padding: 0px 32px 32px;
  margin: 0px auto;
  background-color: <?php echo $color['steel']; ?>;
}

.logo {
  background-color: <?php echo $color['black_highlight']; ?>;
  width: 100%;
  text-align: center;
  padding: 0px;
}

.game {
  height: 261px; /* 245 + 16 */
  background-color: <?php echo $color['black_highlight']; ?>;
  margin: 8px 0px;
}

.game .info {
  padding: 8px 0px 8px 16px;
}

.game img {
  float: right;
  padding: 0px 8px;
}
