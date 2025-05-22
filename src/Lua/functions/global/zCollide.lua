function ZE2.ZCollide(mo1,mo2)
	if mo1.z > FixedMul(mo2.height,mo2.scale)+mo2.z then return false end
	if mo2.z > FixedMul(mo1.height,mo2.scale)+mo1.z then return false end
	return true
end