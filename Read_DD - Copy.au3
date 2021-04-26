#include <Excel.au3>
#include <File.au3>
#include <Array.au3>
#include <MsgBoxConstants.au3>
#include <Word.au3>
#include <Process.au3>
#include <StringConstants.au3>
#include "array_process.au3"

Local $sFileOpenDialog = FileOpenDialog("Open DD","","Word (*.docx;*.doc)")
$array_temp = Read_Export_UT($sFileOpenDialog,"ComIfc_BusOffRecovery")
;~ MsgBox(0,0,"Complete")
format_array($array_temp)




Local $array_temp_convert[5000]
$index_array_temp_convert = 0
dell_annotion($array_temp)

_ArrayDisplay($array_temp)











Func Read_Export_UT($_sFileOpenDialog,$name_Func)
	Local $sFileOpenDialog = $_sFileOpenDialog
	_RunDos('taskkill /F /IM "WINWORD*"')
	Local $oarray_func[1][2]
	Local $index_Row = 1
	Local $Name_save = StringRegExp($sFileOpenDialog,"\((.+)\)",1)
	Local $oWord = _Word_Create(False)
	Local $oDoc = _Word_DocOpen($oWord, $sFileOpenDialog)
	If @error Then Exit _Word_Quit($oWord)
	$oDoc.Revisions.AcceptAll
	For $otable in $oDoc.Tables
		If StringInStr($otable.Range.Cells(1).Range.Text,"関数名称") Then
			$string_name_Func = $otable.Range.Cells(2).Range.Text
			$string_name_Func = StringReplace($string_name_Func,@CR,"")
			$string_name_Func = StringReplace($string_name_Func,"","")
			If $string_name_Func == $name_Func Then
				For $cell in $otable.Range.Cells
					$string_cell_tables = StringReplace($cell.range.text,"","")
					If $cell.tables.count > 0 And StringRegExp($string_cell_tables,"【SWE_.+】") > 0 Then
						ExitLoop(2)
					EndIf
				Next
			EndIf
		EndIf
	Next
	_Word_Quit($oWord)

	Local $array = StringSplit($string_cell_tables,@CR,2)
;~ 	_ArrayDisplay($array,"")
	Return $array
EndFunc








