Vapor - LÖVE Distribution Client

## Requirements

* LÖVE 0.8.0 installed in a *nix command line.
* A stable internet connection.

## How can I add my game?

* Fork this repo.
* Extend the `games.json` with the following data;
    id :      A unique id using only A-Z, a-z, underscores and dashes.
    name :    The name of your game.
    sources : An array of links to your .love files with an index representing the current unix time stamp.
              Please ensure that your game is hosted on an http server as opposed to https.
              If you can, please host this on a server, as opposed to a shared website as dropbox.
              Contact me if you would like me to host your .love file.
    stable :  The timestamp of the current stable release index from your sources list.
    author :  Your name or handle.
    engine :  The engine that your game runs. Currently only supports `love-0.8.0`.
    image :   A link to a PNG image 436x245 in dimension. The less text, the better.
              Please ensure that your image is hosted on an http server as opposed to https.
              Do not host this on a site that does not allow hotlinking.
              Sites like imgur.com should do well, but again, private hosts are best.
* Submit your pull request.
* Sit back, and bask in your glory.

## Game Criteria

Your game must
* load and run,
* be playable,
* use LÖVE 0.8.0,
* not use libraries not supplied by love.
