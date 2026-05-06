# steelwool
cleans chrome

## Description

  **SteelWool** was built to address a problem in our student labs where students weren't logging out of their accounts.

  Our structure meant that our labs had to use a common user account, or it would be more difficult to have it set up. Knowing that trying to change this structure would be too much friction, I tried to set browser configurations so that they cleared data on exit.

  Safari can be forced to use a private window by default, and Firefox lets you do essentially what this tool does.

  Chrome likes your user data.

  I determined that the path of least resistance - somehow - was to make a tool to just remove where Chrome stores user data. 

  That became SteelWool.

## Installation

  Brew or Curl, currently TODO.

## How it works

  `SteelWool` itself functions by reading a list `targets.txt` with all the paths that need to be removed. The main function itself is as simple as just making sure targets exists and acting on it.

  `SteelWoolDiff` is what actually generates `targets.txt`. If `targets.txt` hasn't been updated since the last version of Chrome,Diff will throw a warning into the log.

  It actually functions using `diff`. It sees `chromebefore.txt` and `chromeafter.txt`, and just differentiates between them.

  This, of course, relies on an initial targets.txt to work. This itself is generated on a MacOS Sequoia VM that takes the initial state of Chrome, the state after a user is logged in, and differentiates to see what files are different between them. 

  This is updated with every patch as targets.txt, which is downloadable [standalone](example.com) or with `brew upgrade steelwool`.It generally only changes when Chrome releases a major update, since Chrome is rather stable.

### Definitions

#### Chromebefore.txt
  `Chromebefore.txt` is a `find` snapshot of Chrome as its first initialized state.

#### Chromeafter.txt
  `Chromeafter.txt` is a `find` snapshot of Chrome after a user is logged in.

#### targets.txt
  `targets.txt` is a `diff` of `chromebefore.txt` and `chromeafter.txt`.

#### Chromenew.txt
  `Chromenew.txt` is a diff of `chromebefore.txt` and `chrometmp.txt`, which 
is generated temporarily whenever `SteelWoolDiff` runs, before turning into
`chromebefore.txt`. 

## Paths

### Log
  "steelwool.log"
`$HOME/Library/Logs/SteelWool/steelwool.log`

### Data and Config
  "steelwool config.toml"
`$HOME/Library/Application\ Support/SteelWool/config.toml`

  "chromebefore.txt, chromeafter.txt, targets.txt"
`$HOME/Library/Application\ Support/SteelWool`

## Author

Dryophoenix (Neph Hillis)

dryophoenix@outlook.com - Contact me!
