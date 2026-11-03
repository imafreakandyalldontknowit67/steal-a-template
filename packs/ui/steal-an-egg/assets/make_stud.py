from PIL import Image,ImageDraw
im=Image.new('RGBA',(24,24),(255,255,255,0))
d=ImageDraw.Draw(im)
d.line([(5,5),(5,13),(13,13)],fill=(0,0,0,60),width=2)
d.line([(7,5),(13,5),(13,11)],fill=(255,255,255,45),width=2)
im.save(__file__.replace('make_stud.py','stud.png'))
