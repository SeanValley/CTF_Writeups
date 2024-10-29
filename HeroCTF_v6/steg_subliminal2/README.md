# 🏆 **CTF Challenge Write-Up: Subliminal#2**
<div align="right"><img src="https://github.com/user-attachments/assets/8c1f1bcf-74e6-43fe-b364-b94353c1b039" width="200px" height="200px"/><img src="https://github.com/user-attachments/assets/8c9bf907-1281-4e95-84d6-44ef0213a426" width="200px" height="200px"/></div>

## 📋 Challenge Information 

**CTF:** HeroCTF_v6 

**Challenge Name:** Subliminal#2

**Category:** Steganography

**Description:**
The yellow demon triangle is back, even harder than before... An image has been hidden in this video. Don't fall into madness.
Little squares size : 20x20 pixels

**Provided files:**
* subliminal_hide.mp4

---
<br><br><br>
## 🔍 Reconnaissance and Initial Setup

**Observations:** 

In this challenge, we are presented with an mp4 video file. In the video, we see a figure dancing as a small box traverses down and across the page. The description of this challenge mentions that there is an image is hidden in the video. As we watch the video, we can see the square changing colors as it moves across the screen and eventually covers all locations in the frame of the video. This lead me to believe that the image would reveal itself if we took the contents of the 20x20 pixel box at every location within the frame and put it together.

**Plan:**
1. Extract all frames from the video
2. Grab the 20x20 pixel box in each frame
3. Insert the box into our final output image

**Requirements:**

I used the following python libraries while writing my solution:
* pip install opencv-python  (Used to pull frames from the video)
* pip install pillow  (Used to create an output image)

---
<br><br><br>
## 🛠️ Step-by-Step Solution

### Step 1: Pull frames from video

I wrote [mp4_frames.py](https://github.com/SeanValley/CTF_Writeups/blob/main/HeroCTF_v6/steg_subliminal2/solution/mp4_frames.py) to write all of the frames of the video into images and save them into a new folder:
```python
import cv2
import os

video_path = '../subliminal_hide.mp4'
output_folder = 'extracted_frames'

if not os.path.exists(output_folder):
    os.makedirs(output_folder)

cap = cv2.VideoCapture(video_path)
frame_count = 0

while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        break
    
    # Save the frame into folder
    frame_filename = os.path.join(output_folder, f'frame_{frame_count:04d}.png')
    cv2.imwrite(frame_filename, frame)
    frame_count += 1

cap.release()

print('Extracted '+ str(frame_count) + ' frames to ./' + output_folder + '/')
```

<br>

Running this script gives us the 2304 frames from our mp4 video. 
![image](https://github.com/user-attachments/assets/6a7a3cb7-2777-4859-a636-dc10e27984ef)

<br>

We can see that there are a total of 36 frames for each column that the 20x20 pixel box covers. 2304 / 36 = 64. This tells us that we will have 64 columns with 36 frames/boxes making up each column.

<br><br>
<hr>

### Step 2: Grab the 20x20 pixel box from each frame + Save to final image

In [solution.py](https://github.com/SeanValley/CTF_Writeups/blob/main/HeroCTF_v6/steg_subliminal2/solution/solution.py), I start by defining the size of the box, the number of columns and frames per column, and the size of the final image.
```python
from PIL import Image
import os

frame_width = 20
frame_height = 20
columns = 64
frames_per_column = 36

final_image_width = frame_width * columns
final_image_height = frame_height * frames_per_column

# create a new image with required dimensions
final_image = Image.new('RGB', (final_image_width, final_image_height))

# directory with the frames we extracted from the video
frames_directory = './extracted_frames'
```

<br>

After defining this, I iterate through all of the frames. For each frame, I am pulling the pixels at the current location of the moving square and pasting them to the same coordinates in the final image. Finally, I save the image.
```python
# iterate over the frames
for column_index in range(columns):
    for frame_index in range(frames_per_column):
        # Calculate the position of the 20x20 pixel box in the frame
        x_position = column_index * frame_width
        y_position = frame_index * frame_height

        # Calculate the filename for the current frame
        frame_number = (column_index * frames_per_column) + frame_index
        frame_filename = os.path.join(frames_directory, f'frame_{frame_number:04d}.png')

        # Open the current frame
        with Image.open(frame_filename) as img:
            # Extract the 20x20 pixel box from the calculated coordinates
            box = img.crop((x_position, y_position, x_position + frame_width, y_position + frame_height))

            # Paste the box into the final image at the calculated position
            final_image.paste(box, (x_position, y_position))


# Save the final image
final_image.save('final_output.png')
print("Final image created: final_output.png")
```
---
<br><br>

## 🏁 Flag Extraction

After running the solution script, we will have generated "final_output.png". Below, you can see the final image generated by the script. We have our flag!

![image](https://github.com/user-attachments/assets/e92cd5d0-1e5b-4dc5-b0d9-cc49a5671520)


Flag: Hero{The_demon_is_defeated!!!!}
