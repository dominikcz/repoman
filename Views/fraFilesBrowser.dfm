object ViewFilesBrowser: TViewFilesBrowser
  Left = 0
  Top = 0
  Width = 912
  Height = 454
  TabOrder = 0
  object Splitter1: TSplitter
    Left = 200
    Top = 41
    Height = 321
    ExplicitLeft = 208
    ExplicitTop = 232
    ExplicitHeight = 100
  end
  object Splitter2: TSplitter
    Left = 0
    Top = 362
    Width = 912
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    ExplicitLeft = 188
    ExplicitTop = 65
    ExplicitWidth = 300
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 912
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    Caption = 'pnlTop'
    ShowCaption = False
    TabOrder = 0
    object edtWorkingCopyPath: TEdit
      Left = 8
      Top = 11
      Width = 185
      Height = 21
      TabOrder = 0
      OnExit = edtWorkingCopyPathChange
    end
  end
  object log: TMemo
    Left = 0
    Top = 365
    Width = 912
    Height = 89
    Align = alBottom
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    Lines.Strings = (
      'log')
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 1
  end
  object dirTree: TVirtualStringTree
    Left = 0
    Top = 41
    Width = 200
    Height = 321
    Align = alLeft
    AnimationDuration = 100
    AutoExpandDelay = 0
    AutoScrollDelay = 0
    Header.AutoSizeIndex = 0
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.Height = 18
    Header.Options = [hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
    Images = commonResources.repoIcons
    PopupMenu = Repo.popupDirsActions
    TabOrder = 2
    TreeOptions.AnimationOptions = [toAnimatedToggle]
    TreeOptions.AutoOptions = [toAutoDropExpand, toAutoScroll, toAutoScrollOnExpand, toAutoSort, toAutoTristateTracking, toAutoDeleteMovedNodes, toAutoChangeScale]
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning, toReadOnly, toEditOnClick]
    TreeOptions.PaintOptions = [toPopupMode, toShowButtons, toShowDropmark, toShowRoot, toShowTreeLines, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toFullRowSelect]
    Columns = <
      item
        Position = 0
        Width = 183
        WideText = 'dir'
        WideHint = 'shortPath'
      end>
  end
  object fileList: TVirtualStringTree
    Left = 203
    Top = 41
    Width = 709
    Height = 321
    Align = alClient
    BevelInner = bvNone
    BevelOuter = bvNone
    Header.AutoSizeIndex = 0
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.Options = [hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
    Images = commonResources.repoIcons
    Indent = 20
    PopupMenu = Repo.popupRepoActions
    TabOrder = 3
    TreeOptions.AutoOptions = [toAutoDropExpand, toAutoScroll, toAutoScrollOnExpand, toAutoSort, toAutoTristateTracking, toAutoDeleteMovedNodes, toAutoChangeScale]
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toFullRepaintOnResize, toGridExtensions, toInitOnSave, toToggleOnDblClick, toWheelPanning, toReadOnly, toEditOnClick]
    TreeOptions.PaintOptions = [toPopupMode, toShowButtons, toShowDropmark, toShowRoot, toShowTreeLines, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toFullRowSelect, toMultiSelect]
    Columns = <
      item
        Position = 0
        Width = 215
        WideText = 'file'
        WideHint = 'fileName'
      end
      item
        Position = 1
        WideText = 'ext'
        WideHint = 'ext'
      end
      item
        Position = 2
        Width = 473
        WideText = 'path'
        WideHint = 'shortPath'
      end
      item
        Position = 3
        Width = 80
        WideText = 'state'
        WideHint = 'stateAsStr'
      end
      item
        Position = 4
        Width = 74
        WideText = 'revision'
        WideHint = 'revision'
      end
      item
        Position = 5
        Width = 120
        WideText = 'branch'
        WideHint = 'branch'
      end
      item
        Position = 6
        Width = 120
        WideText = 'mod. date'
        WideHint = 'dtAsStr'
      end>
  end
end
