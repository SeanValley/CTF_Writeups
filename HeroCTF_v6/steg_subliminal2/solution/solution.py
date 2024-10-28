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
