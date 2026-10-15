from PIL import Image, ImageDraw

SIZE = 1024
img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
d = ImageDraw.Draw(img)

PURPLE = (124, 77, 255, 255)  # #7C4DFF

# Chat bubble: large rounded rect, centered, with a tail at bottom-left.
# Keep within the safe zone for Android adaptive icons (~66% center) so it is not clipped.
cx, cy = SIZE / 2, SIZE / 2 - 20
w, h = 620, 470
x0, y0 = cx - w / 2, cy - h / 2
x1, y1 = x0 + w, y0 + h
radius = 150

d.rounded_rectangle([x0, y0, x1, y1], radius=radius, fill=PURPLE)

# tail triangle at bottom-left
tx, ty = x0 + 60, y1 + 150
d.polygon([(x0 + 30, y1 - 8), (x0 + 300, y1 - 8), (tx, ty)], fill=PURPLE)

img.save("D:/work/apps/AnyMini/assets/icons/app_icon_1024.png")
print("saved", img.size, "with alpha:", img.mode)