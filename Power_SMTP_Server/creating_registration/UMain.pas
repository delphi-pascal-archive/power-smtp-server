unit UMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,MD5;

type
  TActivation_Bt = class(TForm)
    User_Ed: TEdit;
    User_Lb: TLabel;
    Password_Lb: TLabel;
    Password_Ed: TEdit;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Activation_Bt: TActivation_Bt;

implementation

{$R *.dfm}

procedure TActivation_Bt.Button1Click(Sender: TObject);
Var
 User,Password,AFile,AInfo: string;
 FS: TFileStream;
begin
 AFile:=ExtractFilePath(ParamStr(0))+'Power_Smtp_Server.exe';
 if not FileExists(AFile)
 then Exit;
 User:=MD5Print(MD5String(User_Ed.Text));
 Password:=MD5Print(MD5String(Password_Ed.Text));
 AInfo:=User+'|'+Password;
 FS:=TFileStream.Create(AFile,fmOpenWrite);
 FS.Position:=FS.Size;
 try
  FS.Write(PChar(AInfo)^,Length(AInfo));
 finally
  FS.Free;
 end;
end;

end.
