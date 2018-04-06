VERSION 5.00
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "COMDLG32.OCX"
Begin VB.Form Form1 
   BorderStyle     =   1  'å≈íË(é¿ê¸)
   Caption         =   "STORM terminal"
   ClientHeight    =   6570
   ClientLeft      =   1170
   ClientTop       =   1905
   ClientWidth     =   6030
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   ScaleHeight     =   6570
   ScaleWidth      =   6030
   Begin MSComDlg.CommonDialog CommonDialog1 
      Left            =   0
      Top             =   3840
      _ExtentX        =   847
      _ExtentY        =   847
      _Version        =   393216
      CancelError     =   -1  'True
   End
   Begin VB.TextBox Text1 
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   3495
      Left            =   0
      MultiLine       =   -1  'True
      ScrollBars      =   2  'êÇíº
      TabIndex        =   128
      Top             =   0
      Width           =   6015
   End
   Begin VB.Timer Timer 
      Enabled         =   0   'False
      Interval        =   1
      Left            =   0
      Top             =   3480
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   127
      Left            =   5520
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   127
      Top             =   3600
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   126
      Left            =   5160
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   126
      Top             =   3600
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   125
      Left            =   4800
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   125
      Top             =   3600
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   124
      Left            =   4440
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   124
      Top             =   3600
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   123
      Left            =   4080
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   123
      Top             =   3600
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   122
      Left            =   3720
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   122
      Top             =   3600
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   121
      Left            =   3360
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   121
      Top             =   3600
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   120
      Left            =   3000
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   120
      Top             =   3600
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   119
      Left            =   2640
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   119
      Top             =   3600
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   118
      Left            =   2280
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   118
      Top             =   3600
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   117
      Left            =   1920
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   117
      Top             =   3600
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   116
      Left            =   1560
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   116
      Top             =   3600
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   115
      Left            =   1200
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   115
      Top             =   3600
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   114
      Left            =   840
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   114
      Top             =   3600
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   113
      Left            =   480
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   113
      Top             =   3600
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   112
      Left            =   120
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   112
      Top             =   3600
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   111
      Left            =   5520
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   111
      Top             =   3960
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   110
      Left            =   5160
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   110
      Top             =   3960
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   109
      Left            =   4800
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   109
      Top             =   3960
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   108
      Left            =   4440
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   108
      Top             =   3960
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   107
      Left            =   4080
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   107
      Top             =   3960
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   106
      Left            =   3720
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   106
      Top             =   3960
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   105
      Left            =   3360
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   105
      Top             =   3960
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   104
      Left            =   3000
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   104
      Top             =   3960
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   103
      Left            =   2640
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   103
      Top             =   3960
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   102
      Left            =   2280
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   102
      Top             =   3960
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   101
      Left            =   1920
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   101
      Top             =   3960
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   100
      Left            =   1560
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   100
      Top             =   3960
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   99
      Left            =   1200
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   99
      Top             =   3960
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   98
      Left            =   840
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   98
      Top             =   3960
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   97
      Left            =   480
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   97
      Top             =   3960
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   96
      Left            =   120
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   96
      Top             =   3960
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   95
      Left            =   5520
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   95
      Top             =   4320
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   94
      Left            =   5160
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   94
      Top             =   4320
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   93
      Left            =   4800
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   93
      Top             =   4320
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   92
      Left            =   4440
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   92
      Top             =   4320
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   91
      Left            =   4080
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   91
      Top             =   4320
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   90
      Left            =   3720
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   90
      Top             =   4320
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   89
      Left            =   3360
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   89
      Top             =   4320
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   88
      Left            =   3000
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   88
      Top             =   4320
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   87
      Left            =   2640
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   87
      Top             =   4320
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   86
      Left            =   2280
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   86
      Top             =   4320
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   85
      Left            =   1920
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   85
      Top             =   4320
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   84
      Left            =   1560
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   84
      Top             =   4320
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   83
      Left            =   1200
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   83
      Top             =   4320
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   82
      Left            =   840
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   82
      Top             =   4320
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   81
      Left            =   480
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   81
      Top             =   4320
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   80
      Left            =   120
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   80
      Top             =   4320
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   79
      Left            =   5520
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   79
      Top             =   4680
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   78
      Left            =   5160
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   78
      Top             =   4680
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   77
      Left            =   4800
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   77
      Top             =   4680
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   76
      Left            =   4440
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   76
      Top             =   4680
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   75
      Left            =   4080
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   75
      Top             =   4680
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   74
      Left            =   3720
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   74
      Top             =   4680
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   73
      Left            =   3360
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   73
      Top             =   4680
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   72
      Left            =   3000
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   72
      Top             =   4680
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   71
      Left            =   2640
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   71
      Top             =   4680
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   70
      Left            =   2280
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   70
      Top             =   4680
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   69
      Left            =   1920
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   69
      Top             =   4680
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   68
      Left            =   1560
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   68
      Top             =   4680
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   67
      Left            =   1200
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   67
      Top             =   4680
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   66
      Left            =   840
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   66
      Top             =   4680
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   65
      Left            =   480
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   65
      Top             =   4680
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   64
      Left            =   120
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   64
      Top             =   4680
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   63
      Left            =   5520
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   63
      Top             =   5040
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   62
      Left            =   5160
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   62
      Top             =   5040
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   61
      Left            =   4800
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   61
      Top             =   5040
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   60
      Left            =   4440
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   60
      Top             =   5040
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   59
      Left            =   4080
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   59
      Top             =   5040
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   58
      Left            =   3720
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   58
      Top             =   5040
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   57
      Left            =   3360
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   57
      Top             =   5040
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   56
      Left            =   3000
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   56
      Top             =   5040
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   55
      Left            =   2640
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   55
      Top             =   5040
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   54
      Left            =   2280
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   54
      Top             =   5040
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   53
      Left            =   1920
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   53
      Top             =   5040
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   52
      Left            =   1560
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   52
      Top             =   5040
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   51
      Left            =   1200
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   51
      Top             =   5040
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   50
      Left            =   840
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   50
      Top             =   5040
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   49
      Left            =   480
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   49
      Top             =   5040
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   48
      Left            =   120
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   48
      Top             =   5040
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   47
      Left            =   5520
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   47
      Top             =   5400
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   46
      Left            =   5160
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   46
      Top             =   5400
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   45
      Left            =   4800
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   45
      Top             =   5400
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   44
      Left            =   4440
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   44
      Top             =   5400
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   43
      Left            =   4080
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   43
      Top             =   5400
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   42
      Left            =   3720
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   42
      Top             =   5400
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   41
      Left            =   3360
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   41
      Top             =   5400
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   40
      Left            =   3000
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   40
      Top             =   5400
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   39
      Left            =   2640
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   39
      Top             =   5400
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   38
      Left            =   2280
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   38
      Top             =   5400
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   37
      Left            =   1920
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   37
      Top             =   5400
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   36
      Left            =   1560
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   36
      Top             =   5400
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   35
      Left            =   1200
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   35
      Top             =   5400
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   34
      Left            =   840
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   34
      Top             =   5400
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   33
      Left            =   480
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   33
      Top             =   5400
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   32
      Left            =   120
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   32
      Top             =   5400
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   31
      Left            =   5520
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   31
      Top             =   5760
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   30
      Left            =   5160
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   30
      Top             =   5760
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   29
      Left            =   4800
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   29
      Top             =   5760
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   28
      Left            =   4440
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   28
      Top             =   5760
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   27
      Left            =   4080
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   27
      Top             =   5760
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   26
      Left            =   3720
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   26
      Top             =   5760
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   25
      Left            =   3360
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   25
      Top             =   5760
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   24
      Left            =   3000
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   24
      Top             =   5760
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   23
      Left            =   2640
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   23
      Top             =   5760
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   22
      Left            =   2280
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   22
      Top             =   5760
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   21
      Left            =   1920
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   21
      Top             =   5760
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   20
      Left            =   1560
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   20
      Top             =   5760
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   19
      Left            =   1200
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   19
      Top             =   5760
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   18
      Left            =   840
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   18
      Top             =   5760
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   17
      Left            =   480
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   17
      Top             =   5760
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   16
      Left            =   120
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   16
      Top             =   5760
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   15
      Left            =   5520
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   15
      Top             =   6120
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   14
      Left            =   5160
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   14
      Top             =   6120
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   13
      Left            =   4800
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   13
      Top             =   6120
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   12
      Left            =   4440
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   12
      Top             =   6120
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   11
      Left            =   4080
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   11
      Top             =   6120
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   10
      Left            =   3720
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   10
      Top             =   6120
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   9
      Left            =   3360
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   9
      Top             =   6120
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   8
      Left            =   3000
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   8
      Top             =   6120
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   7
      Left            =   2640
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   7
      Top             =   6120
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   6
      Left            =   2280
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   6
      Top             =   6120
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   5
      Left            =   1920
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   5
      Top             =   6120
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   4
      Left            =   1560
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   4
      Top             =   6120
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   3
      Left            =   1200
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   3
      Top             =   6120
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   2
      Left            =   840
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   2
      Top             =   6120
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   1
      Left            =   480
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   1
      Top             =   6120
      Width           =   340
   End
   Begin VB.CommandButton Butt 
      BackColor       =   &H0000A000&
      BeginProperty Font 
         Name            =   "ÇlÇr ÉSÉVÉbÉN"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   340
      Index           =   0
      Left            =   120
      Style           =   1  '∏ﬁ◊Ã®Ø∏Ω
      TabIndex        =   0
      Top             =   6120
      Width           =   340
   End
   Begin VB.Menu File 
      Caption         =   "ÉtÉ@ÉCÉã(&F)"
      Begin VB.Menu LoadSendData 
         Caption         =   "ÉtÉ@ÉCÉãëóêM(&L)..."
         Shortcut        =   ^L
      End
      Begin VB.Menu Exit 
         Caption         =   "èIóπ(&X)"
         Shortcut        =   ^Q
      End
   End
   Begin VB.Menu Option 
      Caption         =   "ÉIÉvÉVÉáÉì(&O)"
      Begin VB.Menu CommLog 
         Caption         =   "í êMÉçÉOï\é¶(&L)"
      End
      Begin VB.Menu CommOnFocus 
         Caption         =   "ÉtÉHÅ[ÉJÉXéûÇÃÇ›í êM"
         Checked         =   -1  'True
      End
      Begin VB.Menu ResetTerminal 
         Caption         =   "ÉäÉZÉbÉg(&R)"
         Shortcut        =   ^R
      End
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

