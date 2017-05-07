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

  TBranchFilterItem = class
  private
    function getLastActivityAsString: string;
  public
    isSelected: boolean;
    branch: string;
    lastActivity: TDateTime;
    firstRevision: string;
    lastRevision: string;
    constructor Create; overload;
    constructor Create(ABranch, AFirstRevision, ALastRevision: string; ALastActivity: TDateTime; AIsSelected: boolean = false); overload;
    property lastActivityAsString: string read getLastActivityAsString;
  end;

  TBranchFilter = class(TObjectList<TBranchFilterItem>)
  public
    constructor Create;
    function isVisible(branch: string): boolean;
    function tryGetBranch(branch: string; out item: TBranchFilterItem): boolean;
  end;

  TLogNodes = class(TObjectList<TLogNode>)
  public
    constructor Create;
    function getBranchesFilter: TBranchFilter;
    function findParent(idx: integer): TLogNode;
    function tryFindRevision(ARev: string; out node: TLogNode): boolean;
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

function TLogNodes.getBranchesFilter: TBranchFilter;
var
  item: TLogNode;
  branchItem: TBranchFilterItem;
begin
  result := TBranchFilter.Create;
  for item in self do
  begin
    if (item.branch <> '') then
    begin
      if not result.tryGetBranch(item.branch, branchItem) then
      begin
        branchItem := TBranchFilterItem.Create(item.branch, item.revision, item.revision, item.date);
        result.Add(branchItem);
      end
      else if (item.date > branchItem.lastActivity) then
      begin
        branchItem.lastActivity := item.date;
        branchItem.lastRevision := item.revision;
      end;
    end;
  end;
end;

function TLogNodes.tryFindRevision(ARev: string; out node: TLogNode): boolean;
var
  item: TLogNode;
begin
  result := false;
  for item in self do
    if item.revision = ARev then
    begin
      node := item;
      exit(true);
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

function TBranchFilter.tryGetBranch(branch: string; out item: TBranchFilterItem): boolean;
var
  lItem: TBranchFilterItem;
begin
  result := false;
  for lItem in self do
    if lItem.branch = branch then
    begin
      item := lItem;
      exit(true);
    end;
end;

{ TBranchFilterItem }

constructor TBranchFilterItem.Create(ABranch, AFirstRevision, ALastRevision: string; ALastActivity: TDateTime; AIsSelected: boolean);
begin
  inherited Create;
  branch := ABranch;
  lastActivity := ALastActivity;
  firstRevision := AFirstRevision;
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
