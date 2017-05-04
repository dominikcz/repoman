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
      object graphPanel: TScrollBox
        Left = 0
        Top = 0
        Width = 816
        Height = 407
        Align = alClient
        TabOrder = 0
        OnMouseWheel = graphPanelMouseWheel
      end
      object graphMemo: TMemo
        Left = 0
        Top = 407
        Width = 816
        Height = 89
        Align = alBottom
        TabOrder = 1
      end
    end
    object tabGraphLog: TTabSheet
      Caption = 'Graph + log'
      ImageIndex = 1
      object logoGraph: TVirtualStringTree
        Left = 0
        Top = 0
        Width = 816
        Height = 496
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
        Header.Options = [hoColumnResize, hoDblClickResize, hoDrag, hoShowHint, hoVisible, hoDisableAnimatedResize, hoHeightResize]
        HintMode = hmTooltip
        Indent = 20
        ParentShowHint = False
        PopupMenu = PopupActionBar1
        ShowHint = True
        TabOrder = 0
        TreeOptions.AutoOptions = [toAutoDropExpand, toAutoScroll, toAutoScrollOnExpand, toAutoSort, toAutoTristateTracking, toAutoDeleteMovedNodes, toAutoChangeScale]
        TreeOptions.MiscOptions = [toAcceptOLEDrop, toFullRepaintOnResize, toGridExtensions, toInitOnSave, toToggleOnDblClick, toWheelPanning, toReadOnly, toEditOnClick]
        TreeOptions.PaintOptions = [toPopupMode, toShowButtons, toShowDropmark, toShowRoot, toShowTreeLines, toThemeAware, toUseBlendedImages]
        TreeOptions.SelectionOptions = [toFullRowSelect, toMultiSelect]
        OnColumnResize = logoGraphColumnResize
        OnColumnWidthDblClickResize = logoGraphColumnWidthDblClickResize
        Columns = <
          item
            Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus]
            Position = 0
            Width = 40
            WideText = 'date'
            WideHint = 'DateAsString'
          end
          item
            Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus]
            Position = 1
            Width = 648
            WideText = 'comment'
            WideHint = 'comment'
          end
          item
            Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus]
            Position = 2
            Width = 87
            WideText = 'revision'
            WideHint = 'revision'
          end>
      end
    end
  end
  object icons: TPngImageList
    PngImages = <
      item
        Background = clFuchsia
        Name = 'filter'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000010000000100403000000EDDDE2
          5200000012504C5445800080808080FFFFFF000000C0C0C088008830B3440100
          00000174524E530040E6D86600000001624B474405F86FE9C700000009704859
          7300000B1300000B1301009A9C180000000774494D4507E1040F0C1A2ADEA31E
          780000001063614E76000000F00000001000000010000000008588ABCC000000
          464944415478DA63648002460443104CFF6764101200D1FC8C0C8CCA0A0C7F2F
          BD05AA113262382B7F01C8605496BDF416AC4B44F7FD05A219820CF21006B3C1
          DF0BC896420100154916514E711FB80000002574455874646174653A63726561
          746500323031372D30342D31355430353A30373A32332B30323A30302D000739
          0000002574455874646174653A6D6F6469667900323031372D30342D31355431
          323A32363A34322B30323A30306B9788670000000049454E44AE426082}
      end>
    Left = 232
    Top = 208
    Bitmap = {}
  end
  object ActionList1: TActionList
    Images = icons
    Left = 396
    Top = 240
    object actHideIgnored: TAction
      AutoCheck = True
      Caption = 'hide ignored'
      Checked = True
      OnExecute = actHideIgnoredExecute
    end
    object actFilterBranches: TAction
      Caption = 'filter branches'
      ImageIndex = 0
      OnExecute = actFilterBranchesExecute
    end
  end
  object PopupActionBar1: TPopupActionBar
    Images = icons
    Left = 188
    Top = 280
    object Hideignored1: TMenuItem
      Action = actHideIgnored
      AutoCheck = True
    end
    object filterbranches1: TMenuItem
      Action = actFilterBranches
    end
  end
end
