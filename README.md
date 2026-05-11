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

  In progress

## How it works

  `SteelWool` itself functions by reading a list `targets.txt` with all the paths that need to be removed. The main function itself is as simple as just making sure targets exists and acting on it.

  `SteelWoolDiff` is what actually generates `targets.txt`. If `targets.txt` hasn't been updated since the last version of Chrome,Diff will throw a warning into the log.

  It actually functions using `diff`. It sees `chromebefore.txt` and `chromeafter.txt`, and just differentiates between them.

  This, of course, relies on an initial targets.txt to work. This itself is generated on a MacOS Sequoia VM that takes the initial state of Chrome, the state after a user is logged in, and differentiates to see what files are different between them. 

  This is updated with every patch as targets.txt, which is downloadable [standalone](example.com) or with `brew upgrade steelwool`.It generally only changes when Chrome releases a major update, since Chrome is rather stable.

## Maintainers

  Generally, I should be the only one modifying targets.txt, at least until a better solution for making sure that it is completely secure can be found. Because of the nature of SteelWool, anything that is put in targets.txt will be removed. This may include arbitrary files inserted into SteelWool, since SteelWoolDiff cannot be updated before run. Essentially, the tool requires a central database of targets, which must be protected from modification.

  Otherwise, I would love any contribution to the project if you find it helpful! Better versions of some of the functions could be appreciated, better documentation could be nice, expansion would be awesome, as long as it maintains its initial purpose to "clean chrome".

  Ideally, Google someday makes SteelWool irrelevant, but as long as Chrome wants to hold onto data, this tool exists instead.

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

dryo@dryophoenix.net - Contact me!
