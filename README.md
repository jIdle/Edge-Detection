# Edge-Detection
This program will convolve the specified image with the Sobel operator, resulting in an approximation of the image gradient.
Edges (changes in pixel intensity) will be emphasized in the resulting image, allowing the user to more easily detect where lines and edges exist within the photo.

Love2D is necessary for this program to work. While the standard Lua libraries are sufficient to convolve the image, Love2D is needed to retrieve initial pixel values, as well as automatically displaying the final image to the user.


# Example
### Initial Image
![Image of Rose before convolution](https://github.com/jIdle/Edge-Detection/Rose.png)
### Convolved Image
![Image of Rose after convolution](https://github.com/jIdle/Edge-Detection/ConvolvedRose.png)
