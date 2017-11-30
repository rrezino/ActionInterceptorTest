
unit uMain;

interface

uses
  uCblActionObserver,

  System.Actions,
  System.Classes,
  System.SysUtils,
  System.Variants,

  Vcl.ActnList,
  Vcl.Controls,
  Vcl.Dialogs,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.StdCtrls,

  Winapi.Messages,
  Winapi.Windows;

type
  TActionObserverExample = class(TInterfacedObject, IActionObserver)
  private
    FMemo: TMemo;
  public
    constructor Create(Memo: TMemo);

    procedure OnBeforeExecute(const Sender: TAction);
    procedure OnAfterExecute(const Sender: TAction);
  end;

  TForm38 = class(TForm)
    btnTest: TButton;
    actMain: TActionList;
    actShowMessage: TAction;
    btnStartInterception: TButton;
    mmoLog: TMemo;
    btnStartLoggingWithObservable: TButton;
    procedure actShowMessageExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnStartLoggingWithObservableClick(Sender: TObject);
  public
    { Public declarations }
  end;

var
  Form38: TForm38;

implementation

{$R *.dfm}

procedure TForm38.actShowMessageExecute(Sender: TObject);
begin
  ShowMessage('Test');
end;

procedure TForm38.btnStartLoggingWithObservableClick(Sender: TObject);
var
  FActionObserverExample: TActionObserverExample;
begin
  FActionObserverExample := TActionObserverExample.Create(mmoLog);
  RegisterGlobalActionObserver(FActionObserverExample);
end;

procedure TForm38.FormCreate(Sender: TObject);
begin

end;

{ TActionObserverExample }

constructor TActionObserverExample.Create(Memo: TMemo);
begin
  FMemo := Memo;
end;

procedure TActionObserverExample.OnAfterExecute(const Sender: TAction);
begin
  FMemo.Lines.Add('On after Execute :' + Sender.Name);
end;

procedure TActionObserverExample.OnBeforeExecute(const Sender: TAction);
begin
  FMemo.Lines.Add('On before Execute :' + Sender.Name);
end;

initialization


end.
