{*******************************************************
Copyright (c) 2016 Immortal Pony
Tested on Lineage2.com Classic
*******************************************************}

unit Pathfinder;

interface

uses SysUtils, Classes;

function MoveTo( X, Y : Integer ) : Boolean;
function GpsMoveTo(x, y, z: integer): boolean;  // GPS движение
procedure RecordPath(p: pointer);

type
TPoint = packed record
	X: Integer;
	Y: Integer;
	Z: Integer;
end;

PPoint = ^TPoint;

TRange = packed record
	X : Integer;
	Y : Integer;
	Z : Integer;
	Range : Cardinal;
	ZRange : Cardinal;
end;

const
Cedric : TRange = ( X : -72018; Y : 258963;	Z : -3141; Range : 5000; ZRange : 5000 );

function UserInRange( Range : TRange ) : Boolean;
function GetMyLocation : string;

implementation

function UserInRange( Range : TRange ) : Boolean;
var
	Loaction : string;
begin
	Result := User.InRange(Range.X, Range.Y, Range.Z, Range.Range, Range.ZRange);
end;

function GetMyLocation : string;
begin
	Result := 'Unknown Location';
	if UserInRange(Cedric) then begin Result := 'Cedric Training Hall'; exit; end;
end;

function GetLastId( SQL : TStringList ) : Integer;
var
	Start, Finish, Last : Integer;
	Str : string;
begin
	Result := -1;
	Start := 0;
	Last := SQL.Count;
	while Last > 0 do
	begin
		Dec(Last);
		if Pos('Point',SQL[Last]) <> 0 then
		begin
			Start := Pos('VALUES (',SQL[Last]);	
			break;
		end;
	end;
	if Start = 0 then exit;
	Start := Start + Length('VALUES (');
	Str := Copy(SQL[Last], Start, Length(SQL[Last]));
	Finish := Pos(',',Str) - 1;
	Str := Copy(SQL[Last], Start, Finish);
	Result := StrToInt(Str);
end;

procedure RecordPath(p: pointer);
var
	SQL : TStringList;
	FileName, PointName : string;
	PointLast, PointNew : PPoint;
	IdLast, IdNew, Radius : Integer; 
	FistRecord : Boolean;
begin
	FileName := './sql.txt';
	SQL := TStringList.Create;
	New(PointLast);
	New(PointNew);
	PointLast.X := 0;
	PointLast.Y := 0;	
	PointLast.Z := 0;	
	Radius := 250;
	IdLast := -1;
	FistRecord := true;
	if FileExists(FileName) then
	begin
		SQL.LoadFromFile(FileName);
		IdLast := GetLastId(SQL);
	end;
	IdNew := IdLast + 1;
	while Engine.Status = lsOnline do
	begin
		PointNew.X := User.ToX;
		PointNew.Y := User.ToY;	
		PointNew.Z := User.ToZ;	
		if (PointNew.X <> PointLast.X) or (PointNew.Y <> PointLast.Y) or (PointNew.Z <> PointLast.Z)  then
		begin
			PointName := GetMyLocation;
			SQL.Add('INSERT INTO Point (id,x,y,z,name,radius) VALUES ('+ IntToStr(IdNew) +','+ IntToStr(PointNew.X) + ',' + IntToStr(PointNew.Y) + ',' + IntToStr(PointNew.Z) + ',''' + PointName + ''',' + IntToStr(Radius) + ');');
			if not FistRecord then
				SQL.Add('INSERT INTO Link (start_point_id,End_point_id, one_way) VALUES ('+ IntToStr(IdLast) +','+ IntToStr(IdNew) +',0);');
			SQL.SaveToFile(FileName);
			PointLast.X := PointNew.X;
			PointLast.Y := PointNew.Y;
			PointLast.Z := PointNew.Z;	
			IdLast := IdNew;	
			Inc(IdNew);
			FistRecord := false;
		end;	
	end;
	Dispose(PointLast);
	Dispose(PointNew);
	Sql.Free;
end;

function MoveTo( X, Y : Integer ) : Boolean;
var
  j: Integer;
  Point: PPoint;
  PathList : TList;
  Path : TList;
begin
  PathList := TList.Create;
  Path := TList.Create;
  if not Engine.FindPath(User.X, User.Y, X, Y, PathList) then
    Print('Path not found.');
  j := 0;
  while j < PathList.Count do           
    begin
      New(Point);                                                          
      Point.X := Integer(PathList[j]);
      Point.Y := Integer(PathList[j+1]);
      Path.Add(Point);
      j := j + 2;
    end;
  for j := 0 to Path.Count - 1 do
    begin                                                                                    
      Point := PPoint(Path[j]);
      Print(IntToStr(Point.X) + ' ' + IntToStr(Point.Y));
      Engine.MoveTo(Point.X, Point.Y, User.Z);
      Dispose(Point);
    end;
  PathList.Free;
  Path.Free;
  end;
  
function GpsMoveTo(x, y, z: integer): boolean;  // GPS движение
var dist: integer;  i: integer;
begin
  dist:= trunc(GPS.GetPath((user.x), (user.y), (user.z), (x), (y), (z)));
  engine.msg('[GpsMoveTo]',format('Mowing to the point %d (x=%d y=%d z=%d), distance: %d m',[i,x,y,z,dist]), 4210752);
  if (GPS.count > 0) then
  begin
    for i:= 0 to GPS.count-1 do
    begin
      if not Engine.MoveTo(trunc(GPS.items(i).x), trunc(GPS.items(i).y), trunc(GPS.items(i).z)) then
      begin
        engine.msg('[GpsMoveTo]',format('Error while moving to № %d : (%d, %d, %d)',[i,trunc(GPS.items(i).x), trunc(GPS.items(i).y), trunc(GPS.items(i).z)]), 222);
        result:= false;
        break;
      end;
    end;
      result:= Engine.MoveTo(x, y, z) or (user.distto(x, y, z) < 150);
  end
  else engine.msg('[GpsMoveTo]','Path not found.', 128);
end; 
  
end.