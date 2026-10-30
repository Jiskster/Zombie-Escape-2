local Vec3 = {}
Vec3.__index = Vec3

function Vec3.Add(v1, v2) 
    return Vec3.New(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z)
end

function Vec3.Sub(v1, v2) 
    return Vec3.New(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z)
end

function Vec3.Mul(v1, x2) 
    if type(x2) == "number" then
        return Vec3.New(FixedMul(v1.x, x2), FixedMul(v1.y, x2), FixedMul(v1.z, x2))
    end
    
    return Vec3.New(FixedMul(v1.x, x2.x), FixedMul(v1.y, x2.y), FixedMul(v1.z, x2.z))
end

function Vec3.Div(v1, x2) 
    if type(x2) == "number" then
        return Vec3.New(FixedDiv(v1.x, x2), FixedDiv(v1.y, x2), FixedDiv(v1.z, x2))
    end
    
    return Vec3.New(FixedDiv(v1.x, x2.x), FixedDiv(v1.y, x2.y), FixedDiv(v1.z, x2.z))
end

function Vec3.Dot(v1, v2)
    return FixedMul(v1.x, v2.x) + FixedMul(v1.y, v2.y) + FixedMul(v1.z, v2.z)
end

function Vec3.Cross(v1, v2)
    return Vec3.New(
        FixedMul(v1.y, v2.z) - FixedMul(v1.z, v2.y),
        FixedMul(v1.z, v2.x) - FixedMul(v1.x, v2.z),
        FixedMul(v1.x, v2.y) - FixedMul(v1.y, v2.x)
    )
end

function Vec3.Neg(v) 
    return Vec3.New(-v.x, -v.y, -v.z)
end

function Vec3.Len(v) 
	local temp = v:Dot(v)
	if temp < 0 then temp = -$; end
    return FixedSqrt(temp)
end

function Vec3.Normalize(v) 
    local l = v:Len()
    
    if l == 0 then
        return v
    end
    
    return v:Div(l)
end

function Vec3.ToString(v)
	return ("x = %f\ty = %f\tz = %f (%f)"):format(v.x, v.y, v.z, #v)
end

function Vec3.ToMobjMom(v, mo, absolute)
	if absolute then
		mo.momx = v.x
		mo.momy = v.y
		mo.momz = v.z
	else
		mo.momx = $ + v.x
		mo.momy = $ + v.y
		mo.momz = $ + v.z
	end
end

function Vec3.ToMobjPos(v, mo, absolute, nointerp)
	local destx = v.x
	local desty = v.y
	local destz = v.z
	if not absolute then
		destx = $ + mo.x
		desty = $ + mo.y
		destz = $ + mo.z
	end
	
	if nointerp then
		P_SetOrigin(mo, destx,desty,destz)
	else
		P_MoveOrigin(mo, destx,desty,destz)
	end
end

-- Shortcuts
Vec3.__add = Vec3.Add
Vec3.__sub = Vec3.Sub
Vec3.__mul = Vec3.Mul
Vec3.__div = Vec3.Div
Vec3.__len = Vec3.Len
Vec3.__tostring = Vec3.ToString

registerMetatable(Vec3)

function Vec3.New(x, y, z) 
    return setmetatable({
        ["x"] = x,
        ["y"] = y,
        ["z"] = z,
    }, Vec3)
end

-- Extra misc constructors
function Vec3.SphereToCartesian(a,b)
    return Vec3.New(
        FixedMul(cos(a), cos(b)),
        FixedMul(sin(a), cos(b)),
        sin(b)
    )
end
function Vec3.MobjPosToVec(mo)
	return Vec3.New(
		mo.x, mo.y, mo.z
	)
end
function Vec3.MobjMomToVec(mo)
	return Vec3.New(
		mo.momx, mo.momy, mo.momz
	)
end
function Vec3.Perpendicular(v)
    local up = Vec3.New(0, 0, FU)

    if abs(v:Dot(up)) > (99 * FU / 100) then
        up = Vec3.New(FU, 0, 0)
    end

    return v:Cross(up):Normalize()
end

rawset(_G, "Vec3", Vec3)