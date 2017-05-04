object FileHistoryForm: TFileHistoryForm
  Left = 0
  Top = 0
  Caption = 'File history'
  ClientHeight = 507
  ClientWidth = 888
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 193
    Width = 888
    Height = 3
    Cursor = crVSplit
    Align = alTop
    ExplicitLeft = 2
    ExplicitTop = 199
    ExplicitWidth = 886
  end
  object pnlGraph: TPanel
    Left = 0
    Top = 0
    Width = 888
    Height = 193
    Align = alTop
    Caption = 'pnlGraph'
    TabOrder = 0
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 196
    Width = 888
    Height = 311
    ActivePage = tabView
    Align = alClient
    TabOrder = 1
    object tabView: TTabSheet
      Caption = 'View'
    end
    object tabDiff: TTabSheet
      Caption = 'Diff'
      ImageIndex = 1
    end
    object tabAnnotate: TTabSheet
      Caption = 'Annotate'
      ImageIndex = 2
    end
  end
end
