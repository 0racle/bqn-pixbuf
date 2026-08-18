# BQN Pixbuf

This library provides functions for reading and writing images in several formats.

This is done through FFI bindings to libgdk-pixbuf, and while some raw bindings are available, it is intended that most users can use the following functions

This library uses newer syntax and feature of CBQN 0.12, so make sure you're up to date!

```bqn
⟨ReadImg,WriteImg,ToRGB,ToRGBA⟩ ← •Import "pixbuf.bqn"
```

### ReadImg

```bqn
img ← ReadImg "image.png"
```

Right arg: string of the file path to be read  
Returns: m×n (2D) matrix of 32-bit integers, each encoding RGBA values

### WriteImg

```bqn
img WriteImg "image.png"
```

Right arg: string of the file path to be written  
Left arg: array representation of a image*  
Returns: 1 on success, throws on failure  

The left argument may be in the following formats
  * m×n (2D) matrix of 32-bit integers
  * m×n×3 array representing RGB values
  * m×n×4 array representing RGBA values

**Note:** The format will be auto-detected from the extension.  
Formats tested as working are "png", "jpg" (or "jpeg"), "bmp", "tif" (or "tiff")

### ToRGB

```bqn
img ← ToRGB ReadImg "image.png"
```

Right arg: m×n (2D) matrix of 32-bit integers  
Returns: m×n×3 array representing RGB values

If the image being read has an alpha channel, `ToRGB` will not return it.  
If you need the alpha channel, use `ToRGBA`.

### ToRGBA

```bqn
img ← ToRGBA ReadImg "image.png"
```

Right arg: m×n (2D) matrix of 32-bit integers  
Returns: m×n×4 array representing RGBA values

# See also

This module plays nicely with [bqn-viewmat](https://github.com/0racle/bqn-viewmat) for viewing images

```bqn
⟨Viewmat⟩ ← •Import "viewmat.bqn"
"rgb" Viewmat ReadImg "image.png"
```

# Advanced

If you want access to the underlying raw bindings, this module also exports the namespace `gdkPixbuf` which contains the few functions this library uses, as well as the `•FFI` bound lib so that you can write your own bindings.
