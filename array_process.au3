Global $array_if[100]


;~ định dạng lại mảng xoá các ô trống và các annotion
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

;~ xoá các dấu chú thích dấu sao
Func dell_annotion(ByRef $array_temp)
	$max_array = UBound($array_temp) - 1
	For $index_array = 0 To $max_array
		$array_temp[$index_array] = StringRegExpReplace($array_temp[$index_array],"\(\s*※[0-9]*\s*\)|^\s*・","")
	Next
EndFunc




Func add_requiment_If(ByRef $array_, ByRef $index_, ByRef $array_temp,$string_compare)
	For $i = 0 To UBound($array_temp)-1
		If $array_temp[$i] == $string_compare Then
			$array_[$index_] = $array_temp[$i]
			add_String_NhanvBui($array_temp,$string_compare)
			$index_ += 1
			For $ii = $i + 1 To UBound($array_temp)-1
				If StringRegExp($array_temp[$ii],".+【SWE.+】.*") And StringRegExp($array_temp[$ii],"下記、.+を行う。") = 0 Then
					Return 1
				EndIf
				$array_[$index_] = $array_temp[$ii]
				$index_ += 1
			Next
		EndIf
	Next

EndFunc


Func add_String_NhanvBui(ByRef $array_temp, $string_compare)   ;thêm chữ NhanvBui-> để bỏ qua dòng thêm vào mảng rồi
	For $i = 0 To UBound($array_temp)-1
		If $array_temp[$i] == $string_compare Then
			$array_temp[$i] = $array_temp[$i] & "NhanvBui->"
			ExitLoop
		EndIf
	Next
EndFunc


Func add__requiment_If(ByRef $array_, ByRef $index_, ByRef $array_temp,$string_compare)

	$number_if = check_if($array_,$index_,$string_compare)
	If $number_if == "<error>" Then
		$array_if[0] += 1
	Else
		Local $check_if_number = StringRegExp($number_if,"\.",1)
		$array_if[UBound($check_if_number)+1] += 1
	EndIf

	For $i = 0 To UBound($array_temp)-1
		If $array_temp[$i] == $string_compare Then
			$array_[$index_] = $array_temp[$i]
			add_String_NhanvBui($array_temp,$string_compare)
			$index_ += 1
			$array_[$index_] = StringRegExpReplace($number_if,"RUE|ALSE",".1IF")
			$index_ += 1
			$array_[$index_] = StringRegExpReplace($array_[$index_-1],"IF\(.+\)","TRUE")
			$index_ += 1
			For $ii = $i + 1 To UBound($array_temp)-1
				If StringRegExp($array_temp[$ii],".+【SWE.+】.*") And StringRegExp($array_temp[$ii],"下記、.+を行う。") = 0 Then
					ExitLoop
				EndIf
				$array_[$index_] = $array_temp[$ii]
				$index_ += 1
			Next
		EndIf
	Next

EndFunc



;~ kiểm tra requiment nằm ở if bao nhiêu
Func check_if($array,$index,$stringcompare)
	For $icheck_if_number = $index To 0 Step -1
		If StringInStr($array[$icheck_if_number],$stringcompare) And StringRegExp($array[$icheck_if_number],"下記、.+を行う。") Then
			For $ii = $icheck_if_number -1 to 0 Step -1
				If StringRegExp($array[$ii],"^※\s*.+") Then
					Return $array[$ii]
				ElseIf StringRegExp($array[$ii],".+【SWE.+】.*") And StringRegExp($array[$ii],"下記、.+を行う。") = 0 Then
					$stringcompare = $array[$ii]
					ExitLoop
				EndIf
			Next
		EndIf
	Next
	Return "<error>"
EndFunc




