function xSlinger.DRAW_held_itemname(v, x, y, text, color)
	color = skincolors[color].chatcolor
	v.drawString(x, y + FU, text, V_SNAPTOBOTTOM|V_ALLOWLOWERCASE|color, "thin-fixed-center")
end
