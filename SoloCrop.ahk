#NoEnv
#SingleInstance force
#Persistent

info =
(C
;SoloCrop
Quickly crop many images in sequence

version 2018-02-13
by Nod5
Free Software -- http://www.gnu.org/licenses/gpl-3.0.html
Made in Windows 10

HOW TO USE
1. Drag and drop jpg/tif/png images
2. Click and draw a rectangle
3. Release mouse button to crop
4. SoloCrop loads the next image

The cropped image is saved with prefix "crop_"
The original file is unchanged

FEATURES
If multiple files are dropped:
- SoloCrop shows the previous crop rectangle (in blue)
- Space: crop with blue rectangle
- Up/Down/Left/Right: move rectangle
- +/-: Expand/shrink rectangle
- Hold Shift for larger move/resize steps
- PgDn/WheelDn: Skip current image

Esc or right click: cancel rectangle draw
Tab or click ?: show this help

Command line parameters: image filepaths or 
a .txt file with one image filepath per line
Example: SoloCrop.exe "C:\dir\a.jpg" "C:\a folder\b.jpg"
Example: SoloCrop.exe "C:\files.txt"

If input files are named 0001L.jpg , 0001R.jpg , 
0002L.jpg ... (four digits and R/L) then SoloCrop uses 
separate previous crop rectangles for R and L images.

FEEDBACK
;https://github.com/nod5/SoloCrop
)

xwintitle = SoloCrop
DetectHiddenWindows, On
guinum := 5


;variable inventory
; x1 y1  x2 y2   = crop rectangle top left and bottom right corners:
; screenx1       = x1 relative to screen    top left
; picx1          = x1 relative to gui pic   top left
; x1             = upscaled x1 relative to imagefile top Left
; oldx1          = upscaled x1 relative to imagefile top left (old crop rect)
; oldx1R/L       =  ... in old R/L mode crop rect

; edgex1         = pic left edge relative to screen
; local x1 in LetUserSelectRect() = ongoing rect top left relative to screen