Func check_index_array($array_temp,$index_array,$max_array) ;kiểm tra block đầu tiên trong requiment ID
;~ 	_ArrayDisplay($array_temp,"")
	Local $array_return[1]
	Local $index_array_return = 1
	Local $index_array2
	For $index_array2 = $index_array + 1 To $max_array
		$stringtemp2 = $array_temp[$index_array2]
		If StringRegExp($stringtemp2,".+【SWE.+】.+") And StringRegExp($stringtemp2,"下記、.+を行う。") = 0 Then
			ExitLoop
		ElseIf StringRegExp($stringtemp2,"^\s*[0-9]+\s*$") Then
			If StringRegExp($array_temp[$index_array2+1],"^\s*-\s*$") Then
				For $i = $index_array2+2 To $max_array
					If StringRegExp($array_temp[$i],".+【SWE.+】.+") And StringRegExp($array_temp[$i],"下記、.+を行う。") = 0 Then
						ExitLoop(2)
					EndIf
					$array_return[$index_array_return-1] = $array_temp[$i]
					$index_array_return += 1
					ReDim $array_return[$index_array_return]
				Next
			Else
				For $i = $index_array2 To $max_array
					If StringRegExp($array_temp[$i],".+【SWE.+】.+") And StringRegExp($array_temp[$i],"下記、.+を行う。") = 0 Then
						ExitLoop(2)
					EndIf
					$array_return[$index_array_return-1] = $array_temp[$i]
					$index_array_return += 1
					ReDim $array_return[$index_array_return]
				Next
			EndIf
			ExitLoop
		EndIf
	Next
;~ 	_ArrayDisplay($array_return,"con")
	Return $array_return
EndFunc





Func Gen_UT(ByRef $array, ByRef $array_UT, ByRef $index_array_UT)

	Local $block_tam
	For $index_array = 0 To UBound($array)-1
;~ 		kiểm tra nếu là requiment thì đọc hết cái block đó
		If StringRegExp($array[$index_array],".+【SWE.+】.*") And StringRegExp($array[$index_array],"下記、.+を行う。") = 0 And StringRegExp($array[$index_array],"NhanvBui->") = 0 Then
			$array_UT[$index_array_UT] = $array[$index_array]
			add_String_NhanvBui($array,$array[$index_array])
			$index_array_UT += 1
			For $index_for_while = $index_array + 1 To UBound($array)-1
				If StringRegExp($array[$index_for_while],"^\s*[0-9]+\s*$") Then
					ExitLoop
				EndIf
				$array_UT[$index_array_UT] = $array[$index_for_while]
				$index_array_UT += 1
			Next
			$block_tam = check_index_array($array,$index_array,UBound($array)-1)

			If UBound($block_tam) = 0 Then

			Else
				If StringRegExp($block_tam[0],"^\s*[0-9]+\s*$") Then
					For $oi = 0 To UBound($block_tam)-1
						If StringRegExp($block_tam[$oi],"^\s*[0-9]+\s*$") And Number($block_tam[$oi]) = 1 Then
							$array_if[0] += 1
							$array_temp_convert[$index_array_temp_convert] = "※ " & $array_if[0] & " IF(" & $block_tam[$oi+1] & ")"
							$index_array_temp_convert += 1
							$array_temp_convert[$index_array_temp_convert] = StringRegExpReplace($array_temp_convert[$index_array_temp_convert-1],"IF\(.+\)","TRUE")
							$index_array_temp_convert += 1
							Local $string_requiment_ID = ""
							For $oii = $oi+2 To UBound($block_tam)-1
								If StringRegExp($block_tam[$oii],"^\s*[0-9]+\s*$")  Then
									ExitLoop
								EndIf
								$array_temp_convert[$index_array_temp_convert] = $block_tam[$oii]
								$index_array_temp_convert += 1
								If StringRegExp($block_tam[$oii],"下記、.+を行う。") Then
									Local $string_add_tam = StringRegExp($block_tam[$oii],"下記、(.+)を行う。",1)
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
						ElseIf StringRegExp($block_tam[$oi],"^\s*[0-9]+\s*$") And Number($block_tam[$oi]) > 1 and $block_tam[$oi+1] <> "else" Then

						EndIf
					Next
				Else
					Local $string_requiment_ID = ""
					For $i_tam = 0 To UBound($block_tam)-1
						$array_temp_convert[$index_array_temp_convert] = $block_tam[$i_tam]
						$index_array_temp_convert += 1
						If StringRegExp($block_tam[$i_tam],"下記、.+を行う。") Then
							Local $string_add_tam = StringRegExp($block_tam[$i_tam],"下記、(.+)を行う。",1)
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
EndFunc








