#Const bDebug = False
#Const bStrictPIO = False
#Const bReturnACK = True
#Const bBufferedMsg = True

Const CMD_W_PORT = &H1
Const CMD_W_DATA = &H2
Const CMD_R_PORT = &H9
Const CMD_R_DATA = &HA

'command from CPU
Private Enum CMD_READ
    PORT_GetButt
    PORT_SetButt
    PORT_SetButtNo
    PORT_SetButtState
    PORT_SetButtColor
    PORT_SetButtChar
    PORT_GetData
    PORT_GetDataAry
    PORT_Putc
    PORT_DataL
    PORT_DataH
    PORT_ResetTerm
End Enum


Dim ButtState(127)  As Integer
Dim ButtColor(127)  As Integer
Dim ButtChar(127)   As Integer

Dim PIOBase         As Integer
Dim ButtNo          As Integer
Dim DataL           As Integer

Dim PushButtBuf(16) As Integer
Dim PushButtBufSp   As Integer
Dim PushButtBufEp   As Integer

Dim SendFileSize    As Long
Dim SendFileName    As String
Dim MessageTextBuf  As String

#If (bDebug) Then
Dim PrePort         As Integer
#End If

Private Declare Function Inp Lib "portio" Alias "_Inp@4" (ByVal Port As Integer) As Long
Private Declare Function Outp Lib "portio" Alias "_Outp@8" (ByVal Port As Integer, ByVal Data As Long) As Long
Private Declare Sub CPUIntCtrl Lib "portio" Alias "_CPUIntCtrl@4" (ByVal Enable As Long)

