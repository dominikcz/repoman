object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'RepoMan'
  ClientHeight = 661
  ClientWidth = 984
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pages: TPageControl
    Left = 0
    Top = 0
    Width = 984
    Height = 642
    ActivePage = tabCommit
    Align = alClient
    TabOrder = 0
    object tabRepoView: TTabSheet
      Caption = 'Repo'
      inline ViewFilesBrowser1: TViewFilesBrowser
        Left = 0
        Top = 0
        Width = 976
        Height = 614
        Align = alClient
        TabOrder = 0
        ExplicitLeft = 13
        ExplicitTop = 160
        inherited Splitter1: TSplitter
          Height = 481
        end
        inherited Splitter2: TSplitter
          Top = 522
          Width = 976
        end
        inherited Panel1: TPanel
          Width = 976
        end
        inherited log: TMemo
          Top = 525
          Width = 976
        end
        inherited dirTree: TVirtualStringTree
          Height = 481
          ExplicitLeft = 0
          ExplicitTop = 41
        end
        inherited fileList: TVirtualStringTree
          Width = 773
          Height = 481
        end
      end
    end
    object tabCommit: TTabSheet
      Caption = 'Commit'
      ImageIndex = 2
      ExplicitLeft = 8
      ExplicitTop = 22
    end
    object tabCodeReview: TTabSheet
      Caption = 'Code review'
      ImageIndex = 1
      ExplicitLeft = 52
      ExplicitTop = 22
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 642
    Width = 984
    Height = 19
    Panels = <>
  end
end
