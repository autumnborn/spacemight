; Images

; Weapons
img_w1 file "img\sm_wpn1_2x8x32_raw.bmp"
img_w2 file "img\sm_wpn2_14x6x32_raw.bmp"
img_w3 file "img\sm_wpn3_24x8x32_raw.bmp"

; Player
img_pl file "img\sm_plr_32x32x32_raw.bmp"

; Enemies
img_e1 file "img\sm_enm1_24x32x32_raw.bmp"
img_e2 file "img\sm_enm2_24x32x32_raw.bmp"
img_e3 file "img\sm_enm3_32x32x32_raw.bmp"
img_e4 file "img\sm_enm4_20x32x32_raw.bmp"
img_e5 file "img\sm_enm5_24x24x32_raw.bmp"
img_e6 file "img\sm_enm6_32x32x32_raw.bmp"

; Animation sequences
img_exp1 file "img\sm_exp1seq3f_72x24x32_raw.bmp"
img_logo file "img\sm_logo1seq10f_320x32x32_raw.bmp"

; Objects description

; Weapons
wpntype_1 WPNTYPE W_SIMPLE, 50, img_w1, <2, 8>
wpntype_2 WPNTYPE W_DOUBLE, 50, img_w2, <14, 6>
wpntype_3 WPNTYPE W_TRIPPLE, 50, img_w3, <24, 8>

; Player
plrtype UNITTYPE 0, 4, 500, wpntype_1, WPN_DIRECT_U, anim, img_pl, <32, 32>

; Enemies
etype_1 UNITTYPE 1, 2, 50, wpntype_1, WPN_DIRECT_D, anim, img_e1, <24, 32>
etype_2 UNITTYPE 2, 2, 150, wpntype_1, WPN_DIRECT_D, anim, img_e2, <24, 32>
etype_3 UNITTYPE 3, 2, 100, wpntype_2, WPN_DIRECT_D, anim, img_e2, <24, 32>
etype_4 UNITTYPE 4, 2, 150, wpntype_2, WPN_DIRECT_D, anim, img_e3, <32, 32>
etype_5 UNITTYPE 5, 2, 150, wpntype_3, WPN_DIRECT_D, anim, img_e3, <32, 32>
etype_6 UNITTYPE 6, 3, 100, wpntype_1, WPN_DIRECT_D, anim, img_e4, <20, 32>
etype_7 UNITTYPE 7, 3, 100, wpntype_2, WPN_DIRECT_D, anim, img_e4, <20, 32>
etype_8 UNITTYPE 8, 3, 100, wpntype_3, WPN_DIRECT_D, anim, img_e5, <24, 24>
etype_9 UNITTYPE 9, 3, 100, wpntype_3, WPN_DIRECT_D, anim, img_e5, <24, 24>
etype_10 UNITTYPE 10, 3, 150, wpntype_3, WPN_DIRECT_D, anim, img_e6, <32, 32>

; Animation
atExp1 ANIMTYPE 3, img_exp1, <72, 24>
atLogo ANIMTYPE 10, img_logo, <320, 32>