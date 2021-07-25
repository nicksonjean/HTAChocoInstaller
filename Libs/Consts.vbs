' Consts.vbs
' VBScript add new constansts in VBS
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
	CurrentFile = WScript.ScriptFullName
End Function

Function CurrentDirectory()
	CurrentDirectory = Replace(WScript.ScriptFullName, WScript.ScriptName,"")
End Function

Dim CURFILE : Set CURFILE = GetRef("CurrentFile")
Dim CURDIR : Set CURDIR = GetRef("CurrentDirectory")
Dim TIMESTAMP : Set TIMESTAMP = GetRef("CurrentTimeStamp")