#Vapor - LÖVE Distribution Client

![Screenshot](https://raw.github.com/josefnpat/vapor/master/dev/screenshots/screenshot.png)

## Requirements

* LÖVE 0.8.0
* A stable internet connection.

## How can I add my game?

* Fork [this repo](https://github.com/josefnpat/vapor).
* Extend the `games.json` with the following data;

    **Make an [issue](https://github.com/josefnpat/vapor/issues) with all the following information from this step if you can't use git or json.**

Please see [/src/games.json](/src/games.json) for an example of how this is done.

    * id:          A unique id using only A-Z, a-z, underscores and dashes.
    * name:        The name of your game.
    * sources:     An array of links to your .love files with an index representing the current unix timestamp.
                   Please ensure that your game is hosted on an http server as opposed to https.
                   If you can, please host this on a server, as opposed to a shared website like dropbox.
                   @jpikl has found out that you can link to bitbucket http addresses as well! The trick is to use the
                   cdn.bitbucket.org subdomain. See the `src/games.json` for an example.
                   Contact me if you would like me to host your .love file.
    * hashes:      An array of SHA-1 hashes for your .love files with an index representing the current unix timestamp.
                   This means that if you change your .love file on your server, it will no longer be valid, and you will
                   have to make a new entry in the sources and hashes arrays. [1]
    * sizes:       An array of the sizes in bytes for your .love files with an index representing the current unix timestamp.
    * stable:      The timestamp of the current stable release index from your sources list.
                   If you only have one element in sources, this would be that elements index.
    * author:      Your name or handle.
    * website:     Your website. [optional]
    * description: A description of the game. [optional]
    * engine:      The engine that your game runs. Currently only supports `love-0.8.0`.
    * image:       A link to a PNG image 436x245 in dimension. The less text, the better.
                   Please ensure that your image is hosted on an http server as opposed to https.
                   Do not host this on a site that does not allow hotlinking.
                   Sites like imgur.com should do well, but again, private hosts are best.

* [Test your submission.](#testing-your-game-submission)
* Submit your pull request.
* Sit back and bask in the glory.

## Testing your game submission

Vapor currently attempts to read the `games.json` file from three locations, in this order:

1. [Remotely, from the server](http://50.116.63.25/public/vapor/games.json) (so that everyone always has the newest version!)
2. Your cache, which was the last successful download. The cached `games.json` can be found here:

  * Windows XP: `C:\Documents and Settings\user\Application Data\LOVE\vapor-data\` or `%appdata%\LOVE\vapor-data\`
  * Windows Vista and 7: `C:\Users\user\AppData\Roaming\LOVE\vapor-data\` or `%appdata%\LOVE\vapor-data\`
  * Linux: `$XDG_DATA_HOME/love/vapor-data/` or `~/.local/share/love/vapor-data/`
  * Mac: `/Users/user/Library/Application Support/LOVE/vapor-data/`

3. From the current directory / archive (e.g. `vapor-*.love`), which is the `games.json` that the archive will be deployed with.

To force vapor to read from the current directory / archive, use the `force_local` flag. e.g.;

    love ./vapor-*.love force_local

You will know if this is done correctly if the console output says, 'Updated from local games.json`.

To remove the cached settings (`settings.json`) and cached database (`games.json`) use the `clear_cache` flag. e.g.;

    love ./vapor-*.love clear_cache

## Game Criteria

Your game must:
* load and run,
* be playable,
* not start in fullscreen mode,
* use LÖVE 0.8.0,

Your game must not:
* use compiled Lua libraries not provided by love (e.g. luasec, enet, lsqlite3, LuaFileSystem).

## Your client sucks

_Yeah, what of it?_

Feature Requests, Suggestions, Bugs, etc. go in the [issue queue](https://github.com/josefnpat/vapor/issues).

If you are interested in helping out in the project, you can find josefnpat on [OFTC](irc://irc.oftc.net:6667) in #vapor-dev or #love.

## Translations

If you are interested in creating a new language for vapor:

* __Be dedicated__. If you abandon your language, and I cannot get a translation easily, I will have to remove it.
* __Create a new issue entitled: "Add Language <LANG>"__ so that I can ping you when I need to get translations.
* __Use `src/core/lang/en.lua` as a guide__, as that will always be up to date, since EN is the default language.

## Documentation

Please visit the [wiki hosted at GitHub](https://github.com/josefnpat/vapor/wiki).

[1] How to on [windows](http://support.microsoft.com/kb/889768), [OS X](http://ss64.com/osx/shasum.html) or [linux](http://en.wikipedia.org/wiki/Sha1sum)
