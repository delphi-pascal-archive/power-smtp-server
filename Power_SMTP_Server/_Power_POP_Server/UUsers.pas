unit UUsers;

interface

Uses Classes,SysUtils,IdUserAccounts;

Procedure Users_Initialization(UserManager:TidUserManager);
Procedure User_Add_ServerFTP(AUser,APassword:string;UserManager:TidUserManager);

implementation

USes UMain,UIniFile,UCrypt;

{>>Ajout de tout les utilisateurs}
Procedure Users_Initialization(UserManager:TidUserManager);
Var
AUser,APassword:String;
Users,Passwords:TStringList;
Index:Cardinal;
Begin
Users:=TStringList.Create;
Passwords:=TStringList.Create;
Read_type_keys(UsersFile,'User',Users);
Read_type_keys(UsersFile,'Password',Passwords);
For Index:=0 to (Users.Count-1) do
  Begin
  AUser:=Users.Strings[Index];
  APassword:=Crypt(Passwords.Strings[Index]);
  User_Add_ServerFTp(AUser,APassword,UserManager);
  End;
Users.Free;
Passwords.Free;
End;

{>>Ajout d'un utilisateur}
Procedure User_Add_ServerFTP(AUser,APassword:string;UserManager:TidUserManager);
Begin
with UserManager.Accounts.Add do
    begin
    Username:=AUser;
    Password:=APassword;
    end;
End;

end.