Private Declare Function LoadGiveIO Lib "portio" Alias "_LoadGiveIO@4" (ByVal szDriverName As String) As Long
Private Declare Function UnloadDriver Lib "portio" Alias "_UnloadDriver@4" (ByVal szDriverName As String) As Long

#If 0 Then
Private Function Inp(Port As Integer) As Long
    Inp = 0
End Function

Private Function Outp(Port As Integer, Data As Long) As Long
    Outp = 0
End Function
#End If

'*** Form ********************************************************************
Private Sub Form_Load()
    PIOBase = &H378
    
    If (LoadGiveIO("STERM_GiveIO") = 0) Then
        MsgBox ("GiveIO.sys ÇÃÉçÅ[ÉhÇ…é∏îsÇµÇ‹ÇµÇΩ")
    End If
    
    HookWindowProc
    ResetTerminal_Click
    
    OutputMsgLn ("===============================================")
    OutputMsgLn ("    STORM terminal v1.00")
    OutputMsgLn ("    Copyright(C) 2002 by Deyu Deyu Software")
    OutputMsgLn ("===============================================")
    
    Timer.Enabled = True
    
End Sub

Private Sub Form_Unload(cancel As Integer)
    Timer.Enabled = False
    UnhookWindowProc
    
    If (UnloadDriver("STERM_GiveIO") = 0) Then
        MsgBox ("GiveIO.sys ÇÃÉAÉìÉçÅ[ÉhÇ…é∏îsÇµÇ‹ÇµÇΩ")
    End If
