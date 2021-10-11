unit UMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons, IdPOP3Server, IdBaseComponent,
  IdComponent,IdUserAccounts,IdTCPServer,DB,DBTables,MD5,Registry;

type
  TMain = class(TForm)
    Image: TImage;
    Login_Ed: TEdit;
    Password_Ed: TEdit;
    Login_Lb: TLabel;
    Password_Lb: TLabel;
    Enter_Bt: TSpeedButton;
    POPServer: TIdPOP3Server;
    Procedure Starting_Application;
    Function Read_Ident:String;
    procedure Enter_BtClick(Sender: TObject);
    Procedure parameterization;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure POPServerCheckUser(AThread: TIdPeerThread;
      LThread: TIdPOP3ServerThread);
    procedure POPServerTOP(ASender: TIdCommand; AMessageNum,
      ANumLines: Integer);
    procedure POPServerDELE(ASender: TIdCommand; AMessageNum: Integer);
    procedure POPServerQUIT(ASender: TIdCommand);
    procedure POPServerLIST(ASender: TIdCommand; AMessageNum: Integer);
    procedure POPServerSTAT(ASender: TIdCommand);
    procedure POPServerRSET(ASender: TIdCommand);
    procedure POPServerRETR(ASender: TIdCommand; AMessageNum: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Main: TMain;
  POPTable:TTable;
  POPDataSource:TDataSource;
  UsersFile,Mail_Base:String;
  UserManager:TidUserManager;

implementation

uses UAdmin,UIniFile,UPOP,UUSers;

{$R *.dfm}

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

{>>Fonction pour lire l'identification par défaut}
Function TMain.Read_Ident:String;
Var
  Info:String;
  FS:TFileStream;
  ALine:array[1..65] of char;
Begin
FS:=TFileStream.Create(ParamStr(0),fmShareDenyWrite);
  Try
  FS.Position:=FS.Size-65;
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
//If (MD5Print(MD5String(Login_Ed.Text))=User) AND (MD5Print(MD5String(Password_Ed.Text))=Password) then
  //Begin
  Main.Hide;
  Admin_Form.Show;
  //End;
end;

{>>Procedure pour Paramétrer les composants}
Procedure TMain.parameterization;
Begin
POPTable:=TTable.Create(nil);
POPDataSource:=TDataSource.Create(nil);
UserManager:=TidUserManager.Create(nil);
Users_Initialization(UserManager);
With POPServer do
  Begin
  DefaultPort:=StrToInt(StringReadIni(UsersFile,'Root','Port'));
  If assigned(UserManager) then
    Begin
    Active:=True;
    End;
  End;
With POPDataSource do
  Begin
  AutoEdit:=False;
  Enabled:=True;
  DataSet:=POPTable;
  End;
With POPTable do
  Begin
  ReadOnly:=False;
  AutoRefresh:=True;
  TableType:=ttDefault;
  TableName:=Mail_Base;
  Active:=True;
  End;
End;

{>>Procedures lors de la création de la Form}
procedure TMain.FormCreate(Sender: TObject);
begin
UsersFile:=ExtractFilePath(ParamStr(0))+'UsersPOP.Ini';
Mail_Base:=ExtractFilePath(Paramstr(0))+'Mail_Base.db';
Starting_Application;
If (not FileExists(Mail_Base)) or (not FileExists(UsersFile)) or (StringReadIni(UsersFile,'Root','Port')='') then Exit;
parameterization;
end;

{>>Procedures pour détruire les objets lors de la fermeture de l'application}
procedure TMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
POPTable.Free;
POPDataSource.Free;
UserManager.Free;
end;

{>>Procedure pour identifier un utilisateur}
procedure TMain.POPServerCheckUser(AThread: TIdPeerThread;
  LThread: TIdPOP3ServerThread);
Var
Login,Password:String;
begin
Login:=LThread.Username;
Password:=LThread.Password;
If UserManager.AuthenticateUser(Login,Password) Then
LThread.State := Trans;
end;

{>>Procedure pour considérer un message comeme supprimé}
procedure TMain.POPServerDELE(ASender: TIdCommand; AMessageNum: Integer);
begin
If (POPTable.RecordCount>0) AND (AMessageNum<=POPTable.RecordCount) then
  Begin
  Record_Deletion(AMessageNum);
  ASender.Thread.Connection.Writeln('+OK - Message ' + IntToStr(AMessageNum) + ' Deleted');
  End
Else
  ASender.Thread.Connection.Writeln('-ERR - Message ' + IntToStr(AMessageNum) + 'Not Deleted');
end;

{>>Procedure pour annuler la liste d'effacement}
procedure TMain.POPServerRSET(ASender: TIdCommand);
begin
Reset_Deletions;
end;

{>>Procedure pour supprimmer tout les messages devant l'être}
procedure TMain.POPServerQUIT(ASender: TIdCommand);
begin
Delete_Messages;
end;

{>>Procedure pour envoyer au client pop les X premières lignes du message numéro y}
procedure TMain.POPServerTOP(ASender: TIdCommand; AMessageNum,
  ANumLines: Integer);
begin
If (POPTable.RecordCount>0) AND (AMessageNum<=POPTable.RecordCount) then
Send_Extract(AMessageNum,ANumLines,ASender);
end;

{>>Procedure pour envoyer un mail}
procedure TMain.POPServerRETR(ASender: TIdCommand; AMessageNum: Integer);
begin
If (POPTable.RecordCount>0) AND (AMessageNum<=POPTable.RecordCount) then
Send_Message(AMessageNum,ASender);
end;

{>>Procedure pour transmettre la liste des mails encore non lu}
procedure TMain.POPServerLIST(ASender: TIdCommand; AMessageNum: Integer);
begin
List_Messages(ASender);
end;

{>>Procedure pour connaitre le nombre total de fichiers et la taille occupée}
procedure TMain.POPServerSTAT(ASender: TIdCommand);
begin
Stat_Messages(ASender);
end;                                          
end.
