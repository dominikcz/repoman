unit Models.LogInfo;

interface

uses
  Generics.Collections;

type
  TLogNode = class
  private
    function getDateAsString: string;
    function doExpandRevision(rev: string): string;
  public
    revision: string;
    date: TDateTime;
    author: string;
    authorEmail: string;
    comment: string;
    mergeFrom: string;
    mergeTo: string;
    branch: string;
    isTagOnly: boolean;
    function AsString: string;
    function expandRevision: string;
    function expandMergeFrom: string;

    property DateAsString: string read getDateAsString;
  end;

  TLogBranchInfo = class
  public
    revision: string;
    lastActivity: TDateTime;
    constructor Create(ARev: string; ALastActivity: TDateTime);
  end;

  TBranchFilterItem = class
  private
    function getLastActivityAsString: string;
  public
    isSelected: boolean;
    branch: string;
    lastActivity: TDateTime;
    lastRevision: string;
    constructor Create; overload;
    constructor Create(ABranch, ALastRevision: string; ALastActivity: TDateTime; AIsSelected: boolean = false); overload;
    property lastActivityAsString: string read getLastActivityAsString;
  end;

  TBranchFilter = class(TObjectList<TBranchFilterItem>)
  public
    constructor Create;
    function isVisible(branch: string): boolean;
  end;

  TLogBranches = class(TObjectDictionary<string, TLogBranchInfo>)
  public
    constructor Create;
  end;

  TLogNodes = class(TObjectList<TLogNode>)
  public
    constructor Create;
    function getBranches: TLogBranches;
    function findParent(idx: integer): TLogNode;
  end;


implementation

uses
  SysUtils,
  whizaxe.common,
  Generics.Defaults;

{ TLogNodes }

constructor TLogNodes.Create;
begin
  inherited Create(true);
end;

function TLogNodes.findParent(idx: integer): TLogNode;
var
  i: Integer;
  node: TLogNode;
  node0Rev: string;
begin
  node := items[idx];
  node0rev := items[idx].revision;
  for i := idx downto 0 do
  begin
    node := items[i];
    if node0Rev.StartsWith(node.revision+'.') then
      break;
  end;
  result := node;
end;

function TLogNodes.getBranches: TLogBranches;
var
  item: TLogNode;
  branchInfo: TLogBranchInfo;
begin
  result := TLogBranches.Create;
  for item in self do
  begin
    if (item.branch <> '') then
    begin
      if not result.TryGetValue(item.branch, branchInfo) then
      begin
        branchInfo := TLogBranchInfo.Create(item.revision, item.date);
        result.Add(item.branch, branchInfo);
      end
      else if (item.date > branchInfo.lastActivity) then
      begin
        branchInfo.lastActivity := item.date;
        branchInfo.revision := item.revision;
      end;
    end;
  end;
end;

{ TLogNode }

function TLogNode.AsString: string;
var
  d: string;
begin
  if self.date <> 0 then
    d := DatetimeToStr(self.date)
  else
    d := '';
  result := expandRevision + ';' + d +';'+self.branch+';'+expandMergeFrom;
end;

function TLogNode.getDateAsString: string;
begin
  result := '';
  if self.date <> 0 then
    result := WxU.DateTimeAsFriendlyStr(self.date);
end;

function TLogNode.doExpandRevision(rev: string): string;
var
  tmp: TArray<string>;
  i: Integer;
begin
  tmp := rev.Split(['.']);
  for i := 0 to high(tmp) do
    tmp[i] := tmp[i].PadLeft(4, '0');
  result := String.join('.', tmp);
end;

function TLogNode.expandMergeFrom: string;
begin
  result := doExpandRevision(mergeFrom);
end;

function TLogNode.expandRevision: string;
begin
  result := doExpandRevision(revision);
end;

{ TLogBranches }

constructor TLogBranches.Create;
begin
  inherited Create([doOwnsValues]);
end;

{ TLogBranchInfo }

constructor TLogBranchInfo.Create(ARev: string; ALastActivity: TDateTime);
begin
  inherited Create;
  revision := ARev;
  lastActivity := ALastActivity;
end;

{ TBranchFilter }

constructor TBranchFilter.Create;
begin
  inherited Create(true);
end;

function TBranchFilter.isVisible(branch: string): boolean;
var
  item: TBranchFilterItem;
begin
  result := false;
  for item in self do
    if item.branch = branch then
      exit(item.isSelected);
end;

{ TBranchFilterItem }

constructor TBranchFilterItem.Create(ABranch, ALastRevision: string; ALastActivity: TDateTime; AIsSelected: boolean);
begin
  inherited Create;
  branch := ABranch;
  lastActivity := ALastActivity;
  lastRevision := ALastRevision;
  self.isSelected := AIsSelected;
end;

function TBranchFilterItem.getLastActivityAsString: string;
begin
  result := WxU.DateTimeAsFriendlyStr(lastActivity);
end;

constructor TBranchFilterItem.Create;
begin
  inherited;
end;

end.