End Sub

'*** É{É^Éì push *************************************************************

Private Sub Butt_Click(Index As Integer)
    If (((PushButtBufEp + 1) Mod 16) <> PushButtBufSp) Then
        PushButtBuf(PushButtBufEp) = Index
        PushButtBufEp = (PushButtBufEp + 1) Mod 16
        
        #If (bDebug) Then
            OutputMsg ("Clicked" & Str$(Index) & "  ")
        #End If
    Else
        Beep
    End If
    
    #If (bDebug) Then
        OutputMsgLn ("KeyBuf:" & PushButtBufSp & ":" & PushButtBufEp)
    #End If
    
End Sub

' É{É^Éì ON/OFF ÉZÉbÉg
Private Function SetButtState(Index As Integer, Status As Integer) As Integer
    Dim i As Integer, iStart As Integer, iStop As Integer
    
    ' return button state
    If (Status = 3) Then
        SetButtState = ButtState(Index)
    End If
    
    ' set button state
    If (Index = &HFF) Then
        iStart = 0: iStop = &H7F
    Else
        iStart = Index: iStop = Index
    End If
    
    For i = iStart To iStop
        Select Case Status
        Case 0 To 1
            ButtState(i) = Status
        
        Case 2
            ButtState(i) = 1 - ButtState(i)
        End Select
        
        Dim ColorElem As Long
        Dim Color As Long
        ColorElem = &HA0 + &H5F * ButtState(i)
        
        Butt(i).BackColor = _
            ColorElem * ((ButtColor(i) And 2) / 2) + _
            ColorElem * &H100 * ((ButtColor(i) And 4) / 4) + _
            ColorElem * &H10000 * ((ButtColor(i) And 1) / 1)
    Next
End Function

' É{É^ÉìÉJÉâÅ[ÉZÉbÉg
Private Sub SetButtColor(Index As Integer, Color As Integer)
    Dim i As Integer, iStart As Integer, iStop As Integer
    Dim iStatus As Integer
    
    If (Index = &HFF) Then
        iStart = 0: iStop = &H7F
    Else
        iStart = Index: iStop = Index
    End If
    
    For i = iStart To iStop
        ButtColor(i) = Color And 7
        
        If Color And &H80 = 0 Then
            iStatus = 3
        Else
            iStatus = (Color And &H40) / &H40
        End If
        
        Call SetButtState(i, iStatus)
    Next
End Sub

' É{É^Éìï∂éöÉZÉbÉg
Private Sub SetButtChar(Index As Integer, Char As Integer)
    Dim i As Integer, iStart As Integer, iStop As Integer
    
    If (Index = &HFF) Then
        iStart = 0: iStop = &H7F
    Else
        iStart = Index And &H7F: iStop = Index And &H7F
    End If
    
    For i = iStart To iStop
        ButtChar(i) = Char
        Butt(i).Caption = Chr(Char)
    Next
End Sub

