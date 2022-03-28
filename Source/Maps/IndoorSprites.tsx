<?xml version="1.0" encoding="UTF-8"?>
<tileset version="1.8" tiledversion="1.8.2" name="Indoor Sprites" tilewidth="8" tileheight="16" tilecount="128" columns="16">
 <properties>
  <property name="Sprites" type="bool" value="true"/>
 </properties>
 <image source="IndoorSprites.png" trans="909090" width="128" height="129"/>
 <tile id="0">
  <objectgroup draworder="index" id="2">
   <object id="1" x="1" y="0" width="7" height="16"/>
  </objectgroup>
 </tile>
 <tile id="1">
  <objectgroup draworder="index" id="2">
   <object id="1" x="1" y="2" width="6" height="12"/>
  </objectgroup>
 </tile>
 <tile id="2">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="0" width="8" height="16"/>
  </objectgroup>
 </tile>
 <tile id="3">
  <properties>
   <property name="Fire" type="bool" value="true"/>
  </properties>
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="2" width="8" height="12"/>
  </objectgroup>
  <animation>
   <frame tileid="3" duration="667"/>
   <frame tileid="4" duration="667"/>
  </animation>
 </tile>
 <tile id="16">
  <properties>
   <property name="Pushable" type="bool" value="true"/>
  </properties>
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="0" width="8" height="16"/>
  </objectgroup>
 </tile>
 <tile id="18">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="0" width="8" height="9"/>
  </objectgroup>
 </tile>
</tileset>
