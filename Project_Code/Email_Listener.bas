Declare PtrSafe Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As LongPtr)

Sub EmailListener()

    Dim objOutlook As Outlook.Application
    Dim objNamespace As Outlook.NameSpace
    Dim objInbox As Outlook.MAPIFolder
    Dim objMailItem As Object
    Dim Request As Object
    Dim Trigger As String
    Dim Reset As String
    Dim mailItems As Items
    Dim item As Object

    ' Setup Outlook
    Set objOutlook = Application
    Set objNamespace = objOutlook.GetNamespace("MAPI")
    Set objInbox = objNamespace.GetDefaultFolder(olFolderInbox)

    ' Sort inbox newest first
    Set mailItems = objInbox.Items
    mailItems.Sort "[ReceivedTime]", True
                
    

    ' Loop through each email
    For Each item In mailItems

        ' Make sure it's a MailItem (some items could be Meetings, etc.)
        If item.Class = olMail Then
            Debug.Print "Sender: " & item.Sender & ", Subject: " & item.Subject

            ' Check for keyword ALERT in subject
            If InStr(1, item.Subject, "ALERT", vbTextCompare) > 0 Then

                'MsgBox "ALERT detected! Sending request to Raspberry Pi..."

                ' Mark email as read
                ' item.UnRead = False
                Set Request = CreateObject("MSXML2.ServerXMLHTTP.6.0")

                ' TRIGGER the alarm
                Trigger = "YOUR_OWN_URL"
                Request.Open "GET", Trigger, False
                Request.Send
                Debug.Print "Triggered alarm - Status: " & Request.Status
                Set Request = Nothing

                ' Sleep is used to have the program wait before resetting the alarm
                Sleep 15000

                ' RESET the alarm
                Set Request = CreateObject("MSXML2.ServerXMLHTTP.6.0")
                Reset = "YOUR_OWN_URL"
                Request.Open "GET", Reset, False
                Request.Send
                Debug.Print "Reset alarm - Status: " & Request.Status
                Set Request = Nothing

                Exit For
            End If
        End If
    Next

    ' Cleanup
    Set mailItems = Nothing
    Set objInbox = Nothing
    Set objNamespace = Nothing
    Set objOutlook = Nothing
