unit Models.BlameInfo;

interface

uses
  Classes,
  Generics.Collections;

type
  TBlameInfo = class
  public
    revision: string;
    author: string;
    date: string;
    procedure parseCVSAnnotate(ALine: string; ACodeLines: TStrings);
  end;

  TBlameInfos = class(TObjectList<TBlameInfo>)
  end;

implementation

uses
  Sysutils;

{ TBlameInfo }

procedure TBlameInfo.parseCVSAnnotate(ALine: string; ACodeLines: TStrings);
var
  p1, p2, p3: Integer;
begin
  p1 := ALine.IndexOf('(');
  p2 := ALine.IndexOf(')');
  p3 := ALine.IndexOf(' ', p1);
  self.revision := trim(ALine.Substring(0, p1));
  self.author := ALine.Substring(p1 + 1, p3 - p1 - 1);
  self.date := ALine.Substring(p2 - 9, 9);
  if Assigned(ACodeLines) then
    ACodeLines.Add(ALine.Substring(p2 + 3))
end;

end.
