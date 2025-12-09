from PIL import Image, ImageDraw
import os

densities = {
    "mdpi": 48,
    "hdpi": 72,
    "xhdpi": 96,
    "xxhdpi": 144,
    "xxxhdpi": 192
}

base_path = r"C:\Users\motio\OneDrive\Desktop\Weather\android\app\src\main\res"

for density, size in densities.items():
    dir_path = os.path.join(base_path, f"mipmap-{density}")
    os.makedirs(dir_path, exist_ok=True)
    
    # Create image with blue background
    img = Image.new('RGB', (size, size), color=(33, 150, 243))
    draw = ImageDraw.Draw(img)
    
    # Draw white circle
    padding = int(size * 0.15)
    draw.ellipse([padding, padding, size - padding, size - padding], fill='white')
    
    # Save
    icon_path = os.path.join(dir_path, "ic_launcher.png")
    img.save(icon_path)
    print(f"Created {icon_path} ({size}x{size})")

print("All icons created successfully!")