'*** console ï\é¶ ************************************************************

' ÉäÉ^Å[ÉìÉLÅ[Ç≈ SendString
Private Sub Text1_KeyPress(KeyAscii As Integer)
    Dim Char As String
    Char = Chr(KeyAscii)
    'OutputMsg (">" + Str$(KeyAscii) + "<")
End Sub

' console Ç…ÉÅÉbÉZÅ[ÉWèoóÕ
Public Sub OutputMsg(Msg As String)
    MessageTextBuf = MessageTextBuf & Msg
    
    #If (Not bBufferedMsg) Then
        Call OutputMsgDraw
    #End If
End Sub

Public Sub OutputMsgLn(Msg As String)
    OutputMsg (Msg + Chr(13) + Chr(10))
End Sub

Public Sub OutputMsgDraw()
    
    If (MessageTextBuf = "") Then Exit Sub
    
    ' ëIëâèú & ÉJÅ[É\ÉãÇç≈å„îˆÇ…
    Text1.SelStart = 65535
    
    ' ÉoÉbÉtÉ@Ç™ 3/4 Çí¥Ç¶ÇΩÇÁÅC1/4ÉJÉbÉg
    If (Text1.SelStart >= 24 * 1024) Then
        Text1.SelStart = 0
        Text1.SelLength = 8 * 1024
        Text1.SelText = ""
        Text1.SelStart = 65535
        
        #If bDebug Then
        OutputMsgLn ("ÉoÉbÉtÉ@ÇêÿÇËãlÇﬂÇ‹ÇµÇΩ")
        #End If
    End If
    
    ' msg ë}ì¸
    Text1.SelText = MessageTextBuf
    MessageTextBuf = ""
End Sub

'*** menu command ************************************************************

Private Sub Exit_Click()
    Close
    Unload Form1
    End
End Sub

Private Sub LoadSendData_Click()
    
    'ëOÇ… Open Ç≥ÇÍÇƒÇ¢ÇÈÉtÉ@ÉCÉãÇ Close
    Close
    SendFileSize = 0
    
    'Open É_ÉCÉAÉçÉO
    CommonDialog1.Flags = cdlOFNFileMustExist Or cdlOFNHideReadOnly
    On Error GoTo Canceled
    CommonDialog1.ShowOpen
    
    'Open èàóù
    Open CommonDialog1.FileName For Binary Access Read As #1
    SendFileSize = LOF(1)
    
Canceled:
End Sub

Private Sub CommLog_Click()
    CommLog.Checked = Not CommLog.Checked
End Sub

Private Sub CommOnFocus_Click()
    CommOnFocus.Checked = Not CommOnFocus.Checked
End Sub

Private Sub ResetTerminal_Click()
    
    Dim ButtStr(7) As String
    
    ButtStr(7) = "!'#$%&'()-^\=~|*"
    ButtStr(6) = "QWERTYUIOP@[`{**"
    ButtStr(5) = "ASDFGHJKL;:]+*}*"
    ButtStr(4) = "ZXCVBNM,./\<>?_*"
    ButtStr(3) = "789/DF"
    ButtStr(2) = "345*CE"
    ButtStr(1) = "123-B"
    ButtStr(0) = "0,.+A"
    
    Text1.Text = ""
    MessageTextBuf = ""
    
    Call SetButtColor(&HFF, 4)
    Call SetButtState(&HFF, 0)
    Call SetButtChar(&HFF, 32)
    
    'ÉLÅ[É{Å[ÉhÉoÉbÉtÉ@ÉNÉäÉA
    PushButtBufSp = 0
    PushButtBufEp = 0
    
    'File ÉNÉçÅ[ÉY
    Close
    SendFileSize = 0
    
    'PIO èâä˙âª
    Call Outp(PIOBase + 2, &H4) '37A
    Call Outp(PIOBase, &HDA)    '378
    Call Outp(PIOBase + 2, &H6) '37A
    Call Outp(PIOBase + 2, &H4) '37A
    
End Sub

'*** port IO function ********************************************************

