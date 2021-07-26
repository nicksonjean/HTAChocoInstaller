' Functions.vbs
' VBScript Misc Functions
' Author Nickson Jeanmerson
' Version 0.0.1 - 26/Jun/2021
' ----------------------------------------'

Option Explicit
On Error Resume Next

Function IIf( Expression, TruePart, FalsePart )
	Dim vType, bExpression
	vType = VarType(Expression)
	Select Case vType
		Case vbBoolean : bExpression = Expression 
		Case vbString : bExpression = Len(Expression) > 0
		Case vbEmpty, vbNull, vbError : bExpression = False
		Case vbObject : bExpression = Not (Expression Is Nothing)
		Case vbDate, vbDataObject : bExpression = True
		Case Else
			If vType > 8192 Then
				bExpression = True
			Else
				bExpression = False
				On Error Resume Next
				bExpression = CBool(Expression)
				On Error Goto 0
			End If
	End Select
	If bExpression Then
		If IsObject(TruePart) Then
			Set IIf = TruePart
		Else
			IIf = TruePart
		End If
	Else
		If IsObject(FalsePart) Then
			Set IIf = FalsePart
		Else
			IIf = FalsePart
		End If
	End If
End Function

Function Slice (aInput, Byval aStart, Byval aEnd)
	If IsArray(aInput) Then
		Dim i, intStep, arrReturn
		If aStart < 0 Then
			aStart = aStart + Ubound(aInput) + 1
		End If
		If aEnd < 0 Then
			aEnd = aEnd + Ubound(aInput) + 1
		End If
		Redim arrReturn(Abs(aStart - aEnd))
		If aStart > aEnd Then
			intStep = -1
		Else
			intStep = 1
		End If
		For i = aStart To aEnd Step intStep
			If Isobject(aInput(i)) Then
				Set arrReturn(Abs(i-aStart)) = aInput(i)
			Else
				arrReturn(Abs(i-aStart)) = aInput(i)
			End If
		Next
		Slice = arrReturn
	Else
		Slice = Null
	End If
End Function

Sub WriteLog(Message)
	Const FOR_APPENDING = 8
	Dim WshFSO, LogFile, PathDir
	PathDir = CURDIR & "Log.log"
	Set WshFSO = CreateObject("Scripting.FileSystemObject")
	If WshFSO.FileExists(PathDir) Then
		Set LogFile = WshFSO.OpenTextFile(PathDir, FOR_APPENDING, True, True)
	Else
		Set LogFile = WshFSO.CreateTextFile(PathDir, False, True)
	End If
	LogFile.WriteLine "[Log]" & " " & "[" & TIMESTAMP & "]" & " " & "{" & Chr(34) & "Message" & Chr(34) & ":" & Chr(34) & Message & Chr(34) & "}"
	LogFile.Close
End Sub