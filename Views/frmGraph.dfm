object GraphForm: TGraphForm
  Left = 0
  Top = 0
  Width = 840
  Height = 563
  HorzScrollBar.Tracking = True
  VertScrollBar.Tracking = True
  AutoScroll = True
  Caption = 'Graph'
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
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 824
    Height = 524
    ActivePage = tabGraphLog
    Align = alClient
    TabOrder = 0
    object tabGraph: TTabSheet
      Caption = 'Graph'
      ExplicitLeft = 0
      ExplicitTop = 28
      object graphPanel: TScrollBox
        Left = 0
        Top = 0
        Width = 816
        Height = 407
        Align = alClient
        TabOrder = 0
        OnMouseWheel = graphPanelMouseWheel
        ExplicitLeft = 88
        ExplicitTop = 40
        ExplicitWidth = 185
        ExplicitHeight = 41
      end
      object graphMemo: TMemo
        Left = 0
        Top = 407
        Width = 816
        Height = 89
        Align = alBottom
        TabOrder = 1
        ExplicitLeft = 104
        ExplicitTop = 344
        ExplicitWidth = 185
      end
    end
    object tabGraphLog: TTabSheet
      Caption = 'Graph + log'
      ImageIndex = 1
      ExplicitLeft = 8
      ExplicitTop = 28
      object logoGraph: TVirtualStringTree
        Left = 0
        Top = 41
        Width = 816
        Height = 455
        Align = alClient
        BevelInner = bvNone
        BevelOuter = bvNone
        Header.AutoSizeIndex = -1
        Header.Font.Charset = DEFAULT_CHARSET
        Header.Font.Color = clWindowText
        Header.Font.Height = -11
        Header.Font.Name = 'Tahoma'
        Header.Font.Style = []
        Header.Height = 119
        Header.MainColumn = 1
        Header.Options = [hoColumnResize, hoDrag, hoShowHint, hoShowSortGlyphs, hoVisible, hoHeightResize]
        Indent = 20
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        TreeOptions.AutoOptions = [toAutoDropExpand, toAutoScroll, toAutoScrollOnExpand, toAutoSort, toAutoTristateTracking, toAutoDeleteMovedNodes, toAutoChangeScale]
        TreeOptions.MiscOptions = [toAcceptOLEDrop, toFullRepaintOnResize, toGridExtensions, toInitOnSave, toToggleOnDblClick, toWheelPanning, toReadOnly, toEditOnClick]
        TreeOptions.PaintOptions = [toPopupMode, toShowButtons, toShowDropmark, toShowRoot, toShowTreeLines, toThemeAware, toUseBlendedImages]
        TreeOptions.SelectionOptions = [toFullRowSelect, toMultiSelect]
        OnAfterItemPaint = logoGraphAfterItemPaint
        ExplicitTop = 47
        Columns = <
          item
            Position = 0
            Width = 86
            WideText = 'date'
            WideHint = 'DateAsString'
          end
          item
            Position = 1
            Width = 87
            WideText = 'revision'
            WideHint = 'revision'
          end
          item
            Position = 2
            Width = 648
            WideText = 'comment'
            WideHint = 'comment'
          end>
      end
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 816
        Height = 41
        Align = alTop
        BevelOuter = bvNone
        Caption = 'Panel1'
        ShowCaption = False
        TabOrder = 1
        object cbxHideTrash: TCheckBox
          Left = 9
          Top = 12
          Width = 129
          Height = 17
          Caption = 'hide non significant'
          Checked = True
          State = cbChecked
          TabOrder = 0
          OnClick = cbxHideTrashClick
        end
      end
    end
  end
end
