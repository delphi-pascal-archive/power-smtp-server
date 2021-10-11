unit USMTP;

interface

Uses Forms,Windows,SysUtils,Classes,Dialogs,IdMessage,DB,DBTables;

Procedure Create_File_Fields(Action:string); 
Procedure AddMessage(AMsg:TIdMessage;Recipient_Address:String);

implementation

Uses UMain;


{>>Procedure pour Créer un Field}
Procedure Create_File_Fields(Action:string);
var
Query: TQuery;
begin
Query := TQuery.Create(nil);
with Query do
  try
    Query.DatabaseName:=SMTPTable.DatabaseName;
    Sql.Text:=Action;
    ExecSql;
  finally
    Close;
    Free;
  end;
End;

{>>Procedure pour afficher un message dans la base de données}
Procedure AddMessage(AMsg:TIdMessage;Recipient_Address:String);
Var
Index,IndexFile:integer;
TempFolder,AFile:String;
Folder:array[0..1024] of Char;
Begin
IndexFile:=0;
If GetTempPath(SizeOf(Folder),Folder)<>0 then TempFolder:=StrPas(Folder);
With SMTPTable do
  Begin
  If RecordCount>0 then Append;
  Edit;
    Try
    FieldByName('Shipper').Value:=Shipper;
    FieldByName('BlackList').Value:='No';
    FieldByName('Recipient').Value:=Recipient_Address;
    FieldByName('Date').Value:=AMsg.Date;
    FieldByName('Subject').Value:=AMsg.Subject;
    FieldByName('Body').Value:=AMsg.Body.Text;
    FieldByName('Read').Value:='No';
    For Index:=0 to (AMsg.MessageParts.Count-1) do
      Begin
      If Amsg.MessageParts.Items[Index] is TIdText then
      FieldByName('Body').Value:=(TIdText(Amsg.MessageParts.Items[Index]).Body.text);
      If (AMsg.MessageParts.Items[Index])is TIdAttachment then
        Begin
        Inc(IndexFile);
        If IndexFile>((SMTPTable.FieldCount-8) div 2) then
          Begin
          If Active then Active:=False;
          Create_File_Fields('ALTER TABLE Mail_Base ADD Name'+IntToStr(IndexFile)+' varchar(30)');
          Create_File_Fields('ALTER TABLE Mail_Base ADD File'+IntToStr(IndexFile)+' blob(240,2)');
          End;
        Active:=True;
        AFile:=TIdAttachment(AMsg.MessageParts.Items[Index]).filename;
        FieldByName('Name'+IntToStr(IndexFile)).Value:=AFile;
        sleep(1000);
        Application.ProcessMessages;
        TIdAttachment(AMsg.MessageParts.Items[Index]).SaveToFile(TempFolder+AFile);
        (FieldByName('File'+IntToStr(IndexFile)) as TBlobField).LoadFromFile(TempFolder+AFile);
        DeleteFile(TempFolder+AFile);
        End;
      End;  
    Finally
    Post;
    End;
  End;
End;

end.
