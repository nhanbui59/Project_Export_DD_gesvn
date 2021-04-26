#include <Excel.au3>
#include <File.au3>
#include <Array.au3>
#include <MsgBoxConstants.au3>
#include <Word.au3>
#include <Process.au3>
#include <StringConstants.au3>
#include "array_UDF.au3"

Local $sFileOpenDialog = FileOpenDialog("Open DD","","Word (*.docx;*.doc)")
$array_temp = Read_Export_UT($sFileOpenDialog,"ComIfc_BusOffRecovery")
;~ MsgBox(0,0,"Complete")
format_array($array_temp)
;~ _ArrayDisplay($array_temp,"")
;~ Local $oExcel = _Excel_Open(False)
;~ $oWorkbook = _Excel_BookNew($oExcel, 1)
;~ _Excel_RangeWrite($oWorkbook, $oWorkbook.Worksheets(1), $array_temp, "A1")
;~ _Excel_BookSaveAs ($oWorkbook, @ScriptDir & "\" & "xx-xx.xlsx", Default, True)
;~ _Excel_Close($oExcel)
;~ Protect_Calc_LimitRate_VCU_DCU_Idc.xlsx        tesst cais nayf nua



Local $array_temp_convert[5000]
$index_array_temp_convert = 0




$max_array = UBound($array_temp) - 1
;~ xoá các annotion và các dấu chấm đầu chuỗi
For $index_array = 0 To $max_array
	$array_temp[$index_array] = StringRegExpReplace($array_temp[$index_array],"\(\s*※[0-9]*\s*\)|^\s*・","")
Next
;~ _ArrayDisplay($array_temp,"")

Local $array_tamp
For $index_array = 0 To $max_array
	$stringtemp = $array_temp[$index_array]
	If StringRegExp($stringtemp,".+【SWE.+】.*") And StringRegExp($stringtemp,"下記、.+を行う。") = 0 And StringRegExp($stringtemp,"NhanvBui->") = 0 Then
		$array_temp_convert[$index_array_temp_convert] = $stringtemp
		add_String_NhanvBui($array_temp,$stringtemp)
		$index_array_temp_convert += 1
		For $index_for_while = $index_array + 1 To $max_array
			If StringRegExp($array_temp[$index_for_while],"^\s*[0-9]+\s*$") Then
				ExitLoop
			EndIf
			$array_temp_convert[$index_array_temp_convert] = $array_temp[$index_for_while]
			add_String_NhanvBui($array_temp,$array_temp[$index_for_while])
			$index_array_temp_convert += 1
		Next
		$array_tamp = check_index_array($array_temp,$index_array,$max_array)
		If UBound($array_tamp) = 0 Then

		Else
			If StringRegExp($array_tamp[0],"^\s*[0-9]+\s*$") Then
				For $oi = 0 To UBound($array_tamp)-1
					If StringRegExp($array_tamp[$oi],"^\s*[0-9]+\s*$") And Number($array_tamp[$oi]) = 1 Then
						$array_if[0] += 1
						$array_temp_convert[$index_array_temp_convert] = "※ " & $array_if[0] & " IF(" & $array_tamp[$oi+1] & ")"
						$index_array_temp_convert += 1
						$array_temp_convert[$index_array_temp_convert] = StringRegExpReplace($array_temp_convert[$index_array_temp_convert-1],"IF\(.+\)","TRUE")
						$index_array_temp_convert += 1
						Local $string_requiment_ID = ""
						For $oii = $oi+2 To UBound($array_tamp)-1
							If StringRegExp($array_tamp[$oii],"^\s*[0-9]+\s*$")  Then
								ExitLoop
							EndIf
							$array_temp_convert[$index_array_temp_convert] = $array_tamp[$oii]
							$index_array_temp_convert += 1
							If StringRegExp($array_tamp[$oii],"下記、.+を行う。") Then
								Local $string_add_tam = StringRegExp($array_tamp[$oii],"下記、(.+)を行う。",1)
								$string_add_tam[0] = StringRegExpReplace($string_add_tam[0],"「|」","")
								$string_add_tam[0] = StringStripWS($string_add_tam[0], $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES)
								$string_requiment_ID &= $string_add_tam[0] & "Nhan-Dong<>"
							EndIf
						Next
						If StringLen($string_requiment_ID) <> 0 Then
							Local $oarray_requiment_ID = StringSplit($string_requiment_ID,"Nhan-Dong<>",$STR_ENTIRESPLIT)
							For $if = 1 To $oarray_requiment_ID[0]
								If StringLen($oarray_requiment_ID[$if]) <= 0 Then
									ContinueLoop
								EndIf

							Next
						EndIf
					ElseIf StringRegExp($array_tamp[$oi],"^\s*[0-9]+\s*$") And Number($array_tamp[$oi]) > 1 and $array_tamp[$oi+1] <> "else" Then

					EndIf
				Next
			Else
				Local $string_requiment_ID = ""
				For $i_tam = 0 To UBound($array_tamp)-1
					$array_temp_convert[$index_array_temp_convert] = $array_tamp[$i_tam]
					$index_array_temp_convert += 1
					If StringRegExp($array_tamp[$i_tam],"下記、.+を行う。") Then
						Local $string_add_tam = StringRegExp($array_tamp[$i_tam],"下記、(.+)を行う。",1)
						$string_add_tam[0] = StringRegExpReplace($string_add_tam[0],"「|」","")
						$string_add_tam[0] = StringStripWS($string_add_tam[0], $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES)
						$string_requiment_ID &= $string_add_tam[0] & "Nhan-Dong<>"
					EndIf
				Next
				If StringLen($string_requiment_ID) <> 0 Then
					Local $oarray_requiment_ID = StringSplit($string_requiment_ID,"Nhan-Dong<>",$STR_ENTIRESPLIT)
					add_requiment_If($array_temp_convert,$index_array_temp_convert,$array_temp,$oarray_requiment_ID[1])
				EndIf
			EndIf
		EndIf

	EndIf
Next



_ArrayDisplay($array_temp,"")
_ArrayDisplay($array_temp_convert,"Con")








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


Func format_array(ByRef $array)
	$max_array = UBound($array)
	Local $i = 0
	While $i < $max_array
		If $array[$i] == "優先順位" Or $array[$i] == "実行条件" Or $array[$i] == "処理" Or StringRegExp($array[$i],"^\(※\d{0,10}\)") Or StringLen($array[$i]) = 0 or StringRegExp($array[$i],"^\s*$") Then
			$max_array = dell_array($array,$i)
			$i -= 1
		EndIf
		$i += 1
	WEnd
EndFunc

Func dell_array(ByRef $array,$location_dell)
	$index_array = UBound($array)
	For $i = $location_dell To $index_array - 2
		$array[$i] = $array[$i + 1]
	Next
	ReDim $array[$index_array-1]
	Return UBound($array)-2
EndFunc





