<?xml version="1.0" encoding="UTF-8"?>
<tileset version="1.8" tiledversion="1.8.2" name="Overworld Tiles" tilewidth="8" tileheight="16" tilecount="128" columns="16">
 <image source="OverworldTiles.png" width="128" height="129"/>
 <tile id="2">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="0" width="8" height="16"/>
  </objectgroup>
 </tile>
 <tile id="4">
  <properties>
   <property name="Water" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="5">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="0" width="8" height="16"/>
  </objectgroup>
 </tile>
 <tile id="6">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="0" width="8" height="16"/>
  </objectgroup>
 </tile>
 <tile id="7">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="0" width="8" height="16"/>
  </objectgroup>
 </tile>
 <tile id="21">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="0" width="8" height="16"/>
  </objectgroup>
 </tile>
 <tile id="22">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="0" width="8" height="16"/>
  </objectgroup>
 </tile>
 <tile id="23">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="0" width="8" height="16"/>
  </objectgroup>
 </tile>
 <tile id="33">
  <properties>
   <property name="Water" type="bool" value="true"/>
  </properties>
  <animation>
   <frame tileid="33" duration="667"/>
   <frame tileid="4" duration="667"/>
  </animation>
 </tile>
 <tile id="37">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="0" width="8" height="16"/>
  </objectgroup>
 </tile>
 <tile id="38">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="0" width="8" height="16"/>
  </objectgroup>
 </tile>
 <tile id="39">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="0" width="8" height="16"/>
  </objectgroup>
 </tile>
 <tile id="51">
  <objectgroup draworder="index" id="2">
   <object id="2" x="0" y="0" width="8" height="16"/>
  </objectgroup>
 </tile>
 <tile id="52">
  <objectgroup draworder="index" id="2">
   <object id="2" x="0" y="0" width="8" height="16"/>
  </objectgroup>
 </tile>
 <tile id="54">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="0" width="8" height="16"/>
  </objectgroup>
 </tile>
 <tile id="55">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="0" width="8" height="16"/>
  </objectgroup>
 </tile>
 <tile id="64">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="0" width="8" height="16"/>
  </objectgroup>
 </tile>
 <tile id="65">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="0" width="8" height="16"/>
  </objectgroup>
 </tile>
 <tile id="66" probability="0.1"/>
 <tile id="80">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="0" width="8" height="16"/>
  </objectgroup>
 </tile>
 <tile id="81">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="0" width="8" height="16"/>
  </objectgroup>
 </tile>
 <tile id="82" probability="0.025"/>
 <tile id="96">
  <objectgroup draworder="index" id="2">
   <object id="1" x="2.10526" y="0" width="5.89474" height="13.2835"/>
  </objectgroup>
 </tile>
 <tile id="97">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="0" width="5.65705" height="13.657"/>
  </objectgroup>
 </tile>
 <wangsets>
  <wangset name="Water and Land" type="corner" tile="-1">
   <wangcolor name="Land" color="#26a269" tile="-1" probability="1"/>
   <wangcolor name="Water" color="#1a5fb4" tile="-1" probability="1"/>
   <wangcolor name="Dirt Road" color="#fcaf3e" tile="-1" probability="1"/>
   <wangcolor name="Roof" color="#ef2929" tile="-1" probability="1"/>
   <wangtile tileid="0" wangid="0,1,0,1,0,1,0,1"/>
   <wangtile tileid="1" wangid="0,1,0,1,0,1,0,1"/>
   <wangtile tileid="5" wangid="0,0,0,4,0,0,0,0"/>
   <wangtile tileid="6" wangid="0,0,0,4,0,4,0,0"/>
   <wangtile tileid="7" wangid="0,0,0,0,0,4,0,0"/>
   <wangtile tileid="8" wangid="0,1,0,3,0,1,0,1"/>
   <wangtile tileid="9" wangid="0,1,0,3,0,3,0,1"/>
   <wangtile tileid="10" wangid="0,1,0,1,0,3,0,1"/>
   <wangtile tileid="16" wangid="0,1,0,2,0,1,0,1"/>
   <wangtile tileid="17" wangid="0,1,0,2,0,2,0,1"/>
   <wangtile tileid="18" wangid="0,1,0,1,0,2,0,1"/>
   <wangtile tileid="19" wangid="0,2,0,1,0,2,0,2"/>
   <wangtile tileid="20" wangid="0,2,0,2,0,1,0,2"/>
   <wangtile tileid="21" wangid="0,4,0,4,0,0,0,0"/>
   <wangtile tileid="22" wangid="0,4,0,4,0,4,0,4"/>
   <wangtile tileid="23" wangid="0,0,0,0,0,4,0,4"/>
   <wangtile tileid="24" wangid="0,3,0,3,0,1,0,1"/>
   <wangtile tileid="26" wangid="0,1,0,1,0,3,0,3"/>
   <wangtile tileid="32" wangid="0,2,0,2,0,1,0,1"/>
   <wangtile tileid="33" wangid="0,2,0,2,0,2,0,2"/>
   <wangtile tileid="34" wangid="0,1,0,1,0,2,0,2"/>
   <wangtile tileid="35" wangid="0,1,0,2,0,2,0,2"/>
   <wangtile tileid="36" wangid="0,2,0,2,0,2,0,1"/>
   <wangtile tileid="37" wangid="0,4,0,0,0,0,0,0"/>
   <wangtile tileid="38" wangid="0,4,0,0,0,0,0,4"/>
   <wangtile tileid="39" wangid="0,0,0,0,0,0,0,4"/>
   <wangtile tileid="40" wangid="0,3,0,1,0,1,0,1"/>
   <wangtile tileid="41" wangid="0,3,0,1,0,1,0,3"/>
   <wangtile tileid="42" wangid="0,1,0,1,0,1,0,3"/>
   <wangtile tileid="48" wangid="0,2,0,1,0,1,0,1"/>
   <wangtile tileid="49" wangid="0,2,0,1,0,1,0,2"/>
   <wangtile tileid="50" wangid="0,1,0,1,0,1,0,2"/>
   <wangtile tileid="51" wangid="0,2,0,1,0,2,0,1"/>
   <wangtile tileid="52" wangid="0,1,0,2,0,1,0,2"/>
   <wangtile tileid="56" wangid="0,3,0,1,0,3,0,3"/>
   <wangtile tileid="57" wangid="0,3,0,3,0,1,0,3"/>
   <wangtile tileid="66" wangid="0,1,0,1,0,1,0,1"/>
   <wangtile tileid="72" wangid="0,1,0,3,0,3,0,3"/>
   <wangtile tileid="73" wangid="0,3,0,3,0,3,0,1"/>
   <wangtile tileid="82" wangid="0,1,0,1,0,1,0,1"/>
  </wangset>
 </wangsets>
</tileset>
