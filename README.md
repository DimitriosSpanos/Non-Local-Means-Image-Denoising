# Parallel-Exercise3


To test locally, I recommend you use a 128x128 png. Run the **image_read** script. You will 
be shown the original image but grayscaled and the image with noise. Then, run the program
and after that press any key so that the filtered image is shown in matlab.

```
1. Run script
2. Run Non-Local-Means program
3. Press any key if filtered image txt is ready.
4. Filtered image will be shown in matlab!
```
# Things to look out

-In the matlab script you should make sure your input is correct
(V1 outputs filtered_image_V1.txt, V2 outputs filtered_image_V2.txt)
```
image_filename = 'name_of_image.png';
f_image_filename = 'filtered_image.txt';
```
-In the program you wish to run make sure the variable PIXELS is correct.

```
#define PIXELS 64 // meaning image with 64x64 pixels
```

Repo for the second exercise of course 050 - Parallel and Distributed Systems, Aristotle University of Thessaloniki, Dpt. of Electrical & Computer Engineering.
