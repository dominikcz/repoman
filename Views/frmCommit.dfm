object FormCommit: TFormCommit
  Left = 0
  Top = 0
  Caption = 'Commit'
  ClientHeight = 705
  ClientWidth = 1045
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
  object leftPanel: TPanel
    Left = 0
    Top = 0
    Width = 449
    Height = 705
    Align = alLeft
    BevelOuter = bvNone
    Caption = 'leftPanel'
    ShowCaption = False
    TabOrder = 0
    object Splitter1: TSplitter
      Left = 0
      Top = 238
      Width = 449
      Height = 3
      Cursor = crVSplit
      Align = alTop
      ExplicitLeft = 2
      ExplicitTop = 273
      ExplicitWidth = 447
    end
    object Splitter2: TSplitter
      Left = 0
      Top = 516
      Width = 449
      Height = 3
      Cursor = crVSplit
      Align = alBottom
      ExplicitLeft = -6
      ExplicitTop = 456
    end
    object pnlUnstaged: TPanel
      Left = 0
      Top = 0
      Width = 449
      Height = 238
      Align = alTop
      BevelOuter = bvNone
      Caption = 'pnlUnstaged'
      TabOrder = 0
      object vstAvailableFiles: TVirtualStringTree
        Left = 0
        Top = 26
        Width = 449
        Height = 212
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
        Header.SortColumn = 0
        Images = commonResources.repoIcons
        Indent = 22
        PopupMenu = PopupActionBar1
        TabOrder = 0
        TreeOptions.MiscOptions = [toAcceptOLEDrop, toFullRepaintOnResize, toGridExtensions, toInitOnSave, toToggleOnDblClick, toWheelPanning, toEditOnClick]
        TreeOptions.SelectionOptions = [toMultiSelect]
        Columns = <
          item
            Position = 0
            Width = 381
            WideText = 'available files'
            WideHint = 'shortPath'
          end
          item
            Position = 1
            Width = 55
            WideText = 'state'
            WideHint = 'stateAsStr'
          end>
      end
      object ActionToolBar2: TActionToolBar
        Left = 0
        Top = 0
        Width = 449
        Height = 26
        ActionManager = ActionManager1
        Caption = 'ActionToolBar2'
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
        ParentFont = False
        Spacing = 0
      end
    end
    object pnlStaged: TPanel
      Left = 0
      Top = 241
      Width = 449
      Height = 275
      Align = alClient
      BevelOuter = bvNone
      Caption = 'pnlStaged'
      TabOrder = 1
      object stagingPanel: TPanel
        Left = 0
        Top = 0
        Width = 449
        Height = 40
        Align = alTop
        BevelOuter = bvNone
        Caption = 'filterPanel'
        ShowCaption = False
        TabOrder = 0
        DesignSize = (
          449
          40)
        object Label1: TLabel
          Left = 90
          Top = 13
          Width = 39
          Height = 13
          Caption = 'unstage'
        end
        object Label2: TLabel
          Left = 333
          Top = 13
          Width = 27
          Height = 13
          Anchors = [akTop, akRight]
          Caption = 'stage'
        end
        object PngSpeedButton1: TPngSpeedButton
          Left = 10
          Top = 8
          Width = 33
          Height = 22
          Action = actUnstageAll
        end
        object PngSpeedButton2: TPngSpeedButton
          Left = 49
          Top = 8
          Width = 33
          Height = 22
          Action = actUnstageSelected
        end
        object PngSpeedButton3: TPngSpeedButton
          Left = 365
          Top = 8
          Width = 33
          Height = 22
          Action = actStageSelected
        end
        object PngSpeedButton4: TPngSpeedButton
          Left = 404
          Top = 8
          Width = 33
          Height = 22
          Action = actStageAll
        end
      end
      object vstStagedFiles: TVirtualStringTree
        Left = 0
        Top = 40
        Width = 449
        Height = 235
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
        Header.SortColumn = 0
        Images = commonResources.repoIcons
        Indent = 20
        TabOrder = 1
        TreeOptions.MiscOptions = [toAcceptOLEDrop, toFullRepaintOnResize, toGridExtensions, toInitOnSave, toToggleOnDblClick, toWheelPanning, toEditOnClick]
        TreeOptions.SelectionOptions = [toMultiSelect]
        Columns = <
          item
            Position = 0
            Width = 381
            WideText = 'staged files'
            WideHint = 'shortPath'
          end
          item
            Position = 1
            Width = 58
            WideText = 'state'
            WideHint = 'stateAsStr'
          end>
      end
    end
    object pnlCommit: TPanel
      Left = 0
      Top = 519
      Width = 449
      Height = 186
      Align = alBottom
      BevelOuter = bvNone
      Caption = 'pnlCommit'
      ShowCaption = False
      TabOrder = 2
      object commitMsg: TMemo
        AlignWithMargins = True
        Left = 0
        Top = 40
        Width = 449
        Height = 146
        Margins.Left = 0
        Margins.Top = 40
        Margins.Right = 0
        Margins.Bottom = 0
        Align = alClient
        ScrollBars = ssBoth
        TabOrder = 0
      end
      object cbPrevMessages: TComboBox
        Left = 10
        Top = 10
        Width = 349
        Height = 21
        TabOrder = 1
        OnChange = cbPrevMessagesChange
      end
      object PngBitBtn1: TPngBitBtn
        Left = 365
        Top = 8
        Width = 72
        Height = 25
        Action = actCommit
        Caption = 'commit'
        TabOrder = 2
      end
    end
  end
  object alStaggingActions: TActionList
    Images = commonResources.repoIcons
    Left = 256
    Top = 144
    object actUnstageSelected: TAction
      ImageIndex = 24
      OnExecute = actUnstageSelectedExecute
      OnUpdate = actUnstageSelectedUpdate
    end
    object actUnstageAll: TAction
      ImageIndex = 40
      OnExecute = actUnstageAllExecute
    end
    object actStageSelected: TAction
      ImageIndex = 22
      OnExecute = actStageSelectedExecute
      OnUpdate = actStageSelectedUpdate
    end
    object actStageAll: TAction
      ImageIndex = 39
      OnExecute = actStageAllExecute
    end
    object actCommit: TAction
      Caption = 'commit'
      ImageIndex = 27
      OnExecute = actCommitExecute
      OnUpdate = actCommitUpdate
    end
  end
  object alFilterActions: TActionList
    Images = commonResources.repoIcons
    Left = 368
    Top = 128
    object actModifiedOnly: TAction
      Category = 'view'
      AutoCheck = True
      Caption = 'modified'
      Checked = True
      Hint = 'toggle modified'
      ImageIndex = 35
      OnExecute = refreshAvailable
    end
    object actShowUnversioned: TAction
      Category = 'view'
      AutoCheck = True
      Caption = 'unversioned'
      Checked = True
      Hint = 'toggle unversioned'
      ImageIndex = 36
      OnExecute = refreshAvailable
    end
    object actShowIgnored: TAction
      Category = 'view'
      AutoCheck = True
      Caption = 'ignored'
      Hint = 'toggle ignored'
      ImageIndex = 37
      OnExecute = refreshAvailable
    end
    object actRefresh: TAction
      Category = 'view'
      Caption = 'refresh'
      Hint = 'refresh'
      ImageIndex = 38
      SecondaryShortCuts.Strings = (
        'Ctrl+R')
      ShortCut = 116
      OnExecute = actRefreshExecute
    end
    object actAddToIgnored: TAction
      Caption = 'add to ignored'
      OnUpdate = actAddToIgnoredUpdate
    end
  end
  object ActionManager1: TActionManager
    ActionBars = <
      item
      end
      item
        Items = <
          item
            Action = actRefresh
            Caption = '&refresh'
            ImageIndex = 38
            ShortCut = 116
          end
          item
            Action = actModifiedOnly
            Caption = '&modified'
            ImageIndex = 35
          end
          item
            Action = actShowUnversioned
            Caption = '&unversioned'
            ImageIndex = 36
          end
          item
            Action = actShowIgnored
            Caption = '&ignored'
            ImageIndex = 37
          end>
        ActionBar = ActionToolBar2
      end>
    LinkedActionLists = <
      item
        ActionList = alFilterActions
        Caption = 'alFilterActions'
      end>
    Images = commonResources.repoIcons
    Left = 344
    Top = 184
    StyleName = 'Platform Default'
  end
  object PopupActionBar1: TPopupActionBar
    Left = 120
    Top = 96
    object addtoignored1: TMenuItem
      Action = actAddToIgnored
    end
  end
end
