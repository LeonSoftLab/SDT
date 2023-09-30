object Form_Mustok: TForm_Mustok
  Left = 0
  Top = 0
  ClientHeight = 523
  ClientWidth = 738
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 738
    Height = 523
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = #1058#1080#1087#1099' '#1084#1072#1089#1090#1086#1082#1086#1074
      object DBGrid_Mustok_Type: TDBGrid
        Left = 0
        Top = 26
        Width = 730
        Height = 469
        Align = alClient
        DataSource = mData.DataSource_Mustok_Type
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
      end
      object ToolBar1: TToolBar
        Left = 0
        Top = 0
        Width = 730
        Height = 26
        Caption = 'ToolBar1'
        TabOrder = 1
        object DBNavigator_Mustok_Type: TDBNavigator
          Left = 0
          Top = 0
          Width = 730
          Height = 22
          DataSource = mData.DataSource_Mustok_Type
          TabOrder = 0
        end
      end
    end
    object TabSheet2: TTabSheet
      Caption = #1052#1072#1089#1090#1086#1082#1080
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object DBGrid_Mustok: TDBGrid
        Left = 0
        Top = 23
        Width = 730
        Height = 472
        Align = alClient
        DataSource = mData.DataSource_Mustok
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
      end
      object ToolBar2: TToolBar
        Left = 0
        Top = 0
        Width = 730
        Height = 23
        Caption = 'ToolBar2'
        TabOrder = 1
        object DBNavigator_Mustok: TDBNavigator
          Left = 0
          Top = 0
          Width = 730
          Height = 22
          DataSource = mData.DataSource_Mustok
          TabOrder = 0
        end
      end
    end
    object TabSheet3: TTabSheet
      Caption = #1057#1090#1088#1086#1082#1080' '#1084#1072#1089#1090#1086#1082#1072
      ImageIndex = 2
      object DBGrid_Mustok_Rows: TDBGrid
        Left = 0
        Top = 41
        Width = 730
        Height = 454
        Align = alClient
        DataSource = mData.DataSource_Mustok_Row
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
      end
      object ToolBar3: TToolBar
        Left = 0
        Top = 0
        Width = 730
        Height = 23
        Caption = 'ToolBar3'
        TabOrder = 1
        object DBNavigator_Mustok_Rows: TDBNavigator
          Left = 0
          Top = 0
          Width = 320
          Height = 22
          DataSource = mData.DataSource_Mustok_Row
          TabOrder = 0
        end
        object Button_AddGoods: TButton
          Left = 320
          Top = 0
          Width = 231
          Height = 22
          Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1085#1077#1089#1082#1086#1083#1100#1082#1086' '#1090#1086#1074#1072#1088#1086#1074
          TabOrder = 1
          OnClick = Button_AddGoodsClick
        end
      end
      object ToolBar4: TToolBar
        Left = 0
        Top = 23
        Width = 730
        Height = 18
        ButtonHeight = 19
        Caption = 'ToolBar4'
        TabOrder = 2
        object Label_Good_Info: TLabel
          Left = 0
          Top = 0
          Width = 82
          Height = 19
          Caption = 'Label_Good_Info'
        end
      end
    end
  end
end
