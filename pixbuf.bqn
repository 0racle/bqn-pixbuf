#!/usr/bin/env bqn

gdkPixbuf ← {
  Lib ⇐ "/usr/lib/x86_64-linux-gnu/libgdk_pixbuf-2.0.so"⊸•FFI
  unref        ⇐ Lib    ""‿"gdk_pixbuf_unref"        ‿"*"
  newFrom_file ⇐ Lib   "*"‿"gdk_pixbuf_new_from_file"‿"*u8:c8"‿"&u8"
  getWidth     ⇐ Lib "u32"‿"gdk_pixbuf_get_width"    ‿"*"
  getHeight    ⇐ Lib "u32"‿"gdk_pixbuf_get_height"   ‿"*"
  getPixels    ⇐ Lib "*u8"‿"gdk_pixbuf_get_pixels"   ‿"*"
  addAlpha     ⇐ Lib   "*"‿"gdk_pixbuf_add_alpha"    ‿"*"‿"i8"‿"i8"‿"i8"‿"i8"
  newFromData  ⇐ Lib   "*"‿"gdk_pixbuf_new_from_data"‿"*u8"‿"u8"‿"u8"‿"u32"‿"u32"‿"u32"‿"u32"‿"u8"‿"u8"
  save         ⇐ Lib  "u8"‿"gdk_pixbuf_save"         ‿"*"‿"*u8:c8"‿"*u8:c8"‿"u8"‿"u8"
}

⟨ReadImg,WriteImg,ToRGB,ToRGBA,gdkPixbuf⟩⇐

ToRGB ←  {⍉>  256|⌊∘÷⟜256⍟(⌽↕3)𝕩}
ToRGBA ← {⍉>1⌽256|⌊∘÷⟜256⍟(⌽↕4)𝕩}

ReadImg ← {
  buf‿err ← ∾⟜⊑˝ gdkPixbuf.NewFromFile⟨(𝕩∾@),⟨0⟩⟩
  "Failed reading file " ! err=0
  w‿h ← (gdkPixbuf.GetWidth∾gdkPixbuf.GetHeight)⟨buf⟩
  p ← gdkPixbuf.GetPixels⟨img←gdkPixbuf.AddAlpha⟨buf,0,0,0,0⟩⟩
  z ← h‿w⥊{+´16777216‿65536‿256‿1×¯1⌽𝕩}˘∘‿4⥊p.Readlist 4×w×h
  gdkPixbuf.Unref⟨buf⟩ ⋄ gdkPixbuf.Unref⟨img⟩
  z
}

types ← ⟨"png"‿@⟩‿⟨"bmp"‿@⟩‿⟨"jpg"‿"jpeg"⟩‿⟨"tif"‿"tiff"⟩

WriteImg ← {img𝕊fname:
  ext ← (+`'.'=»)⊸/fname
  "Unknown type" ! ≠ type ← /∾´⟨ext⟩ ⊑∘∊⚇2 types
  h‿w ← 2↑≢img ⋄ fmt ← ⊑>types⊑˜type
  data ← ⥊ (2=≠∘≢)◶((∾⟜255˘˘)⍟(4>⊢´∘≢))‿ToRGBA img
  buf ← gdkPixBuf.NewFromData⟨data,0,1,8,w,h,(4×w),0,0⟩
  "Image save failed" ! ok ← gdkPixBuf.Save⟨buf,(𝕩∾@),(fmt∾@),0,0⟩
  # Unref crashes when writing ≥3 images in a row
  # Seems fine when run with `-Xjit-disable`
  # gdkPixbuf.Unref⟨buf⟩
  ok
}
