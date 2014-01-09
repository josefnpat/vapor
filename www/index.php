<?php

$data = json_decode(file_get_contents("../games.json"));
$gamecount = count($data->games);

?><!DOCTYPE html>

  <head>
    <title>Vapor &mdash; L&Ouml;VE Distribution Client</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  </head>

  <body>

    <h1>Vapor</h1>

    <h2>L&Ouml;VE Distribution Client</h2>

    <h3><a href="https://github.com/josefnpat/vapor/releases/latest">Download the latest release of vapor here.</a></h3>

    <p>See the project at <a href="https://github.com/josefnpat/vapor">GitHub</a>.</p>
    <p>Contribute to vapor! Check out the <a href="https://github.com/josefnpat/vapor/issues">issue queue</a>!</p>
    <p>Vapor uses <a href="http://love2d.org">L&Ouml;VE 0.8.0</a>.</p>

    <h3>Games (<?php echo $gamecount; ?>)</h3>

<?php
    usort($data->games,function($a,$b){ return $a->stable<$b->stable; });

    echo "    <ul>\n";
    foreach($data->games as $gamekey => $gamedata){
      $name = $gamedata->name;
      $date = date('Y-m-d',$gamedata->stable);
      if(isset($gamedata->website)){
        $author = '<a target="_blank" href="'.$gamedata->website.'">'.$gamedata->author."</a>";
      } else {
        $author = $gamedata->author;
      }
    echo "      <li><b>$name</b> by <em>$author</em> <small>($date)</small></li>\n";
    }
    echo "    </ul>\n";

?>

  </body>
</html>
