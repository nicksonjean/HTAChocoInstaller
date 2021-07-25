' CSV.vbs
' VBScript to read and write a CSV file.
' Author Nickson Jeanmerson
' Version 0.0.1a - 01/Jul/2021
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

Call Include("..\..\Functions.vbs")
Call Include("..\..\Consts.vbs")
Call Include("..\Log.vbs")

Class CSV
	Private ONE_DOUBLE_QUOTE
	Private TWO_DOUBLE_QUOTE

	Private BoolIgnoreFirstLine
	Public Property Let IgnoreFirstLine(IgnoreFirstLineBool)
		BoolIgnoreFirstLine = IgnoreFirstLineBool
	End Property
	Public Property Get IgnoreFirstLine()
		IgnoreFirstLine = BoolIgnoreFirstLine
	End Property

	Private StrLineSeparator
	Public Property Let LineSeparator(LineSeparatorStr)
		StrLineSeparator = LineSeparatorStr
	End Property
	Public Property Get LineSeparator()
		LineSeparator = StrLineSeparator
	End Property

	Private StrColumnSeparator
	Public Property Let ColumnSeparator(ColumnSeparatorStr)
		StrColumnSeparator = ColumnSeparatorStr
	End Property
	Public Property Get ColumnSeparator()
		ColumnSeparator = StrColumnSeparator
	End Property

	Private StrFilePath
	Public Property Let FilePath(FilePathStr)
		StrFilePath = FilePathStr
	End Property
	Public Property Get FilePath()
		FilePath = StrFilePath
	End Property

	Private BoolDebug
	Public Property Let Debug(DebugBool)
		BoolDebug = DebugBool
	End Property
	Public Property Get Debug()
		Debug = BoolDebug
	End Property

	Private Sub Class_Initialize()
		ONE_DOUBLE_QUOTE = """"
		TWO_DOUBLE_QUOTE = """"""
		Debug = False
		IgnoreFirstLine = False
		LineSeparator = vbCrLf
		ColumnSeparator = ","
	End Sub

	Private Sub CheckDebug(LoggedStr)
		If Debug Then
			Call WriteLog(LoggedStr)
		End If
	End Sub

	Public Function ToWrite()

	End Function

	Public Function Write()

	End Function

	Public Function ToRead(IgnoreFirstLine, LineSeparator, ColumnSeparator, FilePath, BoolDebug)
		Dim FSO, DCT, TextStream, TextLine, TextColumn, ArrayList, ArrayLine, EachLine, EachColumn, Line, Column
		Debug = BoolDebug
		Set DCT = WScript.CreateObject("Scripting.Dictionary")
		Set FSO = WScript.CreateObject("Scripting.FileSystemObject")
		If (FSO.FileExists(FilePath)) Then
			Set TextStream = FSO.OpenTextFile(FilePath, 1, False, 0)
			TextLine = Split(TextStream.ReadAll, LineSeparator)
			ArrayList = Array()
			EachLine = 0
			For Each Line In TextLine
				If EachLine >= IIf(IgnoreFirstLine, 1, 0) AND Trim(Line) <> "" Then
					TextColumn = Split(Line, ColumnSeparator)
					EachColumn = 0
					For Each Column In TextColumn
						ReDim Preserve ArrayList(EachColumn)
						If (Left(Column, 1) = ONE_DOUBLE_QUOTE) Then
							Column = Replace(Mid(Column, 2, Len(Column) - 2), ONE_DOUBLE_QUOTE, TWO_DOUBLE_QUOTE)
						Else
							Column = Column
						End If
						ArrayList(EachColumn) = Column
						EachColumn = EachColumn + 1
					Next
					If DCT.Exists(EachLine) Then
						DCT.Item(EachLine).Add(ArrayList)
					Else
						DCT.Add EachLine, ArrayList
					End If
					Call CheckDebug(Join(ArrayList, ColumnSeparator))
				End If
				EachLine = EachLine + 1
			Next
			TextStream.Close()
			Set ToRead = DCT
		End If
	End Function

	Public Function Read()
		Set Read = Me
		Set Read = Me.ToRead(IgnoreFirstLine, LineSeparator, ColumnSeparator, FilePath, Debug)
	End Function

End Class

' How to use: Form one
' ----------------------------------------'

Dim Instance, ParsedCSV, CSVObj, Line
Set Instance = New CSV
Instance.IgnoreFirstLine = True
Instance.LineSeparator = vbCrLf
Instance.ColumnSeparator = ","
Instance.FilePath = "..\..\..\Assets\Subst.csv"
Instance.Debug = True
Set ParsedCSV = Instance.Read
Set Instance = Nothing

' How to use: Form two
' ----------------------------------------'

' Dim ParsedCSV, CSVObj, Line
' Set ParsedCSV = new CSV.ToRead(True, vbCrLf, ",", "..\..\..\Assets\Subst.csv", True)

CSVObj = ParsedCSV.Items
For Line = 0 To UBound(CSVObj)
  Wscript.Echo CSVObj(Line)(0) & " - " & CSVObj(Line)(1) & " - " & CSVObj(Line)(2)
Next

Set ParsedCSV = Nothing

WScript.Quit

'taskkill /f /t /im wscript.exe