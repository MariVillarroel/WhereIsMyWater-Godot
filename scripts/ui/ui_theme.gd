class_name UITheme

# =====================================================
# FUENTES
# =====================================================

const FONT_BOLD: FontFile = preload("res://assets/fonts/PixelifySans-Bold.ttf")
const FONT_MEDIUM: FontFile = preload("res://assets/fonts/PixelifySans-Medium.ttf")
const FONT_REGULAR: FontFile = preload("res://assets/fonts/PixelifySans-Regular.ttf")
const FONT_SEMIBOLD: FontFile = preload("res://assets/fonts/PixelifySans-SemiBold.ttf")


# =====================================================
# COLORES
# =====================================================

const COLOR_PRIMARY := Color("03B3FF")
const COLOR_WHITE := Color.WHITE

const COLOR_SUCCESS := Color("55E06D")
const COLOR_WARNING := Color("FFC857")
const COLOR_DANGER := Color("FF5A5A")

const COLOR_SHADOW := Color("000000", 0.35)


# =====================================================
# TIPOGRAFÍA
# =====================================================

const TITLE_SIZE := 27
const SUBTITLE_SIZE := 24
const NUMBER_SIZE := 26
const TEXT_SIZE := 22
const BUTTON_SIZE := 22
const SMALL_SIZE := 18


# =====================================================
# ESPACIADO
# =====================================================

const PANEL_PADDING := 18
const TEXT_SPACING := 8
const ICON_PADDING := 12


# =====================================================
# TAMAÑOS
# =====================================================

const ICON_SIZE := Vector2i(48, 48)

const SMALL_ICON_SIZE := Vector2i(32, 32)

const HUD_MAIN_SIZE := Vector2i(430, 110)
const HUD_SMALL_SIZE := Vector2i(80, 80)

const PROGRESS_SIZE := Vector2i(230, 24)


# =====================================================
# ANIMACIONES
# =====================================================

const UI_FADE_TIME := 0.20
const UI_POP_TIME := 0.12
const UI_SLIDE_TIME := 0.25


# =====================================================
# CAPAS
# =====================================================

const HUD_Z_INDEX := 100
const POPUP_Z_INDEX := 200
