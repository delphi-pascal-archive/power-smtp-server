program Activation;

uses
  Forms,
  UMain in 'UMain.pas' {Activation_Bt};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TActivation_Bt, Activation_Bt);
  Application.Run;
end.
