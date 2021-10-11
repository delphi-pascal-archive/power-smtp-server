unit UIniFile;

interface

Uses IniFiles,Classes,SysUtils,dialogs,StdCtrls;

Procedure WriteStringIni(AIniFile,ASection,AKey,AValue:String);
Function Read_Nb_Sections(AIniFile:String):Cardinal;
Function StringReadIni(AIniFile,ASection,AKey:String):String;
Procedure Read_type_keys(AIniFile,AKey:String;Var List:TStringList);
Procedure DeleteSectionIni(AIniFile:string;Index:Cardinal);
Function WindowsVersion:string;

implementation

{>>ECRIRE UN STRING DANS UN FICHIER INI}
Procedure WriteStringIni(AIniFile,ASection,AKey,AValue : String);
Var
FileIni : TIniFile;
Begin
FileIni:=TIniFile.Create(AIniFile);
  Try
  FileIni.WriteString(ASection,AKey,AValue);
  Finally
  FileIni.Free;
  End;
If (WindowsVersion='95') or (WindowsVersion='98') then FileIni.UpdateFile;
End;

{>>LIRE LE NOMBRE DE SECTIONS D'UN FICHIER INI}
Function Read_Nb_Sections(AIniFile:String):Cardinal;
var
FileIni: TiniFile;
List:TStringList;
begin
List:=TStringList.create;
FileIni:=TIniFile.Create(AIniFile);
FileIni.ReadSections(List);
Result:=List.count;
List.Free;
If (WindowsVersion='95') or (WindowsVersion='98') then FileIni.UpdateFile;
End;

{>>LIRE UN STRING D'UNE SECTION D'UN FICHIER INI}
Function StringReadIni(AIniFile,ASection,AKey : String): String;
Var
FileIni : TIniFile;
AValue : String;
Begin
FileIni:=TIniFile.Create(AIniFile);
  Try
  Avalue:='';
  AValue:=FileIni.ReadString(ASection,AKey,'');
  Finally
  FileIni.Free;
  End;
If (WindowsVersion='95') or (WindowsVersion='98') then FileIni.UpdateFile;
Result:=AValue;
End;

{>>VERIFIER QU'UNE CLE EXISTE DANS UN FICHIER INI}
Function VerifKey(AIniFile,ASection,AKey : String): Boolean;
Var
FileIni : TIniFile;
Begin
FileIni:=TIniFile.Create(AIniFile);
  Try
  Result:=FileIni.ValueExists(ASection,AKey);
  Finally
  FileIni.Free;
  End;
If (WindowsVersion='95') or (WindowsVersion='98') then FileIni.UpdateFile;
End;

{>>Récupérer les sections admettant une clé donnée}
Procedure Read_type_keys(AIniFile,AKey:String;Var List:TStringList);
Var
FileIni : TIniFile;
SectionsList:TStringList;
Index:Cardinal;
Begin
FileIni:=TIniFile.Create(AIniFile);
SectionsList:=TStringList.Create;
  Try
  FileIni.ReadSections(SectionsList);
  If SectionsList.Count>0 then
    Begin
      For Index:=0 to (SectionsList.Count-1) do
      If FileIni.ValueExists(SectionsList.Strings[Index],AKey) then
      List.Add(FileIni.ReadString(SectionsList.Strings[Index],AKey,''));
    End;
  Finally
  SectionsList.Free;
  FileIni.Free;
  End;
End;

{>>SUPPRIMER UNE SECTION D'UN FICHIER INI}
Procedure DeleteSectionIni(AIniFile:string;Index:Cardinal);
Var
FileIni : TIniFile;
SectionsList:TStringList;
Begin
FileIni:=TIniFile.Create(AIniFile);
SectionsList:=TStringList.Create;
  Try
  FileIni.ReadSections(SectionsList);
  If SectionsList.Count>=0 then
  FileIni.EraseSection(SectionsList.Strings[Index]);
  Finally
  SectionsList.Free;
  FileIni.Free;
  End;
End;

{>>TRAITEMENT ANNEXE SUIVANT LA VERSION DE WINDOWS}
Function WindowsVersion: string;
begin
  case Win32MajorVersion of
    3: Result:='NT 3.51';
    4: case Win32MinorVersion of
         0:  case Win32Platform of
               1: Result:='95';
               2: Result:='NT 4.0'
             else
               Result:='Inconnue';
             end;
         10: Result:='98';
         90: Result:='Millennium';
       else
         Result:='Inconnue';
       end;
    5: case Win32MinorVersion of
         0:  Result:='2000';
         1:  Result:='XP';
         2:  Result:='Server 2003';
       else
         Result:='Inconnue';
       end;
  else
    Result:='Inconnue';
  end;
end;


end.
