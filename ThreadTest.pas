{*******************************************************
Copyright (c) 2016 Immortal Pony
Tested on Lineage2.com Classic
*******************************************************}
uses SysUtils;
var
  S: Integer;
  
procedure Thread(P: Pointer);
begin
  while true do
  begin
    Print(IntToStr(S));
    Delay(1000);
  end;

end;

begin
  S := 1;
  Script.NewThread(@Thread, @S);
  Delay(3000);
  S := 2;
end.