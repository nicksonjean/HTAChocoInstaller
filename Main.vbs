' Sub Require(RelativeFileName)
' 	Dim WshFSO, VbsFile
' 	Set WshFSO = CreateObject("Scripting.FileSystemObject")
' 	Set VbsFile = WshFSO.OpenTextFile(RelativeFileName)
' 	ExecuteGlobal VbsFile.ReadAll()
' 	VbsFile.Close
' End Sub

' Call Require("./libs/Functions.vbs")
' Call Require("./libs/Extensions/Run.vbs")

Function RunCMDAndWaitSyncList()
  Dim Instance, ReturnList, RegEx, Match, Matches, PackageList, PackageNumber, JSONObj, ArrayObj, TextLine, TextColumn, EachLine, Line, IIfIcon, PackageIcon, DefaultIcon, Extension, Command, Argument

  Const TemporaryFolder = 2
  Dim FSO: Set FSO = CreateObject("Scripting.FileSystemObject")
  Dim TempFolder: TempFolder = FSO.GetSpecialFolder(TemporaryFolder) & "\"

  Set Instance = New Run
  ReturnList = Instance.CMDAndWaitSync("choco list --local-only", TempFolder & ".apps")

  Set RegEx = New RegExp
  RegEx.MultiLine = True
  RegEx.Pattern = "((\d{1,3})\spackages\sinstalled\.)((.*\n*){1,})"
  Set Matches = RegEx.Execute(ReturnList)
  Set Match = Matches(0)

  PackageNumber = Match.SubMatches(1)
  PackageList = RegEx.Replace(ReturnList, "")
  DefaultChocoURL = "https://community.chocolatey.org/"
  RepositoryIcon = DefaultChocoURL & "content/packageimages/"
  Command = "choco uninstall "
  Argument = " -x"

  Dim InstanceInfo, ReturnInfo, RegExInfo, MatchInfo, MatchesInfo, PackageName, PackageTitle

  TextLine = Split(PackageList, vbCrLf)
  TextLine = Slice(TextLine, 1, -1)
  EachLine = 0
  JSONObj ="{"
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

      Set InstanceInfo = New Run
      ReturnInfo = Instance.CMDAndWaitSync("choco info " & TextColumn(0), TempFolder & "." & TextColumn(0))
      Set RegExInfo = New RegExp
      RegExInfo.MultiLine = True
      RegExInfo.Global = True
      RegExInfo.Pattern = "Title:\s([\w+\d+\s+\(\-\)\.\[\]]+)"
      Set MatchesInfo = RegExInfo.Execute(ReturnInfo)
      Set MatchInfo = MatchesInfo(0)
      PackageTitle = Trim(MatchInfo.SubMatches(0))

      ArrayObj = ""
      ArrayObj = ArrayObj & "{"
      ArrayObj = ArrayObj & Chr(34) & "packageName" & Chr(34) & ":" & Chr(34) & PackageTitle & Chr(34) & ","
      ArrayObj = ArrayObj & Chr(34) & "packageVersion" & Chr(34) & ":" & Chr(34) & TextColumn(1) & Chr(34) & ","
      ArrayObj = ArrayObj & Chr(34) & "packageIcon" & Chr(34) & ":" & Chr(34) & IIfIcon & Chr(34) & ","
      ArrayObj = ArrayObj & Chr(34) & "packageCommand" & Chr(34) & ":" & Chr(34) & Command & TextColumn(0) & Argument & Chr(34)
      ArrayObj = ArrayObj & "},"
      JSONObj = JSONObj & ArrayObj
    End If
    EachLine = EachLine + 1
  Next
  JSONObj = JSONObj & "]"
  If PackageNumber > 0 Then
    JSONObj = Mid(JSONObj,1,Len(JSONObj) - 2) & "],"
  Else
    JSONObj = JSONObj & ","
  End If
  JSONObj = JSONObj & Chr(34) & "package_lenght" & Chr(34) & ":" & PackageNumber & ""  
  JSONObj = JSONObj & "}"
  RunCMDAndWaitSyncList = JSONObj
  Set Instance = Nothing
End Function

Dim InstalledPackages
InstalledPackages = RunCMDAndWaitSyncList()
' Wscript.Echo InstalledPackages