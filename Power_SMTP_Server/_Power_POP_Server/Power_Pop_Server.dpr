program Power_Pop_Server;

uses
  Forms,
  UMain in 'UMain.pas' {Main},
  UAdmin in 'UAdmin.pas' {Admin_Form},
  UPOP in 'UPOP.pas',
  UUsers in 'UUsers.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMain, Main);
  Application.CreateForm(TAdmin_Form, Admin_Form);
  Application.Run;
end.
