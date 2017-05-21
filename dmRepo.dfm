object Repo: TRepo
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 268
  Width = 441
  object alRepoActions: TActionList
    Images = commonResources.repoIcons
    OnExecute = alRepoActionsExecute
    Left = 136
    Top = 88
    object actDiff: TAction
      Category = 'repo'
      Caption = 'diff'
      Hint = 'diff'
      ImageIndex = 14
      ShortCut = 16452
      OnExecute = actDiffExecute
      OnUpdate = SingleFileActionUpdate
    end
    object actGraph: TAction
      Category = 'repo'
      Caption = 'graph'
      ImageIndex = 17
      ShortCut = 16455
      OnExecute = actGraphExecute
      OnUpdate = SingleFileActionUpdate
    end
    object actLog: TAction
      Category = 'repo'
      Caption = 'log'
      ImageIndex = 15
      ShortCut = 16460
      OnExecute = actLogExecute
      OnUpdate = SingleFileActionUpdate
    end
    object actAnnotate: TAction
      Category = 'repo'
      Caption = 'annotate/blame'
      ImageIndex = 16
      OnExecute = actAnnotateExecute
      OnUpdate = SingleFileActionUpdate
    end
    object actAdd: TAction
      Category = 'repo'
      Caption = 'add'
      ImageIndex = 12
      OnUpdate = actAddUpdate
    end
    object actRemove: TAction
      Category = 'repo-write'
      Caption = 'remove'
      ImageIndex = 13
      OnUpdate = actRemoveUpdate
    end
    object actEdit: TAction
      Category = 'repo'
      Caption = 'edit'
      ImageIndex = 18
      ShortCut = 16397
      OnExecute = actEditExecute
      OnUpdate = SingleFileActionUpdate
    end
    object actHistory: TAction
      Category = 'repo'
      Caption = 'history'
      ImageIndex = 30
      OnExecute = actHistoryExecute
      OnUpdate = SingleFileActionUpdate
    end
    object actUpdateSelected: TAction
      Category = 'repo'
      Caption = 'update'
      ImageIndex = 23
      ShortCut = 16469
      OnExecute = actUpdateSelectedExecute
      OnUpdate = MultiSelectActionUpdate
    end
    object actCommitSelected: TAction
      Category = 'repo-write'
      Caption = 'commit'
      ImageIndex = 28
      ShortCut = 16461
      OnExecute = actCommitSelectedExecute
      OnUpdate = actCommitSelectedUpdate
    end
    object actUpdateAll: TAction
      Category = 'repo'
      Caption = 'update all'
      ImageIndex = 22
      OnExecute = actUpdateAllExecute
      OnUpdate = MultiSelectActionUpdate
    end
    object actUpdateClean: TAction
      Category = 'repo'
      Caption = 'clean copy'
      ImageIndex = 31
      OnExecute = actUpdateCleanExecute
      OnUpdate = MultiSelectActionUpdate
    end
    object actCommitAll: TAction
      Category = 'repo-write'
      Caption = 'commit all'
      ImageIndex = 27
      OnExecute = actCommitAllExecute
    end
    object actImport: TAction
      Category = 'repo-write'
      Caption = 'import'
      OnExecute = actImportExecute
    end
    object actStop: TAction
      Category = 'repo'
      Caption = 'stop'
      ImageIndex = 32
    end
    object actFlatMode: TAction
      Category = 'view'
      AutoCheck = True
      Caption = 'flat mode'
      Checked = True
      Hint = 'toggle flat mode'
      ImageIndex = 33
      OnExecute = refreshView
    end
    object actModifiedOnly: TAction
      Category = 'view'
      AutoCheck = True
      Caption = 'modified'
      Hint = 'toggle modified'
      ImageIndex = 35
      OnExecute = refreshView
    end
    object actShowUnversioned: TAction
      Category = 'view'
      AutoCheck = True
      Caption = 'unversioned'
      Hint = 'toggle unversioned'
      ImageIndex = 36
      OnExecute = refreshView
    end
    object actShowIgnored: TAction
      Category = 'view'
      AutoCheck = True
      Caption = 'ignored'
      Hint = 'toggle ignored'
      ImageIndex = 37
      OnExecute = refreshView
    end
    object actRefresh: TAction
      Category = 'view'
      Caption = 'refresh'
      Hint = 'refresh'
      ImageIndex = 38
      SecondaryShortCuts.Strings = (
        'Ctrl+R')
      ShortCut = 116
      OnExecute = actRefreshExecute
    end
    object actIgnore: TAction
      Category = 'repo'
      Caption = 'add to ignored'
      OnExecute = actIgnoreExecute
      OnUpdate = MultiSelectActionUpdate
    end
  end
  object ActionManager1: TActionManager
    ActionBars = <
      item
        Items.CaptionOptions = coAll
        Items = <
          item
            Action = actFlatMode
            Caption = '&flat mode'
            ImageIndex = 33
          end
          item
            Action = actModifiedOnly
            Caption = '&modified'
            ImageIndex = 35
          end
          item
            Action = actShowUnversioned
            Caption = 'un&versioned'
            ImageIndex = 36
          end
          item
            Action = actShowIgnored
            Caption = 'igno&red'
            ImageIndex = 37
          end
          item
            Action = actRefresh
            ImageIndex = 38
            ShortCut = 116
          end
          item
            Caption = '-'
          end
          item
            Action = actDiff
            Caption = 'd&iff'
            ImageIndex = 14
            ShortCut = 16452
          end
          item
            Action = actGraph
            Caption = '&graph'
            ImageIndex = 17
            ShortCut = 16455
          end
          item
            Action = actLog
            Caption = '&log'
            ImageIndex = 15
            ShortCut = 16460
          end
          item
            Action = actAnnotate
            Caption = '&annotate/blame'
            ImageIndex = 16
          end
          item
            Action = actEdit
            Caption = 'edi&t'
            ImageIndex = 18
            ShortCut = 16397
          end
          item
            Action = actHistory
            Caption = '&history'
            ImageIndex = 30
          end
          item
            Caption = '-'
          end
          item
            Action = actAdd
            Caption = 'a&dd'
            ImageIndex = 12
          end
          item
            Action = actRemove
            Caption = 'r&emove'
            ImageIndex = 13
          end
          item
            Action = actUpdateSelected
            Caption = 'u&pdate'
            ImageIndex = 23
            ShortCut = 16469
          end
          item
            Action = actUpdateClean
            Caption = 'clea&n copy'
            ImageIndex = 31
          end
          item
            Action = actCommitSelected
            Caption = '&commit'
            ImageIndex = 28
            ShortCut = 16461
          end
          item
            Caption = '-'
          end
          item
            Action = actUpdateAll
            Caption = '&update all'
            ImageIndex = 22
          end
          item
            Action = actCommitAll
            Caption = 'c&ommit all'
            ImageIndex = 27
          end
          item
            Caption = '-'
          end
          item
            Action = actStop
            Caption = '&stop'
            ImageIndex = 32
          end>
      end>
    LinkedActionLists = <
      item
        ActionList = alRepoActions
        Caption = 'alRepoActions'
      end>
    Images = commonResources.repoIcons
    Left = 328
    Top = 32
    StyleName = 'Platform Default'
  end
  object popupRepoActions: TPopupActionBar
    Images = commonResources.repoIcons
    Left = 224
    Top = 144
    object diff1: TMenuItem
      Action = actDiff
    end
    object graph1: TMenuItem
      Action = actGraph
    end
    object log1: TMenuItem
      Action = actLog
    end
    object annotateblame1: TMenuItem
      Action = actAnnotate
    end
    object edit1: TMenuItem
      Action = actEdit
    end
    object history1: TMenuItem
      Action = actHistory
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object add1: TMenuItem
      Action = actAdd
    end
    object remove1: TMenuItem
      Action = actRemove
    end
    object update1: TMenuItem
      Action = actUpdateSelected
    end
    object cleancopy1: TMenuItem
      Action = actUpdateClean
    end
    object commit1: TMenuItem
      Action = actCommitSelected
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object updateall1: TMenuItem
      Action = actUpdateAll
    end
    object commitall1: TMenuItem
      Action = actCommitAll
    end
    object import1: TMenuItem
      Action = actImport
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object addtoignored1: TMenuItem
      Action = actIgnore
    end
  end
  object popupDirsActions: TPopupActionBar
    Images = commonResources.repoIcons
    Left = 112
    Top = 184
    object MenuItem9: TMenuItem
      Action = actRemove
    end
    object MenuItem10: TMenuItem
      Action = actUpdateSelected
    end
    object MenuItem11: TMenuItem
      Action = actUpdateClean
    end
    object MenuItem12: TMenuItem
      Action = actCommitSelected
    end
    object MenuItem13: TMenuItem
      Caption = '-'
    end
    object MenuItem16: TMenuItem
      Action = actImport
    end
  end
  object popupRepoActionsSmall: TPopupActionBar
    Images = commonResources.repoIcons
    Left = 312
    Top = 160
    object MenuItem14: TMenuItem
      Action = actRemove
    end
    object MenuItem17: TMenuItem
      Action = actUpdateClean
    end
    object MenuItem19: TMenuItem
      Caption = '-'
    end
    object addtoignored2: TMenuItem
      Action = actIgnore
    end
  end
end
