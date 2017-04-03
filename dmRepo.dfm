object Repo: TRepo
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 268
  Width = 441
  object alRepoActions: TActionList
    Left = 136
    Top = 88
  end
  object alViewActions: TActionList
    Left = 225
    Top = 80
    object actFlatMode: TAction
      AutoCheck = True
      Caption = 'flat mode'
      Checked = True
      Hint = 'toggle flat mode'
      OnExecute = refreshView
    end
    object actModifiedOnly: TAction
      AutoCheck = True
      Caption = 'modified'
      Hint = 'toggle modified/all'
      OnExecute = refreshView
    end
    object actIgnore: TAction
      Caption = 'ignored'
      Hint = 'edit ignored list'
    end
    object actShowIgnored: TAction
      AutoCheck = True
      Caption = 'showIgnored'
      Hint = 'toggle ignored'
      OnExecute = actShowIgnoredExecute
    end
    object actRefresh: TAction
      Caption = 'actRefresh'
      SecondaryShortCuts.Strings = (
        'Ctrl+R')
      ShortCut = 116
      OnExecute = actRefreshExecute
    end
  end
end
