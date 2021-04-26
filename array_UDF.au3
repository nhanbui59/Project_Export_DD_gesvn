Global $array_if[100]

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
