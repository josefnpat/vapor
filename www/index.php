<?php

$data = json_decode(file_get_contents("../games.json"));
$gamecount = count($data->games);

?><!DOCTYPE html>

  <head>
    <title>Vapor &mdash; L&Ouml;VE Distribution Client</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <link rel="icon" type="image/png" href="favicon.png" />
    <link rel="stylesheet" type="text/css" href="style.css.php">
  </head>

  <body>
    <div class="wrapper">

      <div class="logo"><img src="logo.png" alt="Vapor" title="Vapor" /></div>

      <h2>L&Ouml;VE Distribution Client</h2>

      <p>Information</p>

      <ul>
        <li><a href="https://github.com/josefnpat/vapor/releases/latest">Download the latest release of Vapor</a>.</li>
        <li>How to <a href="https://github.com/josefnpat/vapor#how-can-i-add-my-game">add your own L&Ouml;VE game</a> and the <a href="https://github.com/josefnpat/vapor#game-criteria">criteria required</a>.</li>
        <li><a href="https://github.com/josefnpat/vapor#translations">Help translate Vapor</a>.</li>
        <li>See the project at <a href="https://github.com/josefnpat/vapor">GitHub</a>.</li>
        <li>Contribute to vapor! Check out the <a href="https://github.com/josefnpat/vapor/issues">issue queue</a>!</li>
      </ul>

      <h3>Games (<?php echo $gamecount; ?>)</h3>

<?php
      usort($data->games,function($a,$b){ return $a->stable<$b->stable; });

      foreach($data->games as $gamekey => $gamedata){
        echo "<div class=\"game\">\n";
        $image = "<img src=\"".$gamedata->image."\" />";
        echo "<div class=\"info\">\n";
        $name = $gamedata->name;
        if(isset($gamedata->description)){
          $desc = $gamedata->description;
        } else {
          $desc = "";
        }
        $date = date('Y-m-d',$gamedata->stable);
        if(isset($gamedata->website)){
          $author = '<a target="_blank" href="'.$gamedata->website.'">'.$gamedata->author."</a>";
        } else {
          $author = $gamedata->author;
        }
        echo "$image\n";
        echo "<h3>$name</h3>\n";
        echo "<p><em>$author</em> <small>($date)</small></p>\n";
        echo "<p>$desc</p>\n";
        echo "</div>\n";
        echo "</div>\n";
      }

?>

    </div><!-- end wrapper -->
  </body>
</html>
