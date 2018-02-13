

# SoloCrop

SoloCrop.ahk -- version 2018-02-13 -- by Nod5 -- GPLv3 -- Made in Windows 10

AutoHotkey program to quickly crop many images in sequence

[Download SoloCrop binary](https://github.com/nod5/SoloCrop/releases)

![Alt text](images/solocrop_screenshot1.png?raw=true)

![Alt text](images/solocrop_screenshot2.png?raw=true)

[larger screenshot](images/solocrop_screenshot2_large.png)


## How to use
1. Drag and drop jpg/tif/png images
2. Click and draw a rectangle
3. Release mouse button to crop
4. SoloCrop loads the next image

The cropped image is saved with prefix "crop_"  
The original file is unchanged  

## Features

- If multiple files are dropped:

 - SoloCrop shows the previous crop rectangle (in blue)
 - `Space`  Crop with blue rectangle
 - `Up`/`Down`/`Left`/`Right`  Move rectangle
 - `+`/`-`  Expand/shrink rectangle
 - Hold `Shift` for larger move/resize steps
 - `PgDn`/`WheelDown`  Skip current image


- `Esc` or `right click` Cancel rectangle draw

- `Tab` or click `?`  Show this help

- Command line parameters: image filepaths or a .txt file with one image filepath per line
````
SoloCrop.exe "C:\dir\a.jpg" "C:\a folder\b.jpg"
````
````
SoloCrop.exe "C:\files.txt"
````

- If input files are named `0001L.jpg` , `0001R.jpg` , `0002L.jpg` ... (four digits and R/L) then SoloCrop uses separate previous crop rectangles for R and L images.

- If you wish to run/build SoloCrop.ahk from source: install [AutoHotkey](https://autohotkey.com)

## Feedback
GitHub , https://github.com/nod5/SoloCrop

