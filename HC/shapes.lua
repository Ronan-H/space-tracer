
local math_min, math_sqrt, math_huge = math.min, math.sqrt, math.huge

local _PACKAGE, common_local = (...):match("^(.+)%.[^%.]+"), common
if not (type(common) == 'table' and common.class and common.instance) then
	assert(common_class ~= false, 'No class commons specification available.')
	require(_PACKAGE .. '.class')
end
local vector  = require(_PACKAGE .. '.vector-light')
local Polygon = require(_PACKAGE .. '.polygon')
local GJK     = require(_PACKAGE .. '.gjk')

if common_local ~= common then
	common_local, common = common, common_local
end

local Shape = {}
function Shape:init(t)
	self._type = t
	self._rotation = 0
end

local ConvexPolygonShape = {}
function ConvexPolygonShape:init(polygon)
	Shape.init(self, 'polygon')
	assert(polygon:isConvex(), "Polygon is not convex.")
	self._polygon = polygon
end

local ConcavePolygonShape = {}
function ConcavePolygonShape:init(poly)
	Shape.init(self, 'compound')
	self._polygon = poly
	self._shapes = poly:splitConvex()
	for i,s in ipairs(self._shapes) do
		self._shapes[i] = common_local.instance(ConvexPolygonShape, s)
	end
end

local CircleShape = {}
function CircleShape:init(cx,cy, radius)
	Shape.init(self, 'circle')
	self._center = {x = cx, y = cy}
	self._radius = radius
end

local PointShape = {}
function PointShape:init(x,y)
	Shape.init(self, 'point')
	self._pos = {x = x, y = y}
end

--
-- collision functions
--
function ConvexPolygonShape:support(dx,dy)
	local v = self._polygon.vertices
	local max, vmax = -math_huge
	for i = 1,#v do
		local d = vector.dot(v[i].x,v[i].y, dx,dy)
		if d > max then
			max, vmax = d, v[i]
		end
	end
	return vmax.x, vmax.y
end

function CircleShape:support(dx,dy)
	return vector.add(self._center.x, self._center.y,
		vector.mul(self._radius, vector.normalize(dx,dy)))
end

-- collision dispatching:
-- let circle shape or compund shape handle the collision
function ConvexPolygonShape:collidesWith(other)
	if self == other then return false end
	if other._type ~= 'polygon' then
		local collide, sx,sy = other:collidesWith(self)
		return collide, sx and -sx, sy and -sy
	end

	-- else: type is POLYGON
	return GJK(self, other)
end

function ConcavePolygonShape:collidesWith(other)
	if self == other then return false end
	if other._type == 'point' then
		return other:collidesWith(self)
	end
	local collide,dx,dy = false,0,0
	for _,s in ipairs(self._shapes) do
		local status, sx,sy = s:collidesWith(other)
		collide = collide or status
		if status then
			if math.abs(dx) < math.abs(sx) then
				dx = sx
			end
			if math.abs(dy) < math.abs(sy) then
				dy = sy
			end
		end
	end
	return collide, dx, dy
end

function PointShape:collidesWith(other)
	if self == other then return false end
	if other._type == 'point' then
		return (self._pos == other._pos), 0,0
	end
	return other:contains(self._pos.x, self._pos.y), 0,0
end

function PointShape:outcircle()
	return self._pos.x, self._pos.y, 0
end

function ConvexPolygonShape:bbox()
	return self._polygon:bbox()
end

function ConcavePolygonShape:bbox()
	return self._polygon:bbox()
end

function PointShape:bbox()
	local x,y = self:center()
	return x,y,x,y
end

function ConvexPolygonShape:draw(mode)
	mode = mode or 'line'
	love.graphics.polygon(mode, self._polygon:unpack())
end

function ConcavePolygonShape:draw(mode, wireframe)
	local mode = mode or 'line'
	if mode == 'line' then
		love.graphics.polygon('line', self._polygon:unpack())
		if not wireframe then return end
	end
	for _,p in ipairs(self._shapes) do
		love.graphics.polygon(mode, p._polygon:unpack())
	end
end

function CircleShape:draw(mode, segments)
	love.graphics.circle(mode or 'line', self:outcircle())
end

function PointShape:draw()
	love.graphics.point(self:center())
end


Shape = common_local.class('Shape', Shape)
ConvexPolygonShape  = common_local.class('ConvexPolygonShape',  ConvexPolygonShape,  Shape)
ConcavePolygonShape = common_local.class('ConcavePolygonShape', ConcavePolygonShape, Shape)
CircleShape         = common_local.class('CircleShape',         CircleShape,         Shape)
PointShape          = common_local.class('PointShape',          PointShape,          Shape)

local function newPolygonShape(polygon, ...)
	-- create from coordinates if needed
	if type(polygon) == "number" then
		polygon = common_local.instance(Polygon, polygon, ...)
	else
		polygon = polygon:clone()
	end

	if polygon:isConvex() then
		return common_local.instance(ConvexPolygonShape, polygon)
	end

	return common_local.instance(ConcavePolygonShape, polygon)
end

local function newCircleShape(...)
	return common_local.instance(CircleShape, ...)
end

local function newPointShape(...)
	return common_local.instance(PointShape, ...)
end

return {
	ConcavePolygonShape = ConcavePolygonShape,
	ConvexPolygonShape  = ConvexPolygonShape,
	CircleShape         = CircleShape,
	PointShape          = PointShape,
	newPolygonShape     = newPolygonShape,
	newCircleShape      = newCircleShape,
	newPointShape       = newPointShape,
}

