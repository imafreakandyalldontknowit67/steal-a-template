"""Author editable XML instances. Rojo converts this to native binary; no Studio claims."""
from pathlib import Path
import xml.etree.ElementTree as E
import json,hashlib
P=Path(__file__).resolve().parents[1]
seq=0
root=E.Element('roblox',{'version':'4'})
E.SubElement(root,'External').text='null';E.SubElement(root,'External').text='nil'
def prop(props,name,v):
 if name=='Image':
  e=E.SubElement(props,'Content',{'name':name});E.SubElement(e,'null' if not v else 'url').text=v or None;return
 if isinstance(v,tuple):
  typ,*vals=v;e=E.SubElement(props,typ,{'name':name})
  if typ=='Color3':
   for k,a in zip(['R','G','B'],vals):E.SubElement(e,k).text=str(a/255)
  elif typ=='UDim2':
   for k,a in zip(['XS','XO','YS','YO'],vals):E.SubElement(e,k).text=str(a)
  elif typ=='Vector2':
   for k,a in zip(['X','Y'],vals):E.SubElement(e,k).text=str(a)
  elif typ=='UDim':E.SubElement(e,'S').text=str(vals[0]);E.SubElement(e,'O').text=str(round(vals[1]))
  else:e.text=str(vals[0])
 elif isinstance(v,bool):E.SubElement(props,'bool',{'name':name}).text=str(v).lower()
 elif isinstance(v,(int,float)):E.SubElement(props,'int' if name in ['ZIndex','DisplayOrder','BorderSizePixel','LayoutOrder','ScrollBarThickness'] else 'float',{'name':name}).text=str(v)
 else:E.SubElement(props,'string',{'name':name}).text=v

def obj(parent,cls,name,**props):
 global seq
 seq+=1;e=E.SubElement(parent,'Item',{'class':cls,'referent':f'RBX{seq}'});pr=E.SubElement(e,'Properties');prop(pr,'Name',name)
 for n,v in props.items():prop(pr,n,v)
 return e

def c(r,g,b):return ('Color3',r,g,b)
def u(x,y):return ('UDim2',0,round(x),0,round(y))
def frame(parent,name,x,y,w,h,color,z=1,cls='Frame',**kw):
 props=dict(Position=u(x,y),Size=u(w,h),BackgroundColor3=color,BorderSizePixel=0,ZIndex=z)
 if cls in ['TextButton','ImageButton']:props.update(AutoButtonColor=False,Active=True,Selectable=True)
 if cls=='TextButton':props['Text']=''
 return obj(parent,cls,name,**props,**kw)
def stroke(parent,color,width=2):return obj(parent,'UIStroke','Outline',Color=color,Thickness=width,ApplyStrokeMode=('token',1))
def corner(parent,r):return obj(parent,'UICorner','Corners',CornerRadius=('UDim',0,r))
def gradient(parent,stops,rotation=90):
 data=' '.join(f'{t} {r/255} {g/255} {b/255} 0' for t,(r,g,b) in stops)+' '
 return obj(parent,'UIGradient','Shading',Color=('ColorSequence',data),Rotation=rotation)
def text(parent,name,x,y,w,h,value,size,color,z=5):
 return frame(parent,name,x,y,w,h,c(255,255,255),z,cls='TextLabel',Text=value,TextSize=size,Font=('token',26),TextColor3=color,BackgroundTransparency=1,TextStrokeColor3=c(60,8,16),TextStrokeTransparency=0.05)
