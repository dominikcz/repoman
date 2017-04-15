object ViewFilesBrowser: TViewFilesBrowser
  Left = 0
  Top = 0
  Width = 963
  Height = 454
  TabOrder = 0
  object Splitter1: TSplitter
    Left = 200
    Top = 57
    Height = 305
    ExplicitLeft = 208
    ExplicitTop = 232
    ExplicitHeight = 100
  end
  object Splitter2: TSplitter
    Left = 0
    Top = 362
    Width = 963
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
    Width = 963
    Height = 57
    Align = alTop
    BevelOuter = bvNone
    Caption = 'pnlTop'
    ShowCaption = False
    TabOrder = 0
    object btnFlatMode: TSpeedButton
      Left = 234
      Top = 30
      Width = 80
      Height = 21
      Action = Repo.actFlatMode
      AllowAllUp = True
    end
    object btnModifiedOnly: TSpeedButton
      Left = 321
      Top = 30
      Width = 73
      Height = 21
      Action = Repo.actModifiedOnly
      AllowAllUp = True
    end
    object btnShowUnversioned: TSpeedButton
      Left = 400
      Top = 30
      Width = 89
      Height = 21
      Action = Repo.actShowUnversioned
      AllowAllUp = True
    end
    object btnShowIgnored: TSpeedButton
      Left = 494
      Top = 30
      Width = 81
      Height = 21
      Action = Repo.actShowIgnored
      AllowAllUp = True
    end
    object edtWorkingCopyPath: TEdit
      Left = 10
      Top = 30
      Width = 185
      Height = 21
      TabOrder = 0
      OnExit = edtWorkingCopyPathChange
    end
    object Button1: TButton
      Left = 672
      Top = 29
      Width = 75
      Height = 25
      Action = Repo.actRefresh
      TabOrder = 1
    end
  end
  object log: TMemo
    Left = 0
    Top = 365
    Width = 963
    Height = 89
    Align = alBottom
    Lines.Strings = (
      'log')
    TabOrder = 1
  end
  object dirTree: TVirtualStringTree
    Left = 0
    Top = 57
    Width = 200
    Height = 305
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
    Images = Repo.repoIcons
    TabOrder = 2
    TreeOptions.AnimationOptions = [toAnimatedToggle]
    TreeOptions.AutoOptions = [toAutoDropExpand, toAutoScroll, toAutoScrollOnExpand, toAutoSort, toAutoTristateTracking, toAutoDeleteMovedNodes, toAutoChangeScale]
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning, toReadOnly, toEditOnClick]
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
    Top = 57
    Width = 760
    Height = 305
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
    Images = Repo.repoIcons
    Indent = 20
    TabOrder = 3
    TreeOptions.AutoOptions = [toAutoDropExpand, toAutoScroll, toAutoScrollOnExpand, toAutoSort, toAutoTristateTracking, toAutoDeleteMovedNodes, toAutoChangeScale]
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toFullRepaintOnResize, toGridExtensions, toInitOnSave, toToggleOnDblClick, toWheelPanning, toReadOnly, toEditOnClick]
    TreeOptions.SelectionOptions = [toFullRowSelect]
    Columns = <
      item
        Position = 0
        Width = 200
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
        Width = 300
        WideText = 'path'
        WideHint = 'shortPath'
      end
      item
        Position = 3
        WideText = 'state'
        WideHint = 'stateAsStr'
      end
      item
        Position = 4
        WideText = 'revision'
        WideHint = 'revision'
      end
      item
        Position = 5
        Width = 150
        WideText = 'branch'
        WideHint = 'branch'
      end>
  end
end
