unit UMail;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons,DB;

type
  TMail_Form = class(TForm)
    Header_Gb: TGroupBox;
    Shipper_Ed: TEdit;
    Recipient_Ed: TEdit;
    Date_Ed: TEdit;
    Shipper_Lb: TLabel;
    Recipient_Lb: TLabel;
    Date_Lb: TLabel;
    Attachment_Gb: TGroupBox;
    Attachments_CbBox: TComboBox;
    Attachments_Lb: TLabel;
    Searching_Ed: TEdit;
    Searching_Bt: TSpeedButton;
    Save_Bt: TSpeedButton;
    Mail_Gb: TGroupBox;
    Subject_Ed: TEdit;
    Subject_Lb: TLabel;
    Mail_Memo: TMemo;
    Mail_Lb: TLabel;
    SaveDialog: TSaveDialog;
    procedure FormShow(Sender: TObject);
    procedure Searching_BtClick(Sender: TObject);
    procedure Save_BtClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Mail_Form: TMail_Form;

implementation

Uses UMain;

{$R *.dfm}

{>>Procedure pour récupérer le message : corps + en-tête + Pièces jointes}
procedure TMail_Form.FormShow(Sender: TObject);
Var
Index:Cardinal;
begin
With SMTPTable Do
  Begin
  If RecordCount=0 then exit;
  Shipper_Ed.Text:=FieldByName('Shipper').AsString;
  Recipient_Ed.Text:=FieldByName('Recipient').AsString;
  Date_Ed.Text:=DateToStr(FieldByName('Date').AsDateTime);
  Subject_Ed.Text:=FieldByName('Subject').AsString;
  Mail_Memo.Text:=FieldByName('Body').AsString;      
  For Index:=8 to (FieldCount-1) do
  If not Odd(Index) then
  Attachments_CbBox.Items.Add(FieldByName('Name'+IntToStr(Index-7)).AsString);
  End;
end;

{>>Procedure pour afficher la destination de la pièce jointe}
procedure TMail_Form.Searching_BtClick(Sender: TObject);
begin
If SaveDialog.Execute then
Searching_Ed.Text:=SaveDialog.FileName;
end;

procedure TMail_Form.Save_BtClick(Sender: TObject);
Var
Index:Cardinal;
begin
If (Attachments_CbBox.ItemIndex>-1) and (Searching_Ed.Text<>'') then
With SMTPTable do
  Begin
  Index:=Attachments_CbBox.ItemIndex+1;
  TBlobField(FieldByName('File'+IntToStr(Index))).SaveToFile(Searching_Ed.Text);
  End;
end;

procedure TMail_Form.FormClose(Sender: TObject; var Action: TCloseAction);
begin
Main.Close;
end;

end.
