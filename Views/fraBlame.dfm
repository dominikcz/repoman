object BlameFrame: TBlameFrame
  Left = 0
  Top = 0
  Width = 787
  Height = 775
  TabOrder = 0
  OnResize = FrameResize
  object Splitter1: TSplitter
    Left = 337
    Top = 0
    Height = 472
    ExplicitLeft = 360
    ExplicitTop = 176
    ExplicitHeight = 100
  end
  object Splitter2: TSplitter
    Left = 0
    Top = 472
    Width = 787
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    ExplicitLeft = 337
    ExplicitTop = 0
    ExplicitWidth = 475
  end
  object linesList: TVirtualStringTree
    Left = 0
    Top = 0
    Width = 337
    Height = 472
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 16
    Align = alLeft
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    Header.AutoSizeIndex = 0
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.Options = [hoColumnResize, hoDrag]
    Indent = 0
    ScrollBarOptions.AlwaysVisible = True
    ScrollBarOptions.ScrollBars = ssHorizontal
    TabOrder = 0
    TreeOptions.AutoOptions = [toAutoDropExpand, toAutoScroll, toAutoScrollOnExpand, toAutoSort, toAutoTristateTracking, toAutoDeleteMovedNodes, toAutoChangeScale]
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toFullRepaintOnResize, toGridExtensions, toInitOnSave, toToggleOnDblClick, toWheelPanning, toReadOnly, toEditOnClick]
    TreeOptions.PaintOptions = [toPopupMode, toShowButtons, toShowDropmark, toShowRoot, toShowTreeLines, toShowVertGridLines, toThemeAware, toUseBlendedImages, toFullVertGridLines]
    TreeOptions.SelectionOptions = [toFullRowSelect, toMultiSelect]
    OnScroll = linesListScroll
    ExplicitHeight = 493
    Columns = <
      item
        Position = 0
        Width = 120
        WideText = 'rev'
        WideHint = 'revision'
      end
      item
        Position = 1
        Width = 100
        WideText = 'author'
        WideHint = 'author'
      end
      item
        Position = 2
        Width = 110
        WideText = 'date'
        WideHint = 'date'
      end>
  end
  object codeEditor: TSynEdit
    Left = 340
    Top = 0
    Width = 447
    Height = 472
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    TabOrder = 1
    BorderStyle = bsNone
    Gutter.AutoSize = True
    Gutter.Font.Charset = DEFAULT_CHARSET
    Gutter.Font.Color = clGray
    Gutter.Font.Height = -11
    Gutter.Font.Name = 'Courier New'
    Gutter.Font.Style = []
    Gutter.ShowLineNumbers = True
    Highlighter = SynPasSyn1
    Options = [eoAltSetsColumnMode, eoAutoIndent, eoAutoSizeMaxScrollWidth, eoDragDropEditing, eoEnhanceEndKey, eoGroupUndo, eoKeepCaretX, eoScrollPastEol, eoShowScrollHint, eoSmartTabDelete, eoSmartTabs, eoTabIndent, eoTabsToSpaces]
    RightEdge = 120
    OnScroll = codeEditorScroll
    FontSmoothing = fsmClearType
    ExplicitHeight = 493
  end
  inline FrameDiff1: TFrameDiff
    Left = 0
    Top = 475
    Width = 787
    Height = 300
    Align = alBottom
    TabOrder = 2
    ExplicitTop = 475
    ExplicitWidth = 787
    ExplicitHeight = 300
    inherited Splitter2: TSplitter
      Height = 300
    end
    inherited pnlMain: TPanel
      Width = 704
      Height = 300
      inherited Splitter1: TSplitter
        Height = 300
      end
      inherited pnl1: TPanel
        Height = 300
        inherited FrameEditor1: TFrameEditor
          Height = 290
          inherited pnlEditor: TPanel
            Height = 265
            inherited codeEditor: TSynEdit
              Height = 263
            end
          end
        end
      end
      inherited pnl2: TPanel
        Width = 276
        Height = 300
        inherited FrameEditor2: TFrameEditor
          Width = 266
          Height = 290
          inherited pnlEditor: TPanel
            Width = 266
            Height = 265
            inherited codeEditor: TSynEdit
              Width = 264
              Height = 263
            end
          end
          inherited pnlCaption: TPanel
            Width = 266
          end
        end
      end
    end
    inherited pnlNavigation: TPanel
      Height = 300
      inherited pbScrollPosMarker: TPaintBox
        Height = 294
      end
    end
    inherited PngImageList1: TPngImageList
      Bitmap = {}
    end
  end
  object SynPasSyn1: TSynPasSyn
    Options.AutoDetectEnabled = False
    Options.AutoDetectLineLimit = 0
    Options.Visible = False
    Left = 544
    Top = 232
  end
  object SynURIOpener1: TSynURIOpener
    Editor = codeEditor
    URIHighlighter = SynURISyn1
    Left = 448
    Top = 176
  end
  object SynURISyn1: TSynURISyn
    Options.AutoDetectEnabled = False
    Options.AutoDetectLineLimit = 0
    Options.Visible = False
    Left = 528
    Top = 344
  end
end
