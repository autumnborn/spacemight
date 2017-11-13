; Images

; Weapons
img_w1 file "img\sm_wpn1_2x8x32_raw.bmp"
img_w2 file "img\sm_wpn2_14x6x32_raw.bmp"
img_w3 file "img\sm_wpn3_24x8x32_raw.bmp"

; Player
img_pl file "img\sm_plr_32x32x32_raw.bmp"

; Enemies
img_e1 file "img\sm_enm1_24x32x32_raw.bmp"
img_e2 file "img\sm_enm2_32x32x32_raw.bmp"

; Objects description

; Weapons
wpntype_1 WPNTYPE W_SIMPLE, 50, img_w1, <2, 8>
wpntype_2 WPNTYPE W_DOUBLE, 50, img_w2, <14, 6>
wpntype_3 WPNTYPE W_TRIPPLE, 50, img_w3, <24, 8>

; Player
plrtype UNITTYPE 0, 4, wpntype_1, WPN_DIRECT_U, 300, img_pl, <32, 32>

; Enemies
etype_1 UNITTYPE 1, 2, wpntype_1, WPN_DIRECT_D, 50, img_e1, <24, 32>
etype_2 UNITTYPE 2, 2, wpntype_1, WPN_DIRECT_D, 50, img_e1, <24, 32>
etype_3 UNITTYPE 3, 3, wpntype_2, WPN_DIRECT_D, 50, img_e2, <32, 32>
etype_4 UNITTYPE 4, 4, wpntype_3, WPN_DIRECT_D, 50, img_e2, <32, 32>
etype_5 UNITTYPE 4, 4, wpntype_1, WPN_DIRECT_D, 50, img_e1, <24, 32>
etype_6 UNITTYPE 4, 4, wpntype_1, WPN_DIRECT_D, 50, img_e1, <24, 32>
etype_7 UNITTYPE 4, 4, wpntype_1, WPN_DIRECT_D, 50, img_e1, <24, 32>
etype_8 UNITTYPE 4, 4, wpntype_1, WPN_DIRECT_D, 50, img_e1, <24, 32>
etype_9 UNITTYPE 4, 4, wpntype_1, WPN_DIRECT_D, 50, img_e1, <24, 32>
etype_10 UNITTYPE 4, 4, wpntype_1, WPN_DIRECT_D, 50, img_e1, <24, 32>