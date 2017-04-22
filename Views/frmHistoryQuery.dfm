object HistoryQueryForm: THistoryQueryForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'History'
  ClientHeight = 154
  ClientWidth = 468
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 24
    Top = 24
    Width = 49
    Height = 13
    Caption = 'From date'
  end
  object Label2: TLabel
    Left = 288
    Top = 24
    Width = 33
    Height = 13
    Caption = 'Branch'
  end
  object Label3: TLabel
    Left = 144
    Top = 24
    Width = 51
    Height = 13
    Caption = 'User name'
  end
  object edtDate: TDateTimePicker
    Left = 24
    Top = 43
    Width = 97
    Height = 21
    Date = 42847.000000000000000000
    Format = 'yyyy-MM-dd'
    Time = 42847.000000000000000000
    TabOrder = 0
  end
  object edtBranch: TComboBoxEx
    Left = 288
    Top = 43
    Width = 145
    Height = 22
    ItemsEx = <
      item
        Caption = 'aaaaaaaa'
      end>
    TabOrder = 1
  end
  object edtUserName: TEdit
    Left = 144
    Top = 43
    Width = 121
    Height = 21
    TabOrder = 2
  end
  object btnOK: TButton
    Left = 358
    Top = 96
    Width = 75
    Height = 25
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 3
  end
  object Button1: TButton
    Left = 262
    Top = 96
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
  end
end
