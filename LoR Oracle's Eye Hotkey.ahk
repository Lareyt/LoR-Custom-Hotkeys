#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#InstallKeybdHook
#InstallMouseHook
#SingleInstance, Force

CoordMode, Mouse, Client
SetDefaultMouseSpeed, 0
SetDefaults()
Return

SetDefaults()
{
	global

	blnAlwaysGrabData := True ; Set this to true to allow changing the resolution / window size without restarting the script, has a very minor performance impact though

	blnOraclesEyeActive := False
	blnLoRWindowDataGrabbed := False

	intLoRWindowWidth := 0
	intLoRWindowHeight := 0
	fltLoRWindowAspectRatio := 0

	fltOraclesEyeXPosBaseScalar = 0.1
	fltOraclesEyeMaxAspectRatioScalar = 0.66
	fltOraclesEyeXPixelScalar = 0.5

	intOraclesEyeXPos := 0
	intOraclesEyeYPos := 0

	intUserMouseXPos := 0
	intUserMouseYPos := 0

	intResetPosXPos := 0
	intResetPosYPos := 0

	Gosub GrabLoRWindowData
}

#IfWinActive, ahk_exe LoR.exe
$Tab::
$MButton::
$XButton1::
$XButton2::
	If Not blnOraclesEyeActive
	{
		If (blnAlwaysGrabData Or Not blnLoRWindowDataGrabbed)
			Gosub GrabLoRWindowData

		MouseGetPos, intUserMouseXPos, intUserMouseYPos
		
		MouseMove, intOraclesEyeXPos, intOraclesEyeYPos
		blnOraclesEyeActive := True
	}
Return

#IfWinActive, ahk_exe LoR.exe
$Tab Up::
$MButton Up::
$XButton1 Up::
$XButton2 Up::
	If (intUserMouseXPos < 0 Or intUserMouseXPos > intLoRWindowWidth Or intUserMouseYPos < 0 Or intUserMouseYPos > intLoRWindowHeight)
	{
		MouseMove, intResetPosXPos, intResetPosYPos
		Sleep, 30
	}
	MouseMove, intUserMouseXPos, intUserMouseYPos
	blnOraclesEyeActive := False
Return

GrabLoRWindowData:
	If WinActive("ahk_exe LoR.exe")
	{
		GetClientSize(WinExist(ahk_exe LoR.exe), intLoRWindowWidth, intLoRWindowHeight)

		fltLoRWindowAspectRatio := intLoRWindowHeight / intLoRWindowWidth
		intOraclesEyeXPos := Round(intLoRWindowHeight / Max(fltOraclesEyeMaxAspectRatioScalar, fltLoRWindowAspectRatio) * fltOraclesEyeXPosBaseScalar + Max(0, (intLoRWindowWidth - intLoRWindowHeight / fltOraclesEyeMaxAspectRatioScalar) * fltOraclesEyeXPixelScalar))
		intOraclesEyeYPos := Round(intLoRWindowHeight / 2)

		intResetPosXPos := Round(intLoRWindowWidth / 2)
		intResetPosYPos := intOraclesEyeYPos

		blnLoRWindowDataGrabbed := True
	}
	Else
	{
		blnLoRWindowDataGrabbed := False
	}
Return

GetClientSize(strWindowTitle, ByRef intWindowWidth := "", ByRef intWindowHeight := "")
{
	VarSetCapacity(rect, 16)
	DllCall("GetClientRect", "ptr", strWindowTitle, "ptr", &rect)
	intWindowWidth := NumGet(rect, 8, "int")
	intWindowHeight := NumGet(rect, 12, "int")
}
