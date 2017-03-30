object ViewFilesBrowser: TViewFilesBrowser
  Left = 0
  Top = 0
  Width = 963
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
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    Caption = 'pnlTop'
    ShowCaption = False
    TabOrder = 0
    object SpeedButton1: TSpeedButton
      Left = 235
      Top = 11
      Width = 59
      Height = 21
      Action = Repo.actFlatMode
      AllowAllUp = True
    end
    object SpeedButton2: TSpeedButton
      Left = 300
      Top = 11
      Width = 59
      Height = 21
      Action = Repo.actModifiedOnly
      AllowAllUp = True
    end
    object SpeedButton3: TSpeedButton
      Left = 365
      Top = 11
      Width = 83
      Height = 21
      Hint = 'toggle ignored'
      AllowAllUp = True
      Caption = 'showIgnored'
    end
    object edtWorkingCopyPath: TEdit
      Left = 10
      Top = 11
      Width = 185
      Height = 21
      TabOrder = 0
      OnExit = edtWorkingCopyPathChange
    end
    object CheckBox1: TCheckBox
      Left = 536
      Top = 16
      Width = 97
      Height = 17
      Action = Repo.actShowIgnored
      State = cbChecked
      TabOrder = 1
    end
    object Button1: TButton
      Left = 672
      Top = 10
      Width = 75
      Height = 25
      Action = Repo.actRefresh
      TabOrder = 2
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
    Top = 41
    Width = 200
    Height = 321
    Align = alLeft
    Header.AutoSizeIndex = 0
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.Height = 18
    Header.Options = [hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
    TabOrder = 2
    TreeOptions.SelectionOptions = [toFullRowSelect]
    ExplicitLeft = -3
    ExplicitTop = 38
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
    Width = 760
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
    TabOrder = 3
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toFullRepaintOnResize, toGridExtensions, toInitOnSave, toToggleOnDblClick, toWheelPanning, toEditOnClick]
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
        Width = 150
        WideText = 'branch'
        WideHint = 'branch'
      end>
  end
end
