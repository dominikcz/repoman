object DiffForm: TDiffForm
  Left = 0
  Top = 0
  Caption = 'DiffForm'
  ClientHeight = 477
  ClientWidth = 753
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object pnlMain: TPanel
    Left = 49
    Top = 0
    Width = 704
    Height = 477
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object Splitter1: TSplitter
      Left = 465
      Top = 0
      Height = 477
      ExplicitLeft = 315
      ExplicitHeight = 418
    end
    object pnlLeft: TPanel
      Left = 0
      Top = 0
      Width = 465
      Height = 477
      Align = alLeft
      BevelOuter = bvNone
      Caption = 'pnlLeft'
      TabOrder = 0
      object pnlCaptionLeft: TPanel
        Left = 0
        Top = 0
        Width = 465
        Height = 20
        Align = alTop
        Alignment = taLeftJustify
        TabOrder = 0
      end
    end
    object pnlRight: TPanel
      Left = 468
      Top = 0
      Width = 236
      Height = 477
      Align = alClient
      BevelOuter = bvNone
      Caption = 'pnlRight'
      TabOrder = 1
      object pnlCaptionRight: TPanel
        Left = 0
        Top = 0
        Width = 236
        Height = 20
        Align = alTop
        Alignment = taLeftJustify
        TabOrder = 0
      end
    end
  end
  object pnlNavigation: TPanel
    Left = 0
    Top = 0
    Width = 49
    Height = 477
    Align = alLeft
    BevelInner = bvLowered
    BorderWidth = 1
    TabOrder = 1
    Visible = False
    object pbScrollPosMarker: TPaintBox
      Left = 3
      Top = 3
      Width = 43
      Height = 471
      Align = alClient
      Color = clBtnFace
      ParentColor = False
      ExplicitLeft = 2
      ExplicitTop = 2
      ExplicitWidth = 17
      ExplicitHeight = 473
    end
  end
end
