object FrameCommitView: TFrameCommitView
  Left = 0
  Top = 0
  Width = 914
  Height = 612
  TabOrder = 0
  object leftPanel: TPanel
    Left = 0
    Top = 0
    Width = 449
    Height = 612
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
      Top = 500
      Width = 449
      Height = 3
      Cursor = crVSplit
      Align = alBottom
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitWidth = 39
    end
    object Panel1: TPanel
      Left = 0
      Top = 503
      Width = 449
      Height = 41
      Align = alBottom
      BevelOuter = bvNone
      Caption = 'Panel1'
      ShowCaption = False
      TabOrder = 0
      object Button5: TButton
        Left = 367
        Top = 9
        Width = 75
        Height = 25
        Action = actCommit
        TabOrder = 0
      end
      object cbLastMessages: TComboBox
        Left = 8
        Top = 11
        Width = 353
        Height = 21
        TabOrder = 1
        Text = 'cbLastMessages'
      end
    end
    object commitMsg: TMemo
      Left = 0
      Top = 544
      Width = 449
      Height = 68
      Align = alBottom
      TabOrder = 1
    end
    object pnlUnstaged: TPanel
      Left = 0
      Top = 0
      Width = 449
      Height = 238
      Align = alTop
      BevelOuter = bvNone
      Caption = 'pnlUnstaged'
      TabOrder = 2
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
            Width = 400
            WideText = 'file'
            WideHint = 'shortPath'
          end>
      end
    end
    object pnlStaged: TPanel
      Left = 0
      Top = 241
      Width = 449
      Height = 259
      Align = alClient
      BevelOuter = bvNone
      Caption = 'pnlStaged'
      TabOrder = 3
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
        object Button1: TButton
          Left = 12
          Top = 8
          Width = 32
          Height = 22
          Action = actUnstageAll
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -19
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
        end
        object Button2: TButton
          Left = 50
          Top = 8
          Width = 32
          Height = 22
          Action = actUnstageSelected
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -19
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
        end
        object Button3: TButton
          Left = 366
          Top = 8
          Width = 32
          Height = 22
          Action = actStageSelected
          Anchors = [akTop, akRight]
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -19
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 2
        end
        object Button4: TButton
          Left = 404
          Top = 8
          Width = 32
          Height = 22
          Action = actStageAll
          Anchors = [akTop, akRight]
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -19
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 3
        end
      end
      object stagedFiles: TVirtualStringTree
        Left = 0
        Top = 40
        Width = 449
        Height = 219
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
            Width = 400
            WideText = 'file'
            WideHint = 'shortPath'
          end>
      end
    end
  end
  object ActionList1: TActionList
    Left = 256
    Top = 144
    object actUnstageSelected: TAction
      Caption = #8599
    end
    object actUnstageAll: TAction
      Caption = #8663
    end
    object actStageSelected: TAction
      Caption = #8600
    end
    object actStageAll: TAction
      Caption = #8664
    end
    object actCommit: TAction
      Caption = 'commit'
      OnUpdate = actCommitUpdate
    end
  end
end
