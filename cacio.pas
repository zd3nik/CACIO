program cacio;

uses crt,dos;

var n:word;
    w,pov,max,status,pmax,lift:shortint;
    b:array [1..8,1..8] of shortint;
    mv:array [1..9,1..100,1..8] of shortint;
    mvs:array [1..500,1..7] of shortint;
    k:array [-1..1,1..2] of byte;
    pc:array [-1..1] of integer;
    ct:array [-1..1,1..2] of byte;        {1=Qside 2=Kside}
    s:array [0..9] of integer;
    pv:array [1..7,1..7,1..7] of shortint;
    ks:array [1..2,1..4,1..4] of shortint;
    kl:array [1..7,1..4,1..4] of shortint;
    m:array [1..8] of 1..100;
    ply:0..9;
    xc,yc:byte;
    tpm,stt,ett:real;
    st:string;
    ch:char;
    extkey,force,tu,admvs,snd,auto,past:boolean;
    count:longint;
    ex:array [1..40] of byte;

procedure mwindow;
begin
window(4,6,33,18);clrscr;
end;


procedure setupboard;
var i:byte;
begin
n:=1;w:=1;status:=0;
fillchar(b,sizeof(b),0);
for i:=1 to 8 do begin b[i,2]:=1;b[i,7]:=(-1) end;
b[1,1]:=4;b[2,1]:=2;b[3,1]:=3;b[4,1]:=5;
b[5,1]:=6;b[6,1]:=3;b[7,1]:=2;b[8,1]:=4;
b[1,8]:=(-4);b[2,8]:=(-2);b[3,8]:=(-3);b[4,8]:=(-5);
b[5,8]:=(-6);b[6,8]:=(-3);b[7,8]:=(-2);b[8,8]:=(-4);
fillchar(mv,sizeof(mv),0);
fillchar(mvs,sizeof(mvs),0);
k[1,1]:=5;k[1,2]:=1;
k[-1,1]:=5;k[-1,2]:=8;
pc[1]:=19050;pc[-1]:=19050;
fillchar(ct,sizeof(ct),0);
xc:=5;yc:=4;mwindow;
window(37,5,78,5);clrscr;
end;


procedure writexy(x,y:byte;s:string);
begin
gotoxy(x,y);write(s);
end;


procedure writemove(x1,y1,x2,y2,t:byte;p,tk:shortint);
begin
st:='         ';
if t>0 then
   begin
   case abs(p) of
      1:st:='';
      2:st:='N';
      3:st:='B';
      4:st:='R';
      5:st:='Q';
      6:st:='K';
      end;
   st:=st+chr(x1+96)+chr(y1+48);
   case abs(tk) of
      0:if t=8 then begin y2:=y1;st:=st+'x' end else st:=st+'-';
      1:st:=st+'x';
      2:st:=st+'xN';
      3:st:=st+'xB';
      4:st:=st+'xR';
      5:st:=st+'xQ';
      end;
   st:=st+chr(x2+96)+chr(y2+48);
   case t of
      2:st:=st+'=N';
      3:st:=st+'=B';
      4:st:=st+'=R';
      5:st:=st+'=Q';
      6:st:='0-0';
      7:st:='0-0-0';
      8:st:=st+' ep.';
      end;
   st:=copy(st+'         ',1,9);
   end;
write(st);
end;


procedure updateinfo;
var i:byte;
begin
window(1,1,80,4);textcolor(14);
writexy(10,2,'    ');gotoxy(10,2);
if tpm>0
   then begin write('t',(tpm+0.1):1:0) end
   else write(max+lift);
writexy(10,3,'    ');gotoxy(10,3);write((n+1) div 2);
gotoxy(26,3);i:=n-1;
if i>0
   then writemove(mvs[i,1],mvs[i,2],mvs[i,3],mvs[i,4],mvs[i,5],mvs[i,6],mvs[i,7])
   else write('         ');
if w>0
  then begin writexy(37,2,'>');writexy(37,3,' ') end
  else begin writexy(37,2,' ');writexy(37,3,'>') end;
end;


procedure drawinfo;
begin
textcolor(6);window(1,1,80,4);clrscr;
writeln('+-----------------------------------------------------------------------------+');
writeln('|  Level:     Game Area:          º  White:                        Rate:      |');
writeln('|  Move#:     Last Move:          º  Black:                        Rate:      |');
  write('+-----------------------------------------------------------------------------+');
updateinfo;
end;


procedure hr(c1,c2:byte;x:string);
var t,i:byte;
begin
textcolor(c2);t:=1;
for i:=1 to length(x) do if x[i]='~'
   then begin
   if textattr<>c2 then textcolor(c2) else textcolor(c1);
   if i>1 then if x[i-1]='~' then write(x[i]);
   end
   else if t<>1
      then begin
      if not (x[i] in ['0'..'9'])
         then write(x[i])
         else case x[i] of
            '0':textcolor(t+0);
            '1':textcolor(t+1);
            '2':textcolor(t+2);
            '3':textcolor(t+3);
            '4':textcolor(t+4);
            '5':textcolor(t+5);
            '6':textcolor(t+6);
            '7':textcolor(t+7);
            '8':if t=0 then textcolor(8) else textcolor(textattr+128);
            '9':textcolor(t+9);
            end;
      t:=1;
      end
      else if x[i]='|' then t:=10 else if x[i]='@' then t:=0 else write(x[i]);
end;


procedure drawmenu(s:string);
var i:byte;
begin
window(2,5,35,23);clrscr;
st:='+-------------------------------+';
i:=length(s) div 2;s:='~'+s+'~';
insert(s,st,17-i);delete(st,17-i+length(s),length(s)-2);
hr(4,6,st);writeln;
for i:=1 to 13 do begin
   writeln('|                               |') end;
   writeln('+-------------------------------+');
   writeln('|                               |');
   writeln('|                               |');
   writeln('+-------------------------------+');textcolor(4);
     write('Please Enter Command : [        ]');
window(3,20,33,21);
hr(11,2,' ~?~=List Commands        ~X~=Exit');writeln;
hr(11,2,' Move Syntax: e2e4, 0-0, etc..');
end;


procedure square(x,y:byte);
var a,c:byte;
begin
if (odd(x)) xor (odd(y))
   then begin textbackground(4);textcolor(7) end
   else begin textbackground(2);textcolor(0) end;
if pov<0 then begin x:=9-x;y:=9-y end;
a:=(5*x)-4;c:=(2*(9-y)-1);
  writexy(a,c,'     ');
writexy(a,c+1,'     ');
gotoxy(a+1,c+1);
if pov<0 then begin x:=9-x;y:=9-y end;
if b[x,y]>0
   then begin textbackground(7);textcolor(0) end
   else begin textbackground(0);textcolor(7) end;
case abs(b[x,y]) of
   1:write(' P ');
   2:write(' N ');
   3:write(' B ');
   4:write(' R ');
   5:write(' Q ');
   6:write(' K ');
   end;
textbackground(0);
end;


procedure drawboard;
var x,y:byte;
begin
window(37,6,79,22);
for y:=8 downto 1 do for x:=1 to 8 do square(x,y);
textcolor(4);
if pov>0
   then begin
   writexy(1,17,'  A    B    C    D    E    F    G    H');
   for x:=8 downto 1 do begin gotoxy(42,(2*(9-x)));write(x) end;
   end
   else begin
   writexy(1,17,'  H    G    F    E    D    C    B    A');
   for x:=8 downto 1 do begin gotoxy(42,(2*(9-x)));write(9-x) end;
   end;
end;