def bag(parent,x,y,w,h):
 holder=frame(parent,'Backpack',x,y,w,h,c(0,0,0),8,BackgroundTransparency=1)
 native=frame(holder,'NativeBackpack',0,0,w,h,c(0,0,0),8,BackgroundTransparency=1,Rotation=-12,Visible=False)
 def shape(name,xx,yy,ww,hh,color,r,z):
  f=frame(native,name,xx*w,yy*h,ww*w,hh*h,color,z);corner(f,r*w);stroke(f,c(22,9,34),max(1,w*.055));return f
 shape('Handle',.28,.08,.35,.28,c(255,0,81),.15,8)
 shape('Side',.12,.30,.58,.61,c(203,0,58),.2,9)
 shape('Body',.25,.24,.65,.67,c(255,0,83),.22,10)
 f=frame(native,'Pocket',.40*w,.67*h,.48*w,.21*h,c(255,24,109),11);corner(f,.10*w)
 for xx in [.46,.69]:
  f=frame(native,'Patch',xx*w,.44*h,.09*w,.20*h,c(175,0,55),12);corner(f,.05*w)
 text(native,'Glint',.29*w,.41*h,.2*w,.3*h,'\u2726',w*.28,c(255,255,255),13)
 img=obj(holder,'ImageLabel','UploadedBackpack',Size=('UDim2',1,0,1,0),BackgroundTransparency=1,Image='rbxassetid://86135425235678',Visible=True,ZIndex=14,ScaleType=('token',3))
 return holder
screen=obj(root,'ScreenGui','SurfaceInventory',ResetOnSpawn=False,IgnoreGuiInset=False,DisplayOrder=30,ZIndexBehavior=('token',1))
surface=obj(screen,'SurfaceGui','InventorySurface',ResetOnSpawn=False,CanvasSize=('Vector2',1000,720),SizingMode=('token',0),Face=('token',5),AlwaysOnTop=False,LightInfluence=0,Brightness=1.4,Active=True,Enabled=True,ClipsDescendants=False,ZIndexBehavior=('token',1))
canvas=frame(surface,'Canvas',0,0,1000,720,c(0,0,0),1,BackgroundTransparency=1)
panel=frame(canvas,'Panel',70,130,860,560,c(255,255,255),2);stroke(panel,c(52,7,17),4)
gradient(panel,[(0,(255,113,111)),(1,(248,108,105))])
def stud_pattern(parent,name,width,height,pitch=22,size=12,z=3,faint=False):
 holder=frame(parent,name,0,0,width,height,c(0,0,0),z,BackgroundTransparency=1,ClipsDescendants=True)
 holder.find('Properties').remove(holder.find('Properties/UDim2[@name="Size"]'));prop(holder.find('Properties'),'Size',('UDim2',1,0,1,0))
 layers=[frame(holder,n,-44,-44,width+88,height+88,c(0,0,0),z,BackgroundTransparency=1) for n in ['Raised','Recessed']]
 for row,yy in enumerate(range(0,height+110,pitch)):
  for col,xx in enumerate(range(0,width+110,pitch)):
   polarity=(row+col)%2
   opacity=.86 if faint else 0
   f=frame(layers[polarity],f'Stud_{col}_{row}',xx,yy,size,size,c(255,255,255),z,BackgroundTransparency=opacity)
   corner(f,2 if size>=10 else 1)
   # The reference has a flat face bounded by a rounded bevel, not a shaded
   # whole square. Upper/right light and lower/left shadow reverse for sockets.
   colors=[(255,181,162),(255,142,130),(110,30,35),(85,20,27)]
   if polarity:colors.reverse()
   gradient(f,[(0,colors[0]),(.25,colors[1]),(.75,colors[2]),(1,colors[3])],135)
   bevel=2 if size>=10 else 1
   face=frame(f,'FlatFace',bevel,bevel,size-bevel*2,size-bevel*2,c(255,255,255),z,BackgroundTransparency=opacity)
   corner(face,1)
   face_colors=[(248,111,106),(234,97,96)] if not polarity else [(210,80,82),(227,93,91)]
   gradient(face,[(0,face_colors[0]),(1,face_colors[1])],90)
 return holder
# Opposite bevel polarity, alternating raised and recessed squares; each native
# layer wraps by TWO cells, so the alternating motif has no animation seam.
studs=stud_pattern(panel,'Studs',860,580)
slots=frame(panel,'Slots',6,4,497,550,c(0,0,0),5,cls='ScrollingFrame',BackgroundTransparency=1,CanvasSize=('UDim2',0,0,0,1078),ScrollBarThickness=4,ScrollBarImageColor3=c(255,255,255),ScrollBarImageTransparency=0,ScrollingEnabled=True,ScrollingDirection=('token',2),ClipsDescendants=True)
for i in range(60):
 row,col=divmod(i,5);f=frame(slots,f'Slot{i+1:02}',16+39+col*90,16+39+row*88,78,78,c(255,255,255),5,cls='TextButton',AnchorPoint=('Vector2',.5,.5));stroke(f,c(65,3,13),3)
 gradient(f,[(0,(159,0,0)),(.25,(241,0,0)),(.43,(255,104,103)),(.53,(240,14,16)),(.8,(210,0,0)),(1,(146,0,0))],45)
 rim=frame(f,'InnerRim',3,3,72,72,c(0,0,0),6,BackgroundTransparency=1);stroke(rim,c(255,132,126),1)
 selected=frame(f,'Selection',-2,-2,82,82,c(0,0,0),9,BackgroundTransparency=1,Visible=False);stroke(selected,c(255,232,202),3)
 obj(f,'UIScale','RevealScale',Scale=1)
