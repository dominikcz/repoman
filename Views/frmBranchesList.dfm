object BranchesListForm: TBranchesListForm
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'Branches list'
  ClientHeight = 353
  ClientWidth = 270
  Color = clWhite
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
  object branchesTree: TVirtualStringTree
    Left = 0
    Top = 0
    Width = 270
    Height = 304
    Align = alClient
    BevelInner = bvNone
    BevelOuter = bvNone
    Header.AutoSizeIndex = -1
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.Height = 21
    Header.Options = [hoColumnResize, hoDrag, hoShowImages, hoShowSortGlyphs, hoVisible, hoHeightResize]
    Header.SortColumn = 0
    IncrementalSearch = isAll
    Indent = 20
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    TreeOptions.AutoOptions = [toAutoDropExpand, toAutoScroll, toAutoScrollOnExpand, toAutoSort, toAutoTristateTracking, toAutoDeleteMovedNodes, toAutoChangeScale]
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toCheckSupport, toFullRepaintOnResize, toGridExtensions, toInitOnSave, toToggleOnDblClick, toWheelPanning, toReadOnly, toEditOnClick]
    TreeOptions.PaintOptions = [toPopupMode, toShowButtons, toShowDropmark, toShowRoot, toShowTreeLines, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toFullRowSelect, toMultiSelect]
    ExplicitTop = -6
    Columns = <
      item
        CheckBox = True
        Position = 0
        Width = 133
        WideText = 'branch'
        WideHint = 'branch'
      end
      item
        Position = 1
        Width = 128
        WideText = 'last activity'
        WideHint = 'lastActivityAsString'
      end
      item
        Position = 2
        Width = 115
        WideText = 'last revision'
      end>
  end
  object Panel1: TPanel
    Left = 0
    Top = 304
    Width = 270
    Height = 49
    Align = alBottom
    BevelOuter = bvNone
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 1
    DesignSize = (
      270
      49)
    object btnCancel: TButton
      Left = 11
      Top = 12
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 0
    end
    object btnOK: TButton
      Left = 185
      Top = 12
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 1
    end
  end
end
