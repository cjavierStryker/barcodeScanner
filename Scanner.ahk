#Requires AutoHotkey v2.0
#HotIf WinActive("ahk_exe EXCEL.EXE")							; Only fires if Excel is open

scanActive := false												; Declaring variables
snEnter := false

~*:: {															; Lines 7-10 detect * which is the trigger and sets the scan mode to active
global scanActive
scanActive := true

SetTimer resetDetect, 300
resetDetect() {
	scanActive := false
	return
}
}


~Enter:: {
global scanActive
global snEnter

	if (scanActive = true) {									; If scanActive has been triggered
		scanActive := false										; Reset scanActive
		oldClipboard := A_Clipboard								; Capture old clipboard
		A_Clipboard := ""										; Clear clipboard in preparation for capture

		Send "{Up}"												; Go up one cell
		sleep 15
		Send "^c"												; Copy cell contents for analyzation
		ClipWait 2												; Wait up to 2s for clipboard to update
		SetTimer resetClipboard, -1000							; Wait 1s async before reseting clipboard to old clipboard
		if(A_Clipboard ~= "UNDO") {								; Use "else if(A_Clipboard ~= XXX) {" to create a new function, where XXX is function name on the barcode
			goto ScanUndo										; Use "goto YYY" where YYY is the function name to go to (see next section)
		} else if(A_Clipboard ~= "SERIAL#") {
			goto SerialNum
		} else {												; If no command is identified, go back and unhighlight so that normal usage can continue
			Send "{Down}{Escape}"
			return
		}
	}
	if (snEnter = true) {										; If enter is pressed after a SerialNum command, go one to the left as well to re-align with asset tag column
		Send "{Left}"
		snEnter := false
	}
	resetClipboard() {											; Resetting clipboard back to old contents
		A_Clipboard := oldClipboard
	}
return

; ------------- ENTER FUNCTIONS HERE FOR SCANNING -----------------
ScanUndo:														; The function that is called from the goto command (YYY)
	Send "{Delete}{Up}{Delete}"									; Delete command cell and cell above, functionally a delete command
	scanActive := false											; Backup reset of scanActive
	return

SerialNum:														; Function for entering serial numbers of the previously scanned tag
	Send "{Delete}{Up}{Right}"									; Delete command cell and move up and to the right, where empty SN# should be
	snEnter := true												; Setting snEnter to true so that when next enter is pressed it will realign with asset tag column
	return

; -----------------------------------------------------------------
}

~Up:: {
global scanActive
	scanActive := false
	return
}
~Down:: {
global scanActive
	scanActive := false
	return
}
~Left:: {
global scanActive
	scanActive := false
	return
}
~Right:: {
global scanActive
	scanActive := false
	return
}