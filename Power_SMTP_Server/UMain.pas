unit UMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons,IdMessage,IdBaseComponent, IdComponent,
  IdTCPServer,IdSMTPServer,IdEMailAddress, IdTCPConnection, IdAntiFreezeBase,
  IdAntiFreeze,IdUserAccounts,DB,DBTables,Registry,MD5;

type
  TMain = class(TForm)
    Image: TImage;
    Login_Ed: TEdit;
    Password_Ed: TEdit;
    Login_Lb: TLabel;
    Password_Lb: TLabel;
    Enter_Bt: TSpeedButton;
    IdAntiFreeze1: TIdAntiFreeze;
    SMTPServer: TIdSMTPServer;
    Function Read_Ident:String;
    procedure Enter_BtClick(Sender: TObject);
    Procedure Starting_Application;
    Procedure parameterization;
    Procedure Creation_BlackList;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SMTPServerCommandMAIL(const ASender: TIdCommand;
      var Accept: Boolean; EMailAddress: String);
    procedure SMTPServerCommandRCPT(const ASender: TIdCommand; var Accept,
      ToForward: Boolean; EMailAddress: String; var CustomError: String);
    procedure SMTPServerReceiveMessageParsed(ASender: TIdCommand;
      var AMsg: TIdMessage; RCPT: TIdEMailAddressList;
      var CustomError: String);
    procedure SMTPServerCommandVRFY(ASender: TIdCommand);
    procedure SMTPServerCommandEXPN(ASender: TIdCommand);
    procedure SMTPServerCheckUser(ASender: TIdCommand; var Accept: Boolean;
      Username, Password: String);
    procedure SMTPServerCommandHELP(ASender: TIdCommand);
  private
    { Private declarations }
  public
      { Public declarations }
  end;

var
  Main: TMain;
  SMTPTable:TTable;
  SMTPDataSource:TDataSource;
  UsersFile,Mail_Base,Shipper:String;
  UserManager:TidUserManager;
  BlackList:TStringList;

implementation

uses UIniFile,UUsers,USMTP, UAdmin;

{$R *.dfm}
{$R SMTP_Resource.res}

{>>Lancement automatique de l'application à l'allumage du PC}
Procedure TMain.Starting_Application;
Var
Reg:TRegistry;
Begin
Reg:=TRegistry.Create;
With Reg Do
  Begin
  RootKey:=HKEY_LOCAL_MACHINE;
  IF OpenKey('\Software\Microsoft\Windows\CurrentVersion\Run', False) THEN
  WriteString(ParamStr(0),Application.exename);
  Free;
  End;
End;

{>>Procedure pour Paramétrer les composants}
Procedure TMain.parameterization;
Begin
SMTPTable:=TTable.Create(nil);
SMTPDataSource:=TDataSource.Create(nil);
UserManager:=TidUserManager.Create(nil);
Users_Initialization(UserManager);
With SMTPServer do
  Begin
  DefaultPort:=StrToInt(StringReadIni(UsersFile,'Root','Port'));
  If assigned(UserManager) then Active:=True;
  End;
With SMTPDataSource do
  Begin
  AutoEdit:=False;
  Enabled:=True;
  DataSet:=SMTPTable;
  End;
With SMTPTable do
  Begin
  ReadOnly:=False;
  AutoRefresh:=True;
  TableType:=ttDefault;
  TableName:=Mail_Base;
  Active:=True;
  End;
End;

{>>Procedure pour Créer la BlackList}
Procedure TMain.Creation_BlackList;
Var
Index:Cardinal;
Begin
With SMTPTable do
  Begin
  If RecordCount<1 then Exit;
  If Assigned(BlackList) then
  BlackList.Clear Else BlackList:=TstringList.Create;
  With BlackList do
    For Index:=0 to (RecordCount-1) Do
      Begin
      SMTPTable.RecNo:=Index;
      If SMTPTable.FieldByName('BlackList').AsString='Yes' then
      BlackList.Add(SMTPTable.FieldByName('Shipper').AsString);
      End;
  End;
End;

{>>Procedures lancées à la création de la Form}
procedure TMain.FormCreate(Sender: TObject);
begin
UsersFile:=ExtractFilePath(ParamStr(0))+'Users.Ini';
Mail_Base:='Mail_Base.db';
//Starting_Application;
If (not FileExists(Mail_Base)) or (not FileExists(UsersFile)) or (StringReadIni(UsersFile,'Root','Port')='') then Exit;
parameterization;
Creation_BlackList;
end;

