#!/usr/bin/env bqn

gdkPixbuf ← {
  Lib ⇐ ↑‿"libgdk_pixbuf-2.0.so"⊸•FFI
  unref        ⇐ Lib    ""‿"gdk_pixbuf_unref"‿"*"
  new          ⇐ Lib   "*"‿"gdk_pixbuf_new"‿"i32"‿"bool"‿"i32"‿"i32"‿"i32"
  newFromFile  ⇐ Lib   "*"‿"gdk_pixbuf_new_from_file"‿"*u8:c8"‿"&*u8"
  getWidth     ⇐ Lib "u32"‿"gdk_pixbuf_get_width"‿"*"
  getHeight    ⇐ Lib "u32"‿"gdk_pixbuf_get_height"‿"*"
  getPixels    ⇐ Lib "*i8"‿"gdk_pixbuf_get_pixels"‿"*"
  addAlpha     ⇐ Lib   "*"‿"gdk_pixbuf_add_alpha"‿"*"‿"i8"‿"i8"‿"i8"‿"i8"
  save         ⇐ Lib  "u8"‿"gdk_pixbuf_save"‿"*"‿"*u8:c8"‿"*u8:c8"‿"&*u8"‿"u8"
}

⟨ReadImg,WriteImg,ToRGB,ToRGBA,gdkPixbuf⟩⇐

ToRGB ←  {⍉>  256|⌊∘÷⟜256⍟(⌽↕3)𝕩}
ToRGBA ← {⍉>1⌽256|⌊∘÷⟜256⍟(⌽↕4)𝕩}

GetErrorMsg ← {
  domain‿code‿message ← (𝕩.Cast"{u32,i32,*u8}").Read 0
  •FromUTF8 {@+𝕩.Read¨↕1⊸+•_while_(0≠𝕩.Read)0} message
}

ReadImg ← {
  buf‿⟨err⟩ ← gdkPixbuf.NewFromFile⟨(•ToUTF8𝕩∾@),(⋈•foreign.null)⟩
  failed ← err.Sub •foreign.null.Cast "u8"
  (GetErrorMsg⍟(0≠failed) err) ! 0=failed
  w‿h ← (gdkPixbuf.GetWidth∾gdkPixbuf.GetHeight)⟨buf⟩
  p ← gdkPixbuf.GetPixels⟨img←gdkPixbuf.AddAlpha⟨buf,0,0,0,0⟩⟩
  z ← h‿w⥊8‿32•bit._cast 2‿1‿0‿3⊸⊏˘ ∘‿4⥊p.Readlist 4×w×h
  gdkPixbuf.Unref⟨buf⟩ ⋄ gdkPixbuf.Unref⟨img⟩
  z
}

ToLower ← +⟜(32×1="A["⊸⍋)

fmts ← [⟨⋈"png"⟩,⟨⋈"bmp"⟩,⟨"jpeg"‿"jpg"⟩,⟨"tiff"‿"tif"⟩]
FormatFromExt ← {𝕊path:
  fmt ← /⥊ fmts ∨´∘∊⚇2 ⋈ ToLower{𝕩↑˜𝕩⊐'.'}⌾⌽path
  "Unknown or unsupported image format" ! ≠ fmt
  ⊑> fmts ⊏˜ fmt
}

WriteImg ← {img𝕊path:
  fmt ← FormatFromExt path ⋄ h‿w ← 2↑≢img
  p ← gdkPixbuf.GetPixels⟨buf←gdkPixBuf.New⟨0,1,8,w,h⟩⟩
  p.WriteList ⊏˘16‿8•bit._cast≍˘⥊(2=≠∘≢)◶((∾⟜255˘˘)⍟(4>⊢´∘≢))‿ToRGBA img
  ok‿⟨err⟩ ← gdkPixBuf.Save⟨buf,(•ToUTF8𝕩∾@),(fmt∾@),(⋈•foreign.null),0⟩
  gdkPixbuf.Unref⟨buf⟩
  (GetErrorMsg⍟(1≠ok) err) ! 0≠ok
  ok
}
