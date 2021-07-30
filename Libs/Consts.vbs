' Log.vbs
' VBScript for add a log file
' Author Nickson Jeanmerson
' Version 0.0.1 - 26/Jun/2021
' ----------------------------------------'

Option Explicit
On Error Resume Next

Function CurrentTimeStamp()
	Dim DateTime 
	DateTime = Now
	CurrentTimeStamp = Year(DateTime) & "-" & _
	Right("0" & Month(DateTime),2)  & "-" & _
	Right("0" & Day(DateTime),2)  & " " & _
	Right("0" & Hour(DateTime),2) & ":" & _
	Right("0" & Minute(DateTime),2) & ":" & _
	Right("0" & Second(DateTime),2) 
End Function

Function CurrentFile()
	' CurrentFile = WScript.ScriptFullName
	Dim WshShell, CurPath, WshFSO, ObjFolder, ObjFiles, IdxFile, ArrayFiles
	set WshShell = CreateObject("WScript.Shell")
	CurPath = WshShell.Currentdirectory
	Set WshFSO = CreateObject("Scripting.FileSystemObject")
	Set ObjFolder = WshFSO.GetFolder(CurPath)  
	Set ObjFiles = ObjFolder.Files
	Set ArrayFiles = CreateObject("System.Collections.ArrayList")
	For each IdxFile In ObjFiles  
		ArrayFiles.Add WshFSO.GetAbsolutePathName(IdxFile)
		Next
	CurrentFile = ArrayFiles(0)	
End Function

Function CurrentDirectory()
	' CurrentDirectory = Replace(WScript.ScriptFullName, WScript.ScriptName,"")
	CurrentDirectory = CreateObject("Scripting.FileSystemObject").GetAbsolutePathName(".") & "\"
End Function

Dim CURFILE : CURFILE = GetRef("CurrentFile")
Dim CURDIR : CURDIR = GetRef("CurrentDirectory")
Dim TIMESTAMP : TIMESTAMP = GetRef("CurrentTimeStamp")

Wscript.Echo CURFILE
Wscript.Echo CURDIR
Wscript.Echo TIMESTAMP