unit UCrypt;

interface

function Crypt(St:string):string;

implementation

{>>Procédure pour crypter une String}
function Crypt(St:string):string;
var
i:byte;
StCrypt:string;
Key:integer;
begin
Key:=1100;
StCrypt:='';
for i:=1 to Length(St) do
StCrypt:=StCrypt+Char(Byte(St[i]) xor Key shr 8);
result:=StCrypt;
end;

end.
 