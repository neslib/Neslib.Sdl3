# Save the local path
SDL_TTF_LOCAL_PATH := $(call my-dir)/../../

# Enable this if you want to use PlutoSVG for emoji support
SUPPORT_PLUTOSVG ?= true
PLUTOSVG_LIBRARY_PATH := external/plutosvg
PLUTOVG_LIBRARY_PATH := external/plutovg

# Restore local path
LOCAL_PATH := $(SDL_TTF_LOCAL_PATH)
include $(CLEAR_VARS)

LOCAL_MODULE := SDL3_ttf

LOCAL_SRC_FILES := \
    src/SDL_ttf.c.neon \
    src/SDL_hashtable.c \
    src/SDL_hashtable_ttf.c \
    src/SDL_gpu_textengine.c \
    src/SDL_renderer_textengine.c \
    src/SDL_surface_textengine.c

LOCAL_C_INCLUDES += $(LOCAL_PATH)/include

LOCAL_SRC_FILES += \
    external/freetype/src/autofit/autofit.c \
    external/freetype/src/base/ftbase.c \
    external/freetype/src/base/ftbbox.c \
    external/freetype/src/base/ftbdf.c \
    external/freetype/src/base/ftbitmap.c \
    external/freetype/src/base/ftcid.c \
    external/freetype/src/base/ftdebug.c \
    external/freetype/src/base/ftfstype.c \
    external/freetype/src/base/ftgasp.c \
    external/freetype/src/base/ftglyph.c \
    external/freetype/src/base/ftgxval.c \
    external/freetype/src/base/ftinit.c \
    external/freetype/src/base/ftmm.c \
    external/freetype/src/base/ftotval.c \
    external/freetype/src/base/ftpatent.c \
    external/freetype/src/base/ftpfr.c \
    external/freetype/src/base/ftstroke.c \
    external/freetype/src/base/ftsynth.c \
    external/freetype/src/base/ftsystem.c \
    external/freetype/src/base/fttype1.c \
    external/freetype/src/base/ftwinfnt.c \
    external/freetype/src/bdf/bdf.c \
    external/freetype/src/bzip2/ftbzip2.c \
    external/freetype/src/cache/ftcache.c \
    external/freetype/src/cff/cff.c \
    external/freetype/src/cid/type1cid.c \
    external/freetype/src/gzip/ftgzip.c \
    external/freetype/src/lzw/ftlzw.c \
    external/freetype/src/pcf/pcf.c \
    external/freetype/src/pfr/pfr.c \
    external/freetype/src/psaux/psaux.c \
    external/freetype/src/pshinter/pshinter.c \
    external/freetype/src/psnames/psmodule.c \
    external/freetype/src/raster/raster.c \
    external/freetype/src/sdf/sdf.c \
    external/freetype/src/sfnt/sfnt.c \
    external/freetype/src/svg/svg.c \
    external/freetype/src/smooth/smooth.c \
    external/freetype/src/truetype/truetype.c \
    external/freetype/src/type1/type1.c \
    external/freetype/src/type42/type42.c \
    external/freetype/src/winfonts/winfnt.c

LOCAL_CFLAGS += -DFT2_BUILD_LIBRARY -Os -DFT_PUBLIC_FUNCTION_ATTRIBUTE=

LOCAL_C_INCLUDES += $(LOCAL_PATH)/external/freetype/include
LOCAL_C_INCLUDES += $(LOCAL_PATH)/external/harfbuzz/src

LOCAL_CFLAGS += -DFT_CONFIG_OPTION_USE_HARFBUZZ

