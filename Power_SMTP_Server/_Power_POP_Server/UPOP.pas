unit UPOP;

interface

Uses Windows,SysUtils,Classes,StdCtrls,IdTCPServer,DB,Controls;

Procedure Send_Message(IndexMessage:Integer;ASender: TIdCommand);
Procedure Send_Attachments(ASender:TIdCommand;IndexMessage:Cardinal);
Procedure Send_Extract(IndexMessage,NbLines:Integer;ASender: TIdCommand);
Procedure Record_Deletion(IndexMessage:Integer);
Procedure Reset_Deletions;
procedure Delete_Messages;
procedure List_Messages(ASender: TIdCommand);
procedure Stat_Messages(ASender: TIdCommand);

Var
FilesDel:TStringList;

implementation

Uses UMain;


Procedure Send_Message(IndexMessage:Integer;ASender: TIdCommand);
Var
Option : TLocateOptions;
begin
  With POPTable do
    With ASender.Thread.Connection do
      Begin
      Option := [loPartialKey];
      If Locate('ID',IndexMessage,Option)=False then Exit;
      Edit;
      FieldByName('Read').Value:='Yes';
      Post;
      WriteLn('+OK');
      WriteLn(IntToStr(RecordSize));
      WriteLn('From: '+POPTable.FieldByName('Shipper').AsString);
      WriteLn('To: '+FieldByName('Recipient').AsString);
      WriteLn('Date: '+DateToStr(FieldByName('Date').AsDateTime));
      WriteLn('Subject: '+FieldByName('Subject').AsString);
      WriteLn(';');
      WriteLn(FieldByName('Body').AsString);
      Send_Attachments(ASender,IndexMessage);
      End;
End;

Procedure Send_Attachments(ASender:TIdCommand;IndexMessage:Cardinal);
Var
Option : TLocateOptions;
NbFiles,Index:Cardinal;
TempFolder,AFile:String;
Folder:array[0..1024] of Char;
Begin
If GetTempPath(SizeOf(Folder),Folder)<>0 then TempFolder:=StrPas(Folder);
With POPTable Do
  Begin
  Option := [loPartialKey];
  Locate('ID',IndexMessage,Option);
  NbFiles:=(FieldCount-8) div 2;
  If NbFiles<=0 Then Exit;
  For Index:=8 to (FieldCount-1) do
  If not Odd(Index) then
    Begin
    AFile:=POPTable.FieldByName('Name'+IntToStr(Index-7)).AsString;
    (FieldByName('Fichier'+IntToStr(Index+1-7)) as TBlobField).SaveToFile(TempFolder+AFile);
    ASender.Thread.Connection.WriteFile(TempFolder+AFile,True);
    DeleteFile(TempFolder+AFile);
    End;
  End;
End;

Procedure Send_Extract(IndexMessage,NbLines:Integer;ASender: TIdCommand);
Var
Mess:TStringList;
Index:Cardinal;
Option : TLocateOptions;
begin
  With POPTable do
    With ASender.Thread.Connection do
      Begin
      Option := [loPartialKey];
      If Locate('ID',IndexMessage,Option)=False then Exit;
      WriteLn('+OK');
      WriteLn(IntToStr(RecordSize));
      WriteLn('Subject: '+FieldByName('Subject').AsString);
      WriteLn(';');
      Mess:=TStringList.Create;
      Mess.Text:=FieldByName('Body').AsString;
      For Index:=0 To (NbLines) Do
      WriteLn(Mess.Strings[Index]);
      Mess.Free;
      End;
End;

Procedure Record_Deletion(IndexMessage:Integer);
Begin
If not assigned(FilesDel) then FilesDel:=TStringList.Create;
FilesDel.Add(IntToStr(IndexMessage));
End;

Procedure Reset_Deletions;
Begin
FilesDel.Free;
End;

procedure Delete_Messages;
Var
Index:Cardinal;
Option:TLocateOptions;
Begin
Option:=[loPartialKey];
With POPTable do
  Begin
  For Index:=0 To (FilesDel.Count-1) do
    Begin
    Locate('ID',StrToInt(FilesDel.Strings[Index]),Option);
    Delete;
    End;
  FilesDel.Free;
  End;  
End;

procedure List_Messages(ASender: TIdCommand);
Var
Index:Cardinal;
Option : TLocateOptions;
Begin
Option:=[loPartialKey];
With ASender.Thread.Connection do
  Begin
  WriteLn('OK');
  For Index:=0 to (POPTable.RecordCount-1) do
    With POPTable do
      Begin
      Locate('ID',Index+1,Option);
      If FieldByName('Read').AsString='No' then
      WriteLn(IntToStr(Index+1)+' '+IntToStr(RecordSize));
      End;
  End;
End;

procedure Stat_Messages(ASender: TIdCommand);
Var
Index,TotalSize:Integer;
Option : TLocateOptions;
Begin
TotalSize:=0;
Option:=[loPartialKey];
With ASender.Thread.Connection do
  With POPTable do
      Begin
      For Index:=0 to (RecordCount-1) do
        Begin
        Locate('ID',Index+1,Option);
        TotalSize:=TotalSize+RecordSize;
        End;
      WriteLn('OK');
      WriteLn(IntToStr(RecordCount)+' '+IntToStr(TotalSize));
      End;
End;            

end.
