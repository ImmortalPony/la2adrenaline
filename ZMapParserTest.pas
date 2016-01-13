{*******************************************************
Copyright (c) 2015 Immortal Pony
Tested on 4Game Classic
*******************************************************}

uses SysUtils, Classes;

type
  TPoint = packed record
    X: Longint;
    Y: Longint;
  end;

  PPoint = ^TPoint;

function ExtractIntegerValue(ZMap: string; var Start: Integer): Integer;
var
  Finish: Integer;
begin
  Start := PosEx('="', ZMap, Start) + Length('="');
  Finish := PosEx('"', ZMap, Start);
  Result := StrToInt(Copy(ZMap, Start, Finish - Start));
end;

function PosEx(const SubStr, S: string; Offset: Integer = 1): Integer;
var
  I, X: Integer;
  Len, LenSubStr: Integer;
begin
  if Offset = 1 then
    Result := Pos(SubStr, S)
  else
  begin
    I := Offset;
    LenSubStr := Length(SubStr);
    Len := Length(S) - LenSubStr + 1;
    while I <= Len do
    begin
      if S[I] = SubStr[1] then
      begin
        X := 1;
        while (X < LenSubStr) and (S[I + X] = SubStr[X + 1]) do
          Inc(X);
        if (X = LenSubStr) then
        begin
          Result := I;
          exit;
        end;
      end;
      Inc(I);
    end;
    Result := 0;
  end;
end;

procedure GetPolies(ZMap: string; Polies: TList);
var
  Offset: Integer;
  OffsetInner: Integer;
  CloseTag: Integer;
  PointTag: Integer;
  Poly: TList;
  Point: PPoint;
begin
  Offset := PosEx('<poly>', ZMap, 1);
  while Offset <> 0 do
  begin
    CloseTag := PosEx('</poly>', ZMap, Offset);
    Poly := TList.Create;
    OffsetInner := PosEx('<point ', ZMap, Offset);
    while (OffsetInner < CloseTag) and (OffsetInner <> 0) do
    begin
      New(Point);
      Point.X := ExtractIntegerValue(ZMap, OffsetInner);
      Point.Y := ExtractIntegerValue(ZMap, OffsetInner);
      Poly.Add(Point);
      OffsetInner := PosEx('<point ', ZMap, OffsetInner + Length('<point '));
    end;
    Polies.Add(Poly);
    Offset := PosEx('<poly>', ZMap, Offset + Length('<poly>'));
  end;
end;

var
  Polies: TList;
  I, j: Integer;
  Strings: TStringList;
  Point: PPoint;

begin
  Strings := TStringList.Create;
  Polies := TList.Create;
  Strings.LoadFromFile('./Settings/1.zmap');
  GetPolies(Strings.Text, Polies);
  for I := 0 to Polies.Count - 1 do
  begin                                                                    
    Print('Poly # ' + IntToStr(I + 1));
    for j := 0 to TList(Polies[I]).Count - 1 do
    begin
      Point := PPoint(TList(Polies[I])[j]);
      Print(IntToStr(Point.X) + ' ' + IntToStr(Point.Y));
      Dispose(Point);
    end;
  end;
  Strings.Free;
  Polies.Free;
end.