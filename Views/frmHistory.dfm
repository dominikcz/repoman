object HistoryForm: THistoryForm
  Left = 0
  Top = 0
  Caption = 'History browser'
  ClientHeight = 558
  ClientWidth = 1060
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object history: TVirtualStringTree
    Left = 0
    Top = 0
    Width = 1060
    Height = 539
    Align = alClient
    AutoScrollDelay = 0
    BevelInner = bvNone
    BevelOuter = bvNone
    ClipboardFormats.Strings = (
      'CSV')
    Header.AutoSizeIndex = -1
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.Height = 20
    Header.MainColumn = 1
    Header.Options = [hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
    Images = Repo.repoIcons
    Indent = 20
    PopupMenu = PopupActionBar1
    TabOrder = 0
    TreeOptions.AutoOptions = [toAutoDropExpand, toAutoScroll, toAutoScrollOnExpand, toAutoSort, toAutoTristateTracking, toAutoDeleteMovedNodes, toAutoChangeScale]
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toFullRepaintOnResize, toGridExtensions, toInitOnSave, toToggleOnDblClick, toWheelPanning, toReadOnly, toEditOnClick]
    TreeOptions.PaintOptions = [toPopupMode, toShowButtons, toShowDropmark, toShowRoot, toShowTreeLines, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toFullRowSelect]
    Columns = <
      item
        Position = 0
        Width = 25
        WideText = 'op'
      end
      item
        Position = 1
        Width = 106
        WideText = 'date'
        WideHint = 'dtAsStr'
      end
      item
        Position = 2
        Width = 105
        WideText = 'user'
        WideHint = 'user'
      end
      item
        Position = 3
        Width = 476
        WideText = 'object'
        WideHint = 'filePath'
      end
      item
        Position = 4
        Width = 116
        WideText = 'revision/branch'
        WideHint = 'revisionOrBranch'
      end
      item
        Position = 5
        Width = 128
        WideText = 'host'
        WideHint = 'host'
      end>
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 539
    Width = 1060
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object ActionList1: TActionList
    Left = 80
    Top = 56
    object EditCopy1: TEditCopy
      Category = 'Edit'
      Caption = '&Copy'
      Hint = 'Copy|Copies the selection and puts it on the Clipboard'
      ImageIndex = 1
      ShortCut = 16451
      OnExecute = EditCopy1Execute
    end
  end
  object PopupActionBar1: TPopupActionBar
    Left = 416
    Top = 224
    object Copy1: TMenuItem
      Action = EditCopy1
    end
  end
end