;parse command line parameters
if A_Args[1]
{
  If ( SubStr(A_Args[1], -3) == ".txt" )
    if FileExist(A_Args[1])
    {
      ;textfile with linebreak separated image paths
      txtfile := A_Args[1]
      FileRead, params, *t %txtfile%  ;*t formats `n`r into `n
      goto param_started
    }
  ;else add each param to list
  for key, value in A_Args
    params .= value "`n"  ;list
  goto param_started
}

;gui to drag drop images onto
Gui,6: font, s8 cgray
Gui,6: Add, Text,x290 y345 ghelpwindow, ?
Gui,6: font, s12 bold ;cblack
Gui,6: Add, GroupBox, x5 y2 w290 h300
if A_IsCompiled
  Gui,6: Add, Picture,x130 y75, %A_ScriptName%  ;embedded icon
Gui,6: Add, Text,x93 y125,Drop images
Gui,6: Add, Button, x130, Crop
GuiControl,6: Disable, Button2
Gui,6: Show,h360 w300 y200,%xwintitle%
return


helpwindow:
Gui 7:+LastFoundExist
IfWinExist
{
  gui,7: destroy
  return
}
;get pos for main gui (preview or empty)
WinGetPos,mainx,mainy, mainw,, %xwintitle% ahk_class AutoHotkeyGUI
;make helpwin
Gui, 7: +ToolWindow -SysMenu -Caption -resize +AlwaysOnTop +0x800000 -DPIScale
Gui, 7: Font, bold s12
Gui, 7: Add, Text,, %xwintitle%
Gui, 7: Font, normal s10
Gui, 7: Add, Text,, %info%
Gui, 7: Add, Text,h1, %space%
Gui, 7: Font, cblue
Gui, 7: Add, Text,yp-15 xm gwebsite, github.com/nod5/SoloCrop
;show helpwin to the right of main gui
Gui, 7: show, % "x" mainx+mainw " y" mainy
return

website:
Run https://github.com/nod5/SoloCrop
return

7GuiEscape:
gui,7: destroy
return

#IfWinActive, SoloCrop ahk_class AutoHotkeyGUI
Tab:: goto helpwindow
#IfWinActive
return


;file drop event
6GuiDropFiles:
5GuiDropFiles:
param_started:

;inputfiles from parameters or dropped
inputfiles := params ? params : A_GuiEvent

xarr := Object()

Loop, parse, inputfiles, `n
{
  SplitPath, A_LoopField,,,xext
  if xext in tif,jpg,png
    if FileExist(A_LoopField)
      xarr.Insert(A_LoopField)
      ;array of dropped img file paths
}

arrcontinue:
xi := xi == "" ? 1 : xi+1
if ( xi > xarr.MaxIndex() )
{
  reload  ;array finished, restart SoloCrop
  return ;prevents error popup on some reloads (unclear why)
}

;image file to work on
imagepath := xarr[xi]

;guinum toggle  ;use two gui to preload next img in background, quicker
guinum := guinum == 5 ? 25 : 5

;clear old gui rect
loop, 25
  if a_index not in 5,25
    Gui,%A_index%: destroy

;make/show preview pic window

if !WinExist("hide_solo")
{
  ;get image source dimensions and calculate gui pic dimensions (ByRef)
  getdim(imagepath, prop, pic_w, pic_h, imgw, imgh)
  ;create/show new preview pic window
  makegui(imagepath, pic_h, pic_w, xwintitle, guinum, %guinum%MainhWnd)
}
else
{
  ;show existing hidden preview pic window
  ;created with num nextguiwin last iteration = num guiwin this iteration
  WinGetPos, , , nextwinw, , hide_solo
  nextwinx := round ( (A_ScreenWidth - nextwinw) / 2 )
  Gui, %guinum%: show, x%nextwinx% ,%xwintitle% -- %imagepath%
  ;show pic child win
  picguinum := guinum + 50
  Gui, %picguinum%: show
  ;update vars
  pic_h := nextpic_h , pic_w := nextpic_w, prop := nextprop, imgw := nextimgw, imgh := nextimgh
}

;show old rectangle from last crop
oldrect_mode := ""
if old
  oldrect()

;unfocus old rectangle
winactivate, %xwintitle% -- ahk_class AutoHotkeyGUI


;last image?
if ( xi+1  > xarr.MaxIndex() )
  return

;preload and hide next image preview pic gui, for speed

nextguinum := guinum == 5 ? 25 : 5
nextfile := xarr[xi+1]
;get image source dimensions and calculate gui pic dimensions (ByRef)
getdim(nextfile, nextprop, nextpic_w, nextpic_h, nextimgw, nextimgh)
makegui(nextfile, nextpic_h, nextpic_w, "hide_solo", nextguinum, %nextguinum%MainhWnd)
;note: next preview has hide_solo as win title while hidden
winactivate, %xwintitle% -- ahk_class AutoHotkeyGUI
return


;mouse click on pic
#IfWinActive, SoloCrop -- ahk_class AutoHotkeyGUI
~*LButton::
sleep 50
If !WinActive("SoloCrop -- ahk_class AutoHotkeyGUI")
  return
;click in pic or on old rect
MouseGetPos,,,,clickedcontrol
if clickedcontrol in Static1,AutohotkeyGUI1,AutohotkeyGUI2,AutohotkeyGUI3,AutohotkeyGUI4
  goto pic  ;start drawing new rect
return


;move old rect
*Right::
*Left::
*Up::
*Down::
ControlGetPos,controlx,,,, oldrectgui, SoloCrop -- ahk_class AutoHotkeyGUI
if !controlx  ;no old rect exist
  return
;update oldx1 oldx2 or oldy1 oldy2 based on move direction
dimension := A_ThisHotkey == "*Up"    or A_ThisHotkey == "*Down" ? "y" : "x"
dist := GetKeyState("Shift", "P") ? 40 : 10
distance  := A_ThisHotkey == "*Right" or A_ThisHotkey == "*Down" ? dist : -dist

;if RL mode: update oldx1R oldx2R or ... instead
suffix := ""
if (oldrect_mode == "R" and oldR) or (oldrect_mode == "L" and oldL)
  suffix := oldrect_mode  ;R or L

;move
old%dimension%1%suffix% += distance , old%dimension%2%suffix% += distance
;show updated old rect
oldrect()
return

;shrink/expand old rect
*-::
*+::
ControlGetPos,controlx,,,, oldrectgui, SoloCrop -- ahk_class AutoHotkeyGUI
if !controlx  ;no old rect exist
  return
;update oldx1 oldx2 or oldy1 oldy2 based on move direction
dist := GetKeyState("Shift", "P") ? 40 : 10
change  := A_ThisHotkey == "*+" ? dist : -dist

;if RL mode: update oldx1R oldx2R or ... instead
suffix := ""
if (oldrect_mode == "R" and oldR) or (oldrect_mode == "L" and oldL)
  suffix := oldrect_mode  ;R or L

;shrink/expand
oldx1%suffix% -= change , oldx2%suffix% += change
oldy1%suffix% -= change , oldy2%suffix% += change
;show updated old rect
oldrect()
return


;cancel ongoing selection rectangle
*RButton::
5GuiEscape:
25GuiEscape:
cancel_rectangle:
Loop 12
  if a_index in 1,2,3,4,9,10,11,12  ;rect gui
    Gui, %A_Index%: destroy

;prevent crop
block_crop := 1
;cancel ongoing rect
SetTimer, lusr_update, Off
sleep 100
if old  ;show old rect again
  oldrect()
return


;apply old crop rectangle on this image
Space::
If !InStr( GetKeyState("Lbutton", "P") , "D" )
  If old
    goto oldcrop
return


;show next/previous image in array
WheelUp::
WheelDown::
PgDn::      ;next image
PgUp::      ;previous
If InStr ( GetKeyState("Lbutton", "P") , "D" )
  goto cancel_rectangle
if (InStr(a_thislabel, "Up") && xi == 1)               ;first image
  return
if (InStr(a_thislabel, "D")  && xi == xarr.MaxIndex()) ;last image
  return
xi := InStr(a_thislabel, "D") ? xi : xi-2 ;-2 since arrcontinue will do xi+1
goto arrcontinue
return
#IfWinActive


;user clicks on overlay preview pic
pic:
gui,7: destroy
block_crop := 0

;get vars for transform from screen relative to pic relative x/y
;pic control x/y/w/h relative to gui window top left
ControlGetPos, xpic, ypic,wpic,hpic, Static1, %xwintitle% --
;gui x/y/w/h relative to screen
WinGetPos, xwin, ywin, wwin, hwin, %xwintitle% --
;pic edges relative to screen
edgex1 := xwin + xpic    ;pic left edge relative to screen
edgey1 := ywin + ypic    ;pic   top edge
edgex2 := edgex1 + wpic  ;pic right edge
edgey2 := edgey1 + hpic  ;pic  low  edge

;remove old rect
Loop 12
  if a_index > 8
    Gui, %A_Index%: destroy

;Draw rectangle as mouse moves. Return rectangle on Lbutton release.
;returns via ByRef
;returns rect corners relative to screen
LetUserSelectRect(screenx1, screeny1, screenx2, screeny2, xcontrol)

;cancel if no rectangle was made
if (screenx1 == screenx2 or screeny1 == screeny2)
  return
if (block_crop == 1) ;draw cancelled with Space or Esc or Rbutton
  return

;rect corners relative to pic top left
picx1 := screenx1 - edgex1 , picy1 := screeny1 - edgey1
picx2 := screenx2 - edgex1 , picy2 := screeny2 - edgey1

oldcrop:

;upscale for crop
;rect corners relative to full img top left
x1 := Round(picx1/prop) , y1 := Round(picy1/prop)
x2 := Round(picx2/prop) , y2 := Round(picy2/prop)
w := x2 - x1
h := y2 - y1

;upscaled rectangle corners relative to full image
;save for showing old rect (after downscale) on next preview pic
old := 1, oldx1:= x1 , oldx2 := x2, oldy1:= y1 , oldy2 := y2

;RL mode: remember separate previous rectangle for R and L suffix files
RegExMatch(imagepath,"^.*\\\d\d\d\d(R|L)\.(?:jpg|tif|png)$", rl)
if (rl1 == "R")
  oldR := 1 , oldx1R:= x1 , oldx2R := x2 , oldy1R:= y1 , oldy2R := y2
if (rl1 == "L")
  oldL := 1, oldx1L:= x1 , oldx2L := x2 , oldy1L:= y1 , oldy2L := y2

;crop file
SplitPath, imagepath, xfile, xdir, xext, xnamenoext
;remove existing crop_ file since WIA crop cannot overwrite
FileDelete, % xdir "\crop_" xfile
;ImgCrop(target, PxLeft, PxTop, PxRight, PxBottom)
ImgCrop(imagepath, x1, y1, imgw-x2, imgh-y2)
;note: WIA crop preserves input bitdepth value

sleep 10  ;prevents freeze
goto arrcontinue  ;next image
return


6GuiClose:
5GuiClose:
25GuiClose:
ExitApp



;function: get image source dimensions and calculate gui pic dimensions
getdim(xdimfile, ByRef prop, ByRef pic_w, ByRef pic_h, Byref imgw, Byref imgh) {
  Img := ComObjCreate("WIA.ImageFile")
  Img.LoadFile(xdimfile)

  ;image dimensions
  imgw := Img.Width , imgh := Img.Height

  ;try: fit image pic to screen height
  pic_h := A_ScreenHeight-145
  ;exact proportion, used later to upscale rectangle before crop
  prop :=  pic_h/imgh
  pic_w := imgw*prop

  ;if too wide, fit pic to screen width instead (landscape image)
  pic_wmax := A_ScreenWidth-100
  if pic_w > pic_wmax
    pic_w := A_ScreenWidth-100, prop := pic_w/imgw, pic_h := imgh*prop

  ;pic dimensions
  pic_h := Round(pic_h), pic_w := Round(pic_w)
}



;function: make preview pic window
; guinum: 5 or 25
makegui(picfile, pic_h, pic_w, title, guinum, ByRef MainhWnd) {
  hhh := pic_h + 80
  www := pic_w + 80
  Gui, Margin, 40, 40
  ;hide if preload gui with next image preview
  hide := title == "hide_solo" ? 1 : 0

  ;outer parent window
  Gui,%guinum%: font, s8 cgray norm
  Gui,%guinum%: -DPIScale
  if hide
    ;todo: find way to hide taskbar icon for new window
    ;note: hide *and* create offscreen, to avoid brief window popup
        Gui,%guinum%: Show, Hide x-3000 h%hhh% w%www%,%title% -- %picfile%
  else
    Gui,%guinum%: Show, h%hhh% w%www%,%title% -- %picfile%
  Gui,%guinum%: +LastFound
  MainhWnd := WinExist()

  ;inner child pic window
  picguinum := guinum + 50   ;55 for gui 5 , 75 for gui 25
  Gui,%picguinum%: Destroy
  Gui,%picguinum%: Margin,0,0
  Gui,%picguinum%: +Owner -Caption +ToolWindow -DPIScale ;+0x800000
  Gui,%picguinum%: Add, pic,x0 y0 w%pic_w% h%pic_h% AltSubmit, %picfile%
   Gui,%picguinum%: +Parent%MainhWnd%   ;turn pic gui into a child
 if hide
  Gui,%picguinum%: Show, Hide x40 y40 w%pic_w% h%pic_h%
 else
   Gui,%picguinum%: Show, x40 y40 w%pic_w% h%pic_h%

  ;move ? help button position to lower right corner in new gui
  ControlGetPos, , ,wpic,hpic, Static1, %title% --
  xpos := wpic+70 ,   ypos := hpic+65
  static helpbutton
  GuiControlGet, helpexist, %guinum%: Enabled, helpbutton  ;exist already?
  if helpexist
    GuiControl, %guinum%: move, helpbutton, x%xpos% y%ypos%
  else
    Gui,%guinum%: Add, Text,x%xpos% y%ypos% vhelpbutton ghelpwindow, ?
}



;function: show previous crop rectangle in blue, for quick reuse
oldrect() {
  global
  xhWnd := %guinum%MainhWnd

  ;prepare old rect
  Loop 12
  if a_index > 8
  {
    Gui,%A_index%: Destroy
    Gui,%A_Index%: Margin,0,0
    Gui,%A_index%: +Owner -Caption +ToolWindow -DPIScale
    Gui,%A_index%: +Parent%xhWnd%
    Gui,%A_Index%: Color, Blue
  }

  ;use saved upscaled rectangle corners relative to full image
  ;oldx1 oldx2 oldy1 oldy2
  ;use separate old R and L rectangles if input image names end with R/L
  RegExMatch(imagepath,"^.*\\\d\d\d\d(R|L)\.(?:jpg|tif|tiff|png)$", firstrl) ;0003R.jpg
  oldrect_mode := firstrl1
  if (oldrect_mode == "R" and oldR)
    oldx1:= oldx1R , oldx2 := oldx2R , oldy1:= oldy1R , oldy2 := oldy2R
  if (oldrect_mode = "L" and oldL)
    oldx1:= oldx1L , oldx2 := oldx2L , oldy1:= oldy1L , oldy2 := oldy2L

  ;downscale old rect corners to new pic relative vars
  picx1 := round(oldx1 * prop) , picx2 := round(oldx2 * prop)
  picy1 := round(oldy1 * prop) , picy2 := round(oldy2 * prop)

  ;prevent moved rect from going outside pic in gui
  ControlGetPos, , ,wpic,hpic, Static1, %xwintitle% --
  picx1 := picx1<0 ? 0:picx1 , picy1 := picy1<0 ? 0:picy1
  picx2 := picx2>wpic ? wpic:picx2
  picy2 := picy2>hpic ? hpic:picy2


  r := 2 ;line width
  ma := 40 ;x/y margin in parent gui before pic
  oldw := picx2-picx1 , oldh := picy2-picy1  ;diff
  ;draw old rect
  Gui, 9: Show, % "NA X" picx1 + ma   " Y" picy1 + ma   " W" oldw " H" r, oldrectgui ;top rect edge
  Gui, 10:Show, % "NA X" picx1 + ma   " Y" picy2 + ma-r " W" oldw " H" r     ;bottom
  Gui, 11:Show, % "NA X" picx1 + ma   " Y" picy1 + ma   " W" r    " H" oldh  ;left
  Gui, 12:Show, % "NA X" picx2 + ma-r " Y" picy1 + ma   " W" r    " H" oldh  ;right
  WinActivate, %xwintitle% -- ahk_class AutoHotkeyGUI
}



; FUNCTION: SHOW SELECTION RECTANGLE
; first corner set from mouse start position
; other corner tracks user mouse move
; click fixates second corner and returns screen relative rect corners
; note: x1 x2 y1 y2 are local vars for rect corners relative to screen
; they are ByRef returned into screenx1 screenx2 ...

; based on LetUserSelectRect function by Lexikos
; www.autohotkey.com/community/viewtopic.php?t=49784

LetUserSelectRect(ByRef x1, ByRef y1, ByRef x2, ByRef y2, ByRef xcontrol)
{
  CoordMode, Mouse, Screen
  static r := 2  ;line thickness
  xcol := "Red"

  Loop 4 {
    Gui, %A_Index%: -Caption +ToolWindow +AlwaysOnTop -DPIScale
    Gui, %A_Index%: Color, %xcol%
  }

  if GetKeyState("Lbutton", "P") == "U"
    return ;user already released button (quick click)

  MouseGetPos, xo, yo             ;first click position
  SetTimer, lusr_update, 10      ;selection rectangle update timer
  KeyWait, LButton                ;wait for LButton release
  SetTimer, lusr_update, Off
  Loop 4
    Gui, %A_Index%: Destroy        ;Destroy selection rectangles
  return

  lusr_update:
  CoordMode, Mouse, Screen
  MouseGetPos, x, y
  ;flip x1/x2 y1/y2 if negative rect draw
  y1 := y<yo ? y:yo , y2 := y<yo ? yo:y
  x1 := x<xo ? x:xo , x2 := x<xo ? xo:x

  ;pic edges relative to screen
  global edgex1, edgey1, edgex2, edgey2
  ;bound draw at pic edges
  x1 := x1<edgex1 ? edgex1:x1 ,  x2 := x2>edgex2 ? edgex2:x2
  y1 := y1<edgey1 ? edgey1:y1 ,  y2 := y2>edgey2 ? edgey2:y2

  ;Update selection rectangle
  Gui, 1:Show, % "NA X" x1 " Y" y1 " W" x2-x1 " H" r
  Gui, 2:Show, % "NA X" x1 " Y" y2-r " W" x2-x1 " H" r
  Gui, 3:Show, % "NA X" x1 " Y" y1 " W" r " H" y2-y1
  Gui, 4:Show, % "NA X" x2-r " Y" y1 " W" r " H" y2-y1
  return
}



;function: crop image using WIA
;parameters: distance from each img edge to crop
ImgCrop(target, PxLeft, PxTop, PxRight, PxBottom) {
  SplitPath, target, name, dir
  ImgObj := WIA_LoadImage(target)
  ImgObj := WIA_CropImage(ImgObj, PxLeft, PxTop, PxRight, PxBottom)
  WIA_SaveImage(ImgObj, dir "\crop_" name)
}



; WIA image functions
; a subset of the WIA library file WIA.ahk by just me
; https://autohotkey.com/boards/viewtopic.php?t=7254
; License: The Unlicense , https://unlicense.org/

WIA_CropImage(ImgObj, PxLeft, PxTop, PxRight, PxBottom) {
   If (ComObjType(ImgObj, "Name") <> "IImageFile")
      Return False
   If !WIA_IsInteger(PxLeft, PxTop, PxRight, PxBottom) || !WIA_IsPositive(PxLeft, PxTop, PxRight, PxBottom)
      Return False
   If ((ImgObj.Width - PxLeft - PxRight) < 0) || ((ImgObj.Height - PxTop - PxBottom) < 0)
      Return False
   ImgProc := WIA_ImageProcess()
   ImgProc.Filters.Add(ImgProc.FilterInfos("Crop").FilterID)
   ImgProc.Filters[1].Properties("Left") := PxLeft
   ImgProc.Filters[1].Properties("Top") := PxTop
   ImgProc.Filters[1].Properties("Right") := PxRight
   ImgProc.Filters[1].Properties("Bottom") := PxBottom
   Return ImgProc.Apply(ImgObj)
}

WIA_LoadImage(ImgPath) {
   ImgObj := ComObjCreate("WIA.ImageFile")
   ComObjError(0)
   ImgObj.LoadFile(ImgPath)
   ComObjError(1)
   Return A_LastError ? False : ImgObj
}

WIA_SaveImage(ImgObj, ImgPath) {
   If (ComObjType(ImgObj, "Name") <> "IImageFile")
      Return False
   SplitPath, ImgPath, FileName, FileDir, FileExt
   If (ImgObj.FileExtension <> FileExt)
      Return False
   ComObjError(0)
   ImgObj.SaveFile(ImgPath)
   ComObjError(1)
   Return !A_LastError
}

WIA_ImageProcess() {
   Static ImageProcess := ComObjCreate("WIA.ImageProcess")
   While (ImageProcess.Filters.Count)
      ImageProcess.Filters.Remove(1)
   Return ImageProcess
}

WIA_IsInteger(Values*) {
   If Values.MaxIndex() = ""
      Return False
   For Each, Value In Values
      If Value Is Not Integer
         Return False
   Return True
}

WIA_IsPositive(Values*) {
   If Values.MaxIndex() = ""
      Return False
   For Each, Value In Values
      If (Value < 0)
         Return False
   Return True
}
