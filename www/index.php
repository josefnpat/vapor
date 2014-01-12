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
        <li>Chat with the developers at <a href="http://webchat.oftc.net/?channels=vapor-dev">#vapor-dev@irc.oftc.net</a>!</li>
        <li><a href="logs">Check the game database health logs</a>.</li>
      </ul>

      <a class="twitter-timeline" href="https://twitter.com/search?q=%23Vapor+AND+%28%23L%C3%96VE+OR+%23love2d%29" data-widget-id="407356618666303488">Tweets about "#Vapor AND (#LÖVE OR #love2d)"</a>
      <script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+"://platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");</script>

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