Private Function AccessPIO(Cmd As Integer, Data As Integer) As Integer
    Dim TOCnt As Integer        'time out count
    
    'CPUIntCtrl (0)
    
    #If (bStrictPIO) Then
        Call Outp(PIOBase + 2, &H4) '37A
    #End If
    Call Outp(PIOBase, &HDA)    '378
    Call Outp(PIOBase + 2, &H6) '37A
    Call Outp(PIOBase + 2, &H4) '37A
    
    #If (bStrictPIO) Then
        TOCnt = 0
        
        While (Inp(PIOBase + 1) And &H78) <> &H48 And TOCnt < 100    '37A
            TOCnt = TOCnt + 1
        Wend
        
        If (TOCnt >= 100) Then
            If (CommLog.Checked) Then
                OutputMsgLn ("PIO Time out")
            End If
            
            AccessPIO = -1
            'CPUIntCtrl (1)
            Exit Function
        End If
    #End If
    
    Call Outp(PIOBase, &HC2 Or ((Cmd And &HF) * 4))     'cmd
    Call Outp(PIOBase, &HC0 Or ((Cmd And &HF) * 4))
    
    If Cmd And 8 Then
        'receive data
        Call Outp(PIOBase, &HC0)
        AccessPIO = (Inp(PIOBase + 1) And &H78) / 8
        Call Outp(PIOBase, &HC2)
        AccessPIO = ((Inp(PIOBase + 1) And &H78) * 2) Or AccessPIO
        Call Outp(PIOBase, &HC0)
    Else
        'send data
        Call Outp(PIOBase, &HC0 Or ((Data And &HF) * 4))    'data L
        Call Outp(PIOBase, &HC2 Or ((Data And &HF) * 4))    'data L
        Call Outp(PIOBase, &HC2 Or ((Data And &HF0) / 4))   'data H
        Call Outp(PIOBase, &HC0 Or ((Data And &HF0) / 4))   'data H
        
        AccessPIO = 0
        'CPUIntCtrl (1)
    End If
    
    #If (bDebug) Then
        If (Cmd = CMD_R_PORT And PrePort <> AccessPIO) Then
            OutputMsgLn ("[R]*Port:" & Hex(AccessPIO))
            PrePort = AccessPIO
        End If
    #End If
    
End Function

'*** read PIO timer interval *************************************************

Private Sub Timer_Timer()
    Dim Port As Integer
    Dim Data As Integer
    Dim ReadCnt As Long
    Dim ReceivedData As Long
    
    For ReadCnt = 0 To 100
        'read port No. & status
        Port = AccessPIO(CMD_R_PORT, 0)
        
        'invalid read data
        If (Port And &H80) Then
            ReadCnt = ReadCnt + 20
            GoTo NextLoop
        End If
        
        'receive data
        If ((Port <> PORT_GetData) And (Port <> PORT_GetDataAry)) Then
            Data = AccessPIO(CMD_R_DATA, 0)
        End If
        
