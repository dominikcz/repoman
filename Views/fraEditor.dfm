object FrameEditor: TFrameEditor
  Left = 0
  Top = 0
  Width = 452
  Height = 415
  TabOrder = 0
  object pnlEditor: TPanel
    Left = 0
    Top = 25
    Width = 452
    Height = 390
    Align = alClient
    BevelOuter = bvLowered
    Caption = 'pnlEditor'
    TabOrder = 0
    object codeEditor: TSynEdit
      Left = 1
      Top = 1
      Width = 450
      Height = 388
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = []
      TabOrder = 0
      OnEnter = codeEditorEnter
      OnExit = codeEditorExit
      BorderStyle = bsNone
      Gutter.Font.Charset = DEFAULT_CHARSET
      Gutter.Font.Color = clWindowText
      Gutter.Font.Height = -11
      Gutter.Font.Name = 'Courier New'
      Gutter.Font.Style = []
      Options = [eoAltSetsColumnMode, eoAutoIndent, eoAutoSizeMaxScrollWidth, eoDragDropEditing, eoEnhanceEndKey, eoGroupUndo, eoKeepCaretX, eoScrollPastEol, eoShowScrollHint, eoSmartTabDelete, eoSmartTabs, eoTabIndent, eoTabsToSpaces]
      RightEdge = 120
      OnGutterGetText = codeEditorGutterGetText
      OnGutterPaint = codeEditorGutterPaint
      OnSpecialLineColors = codeEditorSpecialLineColors
      FontSmoothing = fsmClearType
    end
  end
  object pnlCaption: TPanel
    Left = 0
    Top = 0
    Width = 452
    Height = 25
    Align = alTop
    Alignment = taLeftJustify
    BevelOuter = bvNone
    Caption = '  filename'
    Color = clActiveCaption
    ParentBackground = False
    TabOrder = 1
  end
  object SynEditSearch1: TSynEditSearch
    Left = 232
    Top = 257
  end
end
