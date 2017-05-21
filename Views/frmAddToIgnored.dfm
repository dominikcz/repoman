object AddToIgnoreForm: TAddToIgnoreForm
  Left = 0
  Top = 0
  Caption = 'Add to ignored'
  ClientHeight = 430
  ClientWidth = 609
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
  object Splitter1: TSplitter
    Left = 0
    Top = 153
    Width = 609
    Height = 3
    Cursor = crVSplit
    Align = alTop
    ExplicitWidth = 223
  end
  object vstPreview: TVirtualStringTree
    AlignWithMargins = True
    Left = 8
    Top = 156
    Width = 593
    Height = 220
    Margins.Left = 8
    Margins.Top = 0
    Margins.Right = 8
    Margins.Bottom = 0
    Align = alClient
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    Header.AutoSizeIndex = 0
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.Options = [hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
    Images = commonResources.repoIcons
    TabOrder = 0
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toFullRepaintOnResize, toGridExtensions, toInitOnSave, toToggleOnDblClick, toWheelPanning, toEditOnClick]
    TreeOptions.SelectionOptions = [toMultiSelect]
    ExplicitLeft = 0
    ExplicitTop = 73
    ExplicitHeight = 222
    Columns = <
      item
        Position = 0
        Width = 584
        WideText = 'ignored files preview (first 100):'
        WideHint = 'shortPath'
      end>
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 609
    Height = 153
    Align = alTop
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 1
    DesignSize = (
      609
      153)
    object Label2: TLabel
      Left = 8
      Top = 13
      Width = 124
      Height = 13
      Caption = 'enter pattern(s) to ignore'
    end
    object mPatterns: TMemo
      Left = 8
      Top = 32
      Width = 593
      Height = 115
      Anchors = [akLeft, akTop, akRight, akBottom]
      ScrollBars = ssBoth
      TabOrder = 0
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 376
    Width = 609
    Height = 54
    Align = alBottom
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 2
    ExplicitTop = 296
    ExplicitWidth = 593
    DesignSize = (
      609
      54)
    object btnCancel: TButton
      Left = 430
      Top = 16
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'cancel'
      ModalResult = 2
      TabOrder = 0
    end
    object btnOk: TButton
      Left = 526
      Top = 16
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 1
      ExplicitLeft = 552
    end
  end
end
