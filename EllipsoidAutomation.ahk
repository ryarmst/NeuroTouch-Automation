; IMPORTANT INFO ABOUT GETTING STARTED: Lines that start with a
; semicolon, such as this one, are comments.  They are not executed.

; Setup global variables ----------------------------------------------------------------------------------------
;global fileTags := Array("practice_1", "practice_1", "practice_1", "practice_2", "practice_3", "practice_4", "1b", "1c", "1af", "1a", "3d", "2a", "2b", "3bf", "2df", "3df", "3a", "1df", "2c", "3c","3af", "2af", "4a", "1d", "2d", "4af", "3b", "1b", "1c", "1af", "1a", "3d", "2a", "2b", "3bf", "2df", "3df", "3a", "1df", "2c", "3c", "3af", "2af", "4a", "1d", "2d", "4af", "3b")
global slicerDir := "C:\Users\LocalAdmin\Desktop\Study 1\Tasks\Slicer\"
global blenderDir := "C:\Users\LocalAdmin\Desktop\Study 1\Tasks\Blender\main"
global renderDir := "C:\Users\LocalAdmin\Desktop\Ellipsoid Results\Renders\"
global blenderExt := ".blend"
global slicerExt := ".mrb"
global caseCount := 1
global state = 1
; In the following line, the entire input is considered as a string literal, so spaces are fine
Run C:\Users\LocalAdmin\Desktop\Study 1\Python Scripts\runsetup.bat

; This opens/creates? the log file for writing, but this isn't needed now because the setup script above handles setting the log file to 0. The file is used 
; rather than a variable because multiple programs (Blender) need to check the value at any given time.
;LogCountFile = FileOpen("C:\tmp\results\log.txt", "w")
;MsgBox % LogCountFile
;LogCountFile.Write("0") ; 
;LogCountFile.Close()
; --------------------------------------------------------------------------------------------------------------

;Testing------------------------------------ Use this to ensure that the script is working. If a notepad window exists, it will activate it, otherwise it will run one
^!o::
IfWinExist Untitled - Notepad
	WinActivate
else
{
	Run Notepad
}
return

; Pressing escape should close the running instance of AHK, but this doesn't always work
Escape::
ExitApp
Return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Before starting, remember to calibrate the haptic device.


; ------- NEW CASE -------
; This command will open the required slicer and blender files and at the same time run the Neurotouch.
; First, it will make sure that Blender and Slicer are both closed as well as any open images.
; When the NeuroTouch is loaded, the program will switch the active context to Slicer and make sure it's maximized.
; The user must slice through the image and then close Slicer and perform the task immediately. 
;^!z:: ;Ctrl+Alt+Z
$space::
;ifWinExist, Camera1 ;;; This checks our current state
if (state=1)
{
; Check if any slicer or blender files are still open and close them if they are.
IfWinExist Blender
	WinActivate
else 
{
	Run, open %blenderDir%%current%%blenderExt%
}
WinClose 3D Slicer
WinClose Camera1
WinClose Camera2

current := fileTags[caseCount]

Run, open %slicerDir%%caseCount%%slicerExt%
WinWaitActive, 3D Slicer
WinActivate NeuroTouch
WinWaitActive NeuroTouch
;Click 400,200
Send !{s}
sleep 5200 ; Wait for NeuroTouch to open

WinActivate, 3D Slicer ; The command searches for the name, so the full name isn't needed
WinWaitActive, 3D Slicer
WinMaximize, 3D Slicer
Send #{Up}
;WinWaitClose 3D Slicer ; Slicer must be closed or the results will not work!!!
;WinActivate NeuroTouch - Simulation 
;WinWaitClose NeuroTouch - Simulation ;This will allow us to time the difference between the components
caseCount := caseCount + 1
state = 2
}
else
{
;First, close the result dialogs
WinActivate NeuroTouch
Click 250,100
sleep 200
Click 500,225
sleep 200

WinClose 3D Slicer
IfWinExist, 3D Slicer ; Sometimes Slicer thinks changes have been made when they have not...  this forces close
{
	WinKill 3D Slicer
}
WinActivate Blender ; Brings Blender up
Sleep 100
WinMaximize Blender
Sleep 200
;Send !p 
Click 650,1035 ; This redundancy caused extra rendering even during an initial render
WinMinimize Blender
Sleep 3000

; Now time to open the images
temp := caseCount - 1
Run, open %renderDir%%temp%\Camera1.png
WinWaitActive, Camera1
Send #{Left}
Run, open %renderDir%%temp%\Camera2.png
WinWaitActive, Camera2
Send #{Right}
state = 1

}
return



; ------- SHOW RESULTS -------
; This command is performed after a successful targetting attempt. First, it makes sure Slicer is closed.
; Next, it will make Blender the active window and click the render button. It will wait to close Blender.
; After rendering, The results will be displayed, split to the left and right of the screen.
; There is no need to close these images; they will be closed by the next command.
;^!s:: ; Ctrl+Alt+S
;ifWinExist Camera1
;	return
;else 
^!g::
if (state = 2)
{
;First, close the result dialogs
WinActivate NeuroTouch
Click 250,100
sleep 200
Click 500,225
sleep 200

WinClose 3D Slicer
IfWinExist, 3D Slicer ; Sometimes Slicer thinks changes have been made when they have not...  this forces close
{
	WinKill 3D Slicer
}
WinActivate Blender ; Brings Blender up
Sleep 100
WinMaximize Blender
Sleep 200
;Send !p 
Click 650,1035 ; This redundancy caused extra rendering even during an initial render
WinMinimize Blender
Sleep 3000

; Now time to open the images
temp := caseCount - 1
Run, open %renderDir%%temp%\Camera1.png
WinWaitActive, Camera1
Send #{Left}
Run, open %renderDir%%temp%\Camera2.png
WinWaitActive, Camera2
Send #{Right}
state = 1
}
return

; ------- REPEAT CASE (ENTIRE TASK) -------
^!w::
WinActivate NeuroTouch
Click 250,100
sleep 200
Click 500,225

caseCount := caseCount - 1
WinClose 3D Slicer
WinClose Blender
WinClose Camera1
WinClose Camera2


current := fileTags[caseCount]
;currentCase = Y:\Ryan\Dropbox\EVD Simulation\Experiment Setup\Slicer Scenes\%current%.mrb
Run, open %blenderDir%%current%%blenderExt%
Run, open %slicerDir%%current%%slicerExt%
WinWaitActive, 3D Slicer
WinActivate NeuroTouch
WinWaitActive NeuroTouch
Click 400,200
sleep 5200 ;TODO - Run the NeuroTouch and also include an option for rerunning just the NeuroTouch portion

WinActivate, 3D Slicer ; The command searches for the name, so the full name isn't needed
WinWaitActive, 3D Slicer
WinMaximize, 3D Slicer
Send #{Up}
caseCount := caseCount + 1
return

;;;;;; TRY THIS:: WinWaitCLose on the NeuroTouch - Simulation and when it's closed, then proceed with the results - failures must repeat the entire case


; ------- REPEAT CASE (JUST TARGETTING) -------
^!t::
WinActivate NeuroTouch
Click 250,100
sleep 200
Click 500,225


WinClose 3D Slicer
WinActivate NeuroTouch
WinWaitActive NeuroTouch

return



; -------------- TESTING --------------
^!c::
WinGet, active_id, ID, A
MsgBox %active_id%
sleep 1000
WinMaximize, %active_id%
return

^!d::
SetTitleMatchMode, Fast
WinClose, Camera
return

