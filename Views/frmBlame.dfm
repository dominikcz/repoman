object BlameForm: TBlameForm
  Left = 0
  Top = 0
  Caption = 'Annotate/blame'
  ClientHeight = 769
  ClientWidth = 1112
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object tabs: TPageControl
    Left = 0
    Top = 0
    Width = 1112
    Height = 769
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 808
    ExplicitHeight = 513
  end
end
