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
	blnResetMouseAfterUserMove := False ; Set this to true to always reset the mouse position even after it has been significantly moved

	blnOraclesEyeHotkeyTriggered := False
	blnLoRWindowDataGrabbed := False

	intPause := 30

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

	blnMouseMoveByUser := False
	intTempUserMouseXPos := 0
	intTempUserMouseYPos := 0
	intMousePosResetAllowance := 10

	intResetPosXPos := 0
	intResetPosYPos := 0

	Gosub GrabLoRWindowData
}

GrabLoRWindowData:
	If WinActive(ahk_exe LoR.exe)
	{
		GetClientSize(WinActive(ahk_exe LoR.exe), intLoRWindowWidth, intLoRWindowHeight)
		
		If (blnOraclesEyeHotkeyTriggered Or Not blnLoRWindowDataGrabbed)
		{
			fltLoRWindowAspectRatio := intLoRWindowHeight / intLoRWindowWidth
			intOraclesEyeXPos := Round(intLoRWindowHeight / Max(fltOraclesEyeMaxAspectRatioScalar, fltLoRWindowAspectRatio) * fltOraclesEyeXPosBaseScalar + Max(0, (intLoRWindowWidth - intLoRWindowHeight / fltOraclesEyeMaxAspectRatioScalar) * fltOraclesEyeXPixelScalar))
			intOraclesEyeYPos := Round(intLoRWindowHeight / 2)

			intResetPosXPos := Round(intLoRWindowWidth / 2)
			intResetPosYPos := intOraclesEyeYPos
			
		}

		blnLoRWindowDataGrabbed := True
	}
	Else
		blnLoRWindowDataGrabbed := False
Return

GetClientSize(hexHWND, ByRef intWindowWidth := 0, ByRef intWindowHeight := 0)
{
	VarSetCapacity(rect, 16)
	DllCall("GetClientRect", "ptr", hexHWND, "ptr", &rect)
	intWindowWidth := NumGet(rect, 8, "int")
	intWindowHeight := NumGet(rect, 12, "int")
}

#IfWinActive, ahk_exe LoR.exe
$Tab::
$MButton::
	If Not blnOraclesEyeHotkeyTriggered
	{
		blnOraclesEyeHotkeyTriggered := True
		If (blnAlwaysGrabData Or Not blnLoRWindowDataGrabbed)
			Gosub GrabLoRWindowData
		MouseGetPos, intUserMouseXPos, intUserMouseYPos
		MouseMove, intOraclesEyeXPos, intOraclesEyeYPos
	}
Return

$Tab Up::
$MButton Up::
	If blnOraclesEyeHotkeyTriggered
	{
		blnOraclesEyeHotkeyTriggered := False
		MouseGetPos, intTempUserMouseXPos, intTempUserMouseYPos
		blnMouseMoveByUser := intTempUserMouseXPos - intMousePosResetAllowance > intOraclesEyeXPos Or intTempUserMouseXPos + intMousePosResetAllowance < intOraclesEyeXPos Or intTempUserMouseYPos - intMousePosResetAllowance > intOraclesEyeYPos Or intTempUserMouseYPos + intMousePosResetAllowance < intOraclesEyeYPos
		
		If (blnResetMouseAfterUserMove Or Not blnMouseMoveByUser)
		{
			If (intUserMouseXPos < 0 Or intUserMouseXPos > intLoRWindowWidth Or intUserMouseYPos < 0 Or intUserMouseYPos > intLoRWindowHeight)
			{
				MouseMove, intResetPosXPos, intResetPosYPos
				Sleep, intPause
			}
			MouseMove, intUserMouseXPos, intUserMouseYPos
		}
	}
Return

$XButton1::Send {Space}
$XButton2::Send a

#IfWinActive
!+^r::
	Reload
	Sleep, 1000 ; If successful, the reload will close this instance during the Sleep, so the line below will never be reached.
	MsgBox, 0x34, Reload failed!, The script could not be reloaded. Would you like to open it for editing?
	IfMsgBox, Yes, Edit
Return
