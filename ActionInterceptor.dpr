program ActionInterceptor;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {Form38},
  uCblActionObserver in 'uCblActionObserver.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm38, Form38);
  Application.Run;
end.
