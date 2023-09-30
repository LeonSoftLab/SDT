object Form_Add_Goods: TForm_Add_Goods
  Left = 0
  Top = 0
  Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1085#1077#1089#1082#1086#1083#1100#1082#1086' '#1090#1086#1074#1072#1088#1086#1074
  ClientHeight = 664
  ClientWidth = 1089
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 6
    Width = 83
    Height = 13
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1090#1086#1074#1072#1088
  end
  object Label2: TLabel
    Left = 727
    Top = 8
    Width = 127
    Height = 13
    Caption = #1042#1099#1073#1088#1072#1090#1100' '#1075#1088#1091#1087#1087#1091' '#1090#1086#1074#1072#1088#1086#1074
  end
  object DBGrid1: TDBGrid
    Left = 8
    Top = 25
    Width = 713
    Height = 565
    DataSource = mData.DataSource_Goods
    ReadOnly = True
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object DBGrid2: TDBGrid
    Left = 727
    Top = 25
    Width = 356
    Height = 565
    DataSource = mData.DataSource_Goods_Type
    ReadOnly = True
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object Button1: TButton
    Left = 8
    Top = 596
    Width = 88
    Height = 21
    Caption = #1054#1073#1085#1086#1074#1080#1090#1100
    TabOrder = 2
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 727
    Top = 595
    Width = 74
    Height = 22
    Caption = #1054#1073#1085#1086#1074#1080#1090#1100
    TabOrder = 3
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 245
    Top = 620
    Width = 469
    Height = 36
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 4
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 950
    Top = 623
    Width = 133
    Height = 25
    Caption = #1042#1099#1073#1088#1072#1090#1100
    TabOrder = 5
    OnClick = Button4Click
  end
  object Edit1: TEdit
    Left = 102
    Top = 596
    Width = 619
    Height = 21
    TabOrder = 6
    Text = 
      'USE workdb4_7 SELECT * FROM [workdb4_7].[dbo].[refGoods] WHERE d' +
      'eleted=0'
  end
  object Edit2: TEdit
    Left = 807
    Top = 596
    Width = 276
    Height = 21
    TabOrder = 7
    Text = 
      'USE workdb4_7 SELECT * FROM [workdb4_7].[dbo].[refGoodsGroups] W' +
      'HERE deleted=0'
  end
end
