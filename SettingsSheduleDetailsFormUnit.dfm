object fSheduleTaskDetail: TfSheduleTaskDetail
  Left = 0
  Top = 0
  ClientHeight = 303
  ClientWidth = 296
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 296
    Height = 49
    Align = alTop
    Caption = #1058#1080#1087' '#1079#1072#1076#1072#1085#1080#1103
    TabOrder = 0
    object cmbTaskType: TComboBox
      Left = 16
      Top = 18
      Width = 273
      Height = 21
      TabOrder = 0
      OnChange = cmbTaskTypeChange
      Items.Strings = (
        #1048#1084#1087#1086#1088#1090' '#1076#1072#1085#1085#1099#1093' ('#1047#1072#1082#1072#1079#1099' '#1089' '#1050#1055#1050')'
        #1069#1082#1089#1087#1086#1088#1090' '#1076#1072#1085#1085#1099#1093' ('#1056#1072#1089#1093#1086#1076#1085#1099#1077' '#1085#1072#1082#1083#1072#1076#1085#1099#1077')'
        #1069#1082#1089#1087#1086#1088#1090' '#1076#1072#1085#1085#1099#1093' ('#1042#1086#1079#1074#1088#1072#1090#1099' '#1090#1086#1074#1072#1088#1072')'
        #1055#1088#1086#1074#1077#1088#1082#1072' '#1085#1072' '#1085#1072#1083#1080#1095#1080#1077' '#1085#1086#1074#1099#1093' '#1087#1088#1072#1081#1089#1086#1074' '#1074' '#1054#1058
        #1060#1086#1088#1084#1080#1088#1086#1074#1072#1085#1080#1077' '#1076#1072#1085#1085#1099#1093' '#1076#1083#1103' '#1082#1087#1082
        #1060#1086#1088#1084#1080#1088#1086#1074#1072#1085#1080#1077' '#1089#1087#1088#1072#1074#1086#1095#1085#1080#1082#1086#1074
        #1060#1086#1088#1084#1080#1088#1086#1074#1072#1085#1080#1077' '#1076#1077#1073#1077#1090#1086#1088#1082#1080
        #1060#1086#1088#1084#1080#1088#1086#1074#1072#1085#1080#1077' '#1086#1089#1090#1072#1090#1082#1086#1074
        #1056#1077#1089#1090#1072#1088#1090' '#1089#1083#1091#1078#1073#1099)
    end
  end
  object GroupBox2: TGroupBox
    Left = 0
    Top = 49
    Width = 296
    Height = 41
    Align = alTop
    Caption = #1058#1080#1087' '#1079#1072#1087#1091#1089#1082#1072':'
    TabOrder = 1
    object rbRunOne: TRadioButton
      Left = 24
      Top = 16
      Width = 89
      Height = 17
      Caption = #1054#1076#1085#1086#1082#1088#1072#1090#1085#1086
      TabOrder = 0
      OnClick = rbRunOneClick
    end
    object rbRunPeriod: TRadioButton
      Left = 167
      Top = 16
      Width = 98
      Height = 17
      Caption = #1055#1086' '#1080#1085#1090#1077#1088#1074#1072#1083#1091
      TabOrder = 1
      OnClick = rbRunPeriodClick
    end
  end
  object GroupBox3: TGroupBox
    Left = 0
    Top = 117
    Width = 146
    Height = 138
    Caption = #1044#1085#1080' '#1085#1077#1076#1077#1083#1080
    TabOrder = 2
    object chAllDays: TCheckBox
      Left = 16
      Top = 17
      Width = 97
      Height = 17
      Caption = #1042#1089#1077' '#1076#1085#1080
      TabOrder = 0
      OnClick = chAllDaysClick
    end
    object chListDays: TJvCheckListBox
      Left = 2
      Top = 39
      Width = 142
      Height = 97
      OnClickCheck = chListDaysClickCheck
      Align = alBottom
      ItemHeight = 13
      Items.Strings = (
        #1055#1086#1085#1077#1076#1077#1083#1100#1085#1080#1082
        #1042#1090#1086#1088#1085#1080#1082
        #1057#1088#1077#1076#1072
        #1063#1077#1090#1074#1077#1088#1075
        #1055#1103#1090#1085#1080#1094#1072
        #1057#1091#1073#1073#1086#1090#1072
        #1042#1086#1089#1082#1088#1077#1089#1077#1085#1100#1077)
      ScrollWidth = 86
      TabOrder = 1
      MultiSelect = True
    end
  end
  object GroupBox4: TGroupBox
    Left = 144
    Top = 117
    Width = 152
    Height = 138
    Caption = #1042#1088#1077#1084#1103
    TabOrder = 3
    object Label1: TLabel
      Left = 16
      Top = 24
      Width = 41
      Height = 13
      Caption = #1053#1072#1095#1072#1083#1086':'
    end
    object Label2: TLabel
      Left = 16
      Top = 58
      Width = 53
      Height = 13
      Caption = #1048#1085#1090#1077#1088#1074#1072#1083':'
    end
    object Label3: TLabel
      Left = 16
      Top = 93
      Width = 60
      Height = 13
      Caption = #1054#1082#1086#1085#1095#1072#1085#1080#1077':'
    end
    object JvTimeEdit1: TJvTimeEdit
      Left = 80
      Top = 21
      Width = 65
      Height = 21
      TabOrder = 0
    end
    object JvTimeEdit2: TJvTimeEdit
      Left = 80
      Top = 55
      Width = 65
      Height = 21
      TabOrder = 1
    end
    object JvTimeEdit3: TJvTimeEdit
      Left = 80
      Top = 90
      Width = 65
      Height = 21
      TabOrder = 2
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 255
    Width = 296
    Height = 48
    Align = alBottom
    TabOrder = 4
    object Button1: TButton
      Left = 133
      Top = 14
      Width = 75
      Height = 25
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 0
    end
    object Button2: TButton
      Left = 214
      Top = 14
      Width = 75
      Height = 25
      Caption = #1054#1090#1084#1077#1085#1072
      ModalResult = 2
      TabOrder = 1
    end
  end
  object Button_GetFileName: TButton
    Left = 269
    Top = 94
    Width = 23
    Height = 21
    Hint = #1042#1099#1073#1088#1072#1090#1100' '#1092#1072#1081#1083
    Caption = '...'
    Enabled = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 5
    OnClick = Button_GetFileNameClick
  end
  object Edit_Param: TEdit
    Left = 3
    Top = 94
    Width = 262
    Height = 21
    Enabled = False
    TabOrder = 6
  end
  object OpenDialog1: TOpenDialog
    Left = 185
    Top = 135
  end
end
