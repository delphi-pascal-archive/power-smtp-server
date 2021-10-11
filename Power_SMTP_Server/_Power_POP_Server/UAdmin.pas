unit UAdmin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, Buttons, DBGrids;

type
  TAdmin_Form = class(TForm)
    User_Gb: TGroupBox;
    Password_Lb: TLabel;
    User_Lb: TLabel;
    User_Add_Bt: TSpeedButton;
    User_Del_Bt: TSpeedButton;
    Root_Cb: TCheckBox;
    User_Ed: TEdit;
    Password_Ed: TEdit;
    Activity_Gb: TGroupBox;
    LookFor_Activity_Bt: TSpeedButton;
    Print_Activity_Bt: TSpeedButton;
    Save_Activity_Bt: TSpeedButton;
    Port_Lb: TLabel;
    Port_Ed: TEdit;
    Mail_DBGrid: TDBGrid;
    procedure User_Add_BtClick(Sender: TObject);
    procedure User_Del_BtClick(Sender: TObject);
    procedure LookFor_Activity_BtClick(Sender: TObject);
    procedure Save_Activity_BtClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Admin_Form: TAdmin_Form;

implementation

Uses UMain,UIniFile,UCrypt;

{$R *.dfm}

procedure TAdmin_Form.User_Add_BtClick(Sender: TObject);
Var
Section:String;
begin
Section:='User'+IntToStr(Read_Nb_Sections(UsersFile));
If Root_Cb.Checked then
  Begin
  Section:='Root';
  WriteStringIni(UsersFile,Section,'Port',Port_Ed.Text);
  End;
WriteStringIni(UsersFile,Section,'User',User_Ed.Text);
WriteStringIni(UsersFile,Section,'Password',crypt(Password_Ed.Text));
end;

procedure TAdmin_Form.User_Del_BtClick(Sender: TObject);
Var
Users,Passwords:TStringList;
CryptPassword:string;
PosUser:integer;
begin
Users:=TStringList.Create;
Passwords:=TStringList.Create;
  Try
    Read_type_keys(UsersFile,'User',Users);
    Read_type_keys(UsersFile,'Password',Passwords);
    Users.Find(User_Ed.Text,PosUser);
    CryptPassword:=crypt(Password_Ed.Text);
    If (Users.Count>0) AND (PosUser<=Users.Count) Then
      Begin
      If(Passwords.Strings[PosUser]=CryptPassword) then
      DeleteSectionIni(UsersFile,PosUser);
      ENd;
  Finally
    Passwords.Free;
    Users.Free;
  end;
End;  

procedure TAdmin_Form.LookFor_Activity_BtClick(Sender: TObject);
begin
Mail_DBGrid.DataSource:=POPDataSource;
end;

procedure TAdmin_Form.Save_Activity_BtClick(Sender: TObject);
begin
POPTable.Delete;
end;

end.