ProcessCmd:
        
        'If (CommLog.Checked) Then OutputMsgLn ("[R] " & Hex(Port) & ":" & Hex(Data))
        
        Select Case Port
        Case PORT_GetButt       '*** get pushed button ***********************
            If (PushButtBufSp = PushButtBufEp) Then
                Call AccessPIO(CMD_W_DATA, -1)
                'OutputMsgLn ("[S] **********************************")
            Else
                Call AccessPIO(CMD_W_DATA, PushButtBuf(PushButtBufSp))
                
                If (CommLog.Checked) Then
                    OutputMsgLn ("[S] PushButt:" & PushButtBuf(PushButtBufSp))
                End If
                
                ButtNo = PushButtBuf(PushButtBufSp)
                PushButtBufSp = (PushButtBufSp + 1) Mod 16
            End If
            
        Case PORT_SetButt       '*** set button state 0/1 ********************
            #If (bReturnACK) Then
                Call AccessPIO(CMD_W_DATA, 0)   'return ACK
            #End If
            
            Call SetButtState(Data And &H7F, (Data And &H80) / &H80)
            
        Case PORT_SetButtNo     '*** set button No. **************************
            #If (bReturnACK) Then
                Call AccessPIO(CMD_W_DATA, 0)   'return ACK
            #End If
            
            ButtNo = Data
            If (CommLog.Checked) Then
                OutputMsgLn ("[R] ButtNo:" & ButtNo)
            End If
        
        Case PORT_SetButtState  '*** set or get button state *****************
            Call AccessPIO(CMD_W_DATA, SetButtState(ButtNo, Data))
            
            If (CommLog.Checked) Then
                OutputMsgLn ("[R] ButtState:" & ButtNo & ":" & Data)
            End If
        
        Case PORT_SetButtColor  '*** set button color ************************
            #If (bReturnACK) Then
                Call AccessPIO(CMD_W_DATA, 0)   'return ACK
            #End If
            
            Call SetButtColor(ButtNo, Data)
            If (CommLog.Checked) Then
                OutputMsgLn ("[R] ButtColor:" & ButtNo & ":" & Data)
            End If
            
        Case PORT_SetButtChar   '*** set button char *************************
            #If (bReturnACK) Then
                Call AccessPIO(CMD_W_DATA, 0)   'return ACK
            #End If
            
            Call SetButtChar(ButtNo, Data)
            If (CommLog.Checked) Then
                OutputMsgLn ("[R] ButtChar:" & ButtNo & ":" & Chr(Data))
            End If
            
        Case PORT_GetData       '*** synchoronized get data ******************
            While (SendFileSize > 0)
                Port = AccessPIO(CMD_R_PORT, 0)
                
                If (Port = PORT_GetData) Then
                    
                    'ÉfÅ[É^ëóêMóvãÅ
                    Data = AscB(InputB(1, #1))
                    Call AccessPIO(CMD_W_DATA, Data)
                    
                    SendFileSize = SendFileSize - 1
                    
                ElseIf ((Port And &H80) = 0) Then
                    'ÇªÇÃëºÇÃÉRÉ}ÉìÉh
                    GoTo ProcessCmd
                End If
            Wend
            
            'ëSïîëóÇ¡ÇΩÇÁ Close
            Close
            
        Case PORT_Putc          '*** putc to console *************************
            #If (bReturnACK) Then
                Call AccessPIO(CMD_W_DATA, 0)   'return ACK
            #End If
            
            Select Case Data
            Case &HA
                OutputMsgLn ("")
                
            Case Else
                OutputMsg (Chr(Data))
                
            End Select
        
        Case PORT_DataL         '*** Low of Data *****************************
            #If (bReturnACK) Then
                Call AccessPIO(CMD_W_DATA, 0)   'return ACK
            #End If
            DataL = (Data And &HFF)
            
            If (CommLog.Checked) Then
                OutputMsgLn ("[R] DataL:" & Hex$(DataL))
            End If
            
        Case PORT_DataH         '*** High of Data & print data ***************
            #If (bReturnACK) Then
                Call AccessPIO(CMD_W_DATA, 0)   'return ACK
            #End If
            
            If (CommLog.Checked) Then
                OutputMsgLn ("[R] DataH:" & Hex$(Data))
            End If
            
            ReceivedData = Data And &HFF
            ReceivedData = ReceivedData * 256 + DataL
            
            OutputMsg ("Num : " & Right("    " & ReceivedData, 5) & " ")
            If (ReceivedData >= 32768) Then
                OutputMsg (Right("     " & (ReceivedData - 65536), 6))
            Else
                OutputMsg (Right("     " & ReceivedData, 6))
            End If
            
            OutputMsgLn (" 0x" & Right("000" & Hex(ReceivedData), 4))
            
        Case PORT_ResetTerm     '*** reset terminal **************************
            #If (bReturnACK) Then
                Call AccessPIO(CMD_W_DATA, 0)   'return ACK
            #End If
            
            Call ResetTerminal_Click
            
            If (CommLog.Checked) Then
                OutputMsgLn ("[R] Reset terminal")
            End If
        
        Case Else               '*** unknown *********************************
            #If (bReturnACK) Then
                Call AccessPIO(CMD_W_DATA, 0)   'return ACK
            #End If
            
            If (CommLog.Checked) Then
                OutputMsgLn ("[R] Unknown Port:" & Hex$(Port))
            End If

        End Select
NextLoop:
    Next
    
    If (MessageTextBuf <> "") Then
        Call OutputMsgDraw
    End If
End Sub
