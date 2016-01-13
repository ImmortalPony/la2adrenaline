{*******************************************************
Copyright (c) 2016 Immortal Pony
Tested on Lineage2.com Classic
*******************************************************}
uses NativeXML;

var
  Xml: TNativeXML;

begin
  Xml := TNativeXML.CreateName('zone', nil);
  Xml.LoadFromFile('./Settings/1.zmap');
  print(Xml.Root.WriteToString);
end.