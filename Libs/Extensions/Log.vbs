' Lob.vbs
' VBScript add new constansts in VBS
' Author Nickson Jeanmerson
' Version 0.0.1 - 26/Jun/2021
' ----------------------------------------'

Option Explicit
On Error Resume Next

Sub Include(RelativeFileName)
	Dim WshFSO, VbsFile
	Set WshFSO = CreateObject("Scripting.FileSystemObject")
	Set VbsFile = WshFSO.OpenTextFile(RelativeFileName)
	ExecuteGlobal VbsFile.ReadAll()
	VbsFile.Close
End Sub

Call Include("..\Consts.vbs")

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