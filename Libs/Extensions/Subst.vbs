' Subst.vbs
' VBScript to map local drive and renaming.
' Author Nickson Jeanmerson
' Version 0.0.1 - 26/Jun/2021
' ----------------------------------------'

Option Explicit
On Error Resume Next

Sub Include(RelativeFileName)
	Dim WshFSO, VbsFile
	Set WshFSO = WScript.CreateObject("Scripting.FileSystemObject")
	Set VbsFile = WshFSO.OpenTextFile(RelativeFileName)
	ExecuteGlobal VbsFile.ReadAll()
	VbsFile.Close
End Sub

Call Include("..\Consts.vbs")
Call Include(".\Log.vbs")
Call Include(".\Run.vbs")

Class Subst
	Private StrLetter
	Public Property Let Letter(LetterStr)
		StrLetter = LetterStr
	End Property
	Public Property Get Letter()
		Letter = StrLetter
	End Property

	Private StrPath
	Public Property Let Path(PathStr)
		StrPath = PathStr
	End Property
	Public Property Get Path()
		Path = StrPath
	End Property

	Private StrLabel
	Public Property Let Label(LabelStr)
		StrLabel = LabelStr
	End Property
	Public Property Get Label()
		Label = StrLabel
	End Property

	Private BoolDebug
	Public Property Let Debug(DebugBool)
		BoolDebug = DebugBool
	End Property
	Public Property Get Debug()
		Debug = BoolDebug
	End Property

	Private BoolPersist
	Public Property Let Persist(PersistBool)
		BoolPersist = PersistBool
	End Property
	Public Property Get Persist()
		Persist = BoolPersist
	End Property

	Private Sub Class_Initialize()
		Debug = False
		Persist = False
	End Sub
	Private Sub CheckDebug(LoggedStr)
		If Debug Then
			Call WriteLog(LoggedStr)
		End If
	End Sub

	Private Sub Persist(ChocoIsInstall)
		Dim RegEx, Match, Matches, Result, Run
		Set Run = New Run
		If ChocoIsInstall = False Then	
			Run.CMDAndWait("Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))")
		Else
			Set RegEx = New RegExp
			RegEx.Pattern = "(\d{1,3})\spackages\sinstalled."
			Set Matches = RegEx.Execute(Replace(Run.CMD("choco search psubst --local-only"), vbCRLF, " "))
			Set Match = Matches(0)
			Result = Match.SubMatches(0)
			If Result = "0" Then
				Run.CMDAndWait("choco install psubst -y")
			End If
			Set RegEx = Nothing
			Set Matches = Nothing
		End If
		Set Run = Nothing
	End Sub

	Private Sub PreInstall()
		Dim WshFSO, ObjShell, RegEx, Run
		Set Run = New Run
		Set WshFSO = WScript.CreateObject("Scripting.FileSystemObject")
		If WScript.Arguments.length = 0 Then
			Set ObjShell = WScript.CreateObject("Shell.Application")
			ObjShell.ShellExecute "wscript.exe", Chr(34) & WScript.ScriptFullName & Chr(34) & " uac", "", "runas", 1
		Else
			Set RegEx = New RegExp
			With RegEx
				Pattern = "^(?:(\d+)\.)?(?:(\d+)\.)?(\*|\d+)$"
				IgnoreCase = False
				Global = True
			End With
			If RegEx.Test(Run.CMDAndWait("choco -v")) Then
				Call Persist(True)
			Else
				Call Persist(False)
			End If
			Set RegEx = Nothing
		End If
		Set ObjShell = Nothing
		Set WshFSO = Nothing
		Set Run = Nothing
	End Sub

	Public Sub Add(Letter, Path, Label, BoolDebug, BoolPersist)
		Set Add = Me
		Debug = BoolDebug
		Persist = BoolPersist
		Dim WshShell, WshFSO, CommandLine
		Set WshShell = WScript.CreateObject("WScript.Shell")
		Set WshFSO = WScript.CreateObject("Scripting.FileSystemObject")
		If WshFSO.DriveExists(Letter & ":") = False Then
			CommandLine = "cmd.exe /c subst " & Letter & ":" & " " & Chr(34) & Path & Chr(34)
			WshShell.Run CommandLine, 0, True
			WshShell.RegWrite "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2\" & Letter & "", "_StrLabelFromReg", "REG_SZ"
			WshShell.RegWrite "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2\" & Letter & "\_StrLabelFromReg", Label, "REG_SZ"
			Call CheckDebug(CommandLine)
		End If
		Set WshShell = Nothing
		Set WshFSO = Nothing
	End Sub

	Public Sub Remove(Letter, BoolDebug, BoolPersist)
		Set Remove = Me
		Debug = BoolDebug
		Persist = BoolPersist
		Dim WshShell, WshFSO, CommandLine
		Set WshShell = WScript.CreateObject("WScript.Shell")
		Set WshFSO = WScript.CreateObject("Scripting.FileSystemObject")
		If WshFSO.DriveExists(Letter & ":") = True Then
			CommandLine = "cmd.exe /c subst " & Letter & ":" & " /D"
			WshShell.Run CommandLine, 0, True
			Call CheckDebug(CommandLine)
		End If
		Set WshShell = Nothing
		Set WshFSO = Nothing
	End Sub

	Public Sub Create()
		Set Create = Me
		Me.Add Letter, Path, Label, Debug, Persist
	End Sub

	Public Sub Delete()
		Set Delete = Me
		Me.Remove Letter, Debug, Persist
	End Sub
End Class

' How to use: Form one
' ----------------------------------------'

Dim Instance
Set Instance = New Subst
Instance.Letter = "F"
Instance.Path = "D:/Projetos"
Instance.Label = "Projetos"
Instance.Debug = True
Instance.Persist = False
Instance.Delete
Instance.Create
Set Instance = Nothing

' How to use: Form two
' ----------------------------------------'

' Dim Instance
' Set Instance = new Subst.Remove("F", True, False)
' Set Instance = new Subst.Add("F", "D:\Projetos", "Projetos", True, False)
' Set Instance = Nothing

WScript.Quit

'taskkill /f /t /im wscript.exe