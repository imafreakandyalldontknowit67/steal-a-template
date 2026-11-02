from PIL import Image, ImageDraw
import math
from pathlib import Path
out=Path(__file__).parent
def icon(name,draw):
 im=Image.new('RGBA',(128,128));d=ImageDraw.Draw(im);draw(d);im.save(out/(name+'.png'))
def poly(r): return [(64+math.cos(math.radians(22.5+i*45))*r,64+math.sin(math.radians(22.5+i*45))*r) for i in range(8)]
def robux(d):
 d.polygon(poly(60),fill='black');d.polygon(poly(53),fill='white');d.polygon(poly(39),fill='black');d.polygon(poly(33),fill='white');d.rectangle((52,52,76,76),fill='black')
icon('robux',robux)
def cart(d):
 d.line([(10,17),(27,17),(44,88),(103,88)],fill='black',width=14)
 d.polygon([(30,30),(118,36),(104,76),(40,76)],fill='white',outline='black',width=5)
 d.line([(10,17),(27,17),(44,88),(103,88)],fill='white',width=6)
 for x in [49,97]: d.ellipse((x-10,94,x+10,114),fill='white',outline='black',width=4)
icon('cart',cart)
def book(d):
 d.polygon([(24,10),(113,10),(95,115),(8,115)],fill='#008deb',outline='#062d52',width=6)
 d.polygon([(31,18),(104,18),(89,93),(18,93)],fill='#35c6ff',outline='#0064a6',width=4)
 d.polygon([(39,28),(94,28),(88,59),(33,59)],fill='#9be9ff')
 d.line([(24,80),(86,80)],fill='#a6ecff',width=7)
 d.line([(17,101),(91,101)],fill='#b9efff',width=7)
icon('book',book)
def index(d):
 d.polygon([(27,17),(118,17),(99,107),(8,107)],fill='white',outline='black',width=6)
 for y in [37,53,69]:d.line([(38,y),(95,y)],fill='#1f3647',width=6)
icon('index',index)
def paw(d):
 for box in [(10,35,35,72),(32,13,58,54),(65,13,91,54),(94,35,118,72)]:
  d.ellipse(box,fill='#ffbc66',outline='#5e2600',width=6)
 d.rounded_rectangle((28,53,101,116),radius=28,fill='#ffbc66',outline='#5e2600',width=6)
 d.arc((37,61,92,108),180,355,fill='#fff2b1',width=4)
icon('paw',paw)
def timer(d):
 d.polygon([(27,16),(102,16),(95,41),(70,65),(95,89),(103,112),(25,112),(32,88),(58,65),(33,41)],fill='#75d9ff',outline='#402d24',width=7)
 d.polygon([(41,28),(88,28),(65,54)],fill='#ffcc78')
 d.polygon([(65,77),(40,105),(88,105)],fill='#fff0b1')
 d.ellipse((19,5,109,30),fill='#bd834d',outline='#402d24',width=6)
 d.ellipse((19,102,109,124),fill='#bd834d',outline='#402d24',width=6)
 d.line([(40,40),(54,53)],fill='white',width=6)
icon('hourglass',timer)
im=Image.new('RGBA',(512,512));d=ImageDraw.Draw(im)
for i in range(16):
 a=i*math.tau/16;b=a+.11
 d.polygon([(256,256),(256+400*math.cos(a),256+400*math.sin(a)),(256+400*math.cos(b),256+400*math.sin(b))],fill=(255,255,255,135))
im.save(out/'rays.png')

def arrow(d):
 d.polygon([(7,44),(65,44),(65,12),(121,64),(65,116),(65,84),(7,84)],fill='#ff0010',outline='black',width=7)
icon('arrow',arrow)
