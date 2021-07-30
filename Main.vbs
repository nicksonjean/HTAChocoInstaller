' Sub Require(RelativeFileName)
' 	Dim WshFSO, VbsFile
' 	Set WshFSO = CreateObject("Scripting.FileSystemObject")
' 	Set VbsFile = WshFSO.OpenTextFile(RelativeFileName)
' 	ExecuteGlobal VbsFile.ReadAll()
' 	VbsFile.Close
' End Sub

' Call Require("./Libs/Functions.vbs")
' Call Require("./Libs/Extensions/Run.vbs")

Function RunCMDAndWaitSync()
  Dim Instance, ExportedCMDAndWaitSync, RegEx, Match, Matches, PackageList, PackageNumber, JSONObj, ArrayObj, TextLine, TextColumn, EachLine, Line, IIfIcon, PackageIcon, DefaultIcon, Extension
  Set Instance = New Run
  ExportedCMDAndWaitSync = Instance.CMDAndWaitSync("choco list --local-only", "choco_installed_packages.txt")

  Set RegEx = New RegExp
  RegEx.MultiLine = True
  RegEx.Pattern = "((\d{1,3})\spackages\sinstalled\.)((.*\n*){1,})"
  Set Matches = RegEx.Execute(ExportedCMDAndWaitSync)
  Set Match = Matches(0)

  PackageNumber = Match.SubMatches(1)
  PackageList = RegEx.Replace(ExportedCMDAndWaitSync, "")
  DefaultChocoURL = "https://community.chocolatey.org/"
  RepositoryIcon = DefaultChocoURL & "content/packageimages/"

  TextLine = Split(PackageList, vbCrLf)
  TextLine = Slice(TextLine, 1, -1)
  EachLine = 0
  JSONObj ="{"
  JSONObj = JSONObj & Chr(34) & "package_lenght" & Chr(34) & ":" & PackageNumber & ","
  JSONObj = JSONObj & Chr(34) & "packages" & Chr(34) & ":" & "["
  For Each Line In TextLine
    'If EachLine >= IIf(True, 1, 0) AND Trim(Line) <> "" Then
    If Trim(Line) <> "" Then
      TextColumn = Split(Line, " ")
      PackageIcon = RepositoryIcon & TextColumn(0) & "." & TextColumn(1)
      DefaultIcon = DefaultChocoURL & "Content/Images/packageDefaultIcon-50x50.png"
      ' IIfIcon = IIf(URLExists(PackageIcon), PackageIcon, DefaultIcon)
      If URLExists(PackageIcon & ".png") Then
        IIfIcon = PackageIcon & ".png"
      ElseIf URLExists(PackageIcon & ".svg") Then
        IIfIcon = PackageIcon & ".svg"
      ' ElseIf URLExists(PackageIcon & ".bmp") Then
      '   IIfIcon = PackageIcon & ".bmp"
      ' ElseIf URLExists(PackageIcon & ".gif") Then
      '   IIfIcon = PackageIcon & ".gif"
      ' ElseIf URLExists(PackageIcon & ".jpg") Then
      '   IIfIcon = PackageIcon & ".jpg"
      Else
        IIfIcon = DefaultIcon
      End IF
      ArrayObj = ""
      ArrayObj = ArrayObj & "{"
      ArrayObj = ArrayObj & Chr(34) & "packageName" & Chr(34) & ":" & Chr(34) & TextColumn(0) & Chr(34) & ","
      ArrayObj = ArrayObj & Chr(34) & "packageIcon" & Chr(34) & ":" & Chr(34) & IIfIcon & Chr(34) & ","
      ArrayObj = ArrayObj & Chr(34) & "packageVersion" & Chr(34) & ":" & Chr(34) & TextColumn(1) & Chr(34)
      ArrayObj = ArrayObj & "},"
      JSONObj = JSONObj & ArrayObj
    End If
    EachLine = EachLine + 1
  Next
  JSONObj = JSONObj & "]"
  JSONObj = JSONObj & "}"
  JSONObj = Mid(JSONObj,1,Len(JSONObj) - 3) & "]}"

  RunCMDAndWaitSync = JSONObj
  Set Instance = Nothing
End Function

Dim InstalledPackages
InstalledPackages = RunCMDAndWaitSync()
' Wscript.Echo InstalledPackages