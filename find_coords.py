import cv2
import numpy as np

img = cv2.imread(r"C:\Users\경리부2\Desktop\부스.png")
if img is None:
    print("Cannot read 부스.png")
    exit(1)

print("Booth shape:", img.shape)
H, W = img.shape[:2]

# Let's try to detect the big white rectangles.
gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
_, thresh = cv2.threshold(gray, 240, 255, cv2.THRESH_BINARY)
contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

for c in sorted(contours, key=cv2.contourArea, reverse=True)[:5]:
    area = cv2.contourArea(c)
    peri = cv2.arcLength(c, True)
    approx = cv2.approxPolyDP(c, 0.02 * peri, True)
    if len(approx) == 4 and area > H*W*0.01:
        print("Found quadrilateral of area", area)
        print("Coords:", approx.tolist())
