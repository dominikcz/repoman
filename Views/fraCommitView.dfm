object FrameCommitView: TFrameCommitView
  Left = 0
  Top = 0
  Width = 914
  Height = 651
  TabOrder = 0
  object leftPanel: TPanel
    Left = 0
    Top = 0
    Width = 449
    Height = 651
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
      Top = 462
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
      object filterPanel: TPanel
        Left = 0
        Top = 0
        Width = 449
        Height = 41
        Align = alTop
        BevelOuter = bvNone
        Caption = 'filterPanel'
        ShowCaption = False
        TabOrder = 0
      end
      object unstagedFiles: TVirtualStringTree
        Left = 0
        Top = 41
        Width = 449
        Height = 197
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
        TabOrder = 1
        TreeOptions.MiscOptions = [toAcceptOLEDrop, toFullRepaintOnResize, toGridExtensions, toInitOnSave, toToggleOnDblClick, toWheelPanning, toEditOnClick]
        Columns = <
          item
            Position = 0
            Width = 360
            WideText = 'available files'
            WideHint = 'shortPath'
          end>
      end
    end
    object pnlStaged: TPanel
      Left = 0
      Top = 241
      Width = 449
      Height = 221
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
      object stagedFiles: TVirtualStringTree
        Left = 0
        Top = 40
        Width = 449
        Height = 181
        Align = alClient
        BevelInner = bvNone
        BevelOuter = bvNone
        Header.AutoSizeIndex = 0
        Header.Font.Charset = DEFAULT_CHARSET
        Header.Font.Color = clWindowText
        Header.Font.Height = -11
        Header.Font.Name = 'Tahoma'
        Header.Font.Style = []
        Header.Height = 17
        Header.Options = [hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
        TabOrder = 1
        TreeOptions.MiscOptions = [toAcceptOLEDrop, toFullRepaintOnResize, toGridExtensions, toInitOnSave, toToggleOnDblClick, toWheelPanning, toEditOnClick]
        Columns = <
          item
            Position = 0
            Width = 360
            WideText = 'staged files'
            WideHint = 'shortPath'
          end>
      end
    end
    object pnlCommit: TPanel
      Left = 0
      Top = 465
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
      object Button5: TButton
        Left = 366
        Top = 8
        Width = 71
        Height = 25
        Action = actCommit
        TabOrder = 1
      end
      object cbLastMessages: TComboBox
        Left = 10
        Top = 10
        Width = 350
        Height = 21
        TabOrder = 2
      end
    end
  end
  object ActionList1: TActionList
    Left = 256
    Top = 144
    object actUnstageSelected: TAction
      Caption = #8599
      ImageIndex = 24
    end
    object actUnstageAll: TAction
      Caption = #8663
      ImageIndex = 40
    end
    object actStageSelected: TAction
      Caption = #8600
      ImageIndex = 22
    end
    object actStageAll: TAction
      Caption = #8664
      ImageIndex = 39
    end
    object actCommit: TAction
      Caption = 'commit'
      ImageIndex = 27
      OnUpdate = actCommitUpdate
    end
  end
end