function getkey:char;
var c:char;
begin
extkey:=false;c:=readkey;
if c=#0 then
   begin
   extkey:=true;c:=readkey;
   case ord(c) of
      82:c:=#2;83:c:=#3;
      71:c:=#4;79:c:=#5;
      73:c:=#6;81:c:=#7;
      75:c:='4';77:c:='6';
      72:c:='8';80:c:='2';
      30:c:='A';48:c:='B';
      46:c:='C';32:c:='D';
      18:c:='E';33:c:='F';
      34:c:='G';35:c:='H';
      23:c:='I';36:c:='J';
      37:c:='K';38:c:='L';
      50:c:='M';49:c:='N';
      24:c:='O';25:c:='P';
      16:c:='Q';19:c:='R';
      31:c:='S';20:c:='T';
      22:c:='U';47:c:='V';
      17:c:='W';45:c:='X';
      21:c:='Y';44:c:='Z';
      120:c:='!';121:c:='@';
      122:c:='#';123:c:='$';
      124:c:='%';125:c:='^';
      126:c:='&';127:c:='*';
      128:c:='(';
      end;
   end;
if c=#27 then c:=#1;
if c in [#1..#7,#9..#26] then extkey:=true;
getkey:=c;
end;


procedure getcommand;
var c:char;
    x:byte;
begin
st:='';x:=0;
window(26,23,33,23);
textcolor(15);clrscr;
repeat
   begin
   c:=getkey;
   if not (c in [#0,#8,#9,#13]) then
      begin
      inc(x);if x>7 then x:=1;
      if x=1 then case c of
         '-','<':extkey:=true;
         '+','>':extkey:=true;
         '1'..'9','?':extkey:=true;
         end;
      if x=1 then st:=upcase(c) else st:=st+upcase(c);
      if extkey then st:=upcase(c) else write(c);
      end;
   if (c=#8) and (x>0) then
      begin
      dec(x);st:=copy(st,1,x);
      writexy(wherex-1,wherey,' ');
      gotoxy(wherex-1,wherey);
      end;
   end;
until (c=#13) or (extkey);
ch:=upcase(st[1]);
end;


function curtime:real;
var h,m,s,cc:word;
    c:real;
begin
gettime(h,m,s,cc);c:=cc;
curtime:=(360*h)+(60*m)+s+(c/100);
end;


function value(p:shortint):integer;
begin
case abs(p) of
   0:value:=0;
   1:value:=100;
   2:value:=300;
   3:value:=325;
   4:value:=500;
   5:value:=1000;
   6:value:=15000;
   end;
end;


procedure update(x1,y1,x2,y2,t:byte);
var tk:byte;
begin
tk:=abs(b[x2,y2]);
if admvs then
   begin
   mvs[n,1]:=x1;mvs[n,2]:=y1;
   mvs[n,3]:=x2;mvs[n,4]:=y2;
   mvs[n,5]:=t;mvs[n,6]:=b[x1,y1];
   mvs[n,7]:=b[x2,y2];
   end;
if 1 in [y1,y2] then
   begin
   if 1 in [x1,x2] then inc(ct[1,1]);
   if 8 in [x1,x2] then inc(ct[1,2]);
   end;
if 8 in [y1,y2] then
   begin
   if 1 in [x1,x2] then inc(ct[-1,1]);
   if 8 in [x1,x2] then inc(ct[-1,2]);
   end;
b[x2,y2]:=b[x1,y1];b[x1,y1]:=0;
case t of
2..5:begin b[x2,y2]:=w*t;inc(pc[w],value(t)-100) end;
   6:begin b[6,y1]:=b[8,y1];b[8,y1]:=0;inc(ct[w,1]);inc(ct[w,2]) end;
   7:begin b[4,y1]:=b[1,y1];b[1,y1]:=0;inc(ct[w,1]);inc(ct[w,2]) end;
   8:begin b[x2,y1]:=0;dec(pc[-w],100) end;
   end;
if w*b[x2,y2]=6 then
   begin k[w,1]:=x2;k[w,2]:=y2;inc(ct[w,1]);inc(ct[w,2]) end;
if tk>0 then dec(pc[-w],value(tk));
end;


function sqratkd(x,y:byte):boolean;
var f:boolean;
    a,i,t:shortint;
begin
f:=false;
if b[x,y]>0 then a:=1 else a:=(-1);
if b[x,y]=0 then a:=w;
if (x>1) and (y+a in [2..7]) then if b[x-1,y+a]=(-a) then f:=true;
if (x<8) and (y+a in [2..7]) then if b[x+1,y+a]=(-a) then f:=true;
if (x<8) and (y<7) then if a*b[x+1,y+2]=(-2) then f:=true;
if (x<8) and (y>2) then if a*b[x+1,y-2]=(-2) then f:=true;
if (x<7) and (y<8) then if a*b[x+2,y+1]=(-2) then f:=true;
if (x<7) and (y>1) then if a*b[x+2,y-1]=(-2) then f:=true;
if (x>1) and (y<7) then if a*b[x-1,y+2]=(-2) then f:=true;
if (x>1) and (y>2) then if a*b[x-1,y-2]=(-2) then f:=true;
if (x>2) and (y<8) then if a*b[x-2,y+1]=(-2) then f:=true;
if (x>2) and (y>1) then if a*b[x-2,y-1]=(-2) then f:=true;
i:=0;
if (x+1<9) and (y+1<9) then repeat
   inc(i);t:=(-a)*b[x+i,y+i];if t>0 then if t in [3,5] then f:=true;
until (b[x+i,y+i]<>0) or (x+i=8) or (y+i=8);
i:=0;
if (x+1<9) and (y-1>0) then repeat
   inc(i);t:=(-a)*b[x+i,y-i];if t>0 then if t in [3,5] then f:=true;
until (b[x+i,y-i]<>0) or (x+i=8) or (y-i=1);
i:=0;
if (x-1>0) and (y-1>0) then repeat
   inc(i);t:=(-a)*b[x-i,y-i];if t>0 then if t in [3,5] then f:=true;
until (b[x-i,y-i]<>0) or (x-i=1) or (y-i=1);
i:=0;
if (x-1>0) and (y+1<9) then repeat
   inc(i);t:=(-a)*b[x-i,y+i];if t>0 then if t in [3,5] then f:=true;
until (b[x-i,y+i]<>0) or (x-i=1) or (y+i=8);
i:=0;
if x+1<9 then repeat
   inc(i);t:=(-a)*b[x+i,y];if t>0 then if t in [4,5] then f:=true;
until (b[x+i,y]<>0) or (x+i=8);
i:=0;
if x-1>0 then repeat
   inc(i);t:=(-a)*b[x-i,y];if t>0 then if t in [4,5] then f:=true;
until (b[x-i,y]<>0) or (x-i=1);
i:=0;
if y+1<9 then repeat
   inc(i);t:=(-a)*b[x,y+i];if t>0 then if t in [4,5] then f:=true;
until (b[x,y+i]<>0) or (y+i=8);
i:=0;
if y-1>0 then repeat
   inc(i);t:=(-a)*b[x,y-i];if t>0 then if t in [4,5] then f:=true;
until (b[x,y-i]<>0) or (y-i=1);
if x>1 then if a*b[x-1,y]=(-6) then f:=true;
if x<8 then if a*b[x+1,y]=(-6) then f:=true;
if y>1 then if a*b[x,y-1]=(-6) then f:=true;
if y<8 then if a*b[x,y+1]=(-6) then f:=true;
if (x>1) and (y>1) then if a*b[x-1,y-1]=(-6) then f:=true;
if (x>1) and (y<8) then if a*b[x-1,y+1]=(-6) then f:=true;
if (x<8) and (y>1) then if a*b[x+1,y-1]=(-6) then f:=true;
if (x<8) and (y<8) then if a*b[x+1,y+1]=(-6) then f:=true;
sqratkd:=f;
end;


procedure restore(x1,y1,x2,y2,t:byte;tk:shortint);
begin
if 1 in [y1,y2] then
   begin
   if 1 in [x1,x2] then dec(ct[1,1]);
   if 8 in [x1,x2] then dec(ct[1,2]);
   end;
if 8 in [y1,y2] then
   begin
   if 1 in [x1,x2] then dec(ct[-1,1]);
   if 8 in [x1,x2] then dec(ct[-1,2]);
   end;
b[x1,y1]:=b[x2,y2];
b[x2,y2]:=tk;tk:=abs(tk);
case t of
2..5:begin b[x1,y1]:=w;dec(pc[w],value(t)-100) end;
   6:begin b[8,y1]:=b[6,y1];b[6,y1]:=0;dec(ct[w,1]);dec(ct[w,2]) end;
   7:begin b[1,y1]:=b[4,y1];b[4,y1]:=0;dec(ct[w,1]);dec(ct[w,2]) end;
   8:begin b[x2,y1]:=(-w);inc(pc[-w],100) end;
   end;
if w*b[x1,y1]=6 then
   begin k[w,1]:=x1;k[w,2]:=y1;dec(ct[w,1]);dec(ct[w,2]) end;
if tk>0 then inc(pc[-w],value(tk));
end;


function vl(x,y:byte):byte;
var p:byte;
begin
p:=0;
if x>4 then x:=9-x;if y>4 then y:=9-y;
if (x>3) and (y>3) then inc(p,5);
if (x>2) and (y>2) then inc(p,2);
if (x>1) and (y>1) then inc(p);
vl:=p;
end;


procedure addmv(x1,y1,x2,y2,t:byte);
var a,d,i,p:byte;
    tk:shortint;
begin
if w*b[x2,y2]<1 then
   begin
   tk:=b[x2,y2];p:=0;
   update(x1,y1,x2,y2,t);
   if sqratkd(k[w,1],k[w,2])
      then restore(x1,y1,x2,y2,t,tk)
      else begin
      if vl(x2,y2)-vl(x1,y1)>0 then p:=1;
      if sqratkd(k[-w,1],k[-w,2]) then p:=4;
      restore(x1,y1,x2,y2,t,tk);
      if (abs(tk)>p) then p:=abs(tk)+1;
      case t of
      2..5:if t>p then p:=t;
       6,7:if 4>p then p:=4;
         8:if 2>p then p:=2;
         end;
      if odd(ply) then d:=1 else d:=2;
      for a:=1 to 4 do
         begin
         if (x1=ks[d,a,1]) and (y1=ks[d,a,2]) and
            (x2=ks[d,a,3]) and (y2=ks[d,a,4]) then p:=7;
         if (x1=kl[ply,a,1]) and (y1=kl[ply,a,2]) and
            (x2=kl[ply,a,3]) and (y2=kl[ply,a,4]) then p:=8;
         end;
      a:=0;repeat inc(a) until (p>mv[ply,a,8]) or (mv[ply,a,5]=0);
      d:=a;repeat inc(d) until mv[ply,d,5]=0;
      for i:=d downto a+1 do mv[ply,i]:=mv[ply,i-1];
      mv[ply,a,1]:=x1;mv[ply,a,2]:=y1;
      mv[ply,a,3]:=x2;mv[ply,a,4]:=y2;
      mv[ply,a,5]:=t;mv[ply,a,6]:=b[x1,y1];
      mv[ply,a,7]:=tk;mv[ply,a,8]:=p;
      end;
   end;
end;


function advanced(x,y:byte):boolean;
var i:word;
begin
advanced:=false;
if n>1 then
   begin
   i:=n-1;
   if (abs(mvs[i,4]-mvs[i,2])=2) and (mvs[i,3]=x) and (mvs[i,4]=y) then
      advanced:=true;
   end;
end;


procedure pmvs(x,y:byte);
var a,i:byte;
begin
if w>0 then a:=2 else a:=7;
if b[x,y+w]=0 then
   begin
   if (y+w) in [1,8]
      then for i:=2 to 5 do addmv(x,y,x,y+w,i)
      else addmv(x,y,x,y+w,1);
   if (y=a) and (b[x,y+2*w]=0) then addmv(x,y,x,y+2*w,1);
   end;
if x>1 then
   begin
   if w*b[x-1,y+w]<0 then if (y+w) in [1,8]
      then for i:=2 to 5 do addmv(x,y,x-1,y+w,i)
      else addmv(x,y,x-1,y+w,1);
   if (y=a+w*3) and (b[x-1,y+w]=0) and (b[x-1,y]=(-w)) then
      if advanced(x-1,y) then addmv(x,y,x-1,y+w,8);
   end;
if x<8 then
   begin
   if w*b[x+1,y+w]<0 then if (y+w) in [1,8]
      then for i:=2 to 5 do addmv(x,y,x+1,y+w,i)
      else addmv(x,y,x+1,y+w,1);
   if (y=a+w*3) and (b[x+1,y+w]=0) and (b[x+1,y]=(-w)) then
      if advanced(x+1,y) then addmv(x,y,x+1,y+w,8);
   end;
end;


procedure nmvs(x,y:byte);
begin
if (x<8) and (y<7) then addmv(x,y,x+1,y+2,1);
if (x<8) and (y>2) then addmv(x,y,x+1,y-2,1);
if (x<7) and (y<8) then addmv(x,y,x+2,y+1,1);
if (x<7) and (y>1) then addmv(x,y,x+2,y-1,1);
if (x>1) and (y<7) then addmv(x,y,x-1,y+2,1);
if (x>1) and (y>2) then addmv(x,y,x-1,y-2,1);
if (x>2) and (y<8) then addmv(x,y,x-2,y+1,1);
if (x>2) and (y>1) then addmv(x,y,x-2,y-1,1);
end;


procedure bmvs(x,y:byte);
var i,p:byte;
begin
p:=abs(b[x,y]);
if p in [3,5] then
   begin
   i:=1;while (x+i<9) and (y+i<9) do
      begin addmv(x,y,x+i,y+i,1);if b[x+i,y+i]<>0 then i:=8;inc(i) end;
   i:=1;while (x+i<9) and (y-i>0) do
      begin addmv(x,y,x+i,y-i,1);if b[x+i,y-i]<>0 then i:=8;inc(i) end;
   i:=1;while (x-i>0) and (y+i<9) do
      begin addmv(x,y,x-i,y+i,1);if b[x-i,y+i]<>0 then i:=8;inc(i) end;
   i:=1;while (x-i>0) and (y-i>0) do
      begin addmv(x,y,x-i,y-i,1);if b[x-i,y-i]<>0 then i:=8;inc(i) end;
   end;
if p in [4,5] then
   begin
   i:=1;while x+i<9 do
      begin addmv(x,y,x+i,y,1);if b[x+i,y]<>0 then i:=8;inc(i) end;
   i:=1;while x-i>0 do
      begin addmv(x,y,x-i,y,1);if b[x-i,y]<>0 then i:=8;inc(i) end;
   i:=1;while y+i<9 do
      begin addmv(x,y,x,y+i,1);if b[x,y+i]<>0 then i:=8;inc(i) end;
   i:=1;while y-i>0 do
      begin addmv(x,y,x,y-i,1);if b[x,y-i]<>0 then i:=8;inc(i) end;
   end;
end;


procedure kmvs(x,y:byte);
var a,c,i:byte;
begin
if x>1 then addmv(x,y,x-1,y,1);
if x<8 then addmv(x,y,x+1,y,1);
if y>1 then addmv(x,y,x,y-1,1);
if y<8 then addmv(x,y,x,y+1,1);
if (x>1) and (y>1) then addmv(x,y,x-1,y-1,1);
if (x>1) and (y<8) then addmv(x,y,x-1,y+1,1);
if (x<8) and (y>1) then addmv(x,y,x+1,y-1,1);
if (x<8) and (y<8) then addmv(x,y,x+1,y+1,1);
if w>0 then a:=1 else a:=8;
if (x=5) and (y=a) then
   begin
   if (b[2,a]=0) and (b[3,a]=0) and (b[4,a]=0) and (w*b[8,y]=4) and (ct[w,1]=0) then
      begin
      c:=0;for i:=3 to 5 do if sqratkd(i,y) then c:=1;
      if c=0 then addmv(5,y,3,y,7);
      end;
   if (b[6,a]=0) and (b[7,a]=0) and (w*b[8,y]=4) and (ct[w,2]=0) then
      begin
      c:=0;for i:=5 to 7 do if sqratkd(i,y) then c:=1;
      if c=0 then addmv(5,y,7,y,6);
      end;
   end;
end;


procedure getmvsof(x,y:byte);
begin
case w*b[x,y] of
   1:pmvs(x,y);
   2:nmvs(x,y);
3..5:bmvs(x,y);
   6:kmvs(x,y);
   end;
end;


procedure getmvs;
var x,y:byte;
begin
m[ply]:=1;
fillchar(mv[ply],sizeof(mv[ply]),0);
for x:=1 to 8 do for y:=1 to 8 do getmvsof(x,y);
m[ply]:=1;
end;


procedure updatepv;
var i:byte;
begin
pv[ply,ply,1]:=mv[ply,m[ply],1];pv[ply,ply,2]:=mv[ply,m[ply],2];
pv[ply,ply,3]:=mv[ply,m[ply],3];pv[ply,ply,4]:=mv[ply,m[ply],4];
pv[ply,ply,5]:=mv[ply,m[ply],5];pv[ply,ply,6]:=mv[ply,m[ply],6];
pv[ply,ply,7]:=mv[ply,m[ply],7];
for i:=ply+1 to max do pv[ply,i]:=pv[ply+1,i];
end;


procedure addkiller(p:byte);
var i:byte;
begin
for i:=4 downto 2 do begin ks[p,i]:=ks[p,i-1];kl[ply,i]:=kl[ply,i-1] end;
ks[p,1,1]:=mv[ply,m[ply],1];ks[p,1,2]:=mv[ply,m[ply],2];
ks[p,1,3]:=mv[ply,m[ply],3];ks[p,1,4]:=mv[ply,m[ply],4];
kl[ply,1,1]:=mv[ply,m[ply],1];kl[ply,1,2]:=mv[ply,m[ply],2];
kl[ply,1,3]:=mv[ply,m[ply],3];kl[ply,1,4]:=mv[ply,m[ply],4];
end;


function stageofgame:byte;
begin
if (pc[1]<16751) and (pc[-1]<16751)
   then stageofgame:=3
   else begin if n<17 then stageofgame:=1 else stageofgame:=2 end;
end;


procedure adt(p:shortint);
var c,d,i:byte;
begin
if p>0 then c:=1 else c:=0;
p:=abs(p);if p=2 then p:=3;
if past
   then repeat inc(c,2) until ex[c]=0
   else repeat inc(c,2) until (p<ex[c]) or (ex[c]=0);
d:=c;repeat inc(d,2) until ex[d]=0;
i:=d;repeat ex[i]:=ex[i-2];dec(i,2) until i=c;
ex[c]:=p;
end;


function enprise(x,y:byte):integer;
var p:integer;
    a,i:shortint;
    t:boolean;
begin
p:=0;past:=false;
fillchar(ex,sizeof(ex),0);
if b[x,y]>0 then a:=1 else a:=(-1);
ex[1]:=abs(b[x,y]);if ex[1]=2 then ex[1]:=3;
if x>1 then if abs(b[x-1,y])=6 then adt(a*b[x-1,y]);
if x<8 then if abs(b[x+1,y])=6 then adt(a*b[x+1,y]);
if y>1 then if abs(b[x,y-1])=6 then adt(a*b[x,y-1]);
if y<8 then if abs(b[x,y+1])=6 then adt(a*b[x,y+1]);
if (x>1) and (y>1) then if abs(b[x-1,y-1])=6 then adt(a*b[x-1,y-1]);
if (x>1) and (y<8) then if abs(b[x-1,y+1])=6 then adt(a*b[x-1,y+1]);
if (x<8) and (y>1) then if abs(b[x+1,y-1])=6 then adt(a*b[x+1,y-1]);
if (x<8) and (y<8) then if abs(b[x+1,y+1])=6 then adt(a*b[x+1,y+1]);
if (x>1) and (y+a in [2..7]) then if a*b[x-1,y+a]=(-1) then adt(a*b[x-1,y+a]);
if (x<8) and (y+a in [2..7]) then if a*b[x+1,y+a]=(-1) then adt(a*b[x+1,y+a]);
if (x>1) and (y-a in [2..7]) then if a*b[x-1,y-a]=1 then adt(a*b[x-1,y-a]);
if (x<8) and (y-a in [2..7]) then if a*b[x+1,y-a]=1 then adt(a*b[x+1,y-a]);
if (x<8) and (y<7) then if abs(b[x+1,y+2])=2 then adt(a*b[x+1,y+2]);
if (x<8) and (y>2) then if abs(b[x+1,y-2])=2 then adt(a*b[x+1,y-2]);
if (x<7) and (y<8) then if abs(b[x+2,y+1])=2 then adt(a*b[x+2,y+1]);
if (x<7) and (y>1) then if abs(b[x+2,y-1])=2 then adt(a*b[x+2,y-1]);
if (x>1) and (y<7) then if abs(b[x-1,y+2])=2 then adt(a*b[x-1,y+2]);
if (x>1) and (y>2) then if abs(b[x-1,y-2])=2 then adt(a*b[x-1,y-2]);
if (x>2) and (y<8) then if abs(b[x-2,y+1])=2 then adt(a*b[x-2,y+1]);
if (x>2) and (y>1) then if abs(b[x-2,y-1])=2 then adt(a*b[x-2,y-1]);
i:=0;
if (x+1<9) and (y+1<9) then repeat
   inc(i);if abs(b[x+i,y+i]) in [3,5] then begin adt(a*b[x+i,y+i]);past:=true end
until (abs(b[x+i,y+i]) in [1,2,4,6]) or (x+i=8) or (y+i=8);
i:=0;past:=false;
if (x+1<9) and (y-1>0) then repeat
   inc(i);if abs(b[x+i,y-i]) in [3,5] then begin adt(a*b[x+i,y-i]);past:=true end
until (abs(b[x+i,y-i]) in [1,2,4,6]) or (x+i=8) or (y-i=1);
i:=0;
if (x-1>0) and (y-1>0) then repeat
   inc(i);if abs(b[x-i,y-i]) in [3,5] then begin adt(a*b[x-i,y-i]);past:=true end
until (abs(b[x-i,y-i]) in [1,2,4,6]) or (x-i=1) or (y-i=1);
i:=0;
if (x-1>0) and (y+1<9) then repeat
   inc(i);if abs(b[x-i,y+i]) in [3,5] then begin adt(a*b[x-i,y+i]);past:=true end
until (abs(b[x-i,y+i]) in [1,2,4,6]) or (x-i=1) or (y+i=8);
i:=0;
if x+1<9 then repeat
   inc(i);if abs(b[x+i,y]) in [4,5] then begin adt(a*b[x+i,y]);past:=true end
until (abs(b[x+i,y]) in [1..3,6]) or (x+i=8);
i:=0;
if x-1>0 then repeat
   inc(i);if abs(b[x-i,y]) in [4,5] then begin adt(a*b[x-i,y]);past:=true end
until (abs(b[x-i,y]) in [1..3,6]) or (x-i=1);
i:=0;
if y+1<9 then repeat
   inc(i);if abs(b[x,y+i]) in [4,5] then begin adt(a*b[x,y+i]);past:=true end
until (abs(b[x,y+i]) in [1..3,6]) or (y+i=8);
i:=0;
if y-1>0 then repeat
   inc(i);if abs(b[x,y-i]) in [4,5] then begin adt(a*b[x,y-i]);past:=true end
until (abs(b[x,y-i]) in [1..3,6]) or (y-i=1);
i:=1;t:=true;
while (ex[i+1]>0) and (t) do
   begin
   t:=false;
   if ex[i+2]=0
      then t:=true
      else begin
      if ex[i]>=ex[i+1]
         then t:=true
         else begin
         if (ex[i+1]<=ex[i+2]) and (ex[i+3]>0) and (ex[i+4]=0) then t:=true;
         end;
      end;
   if t then
      begin if odd(i) then inc(p,value(ex[i])) else dec(p,value(ex[i])) end;
   inc(i);
   end;
enprise:=p;
end;


function nearking(u:shortint;x,y:byte):integer;
begin
nearking:=14-(abs(k[u,1]-x))-(abs(k[u,2]-y));
end;


function nmob(x,y:byte;u:shortint):byte;
var p:byte;
begin
p:=0;
if (x<8) and (y<7) then if u*b[x+1,y+2]<=0 then inc(p);
if (x<8) and (y>2) then if u*b[x+1,y-2]<=0 then inc(p);
if (x<7) and (y<8) then if u*b[x+2,y+1]<=0 then inc(p);
if (x<7) and (y>1) then if u*b[x+2,y-1]<=0 then inc(p);
if (x>1) and (y<7) then if u*b[x-1,y+2]<=0 then inc(p);
if (x>1) and (y>2) then if u*b[x-1,y-2]<=0 then inc(p);
if (x>2) and (y<8) then if u*b[x-2,y+1]<=0 then inc(p);
if (x>2) and (y>1) then if u*b[x-2,y-1]<=0 then inc(p);
nmob:=p;
end;


function mob(p,x,y:byte;u:shortint):byte;
var i,o:byte;
begin
o:=0;
if p in [3,5] then
   begin
   i:=1;while (x+i<9) and (y+i<9) do
      begin
      case u*b[x+i,y+i] of
         3,5:inc(o);
         -6..-1,1,2,4,6:i:=8;
         end;
      inc(i);
      end;
   i:=1;while (x+i<9) and (y-i>0) do
      begin
      case u*b[x+i,y-i] of
         3,5:inc(o);
         -6..-1,1,2,4,6:i:=8;
         end;
      inc(i);
      end;
   i:=1;while (x-i>0) and (y+i<9) do
      begin
      case u*b[x-i,y+i] of
         3,5:inc(o);
         -6..-1,1,2,4,6:i:=8;
         end;
      inc(i);
      end;
   i:=1;while (x-i>0) and (y-i>0) do
      begin
      case u*b[x-i,y-i] of
         3,5:inc(o);
         -6..-1,1,2,4,6:i:=8;
         end;
      inc(i);
      end;
   end;
if p in [4,5] then
   begin
   i:=1;while x+i<9 do
      begin
      case u*b[x+i,y] of
         4,5:inc(o);
         -6..-1,1,2,3,6:i:=8;
         end;
      inc(i);
      end;
   i:=1;while x-i>0 do
      begin
      case u*b[x-i,y] of
         4,5:inc(o);
         -6..-1,1,2,3,6:i:=8;
         end;
      inc(i);
      end;
   i:=1;while y+i<9 do
      begin
      case u*b[x,y+i] of
         4,5:inc(o);
         -6..-1,1,2,3,6:i:=8;
         end;
      inc(i);
      end;
   i:=1;while y-i>0 do
      begin
      case u*b[x,y-i] of
         4,5:inc(o);
         -6..-1,1,2,3,6:i:=8;
         end;
      inc(i);
      end;
   end;
mob:=o;
end;


function kmob(x,y:byte;u:shortint):byte;
var p:byte;
begin
p:=0;
if x>1 then if u*b[x-1,y]<=0 then inc(p);
if x<8 then if u*b[x+1,y]<=0 then inc(p);
if y>1 then if u*b[x,y-1]<=0 then inc(p);
if y<8 then if u*b[x,y+1]<=0 then inc(p);
if (x>1) and (y>1) then if u*b[x-1,y-1]<=0 then inc(p);
if (x>1) and (y<8) then if u*b[x-1,y+1]<=0 then inc(p);
if (x<8) and (y>1) then if u*b[x+1,y-1]<=0 then inc(p);
if (x<8) and (y<8) then if u*b[x+1,y+1]<=0 then inc(p);
kmob:=p;
end;


function bkwrd(x,y:byte;u:shortint):boolean;
var a,c:byte;
begin
if x>1
   then begin
   c:=y;a:=0;
   if u>0
      then while (a=0) and (c>1) and (c>y-3) do
         begin if b[x-1,c]=1 then a:=1;dec(c) end
      else while (a=0) and (c<8) and (c<y+3) do
         begin if b[x-1,c]=(-1) then a:=1;inc(c) end;
   end
   else a:=1;
if (x<8) and (a=0)
   then begin
   c:=y;
   if u>0
      then while (a=0) and (c>1) and (c>y-3) do
         begin if b[x+1,c]=1 then a:=1;dec(c) end
      else while (a=0) and (c<8) and (c<y+3) do
         begin if b[x+1,c]=(-1) then a:=1;inc(c) end;
   end
   else a:=1;
if a=0 then bkwrd:=true else bkwrd:=false;
end;


function passed(x,y:byte;u:shortint):boolean;
var c:byte;
    p:boolean;
begin
c:=y;if u>0
   then repeat inc(c) until (c=8) or (abs(b[x,c])=1)
   else repeat dec(c) until (c=1) or (abs(b[x,c])=1);
if c in [1,8]
   then begin
   p:=true;
   if x>1 then
      begin
      c:=y;if u>0
         then repeat inc(c) until (c=8) or (b[x-1,c]=(-1))
         else repeat dec(c) until (c=1) or (b[x-1,c]=1);
      if c in [2..7] then p:=false;
      end;
   if (p) and (x<8) then
      begin
      c:=y;if u>0
         then repeat inc(c) until (c=8) or (b[x+1,c]=(-1))
         else repeat dec(c) until (c=1) or (b[x+1,c]=1);
      if c in [2..7] then p:=false;
      end;
   end
   else p:=false;
passed:=p;
end;


function kingpawns(x,y:byte;u:shortint):integer;
var c,l,r,i,p1,p2:byte;
    t:integer;
begin
t:=0;
if x>4 then begin l:=6;r:=8 end else begin l:=1;r:=3 end;
for i:=l to r do
   begin
   p1:=0;p2:=0;
   for c:=1 to 8 do
      begin
      case u*b[i,c] of
         1:p1:=1;
        -1:p2:=1;
     -4,-5:inc(t,10);
         end;
      end;
   if p1=0 then inc(t,10);
   if p2=0 then inc(t,10);
   end;
kingpawns:=t;
end;


procedure error(t:string);
begin
window(2,24,69,24);hr(4,4,t);
if snd then begin sound(50);delay(1700);nosound end else delay(1700);
writeln;
end;


function score:integer;
var t,sc:integer;
    p,x,y:byte;
    stage,a,c,u:shortint;
begin
inc(count);
sc:=pc[w]-pc[-w];
stage:=stageofgame;
if (pc[0]>pc[-w]) and (sc>0) then inc(sc,25);
if stage<3 then for a:=1 to ply do
   begin
   if mv[a,m[a],5] in [6,7] then
      begin if odd(a) then inc(sc,25+(20-a)) else dec(sc,35) end;
   case abs(mv[a,m[a],6]) of
      5:begin if odd(a) then dec(sc,10) else inc(sc,10) end;
      6:begin if odd(a) then dec(sc,15) else inc(sc,15) end;
      end;
   end;
for x:=1 to 8 do for y:=1 to 8 do if b[x,y]<>0 then
   begin
   p:=abs(b[x,y]);t:=0;
   if b[x,y]>0 then u:=1 else u:=(-1);
   if u>0 then a:=1 else a:=8;
   if (p<>6) and (w*u>0) then dec(t,enprise(x,y));
   if t=0 then
      begin
      if (stage<3) and (p>1) and (x in [4,5]) and (y in [3..6]) then
         begin
         if u*b[x,y-u]=1 then dec(t,25);
         if u*b[x,y-2*u]=1 then dec(t,10);
         end;
      case p of
         1:begin
            if stage<3
               then inc(t,vl(x,y)*3)
               else begin
               if u>0 then inc(t,2*y) else inc(t,2*(9-y));
               dec(t,2*nearking(-u,x,y));
               end;
            if y in [3..6] then
               begin if (u*b[x,y-u]=1) or (u*b[x,y-2*u]=1) then dec(t,40) end;
            if bkwrd(x,y,u) then
               begin
               c:=y;if u>0
                  then repeat inc(c) until (c=8) or (b[x,c]=(-1))
                  else repeat dec(c) until (c=1) or (b[x,c]=1);
               if c in [1,8] then dec(t,15);
               end;
            if stage>1 then if passed(x,y,u) then
               begin
               if u>0
                  then inc(t,(20-nearking(-u,x,y))*y)
                  else inc(t,(20-nearking(-u,x,y))*(9-y));
               c:=y;if u>0
                  then repeat dec(c) until (c=1) or (b[x,c]<>0)
                  else repeat inc(c) until (c=8) or (b[x,c]<>0);
               if u*b[x,c]=4 then inc(t,10);
               if u*b[x,c]=(-4) then dec(t,10);
               c:=y;if u>0
                  then repeat
                     inc(c);if b[x,c]<>0 then dec(t,2*abs(b[x,c]))
                  until c=8
                  else repeat
                     dec(c);if b[x,c]<>0 then dec(t,2*abs(b[x,c]))
                  until c=1;
               end;
            end;
         2:begin
            inc(t,nmob(x,y,u));
            if (stage<3) and (vl(x,y)=0) then dec(t,10);
            end;
         3:begin
            inc(t,mob(p,x,y,u));
            if (stage<3) and (vl(x,y)=0) then dec(t,10);
            end;
         4:begin
            inc(t,mob(p,x,y,u));
            if (stage>1) and (y=a+6*u) then inc(t,7);
            c:=y;if u>0
               then begin
               if c<7 then repeat
                  inc(c);if c=8 then inc(t,10);
               until (c=8) or (abs(b[x,c])=1);
               end
               else begin
               if c>2 then repeat
                  dec(c);if c=1 then inc(t,10);
               until (c=1) or (abs(b[x,c])=1);
               end;
            if u*b[x,c]=(-1) then inc(t,7);
            end;
         5:begin
            if stage=1 then dec(t,4*vl(x,y)) else inc(t,mob(p,x,y,u));
            if (stage=2) and (y=a) then dec(t,5);
            end;
         6:begin
            case stage of
               1:dec(t,5*vl(x,y)+kingpawns(x,y,u));
               2:dec(t,5*vl(x,y)+kingpawns(x,y,u)-kmob(x,y,u));
               3:inc(t,2*kmob(x,y,u)+vl(x,y));
               end;
            end;
         end;
      end;
   inc(sc,w*u*t);
   end;
if stage=3 then
   begin
   x:=k[-w,1];y:=k[-w,2];
   if x>4 then x:=9-x;if y>4 then y:=9-y;
   dec(sc,4*kmob(k[-w,1],k[-w,2],-w)+5*x+5*y);
   inc(sc,5*nearking(-w,k[w,1],k[w,2]));
   end;
if sqratkd(k[-w,1],k[-w,2]) then
   begin
   w:=(-w);inc(n);
   inc(ply);admvs:=false;getmvs;admvs:=true;
   if mv[ply,1,5]=0 then
      begin if odd(ply) then sc:=(-32000) else sc:=32000 end;
   w:=(-w);dec(n);dec(ply);
   end;
score:=sc;
end;


procedure search;
var sc:integer;
    stop:byte;
    c:shortint;
    chk:boolean;
begin
inc(ply);stop:=0;getmvs;
if (lift=1) and (ply=max) and (mv[ply,5,5]=0) then chk:=true else chk:=false;
if odd(ply) then s[ply]:=(-32000) else s[ply]:=32000;
while (mv[ply,m[ply],5]>0) and (stop=0) and (not force) do
   begin
   update(mv[ply,m[ply],1],mv[ply,m[ply],2],mv[ply,m[ply],3],mv[ply,m[ply],4],mv[ply,m[ply],5]);
   if (ply<pmax) and ((ply<max) or (chk) or (ply=max+1))
      then begin inc(n);w:=(-w);search;sc:=s[ply+1];dec(n);w:=(-w) end
      else sc:=score;
   if odd(ply)
      then begin
      if sc>s[ply] then begin s[ply]:=sc;updatepv end;
      c:=ply-1;repeat
         if sc>=s[c] then stop:=1;dec(c,2)
      until (stop=1) or (c<1);
      if stop=1 then addkiller(1);
      end
      else begin
      if sc<s[ply] then begin s[ply]:=sc;updatepv end;
      c:=ply-1;repeat
         if sc<=s[c] then stop:=1;dec(c,2)
      until (stop=1) or (c<2);
      if stop=1 then addkiller(2);
      end;
   restore(mv[ply,m[ply],1],mv[ply,m[ply],2],mv[ply,m[ply],3],mv[ply,m[ply],4],mv[ply,m[ply],5],mv[ply,m[ply],7]);
   if keypressed then
      begin if ply>1 then s[ply]:=(-32000);force:=true;ch:=getkey;ch:=' ' end;
   if tpm>0 then
      begin
      if curtime>=ett then
         begin if ply>1 then s[ply]:=(-32000);force:=true;tu:=true end;
      end;
   if (ply=1) and (max=pmax) then write('.');inc(m[ply]);
   end;
if mv[ply,1,5]=0 then
   begin
   if sqratkd(k[w,1],k[w,2])
      then begin if odd(ply) then s[ply]:=(-32000) else s[ply]:=32000 end
      else s[ply]:=0;
   end;
dec(ply);
end;


function shortmaterial:boolean;
var f:boolean;
    x,y:byte;
    wt,bk:array [1..6] of byte;
begin
f:=true;
fillchar(wt,sizeof(wt),0);
fillchar(bk,sizeof(bk),0);
for x:=1 to 8 do for y:=1 to 8 do
   begin
   if b[x,y]>0 then inc(wt[abs(b[x,y])]);
   if b[x,y]<0 then inc(bk[abs(b[x,y])]);
   end;
if (wt[1]>0) or (wt[4]>0) or (wt[5]>0) then f:=false;
if (bk[1]>0) or (bk[4]>0) or (bk[5]>0) then f:=false;
if f then
   begin
   if (wt[2]>0) and (wt[3]>0) then f:=false;
   if (bk[2]>0) and (bk[3]>0) then f:=false;
   if (wt[2]>2) or (wt[3]>1) then f:=false;
   if (bk[2]>2) or (bk[3]>1) then f:=false;
   end;
shortmaterial:=f;
end;


function threereps:boolean;
var a:word;
    c:boolean;
begin
threereps:=false;
if n>8 then
   begin
   c:=true;a:=n-8;
   repeat
      c:=((mvs[a,1]=mvs[a+2,3]) and (mvs[a,2]=mvs[a+2,4]) and
          (mvs[a,3]=mvs[a+2,1]) and (mvs[a,4]=mvs[a+2,2]));
      inc(a);
   until (a=n-1) or (not c);
   threereps:=c;
   end;
end;


function nopm_or_takes:boolean;
var flag:boolean;
    c:word;
begin
flag:=false;c:=n+1;
repeat
   dec(c);
   if (abs(mvs[c,6])=1) or (mvs[c,7]<>0) then flag:=true;
until (c=n-99) or (flag);
nopm_or_takes:=(not flag);
end;


function draw:boolean;
begin
draw:=false;
if shortmaterial
   then draw:=true
   else begin
   if threereps
      then draw:=true
      else begin
      if n>99 then if nopm_or_takes then draw:=true;
      end;
   end;
end;


procedure chkresult;
begin
status:=0;
if sqratkd(k[w,1],k[w,2]) then inc(status);
ply:=1;admvs:=false;getmvs;admvs:=true;
if mv[1,1,5]=0 then inc(status,2);
if status<2 then begin dec(n);if draw then status:=4;inc(n) end;
window(37,5,78,5);clrscr;
case status of
   1:begin
      hr(4,4,'Check!');if snd then begin sound(1400);delay(50);nosound end;
      end;
   2:begin
      hr(7,14,'Stalemate!');
      if snd then
         begin
         sound(587);delay(300);nosound;delay(50);
         sound(494);delay(200);nosound;delay(80);
         sound(587);delay(100);nosound;delay(30);
         sound(523);delay(300);nosound;delay(80);
         sound(440);delay(600);nosound;
         end;
     end;
   3:begin
      hr(7,12,'Checkmate!');
      if snd then
         begin
         sound(310);delay(100);nosound;delay(80);
         sound(310);delay(100);nosound;delay(80);
         sound(310);delay(100);nosound;delay(80);
         sound(262);delay(1000);nosound
         end;
     end;
   4:begin
      hr(7,14,'Draw...');if snd then begin sound(80);delay(1200);nosound end;
      end;
   end;
end;


procedure compute;
var i:byte;
begin
stt:=curtime;
ett:=stt+tpm;
window(2,24,69,24);clrscr;
textcolor(4);write('Thinking.');
fillchar(s,sizeof(s),0);
fillchar(pv,sizeof(pv),0);
fillchar(ks,sizeof(ks),0);
fillchar(kl,sizeof(kl),0);
force:=false;tu:=false;
s[0]:=32000;pc[0]:=pc[-w];
ply:=1;getmvs;ply:=0;count:=0;
pmax:=max;max:=1;
if mv[1,2,5]>0 then repeat
   for i:=4 downto 1 do
      begin
      ks[1,i,1]:=pv[1,1,1];ks[1,i,2]:=pv[1,1,2];
      ks[1,i,3]:=pv[1,1,3];ks[1,i,4]:=pv[1,1,4];
      ks[2,i,1]:=pv[1,2,1];ks[2,i,2]:=pv[1,2,2];
      ks[2,i,3]:=pv[1,2,3];ks[2,i,4]:=pv[1,2,4];
      end;
   while (pv[1,i,5]>0) and (i<5) do
      begin
      kl[i,1,1]:=pv[1,i,1];kl[i,1,2]:=pv[1,i,2];
      kl[i,1,3]:=pv[1,i,3];kl[i,1,4]:=pv[1,i,4];
      kl[i,2,1]:=pv[1,i,1];kl[i,2,2]:=pv[1,i,2];
      kl[i,2,3]:=pv[1,i,3];kl[i,2,4]:=pv[1,i,4];
      kl[i,3,1]:=pv[1,i,1];kl[i,3,2]:=pv[1,i,2];
      kl[i,3,3]:=pv[1,i,3];kl[i,3,4]:=pv[1,i,4];
      kl[i,4,1]:=pv[1,i,1];kl[i,4,2]:=pv[1,i,2];
      kl[i,4,3]:=pv[1,i,3];kl[i,4,4]:=pv[1,i,4];
      inc(i);
      end;
   search;write('.');
   if (force) or (s[1]>30000) then max:=pmax;
   inc(max,2);
until max>pmax;max:=pmax;
clrscr;mwindow;writeln;
hr(14,6,'Time Used: ~');writeln(curtime-stt:1:2);
hr(14,6,'Count: ~');writeln(count);
hr(14,6,'Score: ~');writeln(s[1]);
if pv[1,1,5]>0
   then begin
   update(pv[1,1,1],pv[1,1,2],pv[1,1,3],pv[1,1,4],pv[1,1,5]);
   inc(n);w:=(-w);drawboard;updateinfo;chkresult;
   end
   else begin
   update(mv[1,1,1],mv[1,1,2],mv[1,1,3],mv[1,1,4],mv[1,1,5]);
   inc(n);w:=(-w);drawboard;updateinfo;chkresult;
   end;
if (status=0) and (snd) then begin sound(1000);delay(50);nosound end;
if tu then force:=false;
end;


function prochoice:byte;
var c:char;
begin
window(2,24,69,24);
hr(14,3,'Promote to K~n~ight, ~B~ishop, ~R~ook, or ~Q~ueen?');
repeat c:=upcase(getkey) until c in ['N','B','R','Q'];
writeln;
case c of
   'N':prochoice:=2;
   'B':prochoice:=3;
   'R':prochoice:=4;
   'Q':prochoice:=5;
   end;
end;


procedure movepiece(x1,y1,x2,y2:byte);
var i,t:byte;
begin
ply:=1;t:=0;i:=0;
fillchar(mv,sizeof(mv),0);
getmvsof(x1,y1);
repeat
   inc(i);if (mv[1,i,3]=x2) and (mv[1,i,4]=y2) then t:=i;
until (t>0) or (mv[1,i,5]=0);
if t>0
   then begin
   if mv[1,t,5] in [2..5] then mv[1,t,5]:=prochoice;
   update(x1,y1,x2,y2,mv[1,t,5]);
   inc(n);w:=(-w);drawboard;updateinfo;chkresult;
   if (auto) and (status<2) then compute;
   end
   else error('Invalid Move!');
end;


procedure arrowsq;
var a,c:byte;
begin
window(37,6,79,22);
textbackground(1);textcolor(1);
if pov<0 then begin xc:=9-xc;yc:=9-yc end;
a:=(5*xc)-4;c:=(2*(9-yc)-1);
  writexy(a,c,'     ');
writexy(a,c+1,'     ');
gotoxy(a+1,c+1);
if pov<0 then begin xc:=9-xc;yc:=9-yc end;
if b[xc,yc]>0
   then begin textbackground(7);textcolor(0) end
   else begin textbackground(0);textcolor(7) end;
case abs(b[xc,yc]) of
   1:write(' P ');
   2:write(' N ');
   3:write(' B ');
   4:write(' R ');
   5:write(' Q ');
   6:write(' K ');
   end;
textbackground(0);textcolor(7);
end;


procedure arrow;
begin
case ch of
   '1':begin dec(xc,pov);dec(yc,pov) end;
   '4':dec(xc,pov);
   '7':begin dec(xc,pov);inc(yc,pov) end;
   '2':dec(yc,pov);
   '8':inc(yc,pov);
   '3':begin inc(xc,pov);dec(yc,pov) end;
   '6':inc(xc,pov);
   '9':begin inc(xc,pov);inc(yc,pov) end;
   end;
if xc=9 then xc:=1;if xc=0 then xc:=8;
if yc=9 then yc:=1;if yc=0 then yc:=8;
arrowsq;ch:=getkey;
if ch='5' then ch:=#13;
square(xc,yc);
end;


procedure arrowmv;
var x1,y1,x2,y2:byte;
begin
st:='';
repeat
   arrow;
   if ch=#08 then st:='';
   if ch=#13 then st:=st+chr(xc+64)+chr(yc+48);
   window(26,23,33,23);textcolor(15);clrscr;write(st);
until (length(st)>3) or (ch=#1);
if (length(st)>3) and (status<2) then
   begin
   x1:=(ord(st[1]))-64;y1:=(ord(st[2]))-48;
   x2:=(ord(st[3]))-64;y2:=(ord(st[4]))-48;
   movepiece(x1,y1,x2,y2);ch:=' ';st:='';
   end;
end;


procedure makemove;
var t:string;
    a,i,x1,y1,x2,y2:byte;
begin
if (st='0-0') or (st='o-o') or (st='O-O') then
   begin if w>0 then st:='e1g1' else st:='e8g8' end;
if (st='0-0-0') or (st='o-o-o') or (st='O-O-O') then
   begin if w>0 then st:='e1c1' else st:='e8c8' end;
t:='';a:=1;
for i:=1 to length(st) do
   begin
   if upcase(st[i]) in ['A'..'Z','0'..'9'] then
      begin t[a]:=upcase(st[i]);inc(a) end;
   end;
x1:=(ord(t[1]))-64;y1:=(ord(t[2]))-48;
x2:=(ord(t[3]))-64;y2:=(ord(t[4]))-48;
if (x1>0) and (x1<9) and (y1>0) and (y1<9) and
   (x2>0) and (x2<9) and (y2>0) and (y2<9)
      then movepiece(x1,y1,x2,y2)
      else error('Invalid Coordinates!');
ch:=' ';
end;


function choice(s:string;x,y:char):char;
var c:char;
begin
window(2,24,69,24);
hr(14,3,s+' ~'+x+'~/'+y);
repeat c:=upcase(getkey) until c in [#13,x,y];
if c=#13 then c:=x;choice:=c;
writeln;
end;


procedure buildpos;
var c:shortint;
begin
ch:=' ';status:=0;c:=1;
if choice('Clear Board?','Y','N')='Y' then
   begin
   n:=1;w:=1;
   fillchar(b,sizeof(b),0);
   fillchar(ct,sizeof(ct),0);
   fillchar(mvs,sizeof(mvs),0);
   b[5,1]:=6;b[5,8]:=(-6);
   k[1,1]:=5;k[1,2]:=1;
   k[-1,1]:=5;k[-1,2]:=8;
   pc[1]:=15000;pc[-1]:=15000;
   end;
window(37,5,78,5);clrscr;
updateinfo;drawboard;
mwindow;writeln;
hr(11,2,'~C~olor = ~');
if c=1 then writeln('White') else writeln('Black');
hr(11,2,'~W~ho''s Move = ~');
if w=1 then writeln('White') else writeln('Black');
writeln;
hr(11,2,'Place ~P~awn');writeln;
hr(11,2,'Place K~n~ight');writeln;
hr(11,2,'Place ~B~ishop');writeln;
hr(11,2,'Place ~R~ook');writeln;
hr(11,2,'Place ~Q~ueen');writeln;
hr(11,2,'Place ~K~ing');writeln;
writeln;
hr(11,2,'~D~elete Piece   ~I~nvert Board');writeln;
hr(11,2,'~F~inished');
repeat
   arrow;
   case upcase(ch) of
      'C':begin
         c:=(-c);window(4,6,33,18);
         gotoxy(9,2);if c=1 then hr(11,11,'White') else hr(11,11,'Black');
         end;
      'I':begin pov:=(-pov);drawboard end;
      'W':if sqratkd(k[w,1],k[w,2])
         then error('King Under Attack!  Caonnot Switch Sides')
         else begin
         w:=(-w);window(4,6,33,18);
         gotoxy(14,3);if w=1 then hr(11,11,'White') else hr(11,11,'Black');
         end;
      'D',#3:if abs(b[xc,yc])<6 then
         begin
         b[xc,yc]:=0;
         if b[xc,yc]>0
            then dec(pc[1],value(abs(b[xc,yc])))
            else dec(pc[-1],value(abs(b[xc,yc])));
         end;
      'P':if (yc in [2..7]) and (b[xc,yc]=0) then
         begin
         b[xc,yc]:=c;
         if sqratkd(k[-w,1],k[-w,2]) then b[xc,yc]:=0 else inc(pc[c],100)
         end;
      'N':if b[xc,yc]=0 then
         begin
         b[xc,yc]:=c*2;
         if sqratkd(k[-w,1],k[-w,2]) then b[xc,yc]:=0 else inc(pc[c],300)
         end;
      'B':if b[xc,yc]=0 then
         begin
         b[xc,yc]:=c*3;
         if sqratkd(k[-w,1],k[-w,2]) then b[xc,yc]:=0 else inc(pc[c],315)
         end;
      'R':if b[xc,yc]=0 then
         begin
         b[xc,yc]:=c*4;
         if sqratkd(k[-w,1],k[-w,2]) then b[xc,yc]:=0 else inc(pc[c],500)
         end;
      'Q':if b[xc,yc]=0 then
         begin
         b[xc,yc]:=c*5;
         if sqratkd(k[-w,1],k[-w,2]) then b[xc,yc]:=0 else inc(pc[c],1000)
         end;
      'K':if b[xc,yc]=0 then
         begin
         b[xc,yc]:=c*6;
         b[k[c,1],k[c,2]]:=0;
         if sqratkd(k[-w,1],k[-w,2])
            then begin b[xc,yc]:=0;b[k[c,1],k[c,2]]:=c*6 end
            else begin square(k[c,1],k[c,2]);k[c,1]:=xc;k[c,2]:=yc end;
         end;
      end;
   updateinfo;
until upcase(ch)='F';
mwindow;chkresult;
end;


procedure newlevel;
begin
window(2,24,69,24);
hr(15,3,'Enter New Level: ~');
readln(max);
if max<1 then max:=1;
if max>8 then max:=8;
case max of
   1:begin max:=1;lift:=0 end;
   2:begin max:=1;lift:=1 end;
   3:begin max:=3;lift:=0 end;
   4:begin max:=3;lift:=1 end;
   5:begin max:=5;lift:=0 end;
   6:begin max:=5;lift:=1 end;
   7:begin max:=7;lift:=0 end;
   8:begin max:=7;lift:=1 end;
   end;
end;


procedure newtime;
var i,code:integer;
begin
window(2,24,69,24);
hr(15,3,'Enter Time per Move [5-600 seconds]: ~');
readln(st);val(st,i,code);
if (code=0) and (i>0) and (i<601) then
   begin
   if i>200 then max:=7;
   if i<=200 then max:=5;
   if i<=20 then max:=3;
   tpm:=i-0.1;lift:=1;
   end;
updateinfo;
end;


begin
textbackground(0);
window(1,1,80,25);
clrscr;
pov:=1;
max:=3;
tpm:=0;
lift:=0;
snd:=true;
admvs:=true;
auto:=true;
setupboard;
drawinfo;
drawmenu(' Chess Access ');
drawboard;
repeat
   getcommand;mwindow;
   if (length(st)>2) and (status<2) then begin makemove;ch:=' ';st:='' end;
   case ch of
      '1'..'9':arrowmv;
      'A':auto:=(not auto);
      'B':buildpos;
      'C':if status<2 then compute;
      'I':begin pov:=(-pov);drawboard end;
      'L':begin newlevel;updateinfo end;
      'N':begin setupboard;drawboard;updateinfo end;
      'P':if status<2 then repeat compute until (status>1) or (force);
      'S':snd:=(not snd);
      'T':newtime;
      '>':if (mvs[n,5]>0) and (status<2) then
            begin
            update(mvs[n,1],mvs[n,2],mvs[n,3],mvs[n,4],mvs[n,5]);
            inc(n);w:=(-w);drawboard;updateinfo;chkresult;
            end;
      '<':if n>1 then
            begin
            dec(n);w:=(-w);
            restore(mvs[n,1],mvs[n,2],mvs[n,3],mvs[n,4],mvs[n,5],mvs[n,7]);
            drawboard;updateinfo;chkresult;
            end;
      'Z':repeat
            arrow;
            if ch=#13 then
               begin
               str(nearking(-1,xc,yc),st);
               error(st);
               end;
          until ch=#1;
      '!':begin max:=1;tpm:=0;lift:=0;updateinfo end;
      '@':begin max:=1;tpm:=0;lift:=1;updateinfo end;
      '#':begin max:=3;tpm:=0;lift:=0;updateinfo end;
      '$':begin max:=3;tpm:=0;lift:=1;updateinfo end;
      '%':begin max:=5;tpm:=0;lift:=0;updateinfo end;
      '^':begin max:=5;tpm:=0;lift:=1;updateinfo end;
      '&':begin max:=5;tpm:=9.9;lift:=1;updateinfo end;
      '*':begin max:=5;tpm:=29.9;lift:=1;updateinfo end;
      '(':begin max:=5;tpm:=59.9;lift:=1;updateinfo end;
      'X':if choice('Exit?','Y','N')='N' then ch:=' ';
      end;
until ch='X';
end.
