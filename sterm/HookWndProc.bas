Attribute VB_Name = "Module1"
Option Explicit

Public Declare Function CallWindowProc Lib "user32" Alias "CallWindowProcA" (ByVal PWF&, ByVal hWnd&, ByVal Msg&, ByVal wParam&, ByVal lParam As Long) As Long
Public Declare Function SetWindowLong Lib "user32" Alias "SetWindowLongA" (ByVal hWnd&, ByVal nIndex&, ByVal dwNewLong&) As Long

Public Const GWL_WNDPROC = (-4)
Public Const WM_ACTIVATEAPP = &H1C
Public Const StormCaption = "STORM Terminal"

Dim OriginalWndProc As Long

Public Function WindowProc(ByVal hWnd As Long, ByVal uMsg As Long, ByVal wParam As Long, ByVal lParam As Long) As Long
    If uMsg = WM_ACTIVATEAPP Then
        Debug.Print "WM_ACTIVATE:" & Hex$(wParam And &HFFFF)
        
        If (wParam <> 0) Then
            Form1.Caption = StormCaption
            Form1.Timer.Enabled = True
            
            If (Form1.CommOnFocus.Checked And Form1.CommLog.Checked) Then
                Form1.OutputMsgLn ("[i] PIO restarted")
            End If
        ElseIf (Form1.CommOnFocus.Checked) Then
            Form1.Timer.Enabled = False
            Form1.Caption = "í‚é~ - " & StormCaption
            
            If (Form1.CommLog.Checked) Then
                Form1.OutputMsgLn ("[i] PIO stopped")
                Form1.OutputMsgDraw
            End If
        End If
    End If
    
    WindowProc = CallWindowProc(OriginalWndProc, hWnd, uMsg, wParam, lParam)
End Function

Public Sub HookWindowProc()
    OriginalWndProc = SetWindowLong(Form1.hWnd, GWL_WNDPROC, AddressOf WindowProc)
End Sub

Public Sub UnhookWindowProc()
    SetWindowLong Form1.hWnd, GWL_WNDPROC, OriginalWndProc
End Sub