LOCAL_SRC_FILES += \
    external/harfbuzz/src/hb-aat-layout.cc \
    external/harfbuzz/src/hb-aat-map.cc \
    external/harfbuzz/src/hb-blob.cc \
    external/harfbuzz/src/hb-buffer-serialize.cc \
    external/harfbuzz/src/hb-buffer-verify.cc \
    external/harfbuzz/src/hb-buffer.cc \
    external/harfbuzz/src/hb-common.cc \
    external/harfbuzz/src/hb-draw.cc \
    external/harfbuzz/src/hb-face.cc \
    external/harfbuzz/src/hb-fallback-shape.cc \
    external/harfbuzz/src/hb-font.cc \
    external/harfbuzz/src/hb-ft.cc \
    external/harfbuzz/src/hb-number.cc \
    external/harfbuzz/src/hb-ot-cff1-table.cc \
    external/harfbuzz/src/hb-ot-cff2-table.cc \
    external/harfbuzz/src/hb-ot-color.cc \
    external/harfbuzz/src/hb-ot-face.cc \
    external/harfbuzz/src/hb-ot-font.cc \
    external/harfbuzz/src/hb-ot-layout.cc \
    external/harfbuzz/src/hb-ot-map.cc \
    external/harfbuzz/src/hb-ot-math.cc \
    external/harfbuzz/src/hb-ot-metrics.cc \
    external/harfbuzz/src/hb-ot-shaper-arabic.cc \
    external/harfbuzz/src/hb-ot-shaper-default.cc \
    external/harfbuzz/src/hb-ot-shaper-hangul.cc \
    external/harfbuzz/src/hb-ot-shaper-hebrew.cc \
    external/harfbuzz/src/hb-ot-shaper-indic.cc \
    external/harfbuzz/src/hb-ot-shaper-indic-table.cc \
    external/harfbuzz/src/hb-ot-shaper-khmer.cc \
    external/harfbuzz/src/hb-ot-shaper-myanmar.cc \
    external/harfbuzz/src/hb-ot-shaper-syllabic.cc \
    external/harfbuzz/src/hb-ot-shaper-thai.cc \
    external/harfbuzz/src/hb-ot-shaper-use.cc \
    external/harfbuzz/src/hb-ot-shaper-vowel-constraints.cc \
    external/harfbuzz/src/hb-ot-shape.cc \
    external/harfbuzz/src/hb-ot-shape-fallback.cc \
    external/harfbuzz/src/hb-ot-shape-normalize.cc \
    external/harfbuzz/src/hb-ot-tag.cc \
    external/harfbuzz/src/hb-ot-var.cc \
    external/harfbuzz/src/hb-outline.cc \
    external/harfbuzz/src/hb-paint.cc \
    external/harfbuzz/src/hb-paint-extents.cc \
    external/harfbuzz/src/hb-set.cc \
    external/harfbuzz/src/hb-shape-plan.cc \
    external/harfbuzz/src/hb-shape.cc \
    external/harfbuzz/src/hb-shaper.cc \
    external/harfbuzz/src/hb-static.cc \
    external/harfbuzz/src/hb-ucd.cc \
    external/harfbuzz/src/hb-coretext.cc \
    external/harfbuzz/src/hb-gdi.cc \
    external/harfbuzz/src/hb-uniscribe.cc \
    external/harfbuzz/src/hb-unicode.cc \

LOCAL_ARM_MODE := arm
LOCAL_CPP_EXTENSION := .cc
LOCAL_CFLAGS += -DHAVE_CONFIG_H -fPIC
LOCAL_CFLAGS += -DTTF_USE_HARFBUZZ
LOCAL_C_INCLUDES += $(LOCAL_PATH)/external/harfbuzz

LOCAL_CFLAGS += -O2

ifeq ($(SUPPORT_PLUTOSVG),true)
    LOCAL_C_INCLUDES += $(LOCAL_PATH)/$(PLUTOVG_LIBRARY_PATH)/include
    LOCAL_C_FLAGS += -DTTF_USE_PLUTOSVG -DPLUTOSVG_HAS_FREETYPE
    LOCAL_SRC_FILES += \
        external/plutosvg/source/plutosvg.c \
        external/plutovg/source/plutovg-blend.c \
        external/plutovg/source/plutovg-canvas.c \
        external/plutovg/source/plutovg-font.c \
        external/plutovg/source/plutovg-ft-math.c \
        external/plutovg/source/plutovg-ft-raster.c \
        external/plutovg/source/plutovg-ft-stroker.c \
        external/plutovg/source/plutovg-matrix.c \
        external/plutovg/source/plutovg-paint.c \
        external/plutovg/source/plutovg-path.c \
        external/plutovg/source/plutovg-rasterize.c \
        external/plutovg/source/plutovg-surface.c
endif

LOCAL_SHARED_LIBRARIES := SDL3

LOCAL_EXPORT_C_INCLUDES += $(LOCAL_PATH)/include

###########################
#
# SDL3_ttf static library
#
###########################

LOCAL_MODULE := SDL3_ttf_static

LOCAL_MODULE_FILENAME := libSDL3_ttf

LOCAL_LDLIBS :=
LOCAL_EXPORT_LDLIBS :=

LOCAL_C_INCLUDES += $(LOCAL_PATH)/../SDL-release-3.2.6/include

include $(BUILD_STATIC_LIBRARY)

