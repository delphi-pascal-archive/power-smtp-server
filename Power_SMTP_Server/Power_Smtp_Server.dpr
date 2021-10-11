program Power_Smtp_Server;

uses
  Forms,
  UMain in 'UMain.pas' {Main},
  UAdmin in 'UAdmin.pas' {Admin_Form},
  UUSers in 'UUSers.pas',
  USMTP in 'USMTP.pas',
  UMail in 'UMail.pas' {Mail_Form};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMain, Main);
  Application.CreateForm(TAdmin_Form, Admin_Form);
  Application.CreateForm(TMail_Form, Mail_Form);
  Application.Run;
end.
