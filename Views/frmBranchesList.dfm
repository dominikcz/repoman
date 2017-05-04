object BranchesListForm: TBranchesListForm
  Left = 0
  Top = 0
  Caption = 'Branches list'
  ClientHeight = 343
  ClientWidth = 278
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object logoGraph: TVirtualStringTree
    Left = 0
    Top = 0
    Width = 278
    Height = 343
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
    Header.Options = [hoColumnResize, hoDrag, hoShowHint, hoShowSortGlyphs, hoVisible, hoHeightResize]
    Indent = 20
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    TreeOptions.AutoOptions = [toAutoDropExpand, toAutoScroll, toAutoScrollOnExpand, toAutoSort, toAutoTristateTracking, toAutoDeleteMovedNodes, toAutoChangeScale]
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toFullRepaintOnResize, toGridExtensions, toInitOnSave, toToggleOnDblClick, toWheelPanning, toReadOnly, toEditOnClick]
    TreeOptions.PaintOptions = [toPopupMode, toShowButtons, toShowDropmark, toShowRoot, toShowTreeLines, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toFullRowSelect, toMultiSelect]
    ExplicitWidth = 385
    Columns = <
      item
        Position = 0
        Width = 98
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
end
