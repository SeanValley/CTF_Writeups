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
