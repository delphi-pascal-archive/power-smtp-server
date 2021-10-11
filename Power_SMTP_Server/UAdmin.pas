unit UAdmin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGrids, StdCtrls, Buttons;

type
  TAdmin_Form = class(TForm)
    User_Gb: TGroupBox;
    Password_Lb: TLabel;
    User_Lb: TLabel;
    User_Add_Bt: TSpeedButton;
    User_Del_Bt: TSpeedButton;
    Port_Lb: TLabel;
    Root_Cb: TCheckBox;
    User_Ed: TEdit;
    Password_Ed: TEdit;
    Port_Ed: TEdit;
    Activity_Gb: TGroupBox;
    Mails_Searching_Bt: TSpeedButton;
    Save_Activity_Bt: TSpeedButton;
    Mail_DBGrid: TDBGrid;
    Mail_Address_Lb: TLabel;
    Mail_Address_Ed: TEdit;
    Spam_Bt: TSpeedButton;
    Mail_Bt: TSpeedButton;
    procedure User_Add_BtClick(Sender: TObject);
    procedure User_Del_BtClick(Sender: TObject);
    procedure Mails_Searching_BtClick(Sender: TObject);
    procedure Save_Activity_BtClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Spam_BtClick(Sender: TObject);
    procedure Mail_BtClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Admin_Form: TAdmin_Form;
  UsersFile:String;

implementation

Uses UMain,UIniFile,UCrypt, UMail;

{$R *.dfm}

{>>Procedure pour ajouter un utilisateur}
procedure TAdmin_Form.User_Add_BtClick(Sender: TObject);
Var
Section:String;
begin
UsersFile:=ExtractFilePath(ParamStr(0))+'Users.Ini';
Section:='User'+IntToStr(Read_Nb_Sections(UsersFile));
If Root_Cb.Checked then
  Begin
  Section:='Root';
  WriteStringIni(UsersFile,Section,'Port',Port_Ed.Text);
  End;
WriteStringIni(UsersFile,Section,'User',User_Ed.Text);
WriteStringIni(UsersFile,Section,'Password',crypt(Password_Ed.Text));
WriteStringIni(UsersFile,Section,'Address',Mail_Address_Ed.Text);
end;

{>>Procedure pour supprimer un utilisateur}
procedure TAdmin_Form.User_Del_BtClick(Sender: TObject);
Var
Users,Passwords,Addresses:TStringList;
CryptPassword:string;
PosUser:integer;
begin
Users:=TStringList.Create;
Passwords:=TStringList.Create;
Addresses:=TStringList.Create;
  Try
    Read_type_keys(UsersFile,'User',Users);
    Read_type_keys(UsersFile,'Password',Passwords);
    Read_type_keys(UsersFile,'Address',Addresses);
    Users.Find(User_Ed.Text,PosUser);
    CryptPassword:=crypt(Password_Ed.Text);
    If (Users.Count>0) AND (PosUser<=Users.Count) Then     
      Begin
      If(Passwords.Strings[PosUser]=CryptPassword) AND
      (Addresses.Strings[PosUser]=Mail_Address_Ed.Text) then
      DeleteSectionIni(UsersFile,PosUser);
      ENd;
  Finally
    Addresses.Free;
    Passwords.Free;
    Users.Free;
  end;
End;

{>>Procedure pour afficher les mails récupérés}
procedure TAdmin_Form.Mails_Searching_BtClick(Sender: TObject);
Var
Index:Cardinal;
begin
Mail_DBGrid.DataSource:=SMTPDataSource;
For Index:=8 to (SMTPTable.FieldCount-1) do
  Begin
  Mail_DBGrid.Columns.Add;
    Case odd(Index) of
    False : Mail_DBGrid.Columns[Index].Title.Caption:='Nom du fichier '+IntToStr(Index-9);
    True :Mail_DBGrid.Columns[Index].Title.Caption:='Pièce jointe '+IntToStr(Index-8);
    End;
  End;
end;

{>>Procedure pour sauvegarder la liste des messages}
procedure TAdmin_Form.Save_Activity_BtClick(Sender: TObject);
begin
If Mail_DBGrid.SelectedIndex>0 then
SMTPTable.Delete;
end;

{>>Procedure pour imprimer le StringGrid}
procedure TAdmin_Form.FormShow(Sender: TObject);
begin
UsersFile:=ExtractFilePath(ParamStr(0))+'Users.Ini';
end;

procedure TAdmin_Form.Spam_BtClick(Sender: TObject);
Var
Choice:String;
begin
With SMTPTable do
  Begin
  Edit;
  If FieldByName('BlackList').AsString='No' then Choice:='Yes'
  Else Choice:='No';
  FieldByName('BlackList').Value:=Choice;
  Post;
  End;
Main.Creation_BlackList;
end;

procedure TAdmin_Form.Mail_BtClick(Sender: TObject);
begin
Admin_Form.Hide;
Mail_Form.Show;
end;

procedure TAdmin_Form.FormClose(Sender: TObject; var Action: TCloseAction);
begin
Main.Close;
end;

end.
