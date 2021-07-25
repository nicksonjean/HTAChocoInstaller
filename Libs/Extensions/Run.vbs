' Run.vbs
' VBScript Run Command Line Helper
' Author Nickson Jeanmerson
' Version 0.0.1 - 26/Jun/2021
' ----------------------------------------'

Option Explicit
On Error Resume Next

Class Run
    Sub SubSleep(Seconds)
        Dim WshShell
        Dim CommandLine
        set WshShell = CreateObject("WScript.Shell")
        CommandLine = "%COMSPEC% /c ping -n " & Seconds & " 127.0.0.1 > nul"     
        WshShell.Run CommandLine,0,1 
    End Sub

    Function CMD(CommandLine)
        Dim WshShell, ObsInstance, Result
        Set WshShell = CreateObject("WScript.Shell")
        With WshShell
            Set ObsInstance = .Exec(CommandLine)
            Result = ObsInstance.StdOut.Readall()
            CMD = Result
            Set ObsInstance = Nothing
        End With
        Set WshShell = Nothing
    End Function

    Function CMDAndWait(CommandLine)
      Dim WshShell, ObsInstance, Result
      Set WshShell = CreateObject("WScript.Shell")
      With WshShell
        Set ObsInstance = .Exec(CommandLine)
        Do While ObsInstance.Status <> 1
          ' WScript.Sleep 100
          SubSleep 0.10
        Loop
          Result = ObsInstance.StdOut.Readall()
        CMDAndWait = Result
        Set ObsInstance = Nothing
      End With
      Set WshShell = Nothing
    End Function

    Function CMDAndWaitSync(CommandLine, OutputPathName)
      Dim WMIService, StartupInfo, FSO, CWD, Process, RetCode, PID, File
      Set WMIService = GetObject("winmgmts:\\.\root\cimv2")
      Set StartupInfo = WMIService.Get("Win32_ProcessStartup")
      Set FSO = CreateObject("Scripting.FileSystemObject")
      CWD = FSO.GetAbsolutePathname(".")
      StartupInfo.SpawnInstance_
      StartupInfo.ShowWindow = 0
      Set Process = WMIService.Get("Win32_Process")
      RetCode = Process.Create("cmd.exe /c """ & CommandLine & """ > " & OutputPathName, CWD, StartupInfo, PID)
      If RetCode = 0 Then
        Do While Not FSO.FileExists(OutputPathName)
          ' WScript.Sleep 500
          SubSleep 2
        Loop
        if FSO.FileExists(OutputPathName) then
          Do
            Err.Clear
            Set File = FSO.OpenTextFile(OutputPathName, 1)
            if Err.number = 0 then Exit Do
            ' WScript.Sleep 1000
            SubSleep 1 
          Loop
          On Error Goto 0
          CMDAndWaitSync = File.ReadAll
          File.Close
        End If
      Else 
        CMDAndWaitSync = RetCode
      End If
      Set Process = Nothing
      Set File = Nothing
      Set FSO = Nothing
      Set StartupInfo = Nothing
      Set WMIService = Nothing
    End Function

    Function CMDReadOutput(OutputPathName)
      Dim FSO, OutputResult
      Set FSO = CreateObject("Scripting.FileSystemObject")
      Set OutputResult = FSO.OpenTextFile(OutputPathName, 1)
      CMDReadOutput = OutputResult.ReadAll
      OutputResult.Close
    End Function
End Class

' How to use:
' ----------------------------------------'

' Dim Instance, ExportedCMDAndWaitSync
' Set Instance = New Run
' ExportedCMDAndWaitSync = Instance.CMD("choco list --local-only")
' ExportedCMDAndWaitSync = Instance.CMDAndWait("choco list --local-only")
' ExportedCMDAndWaitSync = Instance.CMDAndWaitSync("choco list --local-only", "choco_installed_packages.txt")

' Wscript.Echo ExportedCMDAndWaitSync
' Set Instance = Nothing
' Set ExportedCMDAndWaitSync = Nothing