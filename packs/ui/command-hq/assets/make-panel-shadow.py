from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter

image = Image.new('RGBA', (256, 256))
ImageDraw.Draw(image).rounded_rectangle((28, 22, 228, 222), radius=16, fill=(0, 0, 0, 160))
image = image.filter(ImageFilter.GaussianBlur(11))
image.save(Path(__file__).with_name('panel-shadow.png'))