{>>Procedures lancées à la fermeture de l'application}
procedure TMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
SMTPServer.Active:=False;
SMTPTable.Free;
SMTPDataSource.Free;
UserManager.Free;
Application.terminate;
BlackList.Free;
end;

{>>Fonction pour lire l'identification par défaut}
Function TMain.Read_Ident:String;
Var
  Info:String;
  FS:TFileStream;
  ALine:array[1..34] of char;
Begin
FS:=TFileStream.Create(ParamStr(0),fmShareDenyWrite);
  Try
  FS.Position:=FS.Size-34;
  FS.Read(ALine,Length(ALine));
  Finally
  FreeAndNil(FS);
  End;
Info:=string(ALine);
result:=Info;
End;

{>>Procedure pour comparer les identifications}
procedure TMain.Enter_BtClick(Sender: TObject);
Var
User,Password,Ident : string;
begin
Ident:=Read_Ident;
User:=Copy(Ident,0,Pos('|',Ident)-1);
Password:=Copy(Ident,Pos('|',Ident)+1,length(Ident));
If (MD5Print(MD5String(Login_Ed.Text))=User) AND (MD5Print(MD5String(Password_Ed.Text))=Password) then
  Begin
  Main.Hide;
  Admin_Form.Show;
  End;
end;

{>>Procedure à déclencher en fonction de l'expediteur}
procedure TMain.SMTPServerCommandMAIL(const ASender: TIdCommand;
  var Accept: Boolean; EMailAddress: String);
Begin
If (Assigned(BlackList)) AND (BlackList.IndexOf(EmailAddress)<>-1) then
    Begin
    ASender.Thread.Connection.WriteLn('500'+ ' Address is refused');
    Accept:=False;
    End
  Else
    Begin
    ASender.Thread.Connection.WriteLn('OK '+ ' Address is accepted');
    Shipper:=EMailAddress;
    Accept:=True;
    End;
end;

{>>Procedure pour tester la validité de l'adresse du récepteur}
procedure TMain.SMTPServerCommandRCPT(const ASender: TIdCommand;
  var Accept, ToForward: Boolean; EMailAddress: String;
  var CustomError: String);
Var
AddressesList:TStringList;
begin
AddressesList:=TStringList.Create;
Read_type_keys(UsersFile,'Address',AddressesList);
If (AddressesList.IndexOf(EMailAddress)=-1) then
  Begin
  CustomError := '500 No at sign';
  Accept:=False;
  End
Else
  Begin
  ASender.Thread.Connection.WriteLn('OK '+ ' Address is accepted');
  Accept:=True;
  End;
AddressesList.Free;
end;

procedure TMain.SMTPServerReceiveMessageParsed(ASender: TIdCommand;
  var AMsg: TIdMessage; RCPT: TIdEMailAddressList;
  var CustomError: String);
Var
Index:Cardinal;
begin
For Index:=0 to (RCPT.Count-1) do
  Begin
  AddMessage(AMsg,RCPT.Items[Index].Address);
  end;
End;

procedure TMain.SMTPServerCommandVRFY(ASender: TIdCommand);
Var
User:String;
Users,Addresses:TStringList;
begin
User:=ASender.UnparsedParams;
Users:=TStringList.Create;
Addresses:=TStringList.Create;
Read_type_keys(UsersFile,'User',Users);
Read_type_keys(UsersFile,'Address',Addresses);
If Users.IndexOf(User)<>-1 then
ASender.Thread.Connection.WriteLn('OK '+Addresses.Strings[Users.IndexOf(User)]+' exists')
Else
  ASender.Thread.Connection.WriteLn('500 this user is not good');
Users.Free;
Addresses.Free;
end;

procedure TMain.SMTPServerCommandEXPN(ASender: TIdCommand);
Var
List:String;
Users,Addresses:TStringList;
Index:Cardinal;
begin
List:=ASender.UnparsedParams;
If List='Users' then
  Begin
  Users:=TStringList.Create;
  Addresses:=TStringList.Create;
  Read_type_keys(UsersFile,'User',Users);
  Read_type_keys(UsersFile,'Address',Addresses);
  ASender.Thread.Connection.WriteLn('ok');
    For Index:=0 to (Users.Count-1) do
    ASender.Thread.Connection.WriteLn(Users.Strings[Index]+' '+Addresses.Strings[Index]+' exists');
  End
Else
  ASender.Thread.Connection.WriteLn('500 List is not correct');
end;

procedure TMain.SMTPServerCheckUser(ASender: TIdCommand;
  var Accept: Boolean; Username, Password: String);
begin
Accept:=UserManager.AuthenticateUser(Username,Password);
end;

procedure TMain.SMTPServerCommandHELP(ASender: TIdCommand);
begin
ASender.Thread.Connection.WriteLn('OK');
ASender.Thread.Connection.WriteLn('VRFY');
ASender.Thread.Connection.WriteLn('EXPN');
ASender.Thread.Connection.WriteLn('MAIL');
ASender.Thread.Connection.WriteLn('RCPT');
ASender.Thread.Connection.WriteLn('DATA');
ASender.Thread.Connection.WriteLn('HELP');
end;

end.

