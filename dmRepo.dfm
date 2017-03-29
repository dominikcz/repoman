object Repo: TRepo
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 268
  Width = 441
  object alRepoActions: TActionList
    Left = 137
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
      GroupIndex = 1
      Hint = 'toggle modified/all'
      OnExecute = refreshView
    end
    object actIgnore: TAction
      Caption = 'ignored'
      GroupIndex = 2
      Hint = 'edit ignored list'
    end
    object actShowIgnored: TAction
      AutoCheck = True
      Caption = 'showIgnored'
      Checked = True
      GroupIndex = 10
      Hint = 'toggle ignored'
      OnExecute = actShowIgnoredExecute
    end
  end
end