detail=frame(panel,'Detail',540,25,292,310,c(255,79,82),5,ClipsDescendants=True);stroke(detail,c(62,5,16),3)
stud_pattern(detail,'Studs',300,320,pitch=22,size=5,z=6,faint=True)
for name,y,w,h in [('ActionPrimary',365,297,82),('ActionSecondary',457,269,65)]:
 f=frame(panel,name,683.5,y+h/2,w,h,c(255,255,255),5,cls='TextButton',AnchorPoint=('Vector2',.5,.5));stroke(f,c(91,7,9),3);gradient(f,[(0,(255,0,0)),(.5,(210,0,0)),(1,(128,0,0))],0)
 frame(f,'Highlight',2,h-3,w-4,2,c(255,129,117),6)
 obj(f,'UIScale','HoverScale',Scale=1)
title=frame(panel,'Title',-38,-108,435,108,c(255,255,255),7);stroke(title,c(40,8,15),3);gradient(title,[(0,(255,100,102)),(.45,(226,57,65)),(1,(160,42,49))])
stud_pattern(title,'Studs',435,108,pitch=22,size=7,z=7,faint=True)
bag(title,12,10,78,84)
text(title,'Label',97,15,325,78,'Inventory',51,c(255,167,158),8)
close=frame(panel,'Close',856,5,74,74,c(255,88,102),8,cls='TextButton',Rotation=15,AnchorPoint=('Vector2',.5,.5));stroke(close,c(39,8,27),3)
obj(close,'UIScale','HoverScale',Scale=1)
for angle in [-45,45]:
 f=frame(close,'Cross',31,11,13,52,c(251,0,79),10,Rotation=angle);corner(f,3);stroke(f,c(48,5,35),3)
launcher=frame(screen,'Launcher',12,0,56,56,c(255,255,255),20,cls='TextButton',AnchorPoint=('Vector2',0,.5))
# Center-left stable HUD anchor, unaffected by panel movement.
for el in launcher.find('Properties'):
 if el.attrib.get('name')=='Position':
  el.find('YS').text='0.5';el.find('YO').text='0'
corner(launcher,7);stroke(launcher,c(24,7,27),3);gradient(launcher,[(0,(255,67,85)),(.65,(255,148,156)),(1,(255,255,255))]);bag(launcher,2,2,52,52)
obj(launcher,'UIScale','HoverScale',Scale=1)
money=text(screen,'Money',0,12,240,50,'MONEY:0',36,c(81,255,1),20)
for el in money.find('Properties'):
 if el.attrib.get('name')=='Position':el.find('XS').text='.5';el.find('XO').text='-120'
obj(screen,'BindableEvent','OpenRequested');obj(screen,'BindableEvent','ItemSelected');obj(screen,'BindableEvent','ActionRequested')
obj(screen,'ModuleScript','Config',Source=('ProtectedString',(P/'src/Config.luau').read_text(encoding='utf-8-sig')))
obj(screen,'LocalScript','Controller',Source=('ProtectedString',(P/'src/Controller.client.luau').read_text(encoding='utf-8-sig')))
E.indent(root)
xml=P/'src/SurfaceInventory.rbxmx';E.ElementTree(root).write(xml,encoding='utf-8',xml_declaration=False)
(P/'src/model.project.json').write_text(json.dumps({'name':'SurfaceInventory','tree':{'$path':'SurfaceInventory.rbxmx'}},indent=2))
print(f'{seq} editable instances authored; XML {xml.stat().st_size} bytes')



