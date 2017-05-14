object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'RepoMan'
  ClientHeight = 661
  ClientWidth = 1322
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShortCut = FormShortCut
  PixelsPerInch = 96
  TextHeight = 13
  object pages: TPageControl
    Left = 0
    Top = 0
    Width = 1322
    Height = 642
    ActivePage = tabRepoView
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 1126
    object tabRepoView: TTabSheet
      Caption = 'Repo'
      ExplicitWidth = 1118
      object ActionToolBar1: TActionToolBar
        Left = 0
        Top = 0
        Width = 1314
        Height = 26
        ActionManager = Repo.ActionManager1
        Caption = 'ActionToolBar1'
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
        ParentBackground = True
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        Spacing = 5
        ExplicitTop = -6
      end
      inline ViewFilesBrowser1: TViewFilesBrowser
        Left = 0
        Top = 26
        Width = 1314
        Height = 588
        Align = alClient
        TabOrder = 1
        ExplicitTop = 54
        ExplicitWidth = 1118
        ExplicitHeight = 560
        inherited Splitter1: TSplitter
          Height = 455
          ExplicitHeight = 455
        end
        inherited Splitter2: TSplitter
          Top = 496
          Width = 1314
          ExplicitTop = 496
          ExplicitWidth = 1034
        end
        inherited Panel1: TPanel
          Width = 1314
          ExplicitWidth = 1118
        end
        inherited log: TMemo
          Top = 499
          Width = 1314
          ExplicitTop = 471
          ExplicitWidth = 1118
        end
        inherited dirTree: TVirtualStringTree
          Height = 455
          ExplicitHeight = 427
        end
        inherited fileList: TVirtualStringTree
          Width = 1111
          Height = 455
          ExplicitLeft = 206
          ExplicitTop = 38
          ExplicitWidth = 915
          ExplicitHeight = 427
        end
      end
    end
    object tabCommit: TTabSheet
      Caption = 'Commit'
      ImageIndex = 2
      ExplicitWidth = 1118
    end
    object tabCodeReview: TTabSheet
      Caption = 'Code review'
      ImageIndex = 1
      ExplicitWidth = 1118
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 642
    Width = 1322
    Height = 19
    Panels = <>
    ExplicitWidth = 1126
  end
end
