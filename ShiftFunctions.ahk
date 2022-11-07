﻿#SingleInstance force 			; Only one instance of this script may run at a time!
#NoEnv  						; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  	     				; Enable warnings to assist with detecting common errors.
#Requires AutoHotkey v1.1.33+ 	; Displays an error and quits if a version requirement is not met.
#KeyHistory, 100

 AppVersion				:= "1.0.2"
;@Ahk2Exe-Let vAppVersion=%A_PriorLine~U)^(.+"){1}(.+)".*$~$2% ; Keep these lines together
;Overrides the custom EXE icon used for compilation
;@Ahk2Exe-SetCopyright GNU GPL 3.x
;@Ahk2Exe-SetDescription Shift pushed and released after some letters replaces them with Polish diacritics.
;@Ahk2Exe-SetProductName Original script name: %A_ScriptName%
;@Ahk2Exe-Set OriginalScriptlocation, https://github.com/mslonik/ShiftDiacritic
;@Ahk2Exe-SetCompanyName  http://mslonik.pl
;@Ahk2Exe-SetFileVersion %U_vAppVersion%
,	ApplicationName     := "ShiftDiacritic"	;global variable
,	v_Char 			:= ""	;global variable
,	f_ShiftPressed 	:= false	;global variable
,	f_ControlPressed	:= false	;global variable
,	f_AltPressed		:= false	;global variable
,	f_WinPressed		:= false	;global variable
,	f_AnyOtherKey		:= false	;global variable
,	f_Capital			:= true	;global variable
,	f_Diacritics		:= true	;global variable

SetBatchLines, 	-1				; Never sleep (i.e. have the script run at maximum speed).
SendMode,			Input			; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir, 	%A_ScriptDir%		; Ensures a consistent starting directory.
StringCaseSense, 	On				;for Switch in F_OnKeyUp()

Menu, Tray, Icon, imageres.dll, 123     ; this line will turn the H icon into a small red a letter-looking thing.
F_InitiateInputHook()
;end initialization section

; - - - - - - - - - - - - - - GLOBAL HOTSTRINGS: BEGINNING- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:*:sdhelp/::
	MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . "information", % "Application hotstrings" . "." . A_Space . "All of them are ""immediate execute"" (*)" . "`n"
		. "and active anywhere in operating system (any window)"						. "`n"
		. "`n`n"
		. "sdhelp/" . A_Tab . A_Tab . 	"shows this message"					 	. "`n"
		. "sdrestart/" . A_Tab . 		"reload" 	. A_Space . "application"		 	. "`n"
		. "sdreload/" . A_Tab . 		 	"reload" 	. A_Space . "application"		 	. "`n"
		. "sdquit/" . A_Tab . A_Tab .		"exit" 	. A_Space . "application"			. "`n"
		. "sdexit/" . A_Tab . A_Tab .		"exit" 	. A_Space . "application"			. "`n"
		. "sdswitch/" . A_Tab . A_Tab .	"toggle"	. A_Space . "shift standalone"		. "`n"
		. "sdtoggle/" . A_Tab . 			"toggle"	. A_Space . "shift standalone"		. "`n"
		. "sdstatus/" . A_Tab . A_Tab .	"status"	. A_Space . "application"			. "`n"
		. "sdstate/" . A_Tab . A_Tab .	"status"	. A_Space . "application"			. "`n"
		. "sdenable/" . A_Tab . 			"enable"	. A_Space . "shift standalone"		. "`n"
		. "sddisable/" . A_Tab . 		"disable"	. A_Space . "shift standalone"		. "`n"
		. "sfddisable/" . A_Tab .		"disable" . A_Space . "shift diacritic"			. "`n"
		. "sfdenable/" . A_Tab .			"enable"	. A_Space . "shift diacritic"			. "`n"
		. "sfcdisable/" . A_Tab .		"disable"	. A_Space . "shift capital"			. "`n"
		. "sfcenable/" . A_Tab .			"enable"	. A_Space . "shift capital"
return

:*:sdreload/::
:*:sdrestart/::     ;global hotstring
	MsgBox, 64, % A_ScriptName, % A_ScriptName . A_Space . "will be restarted!"
	reload
return

:*:sdquit/::
:*:sdexit/::
	ExitApp, 0
return

:*:sdswitch/::
:*:sdtoggle/::
	if (v_InputH.InProgress)
	{
		v_InputH.Stop()
		MsgBox, 64, % A_ScriptName, % A_ScriptName . A_Space . "is DISABLED."
	}
	else
	{
		v_InputH.Start()
		MsgBox, 64, % A_ScriptName, % A_ScriptName . A_Space . "is ENABLED."
	}
return

:*:sdstatus/::
:*:sdstate/::
	MsgBox, 64, % A_ScriptName, % "Current status is" . A_Space . (v_InputH.InProgress ? "ENABLED" : "DISABLED")
return

:*:sdenable/::
	v_InputH.Start()
	MsgBox, 64, % A_ScriptName, % A_ScriptName . A_Space . "is ENABLED."
return

:*:sddisable/::
	v_InputH.Stop()
	MsgBox, 64, % A_ScriptName, % A_ScriptName . A_Space . "is DISABLED."
return

:*:sfddisable/::
	f_Diacritics := false
	MsgBox, 64, % A_ScriptName, % "Shift diacritics is DISABLED."
return

:*:sfdenable/::
	f_Diacritics := true
	MsgBox, 64, % A_ScriptName, % "Shift diacritics is ENABLED."
return

:*:sfcdisable/::
	f_Capital := false
	MsgBox, 64, % A_ScriptName, % "Shift capital is DISABLED."
return

:*:sfcenable/::
	f_Capital := true
	MsgBox, 64, % A_ScriptName, % "Shift capital is ENABLED."
return
; - - - - - - - - - - - - - - GLOBAL HOTSTRINGS: END- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; - - - - - - - - - - - - - - DEFINITIONS OF FUNCTIONS: BEGINNING- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_InitiateInputHook()	;why InputHook: to process triggerstring tips.
{
	global	;assume-global mode of operation
	v_InputH 			:= InputHook("V I2 L0")	;I3 to not feed back this script; V to show pressed keys; L0 as only last char is analysed
,	v_InputH.OnChar 	:= Func("F_OneCharPressed")
,	v_InputH.OnKeyDown	:= Func("F_OnKeyDown")
,	v_InputH.OnKeyUp 	:= Func("F_OnKeyUp")
	v_InputH.KeyOpt("{All}", "N")
	v_InputH.Start()
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_OnKeyDown(ih, VK, SC)
{
	global	;assume-global mode of operation
	local	WhatWasDown := GetKeyName(Format("vk{:x}sc{:x}", VK, SC))

	; OutputDebug, % A_ThisFunc . A_Space . "B" . "`n"
	Switch WhatWasDown
	{
		Case "LShift", "RShift":
			f_ShiftPressed 	:= true
		Case "LControl", "RControl":
			f_ControlPressed 	:= true
		Case "LAlt", "RAlt":
			f_AltPressed 		:= true
		Case "LWin", "RWin":
			f_WinPressed 		:= true
		Default:
			f_AnyOtherKey		:= true
	}
	; OutputDebug, % "WWD:" . WhatWasDown . A_Space . "S:" . f_ShiftPressed . A_Space . "C:" . f_ControlPressed . A_Space . "A:" . f_AltPressed . A_Space . "W:" . f_WinPressed . A_Space . "O:" . f_AnyOtherKey . "`n"
	; OutputDebug, % A_ThisFunc . A_Space . "E" . "`n"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_OnKeyUp(ih, VK, SC)
{
	global	;assume-global mode of operation
	local	WhatWasUp := GetKeyName(Format("vk{:x}sc{:x}", VK, SC))

	; OutputDebug, % A_ThisFunc . A_Space . "B" . "`n"
	; OutputDebug, % "WWUb:" . WhatWasUp . A_Space "v_Char:" . v_Char . "S:" . f_ShiftPressed . A_Space . "C:" . f_ControlPressed . A_Space . "A:" . f_AltPressed . A_Space . "W:" . f_WinPressed . A_Space . "O:" . f_AnyOtherKey . "`n"
	if	(f_Diacritics)
		and ((WhatWasUp = "LShift") or (WhatWasUp = "RShift"))
		and (f_ShiftPressed) and !(f_ControlPressed) and !(f_AltPressed) and !(f_WinPressed) and !(f_AnyOtherKey)
			Diacritics()
	else
	{
		f_ControlPressed 	:= false
,		f_AltPressed		:= false
,		f_WinPressed		:= false
,		f_AnyOtherKey		:= false
	}
	; OutputDebug, % "WWUe:" . WhatWasUp . A_Space . "S:" . f_ShiftPressed . A_Space . "C:" . f_ControlPressed . A_Space . "A:" . f_AltPressed . A_Space . "W:" . f_WinPressed . A_Space . "O:" . f_AnyOtherKey . "`n"
	; OutputDebug, % A_ThisFunc . A_Space . "E" . "`n"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Diacritics()
{
	global	;assume-global mode of operation

	; OutputDebug, % A_ThisFunc . A_Space . "B" . "`n"
	Switch v_Char
	{
		Case "a":		DiacriticOutput("ą")
		Case "A":		DiacriticOutput("Ą")
		Case "c": 	DiacriticOutput("ć")
		Case "C": 	DiacriticOutput("Ć")
		Case "e": 	DiacriticOutput("ę")
		Case "E": 	DiacriticOutput("Ę")
		Case "l": 	DiacriticOutput("ł")
		Case "L": 	DiacriticOutput("Ł")
		Case "n": 	DiacriticOutput("ń")
		Case "N": 	DiacriticOutput("Ń")
		Case "o": 	DiacriticOutput("ó")
		Case "O": 	DiacriticOutput("Ó")
		Case "s": 	DiacriticOutput("ś")
		Case "S": 	DiacriticOutput("Ś")
		Case "x": 	DiacriticOutput("ź")
		Case "X": 	DiacriticOutput("Ź")
		Case "z": 	DiacriticOutput("ż")
		Case "Z": 	DiacriticOutput("Ż")
	}
	; OutputDebug, % A_ThisFunc . A_Space . "E" . "`n"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
DiacriticOutput(Diacritic)
{
	global	;assume-global mode of operation

	OutputDebug, % A_ThisFunc . A_Space . "B" . "`n"
	f_ShiftPressed := false
	SendLevel, 	2
	Send,		% "{BS}" . Diacritic
	SendLevel, 	0
	OutputDebug, % A_ThisFunc . A_Space . "E" . "`n"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_OneCharPressed(ih, Char)
{
	global	;assume-global mode of operation

	; OutputDebug, % A_ThisFunc . A_Space . "B" . "`n"
	f_ControlPressed 	:= false
,	f_AltPressed		:= false
,	f_WinPressed		:= false
,	f_AnyOtherKey		:= false
	; OutputDebug, % A_ThisFunc . A_Space . "Char:" . Char . A_Space . "f_ShiftPressed:" . f_ShiftPressed . "`n"
	; OutputDebug, % "Char:" . Char . "`n"
	if (f_Capital)
		and (f_ShiftPressed) and (Char) 
		and !(f_ControlPressed) and !(f_AltPressed) and !(f_WinPressed) and !(f_AnyOtherKey)
	{
		SendInput, {BS}
		Switch Char
		{
			Case "``": 	SendRaw, ~
			Case "1":		SendRaw, !
			Case "2":		SendRaw, @
			Case "3":		SendRaw, #
			Case "4":		SendRaw, $
			Case "5":		SendRaw, `%
			Case "6":		SendRaw, ^
			Case "7":		SendRaw, &
			Case "8":		SendRaw, *
			Case "9":		SendRaw, (
			Case "0":		SendRaw, )
			Case "-":		SendRaw, _
			Case "=":		SendRaw, +
			Case "[":		SendRaw, {
			Case "]":		SendRaw, }
			Case "\":		SendRaw, |
			Case ";":		SendRaw, :
			Case "'":		SendRaw, "
			Case ",":		SendRaw, <
			Case ".":		SendRaw, >
			Case "/":		SendRaw, ?
			Default:
				Char := Format("{:U}", Char)
				SendRaw, % Char
		}
	}
	f_ShiftPressed 	:= false
,	v_Char 			:= Char
	; OutputDebug, % "v_Char:" . v_Char . "`n"
	; OutputDebug, % A_ThisFunc . A_Space . "E" . "`n"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -