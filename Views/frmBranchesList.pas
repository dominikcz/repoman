unit frmBranchesList;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VirtualTrees;

type
  TBranchesListForm = class(TForm)
    logoGraph: TVirtualStringTree;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  BranchesListForm: TBranchesListForm;

implementation

{$R *.dfm}

end.
