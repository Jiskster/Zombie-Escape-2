local KB = ZE2.Knockback

KB.initKnockback = function(mo)
	mo.knockback = {
		list = {},
		thrust = {x=0,y=0},
		wait = 0,
	}
end