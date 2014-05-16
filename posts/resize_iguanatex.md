---
title: Resizeable IguanaTex
date: '2014-5-16'
description: How to modify IguanaTex to have a resizeable window
categories: [LaTeX]
tags: [programming, LaTeX, powerpoint]
---

Recently I discovered an awesome PowerPoint plugin called [IguanaTex](http://tx.technion.ac.il/~zvikabh/software/iguanatex/). From the site: "IguanaTex is a PowerPoint plug-in which allows you to insert LaTeX equations into your PowerPoint presentation. It is distributed completely for free." It is however a bit more than that, it allows you to write a full LaTeX document within a PowerPoint slide. What does this mean? simply put, anything that you could do in LaTeX, you can now do in PowerPoint, my favorite is generating really nice looking tables, equations and lists. 

My biggest problem with this program is that the main window is not resizeable, these days with high resolution monitors and screens, having more screen space to do work is very helpful. 

###Prerequisites

Before I talk about the changes I made, I am going to assume that you were able to successfully get the program installed and the plugin loaded into PowerPoint. You must have a LaTeX install to  to actually use this plugin, but it is not needed for installation.

###Installation

To install the plugin, simply unload the old plugin (refer to the installation process on how to load plugin) and add [this](http://hamelot.co.uk/assets/media/files/IguanaTex.ppa) version. Now you will have a version that you can resize!

If you would like details on the changes I made, keep reading.

###Details
Seeing as macros for office programs are 'viable attack vectors', according to a friend, it makes sense why you should be careful running any plugin without being able to look at the code. Thankfully the source for IguanaTex is provided by the installer and I am providing the modified version here, feel free to look it over and make any other changes as you see fit. 

The modified ppt file can be found [here](http://hamelot.co.uk/assets/media/files/IguanaTex.ppt). In order to actually modify/view the code you need to enable [developer mode](http://msdn.microsoft.com/en-us/library/bb608625.aspx). From the developer tab you click the 'Visual Basic' button to view the VBA code. 

The first modification was to the 'Macros' file under the 'Modules' folder. I found a nice piece of code written by [Leith Ross](http://www.mrexcel.com/forum/excel-questions/485489-resize-userform.html) that allows a form to be resized. 

<img src="http://hamelot.co.uk/assets/media/images/posts/modifying_the_code.png" alt="screenshot" width="100%"> 


<pre>
'Written: August 02, 2010
'Author:  Leith Ross
'Summary: Makes the UserForm resizable by dragging one of the sides. Place a call
'         to the macro MakeFormResizable in the UserForm's Activate event.
'Source: http://www.mrexcel.com/forum/excel-questions/485489-resize-userform.html

 Private Declare Function SetLastError _
   Lib "kernel32.dll" _
     (ByVal dwErrCode As Long) _
   As Long
   
 Public Declare Function GetActiveWindow _
   Lib "user32.dll" () As Long

 Private Declare Function GetWindowLong _
   Lib "user32.dll" Alias "GetWindowLongA" _
     (ByVal hWnd As Long, _
      ByVal nIndex As Long) _
   As Long
               
 Private Declare Function SetWindowLong _
   Lib "user32.dll" Alias "SetWindowLongA" _
     (ByVal hWnd As Long, _
      ByVal nIndex As Long, _
      ByVal dwNewLong As Long) _
   As Long

Public Sub MakeFormResizable()

  Dim lStyle As Long
  Dim hWnd As Long
  Dim RetVal
  
  Const WS_THICKFRAME = &H40000
  Const GWL_STYLE As Long = (-16)
  
    hWnd = GetActiveWindow
  
    'Get the basic window style
     lStyle = GetWindowLong(hWnd, GWL_STYLE) Or WS_THICKFRAME
     
    'Set the basic window styles
     RetVal = SetWindowLong(hWnd, GWL_STYLE, lStyle)
    
    'Clear any previous API error codes
     SetLastError 0
    
    'Did the style change?
     If RetVal = 0 Then MsgBox "Unable to make UserForm Resizable."
     
End Sub
</pre>

Cool, the form is resizeable, however unlike more modern frameworks like Qt, there is no concept of layouts, everything must be positioned manually. So while the window resizes, nothing inside of it does. The fix for this is to manually resize everything by modifying the 'LatexForm' file under the 'Forms' directory. Add/modify the following:


<pre>
Private Sub UserForm_Initialize()
    LoadSettings
    'This is only to make sure that the form aligns everything, this way there isn't a slight jump when the user first resizes the window
    TextBox1.Height = LatexForm.Height - CommandButton1.Height * 5
    TextBox1.Width = LatexForm.Width - 25
    
    ButtonRun.Top = LatexForm.Height - ButtonRun.Height * 3
    ButtonCancel.Top = LatexForm.Height - ButtonCancel.Height * 3
    CommandButton1.Top = LatexForm.Height - CommandButton1.Height * 4
    CommandButton2.Top = LatexForm.Height - CommandButton2.Height * 3
    
    checkboxDebug.Top = LatexForm.Height - checkboxDebug.Height * 3
    checkboxTransp.Top = LatexForm.Height - checkboxTransp.Height * 4
    checkboxTransp.Top = LatexForm.Height - checkboxTransp.Height * 4
    Label2.Top = LatexForm.Height - Label2.Height * 7
    textboxSize.Top = LatexForm.Height - Label2.Height * 7
    Label3.Top = LatexForm.Height - Label2.Height * 7
    
    
End Sub

Private Sub UserForm_Activate()
  'Execute macro to enable resizeability
  MakeFormResizable
End Sub

Private Sub UserForm_Resize()
    'Make sure that the size is not zero!
    If LatexForm.Height - CommandButton1.Height * 5 > 0 Then
        TextBox1.Height = LatexForm.Height - CommandButton1.Height * 5
        TextBox1.Width = LatexForm.Width - 25
    End If
    
    'Other elements are moved as needed
    ButtonRun.Top = LatexForm.Height - ButtonRun.Height * 3
    ButtonCancel.Top = LatexForm.Height - ButtonCancel.Height * 3
    CommandButton1.Top = LatexForm.Height - CommandButton1.Height * 4
    CommandButton2.Top = LatexForm.Height - CommandButton2.Height * 3
    
    checkboxDebug.Top = LatexForm.Height - checkboxDebug.Height * 3
    checkboxTransp.Top = LatexForm.Height - checkboxTransp.Height * 4
    checkboxTransp.Top = LatexForm.Height - checkboxTransp.Height * 4
    Label2.Top = LatexForm.Height - Label2.Height * 7
    textboxSize.Top = LatexForm.Height - Label2.Height * 7
    Label3.Top = LatexForm.Height - Label2.Height * 7
End Sub
</pre>
The code should be pretty easy to understand, if you don't like how something is positioned, you can change it quite easily. 

And that's it!, quite simple in the end. 


