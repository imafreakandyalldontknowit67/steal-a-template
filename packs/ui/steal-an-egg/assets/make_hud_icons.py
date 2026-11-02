from PIL import Image, ImageDraw
from pathlib import Path
import math
out=Path(__file__).parent
def save(name, painter):
    im=Image.new('RGBA',(384,384)); d=ImageDraw.Draw(im); painter(d)
    im.resize((128,128),Image.Resampling.LANCZOS).save(out/(name+'.png'))
def egg(d):
    pts=[]
    for i in range(361):
        a=i*math.pi/180
        pts.append((192+125*math.sin(a)*(1-.19*math.cos(a)),192-162*math.cos(a)))
    d.polygon(pts,fill='#ffdc9a');d.line(pts+[pts[0]],fill='#171415',width=21,joint='curve')
    d.arc((77,53,289,327),185,275,fill='#fff5d7',width=16)
    d.arc((80,49,305,335),10,100,fill='#e6aa61',width=10)
def paw(d):
    shapes=[(38,103,113,216),(105,45,180,168),(199,45,274,168),(271,103,346,216)]
    for box in shapes:d.ellipse(box,fill='#f9a34c',outline='#fff0c5',width=20);d.ellipse(tuple(v+(-8 if i>1 else 8) for i,v in enumerate(box)),outline='#6d300d',width=7)
    pts=[(80,288),(91,239),(127,210),(149,179),(192,167),(235,179),(257,210),(293,239),(304,288),(282,322),(244,325),(192,310),(140,325),(102,322)]
    d.polygon(pts,fill='#ffb659');d.line(pts+[pts[0]],fill='#fff0c5',width=25,joint='curve');d.line(pts+[pts[0]],fill='#71350e',width=9,joint='curve')
def index(d):
    p=[(80,66),(350,66),(299,319),(29,319)]
    d.polygon(p,fill='#fffdf5');d.line(p+[p[0]],fill='#183540',width=20,joint='curve')
    for y in [116,165,214]: d.line([(111,y),(285,y)],fill='#55636a',width=15)
    d.line([(92,267),(256,267)],fill='#a5c0c5',width=10)
def gear(d):
    p=[]
    for i in range(64):
        a=i*math.tau/64;r=145 if i%8 in [1,2,3,4] else 112
        p.append((192+r*math.cos(a),192+r*math.sin(a)))
    d.polygon(p,fill='#f4f5f7');d.ellipse((137,137,247,247),fill=(0,0,0,0))
def backpack(d):
    d.rounded_rectangle((133,42,251,145),radius=42,outline='#e8edf3',width=16)
    d.rounded_rectangle((80,99,304,331),radius=42,fill='#272b32',outline='#e8edf3',width=14)
    d.rounded_rectangle((115,208,269,300),radius=15,outline='#e8edf3',width=12)
    d.line((111,171,273,171),fill='#e8edf3',width=12)
for name,fn in [('hud-egg',egg),('hud-paw',paw),('hud-index',index),('topbar-gear',gear),('topbar-backpack',backpack)]:save(name,fn)
