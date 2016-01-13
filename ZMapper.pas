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

function GetKeyState(nVirtKey: Integer): byte; stdcall;
  external 'user32.dll' name 'GetKeyState';

function KeyDown(K: byte): Boolean;
begin
  Result := (K = 128) or (K = 129)
end;

function SHIFT: Boolean;
begin
  Result := KeyDown(GetKeyState($10));
end;

function CTRL: Boolean;
begin
  Result := KeyDown(GetKeyState($11));
end;

function ALT: Boolean;
begin
  Result := KeyDown(GetKeyState($12));
end;

function GetPosForNewBorder(ZMap: TStringList): Integer;
begin
  if Pos('<ExternalPoly>', ZMap.Text) = 0 then
  begin
    ZMap.Insert(0, '</zone>');
    ZMap.Insert(0, '</ExternalPoly>');
    ZMap.Insert(0, '</points>');
    ZMap.Insert(0, '<points>');
    ZMap.Insert(0, '<ExternalPoly>');
    ZMap.Insert(0, '<zone>');
    ZMap.Insert(0, '<?xml version="1.0" encoding="utf-8"?>');
  end;
  Result := 4;
end;

function GetPosForNewObstruction(ZMap: TStringList): Integer;
var
  i, Line: Integer;
 
begin
  for i:=0 to ZMap.Count - 1 do
    if Pos('</ExternalPoly>', ZMap[i]) <> 0 then break;
  Line := i + 1;
  if Pos('<InternalPolies>', ZMap.Text) = 0 then
  begin
    ZMap.Insert(Line, '</InternalPolies>');
    ZMap.Insert(Line, '<InternalPolies>');
  end;
  Line := Line + 1;
    ZMap.Insert(Line, '</poly>');
    ZMap.Insert(Line, '</points>');
    ZMap.Insert(Line, '<points>');
    ZMap.Insert(Line, '<poly>');
  Result := Line + 2;
end;

procedure ZMapperProcedure(p: pointer); // Поток для ожидания/обработки событий
var
  KeyCode, I: Integer;
  Obstruction: TList;
  Border: TList;
  ZMap: TStringList;
  FileName: string;
  Point: PPoint;
  Line: Integer;
begin
  FileName := './Settings/test.zmap';
  ZMap := TStringList.Create;
  Border := TList.Create;
  Obstruction := TList.Create;
  while Engine.Status = lsOnline do
  begin // Цикл действует пока чар в игре (Online)
    Engine.WaitAction([laKey], KeyCode, I);
    // **
    if SHIFT and (KeyCode = $43) then // Shift + "C"
    begin
      New(Point);
      Point.X := User.X;
      Point.Y := User.Y;
      Print('New obstruction point: ' + IntToStr(Point.X) + ' ' + IntToStr(Point.Y));
      Obstruction.Add(Point);
    end;
    // **
    if CTRL and (KeyCode = $53) then // Ctrl + "S"
    begin
      ZMap.Clear;
      if FileExists(FileName) then ZMap.LoadFromFile(FileName);
      Line := GetPosForNewBorder( ZMap );
      for I := 0 to Border.Count - 1 do
      begin
        Point := PPoint(Border[I]);
        ZMap.Insert(Line, '<point x="' + IntToStr(Point.X) + '" y="' + IntToStr(Point.Y) + '"/>');
        Dispose(Border[I]);
        Inc(Line);
      end;
      Border.Clear;
      if Obstruction.Count > 0 then Line := GetPosForNewObstruction( ZMap );
      
      for I := 0 to Obstruction.Count - 1 do
      begin
        Point := PPoint(Obstruction[I]);
        ZMap.Insert(Line, '<point x="' + IntToStr(Point.X) + '" y="' + IntToStr(Point.Y) + '"/>');
        Dispose(Obstruction[I]);
        Inc(Line);
      end;
      Obstruction.Clear;

      ZMap.SaveToFile(FileName);
      Print('ZMap updated: ' + FileName);
    end;
    // **
    if SHIFT and (KeyCode = $58) then // Shift + "X"
    begin
      New(Point);
      Point.X := User.X;
      Point.Y := User.Y;
      Print('New border point: ' + IntToStr(Point.X) + ' ' + IntToStr(Point.Y));
      Border.Add(Point);
    end;
    // **
    if CTRL and (KeyCode = $44) then // Ctrl + "D"
    begin
      Engine.LoadZone(FileName);
      Print('ZMap reloaded: ' + FileName);
    end;
  end;
  Dispose(Point);
  ZMap.Free;
  Border.Free;
  Obstruction.Free;
end;

begin
  Script.NewThread(@ZMapperProcedure);
  Delay(-1); // Бесконечная пауза

end.