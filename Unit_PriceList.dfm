object Form_PriceList: TForm_PriceList
  Left = 0
  Top = 0
  Caption = #1055#1088#1072#1081#1089' '#1083#1080#1089#1090
  ClientHeight = 468
  ClientWidth = 742
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 13
  object DBGrid1: TDBGrid
    Left = 0
    Top = 0
    Width = 742
    Height = 468
    Align = alClient
    DataSource = mData.DataSource_refPriceList
    PopupMenu = PopupMenu1
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    OnDblClick = DBGrid1DblClick
    Columns = <
      item
        Expanded = False
        FieldName = 'id'
        Width = 73
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'idGoods'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'idPriceType'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'idUnit'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'idPayType'
        Visible = False
      end
      item
        Expanded = False
        FieldName = 'Price'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'deleted'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'verstamp'
        Visible = False
      end>
  end
  object PopupMenu1: TPopupMenu
    Left = 400
    Top = 185
    object N1: TMenuItem
      Caption = #1048#1085#1092#1086#1088#1084#1072#1094#1080#1103'...'
      OnClick = DBGrid1DblClick
    end
  end
end
