# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/).

## [2018-02-13] - 2018-02-13
### Added
- GitHub repo
- accept multiple image filepaths as command line parameters
- accept multiple image filepaths on separate lines in a .txt file as command line parameter
- .png image support
- keyboard shortcurt to expand/contract previous rectangle
- separate previous crop rectangles for R/L suffixed image inputs

### Changed
- big code cleanup/rewrite
- TIFF input images must have .tif extension (not .tiff)
- fix: disabled DPI scaling to avoid rectangle errors if system has non-standard DPI setting.
- crop using WIA (removed GraphicsMagick dependency)


## [2015-04-21] - 2015-04-21
### Added
- shows previous crop rectangle in blue
- hotkeys to move previous rectangle and go to next/prev file

### Changed
- only operate on dropped images (not whole folder)
- prefix "crop_"

## [2013-10-26] - 2013-10-26b
### Added
- preview in color (was: grayscale)


## [2013-10-26] - 2013-10-26
### Added
- first release
