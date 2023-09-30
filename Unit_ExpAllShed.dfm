object Form_ExpAllShed: TForm_ExpAllShed
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = #1050#1086#1085#1089#1090#1088#1091#1082#1090#1086#1088' '#1092#1086#1088#1084#1080#1088#1086#1074#1072#1085#1080#1103' '#1076#1072#1085#1085#1099#1093' '#1076#1083#1103' '#1082#1087#1082
  ClientHeight = 672
  ClientWidth = 597
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 13
    Top = 88
    Width = 95
    Height = 13
    Caption = #1057#1087#1080#1089#1086#1082' '#1084#1072#1088#1096#1088#1091#1090#1086#1074
  end
  object Label2: TLabel
    Left = 285
    Top = 37
    Width = 35
    Height = 13
    Caption = #1056#1077#1075#1080#1086#1085
  end
  object Label4: TLabel
    Left = 285
    Top = 64
    Width = 56
    Height = 13
    Caption = #1055#1088#1072#1081#1089' '#1083#1080#1089#1090
  end
  object ListBox_Do: TListBox
    Left = 8
    Top = 107
    Width = 191
    Height = 209
    ItemHeight = 13
    TabOrder = 0
    OnDblClick = ListBox_DoDblClick
    OnKeyUp = ListBox_DoKeyUp
  end
  object Button_AddAllRoutes: TButton
    Left = 390
    Top = 3
    Width = 198
    Height = 25
    Hint = #1044#1086#1073#1072#1074#1083#1103#1077#1090' '#1082' '#1089#1087#1080#1089#1082#1091' '#1074#1089#1077' '#1089#1091#1097#1077#1089#1090#1074#1091#1102#1097#1080#1077' '#1084#1072#1088#1096#1088#1091#1090#1099
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1074#1089#1077' '#1084#1072#1088#1096#1088#1091#1090#1099
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    OnClick = Button_AddAllRoutesClick
  end
  object ComboBox_Regions: TComboBox
    Left = 8
    Top = 34
    Width = 271
    Height = 21
    TabOrder = 2
    Text = #1044#1085#1077#1087#1088#1086#1087#1077#1090#1088#1086#1074#1089#1082
    Items.Strings = (
      #1050#1080#1077#1074
      #1061#1072#1088#1100#1082#1086#1074
      #1044#1086#1085#1077#1094#1082
      #1044#1085#1077#1087#1088#1086#1087#1077#1090#1088#1086#1074#1089#1082
      #1047#1072#1087#1086#1088#1086#1078#1100#1077
      #1051#1100#1074#1086#1074
      #1054#1076#1077#1089#1089#1072
      #1055#1086#1083#1090#1072#1074#1072
      #1050#1088#1080#1074#1086#1081' '#1088#1086#1075
      #1063#1077#1088#1082#1072#1089#1089#1099
      #1057#1077#1074#1072#1089#1090#1086#1087#1086#1083#1100
      #1042#1080#1085#1085#1080#1094#1072
      #1053#1080#1082#1086#1083#1072#1077#1074)
  end
  object Button_AddRoutesByRegion: TButton
    Left = 390
    Top = 34
    Width = 198
    Height = 25
    Hint = 
      #1044#1086#1073#1072#1074#1083#1103#1077#1090' '#1074#1089#1077' '#1089#1091#1097#1077#1089#1090#1074#1091#1102#1097#1080#1077' '#1084#1072#1088#1096#1088#1091#1090#1099' '#1086#1090#1085#1086#1089#1103#1097#1080#1077#1089#1103' '#1082' '#1074#1099#1073#1088#1072#1085#1085#1086#1084#1091' '#1088#1077#1075 +
      #1080#1086#1085#1091
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1084#1072#1088#1096#1088#1091#1090#1099' '#1087#1086' '#1088#1077#1075#1080#1086#1085#1091
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
    OnClick = Button_AddRoutesByRegionClick
  end
  object Button_AddRoutesByCodePrice: TButton
    Left = 390
    Top = 65
    Width = 198
    Height = 25
    Hint = 
      #1044#1086#1073#1072#1074#1083#1103#1077#1090' '#1074#1089#1077' '#1089#1091#1097#1077#1089#1090#1074#1091#1102#1097#1080#1077' '#1084#1072#1088#1096#1088#1091#1090#1099', '#1090#1088#1090' '#1082#1086#1090#1086#1088#1099#1093' '#1080#1089#1087#1086#1083#1100#1079#1091#1102#1090' '#1074#1099#1073#1088 +
      #1072#1085#1085#1099#1081' '#1087#1088#1072#1081#1089
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1084#1072#1088#1096#1088#1091#1090#1099' '#1087#1086' '#8470' '#1087#1088#1072#1081#1089#1072
    ParentShowHint = False
    ShowHint = True
    TabOrder = 4
    OnClick = Button_AddRoutesByCodePriceClick
  end
  object ComboBox_PriceTypes: TComboBox
    Left = 102
    Top = 61
    Width = 177
    Height = 21
    TabOrder = 5
  end
  object Button_UpdateInfo: TButton
    Left = 8
    Top = 61
    Width = 88
    Height = 21
    Caption = #1054#1073#1085#1086#1074#1080#1090#1100' ->'
    TabOrder = 6
    OnClick = Button_UpdateInfoClick
  end
  object Button_Exec: TButton
    Left = 205
    Top = 277
    Width = 174
    Height = 39
    Cursor = crHandPoint
    Caption = #1047#1072#1087#1091#1089#1090#1080#1090#1100' '#1092#1086#1088#1084#1080#1088#1086#1074#1072#1085#1080#1077
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 7
    OnClick = Button_ExecClick
  end
  object ProgressBar1: TProgressBar
    Left = 0
    Top = 637
    Width = 597
    Height = 16
    Align = alBottom
    Smooth = True
    TabOrder = 8
  end
  object GroupBox1: TGroupBox
    Left = 205
    Top = 107
    Width = 174
    Height = 164
    Caption = #1057#1090#1072#1090#1080#1089#1090#1080#1082#1072':'
    TabOrder = 9
    object Label3: TLabel
      Left = 10
      Top = 15
      Width = 132
      Height = 13
      Caption = #1059#1076#1072#1095#1085#1086' '#1089#1092#1086#1088#1084#1080#1088#1086#1074#1072#1085#1085#1099#1093':'
    end
    object Label_Complete: TLabel
      Left = 10
      Top = 29
      Width = 8
      Height = 16
      Caption = '0'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGreen
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label5: TLabel
      Left = 10
      Top = 65
      Width = 64
      Height = 13
      Caption = #1057' '#1086#1096#1080#1073#1082#1072#1084#1080':'
    end
    object Label_Error: TLabel
      Left = 10
      Top = 79
      Width = 8
      Height = 16
      Caption = '0'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGreen
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label7: TLabel
      Left = 10
      Top = 115
      Width = 64
      Height = 13
      Caption = #1042' '#1086#1078#1080#1076#1072#1085#1080#1080':'
    end
    object Label_Wait: TLabel
      Left = 10
      Top = 129
      Width = 8
      Height = 16
      Caption = '0'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGreen
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object Button_ClearList: TButton
    Left = 390
    Top = 96
    Width = 198
    Height = 25
    Hint = #1054#1095#1080#1097#1072#1077#1090' '#1089#1087#1080#1089#1086#1082' '#1086#1078#1080#1076#1072#1102#1097#1080#1093' '#1084#1072#1088#1096#1088#1091#1090#1086#1074
    Caption = #1054#1095#1080#1089#1090#1080#1090#1100' '#1089#1087#1080#1089#1086#1082
    ParentShowHint = False
    ShowHint = True
    TabOrder = 10
    OnClick = Button_ClearListClick
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 653
    Width = 597
    Height = 19
    Panels = <>
    SimplePanel = True
    SimpleText = #1057#1086#1089#1090#1086#1103#1085#1080#1077':'
  end
  object Button_SaveToPlan: TButton
    Left = 390
    Top = 127
    Width = 198
    Height = 25
    Hint = #1057#1086#1093#1088#1072#1085#1103#1077#1090' '#1089#1087#1080#1089#1086#1082' '#1084#1072#1088#1096#1088#1091#1090#1086#1074' '#1074' '#1091#1082#1072#1079#1072#1085#1085#1099#1081' '#1092#1072#1081#1083
    Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1089#1087#1080#1089#1086#1082
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 12
    OnClick = Button_SaveToPlanClick
  end
  object Memo_Log: TMemo
    Left = 0
    Top = 322
    Width = 597
    Height = 315
    Align = alBottom
    Color = clCream
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 13
  end
  object CheckBox_Deleted: TCheckBox
    Left = 8
    Top = 8
    Width = 271
    Height = 17
    Caption = #1059#1095#1080#1090#1099#1074#1072#1090#1100' '#1091#1076#1072#1083#1077#1085#1085#1099#1077
    TabOrder = 14
  end
  object Button_LoadFromPlan: TButton
    Left = 390
    Top = 158
    Width = 198
    Height = 25
    Hint = #1047#1072#1075#1088#1091#1078#1072#1077#1090' '#1079#1072#1088#1072#1085#1077#1077' '#1089#1086#1093#1088#1072#1085#1077#1085#1085#1099#1081' '#1092#1072#1081#1083' '#1089#1086' '#1089#1087#1080#1089#1082#1086#1084' '#1084#1072#1088#1096#1088#1091#1090#1086#1074
    Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100' '#1089#1087#1080#1089#1086#1082
    ParentShowHint = False
    ShowHint = True
    TabOrder = 15
    OnClick = Button_LoadFromPlanClick
  end
  object Button_UpdatePriceList: TButton
    Left = 385
    Top = 272
    Width = 146
    Height = 25
    Caption = #1054#1073#1085#1086#1074#1080#1090#1100' '#1087#1088#1072#1081#1089#1099' '#1087#1086' '#1058#1056#1058
    TabOrder = 16
    OnClick = Button_UpdatePriceListClick
  end
  object Button_DeleteTables: TButton
    Left = 385
    Top = 296
    Width = 146
    Height = 25
    Caption = #1059#1076#1072#1083#1080#1090#1100' '#1089#1090#1072#1088#1099#1077' '#1076#1072#1085#1085#1099#1077
    TabOrder = 17
    OnClick = Button_DeleteTablesClick
  end
  object SaveDialog1: TSaveDialog
    Filter = #1050#1086#1085#1092#1080#1075#1060#1072#1081#1083'(cfg)|*.cfg'
    Title = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1089#1087#1080#1089#1086#1082' '#1084#1072#1088#1096#1088#1091#1090#1086#1074
    Left = 550
    Top = 125
  end
  object OpenDialog1: TOpenDialog
    Filter = #1050#1086#1085#1092#1080#1075#1060#1072#1081#1083#1099'(cfg)|*.cfg'
    Title = #1042#1099#1073#1077#1088#1080#1090#1077' '#1092#1072#1081#1083' '#1089#1086' '#1089#1087#1080#1089#1082#1086#1084' '#1084#1072#1088#1096#1088#1091#1090#1086#1074
    Left = 400
    Top = 155
  end
end
