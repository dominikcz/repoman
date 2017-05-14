object DiffForm: TDiffForm
  Left = 0
  Top = 0
  Caption = 'DiffForm'
  ClientHeight = 520
  ClientWidth = 906
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Icon.Data = {
    0000010001001010100001000400280100001600000028000000100000002000
    000001000400000000000000000000000000000000000000000000000000FF00
    00000000FF008080800000FF0000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000004444
    4444443244444442222222332444443333333333324444333333333334444444
    4424443344444444402444344444444400222222222444400000000000244440
    0000000000444444004444444444444440444412444444422222221124444411
    111111111244441111111111144444444444441144444444444444144444FFCF
    0000E0070000C0030000C0070000FDCF0000F9DF0000F0010000E0010000E003
    0000F3FF0000FBCF0000E0070000C0030000C0070000FFCF0000FFDF0000}
  OldCreateOrder = False
  WindowState = wsMaximized
  PixelsPerInch = 96
  TextHeight = 13
  object ActionToolBar1: TActionToolBar
    Left = 0
    Top = 0
    Width = 906
    Height = 26
    ActionManager = ActionManager1
    Caption = 'ActionToolBar1'
    Color = clMenuBar
    ColorMap.DisabledFontColor = 7171437
    ColorMap.HighlightColor = clWhite
    ColorMap.BtnSelectedFont = clBlack
    ColorMap.UnusedColor = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentBackground = True
    ParentFont = False
    Spacing = 0
  end
  inline FrameDiff: TFrameDiff
    Left = 0
    Top = 26
    Width = 906
    Height = 494
    Align = alClient
    TabOrder = 1
    ExplicitTop = 26
    ExplicitWidth = 906
    ExplicitHeight = 494
    inherited Splitter2: TSplitter
      Height = 494
      ExplicitHeight = 494
    end
    inherited pnlMain: TPanel
      Width = 823
      Height = 494
      ExplicitWidth = 823
      ExplicitHeight = 494
      inherited Splitter1: TSplitter
        Height = 494
        ExplicitHeight = 494
      end
      inherited pnl1: TPanel
        Height = 494
        ExplicitHeight = 494
        inherited FrameEditor1: TFrameEditor
          Height = 484
          ExplicitHeight = 484
          inherited pnlEditor: TPanel
            Height = 459
            ExplicitHeight = 459
            inherited codeEditor: TSynEdit
              Height = 457
              ExplicitHeight = 457
            end
          end
        end
      end
      inherited pnl2: TPanel
        Width = 395
        Height = 494
        ExplicitWidth = 395
        ExplicitHeight = 494
        inherited FrameEditor2: TFrameEditor
          Width = 385
          Height = 484
          ExplicitWidth = 385
          ExplicitHeight = 484
          inherited pnlEditor: TPanel
            Width = 385
            Height = 459
            ExplicitWidth = 385
            ExplicitHeight = 459
            inherited codeEditor: TSynEdit
              Width = 383
              Height = 457
              ExplicitWidth = 383
              ExplicitHeight = 457
            end
          end
          inherited pnlCaption: TPanel
            Width = 385
            ExplicitWidth = 385
          end
        end
      end
    end
    inherited pnlNavigation: TPanel
      Height = 494
      ExplicitHeight = 494
      inherited pbScrollPosMarker: TPaintBox
        Height = 488
      end
    end
    inherited PngImageList1: TPngImageList
      Bitmap = {}
    end
  end
  object ActionManager1: TActionManager
    ActionBars = <
      item
        Items.CaptionOptions = coNone
        Items = <
          item
            Caption = '&actSave'
            ImageIndex = 0
            ShortCut = 16467
          end
          item
            Caption = 'a&ctUndo'
            ImageIndex = 1
          end
          item
            Caption = 'ac&tRedo'
            ImageIndex = 2
          end
          item
            Caption = '-'
          end
          item
            Caption = 'act&Next'
            ImageIndex = 3
          end
          item
            Caption = 'act&Prev'
            ImageIndex = 4
          end
          item
            Caption = '-'
          end
          item
            Caption = 'actC&urrent'
            ImageIndex = 6
          end
          item
            Caption = 'act&First'
            ImageIndex = 5
          end
          item
            Caption = 'act&Last'
            ImageIndex = 7
          end
          item
            Caption = '-'
          end
          item
            Caption = 'actC&opyRight'
            ImageIndex = 8
          end
          item
            Caption = 'actCop&yLeft'
            ImageIndex = 9
          end
          item
            Caption = '-'
          end
          item
            Caption = 'actCopy&RightAndNext'
            ImageIndex = 10
          end
          item
            Caption = 'actCopyL&eftAndNext'
            ImageIndex = 11
          end
          item
            Caption = '-'
          end
          item
            Caption = 'actAllR&ight'
            ImageIndex = 12
          end
          item
            Caption = 'ActionClientItem18'
            ImageIndex = 13
          end
          item
            Caption = '-'
          end
          item
            Caption = '&diffs only'
            ImageIndex = 15
          end
          item
            Caption = 'actRefre&sh'
            ImageIndex = 14
          end>
        ActionBar = ActionToolBar1
      end>
    LinkedActionLists = <
      item
        ActionList = FrameDiff.ActionList1
        Caption = 'ActionList1'
      end>
    Images = FrameDiff.PngImageList1
    Left = 657
    Top = 125
    StyleName = 'Platform Default'
  end
end
