-- i know, i know
-- this might not be a pretty vector implementation, and
-- it could certainly be improved with metatables...
-- but it works fine for our purposes

local vec = {}

function vec.new(x,y)
  local v = {x = x or 0, y = y or 0, type = "vec"}
  return v
end

function vec.add(v1,v2)
  return vec.new(v1.x+v2.x,v1.y+v2.y)
end

function vec.sub(v1,v2)
  return vec.new(v1.x-v2.x,v1.y-v2.y)
end

function vec.mul(v1, v2)
  local x = v1.x*v2.x - v1.y*v2.y
  local y = (v1.x*v2.y)+(v1.y*v2.x)
  return vec.new(x,y)
end

function vec.div(v1, v2)
  local d = v2.x*v2.x+v2.y*v2.y
  local x = (v1.x*v2.x+v1.y*v2.y)/d
  local y = (v1.y*v2.x+v1.x*v2.y)/d
  return vec.new(x,y)
end

function vec.pow(v1, v2)
  local arg = vec.arg(v1)
  local magSq = vec.magSq(v1)

  local a = math.pow(magSq, v2.x/2)*math.exp(-v2.y*arg)
  local b = v2.x*arg + 0.5*v2.y*math.log(magSq)

  return vec.new(a*math.cos(b), a*math.sin(b));
end

function vec.sin(v1)
  local x = math.sin(v1.x)*math.cosh(v1.y)
  local y = math.cos(v1.x)*math.sinh(v1.y)
  return vec.new(x, y)
end

function vec.cos(v1)
  local x = math.cos(v1.x)*math.cosh(v1.y)
  local y = -math.sin(v1.x)*math.sinh(v1.y)
  return vec.new(x, y)
end

function vec.tan(v1)
  return vec.div(vec.sin(v1), vec.cos(v1))
end

function vec.csc(v1)
  return vec.div(vec.new(1,0), vec.sin(v1))
end

function vec.sec(v1)
  return vec.div(vec.new(1,0), vec.cos(v1))
end

function vec.cot(v1)
  return vec.div(vec.new(1,0), vec.tan(v1))
end

function vec.sinh(v1)
  local x = math.sinh(v1.x)*math.cos(v1.y)
  local y = math.cosh(v1.x)*math.sin(v1.y)
  return vec.new(x, y)
end

function vec.cosh(v1)
  local x = math.cosh(v1.x)*math.cos(v1.y)
  local y = math.sinh(v1.x)*math.sin(v1.y)
  return vec.new(x, y)
end

function vec.tanh(v1)
  return vec.div(vec.sinh(v1), vec.cosh(v1))
end

function vec.csch(v1)
  return vec.div(vec.new(1,0), vec.sinh(v1))
end

function vec.sech(v1)
  return vec.div(vec.new(1,0), vec.cosh(v1))
end

function vec.coth(v1)
  return vec.div(vec.new(1,0), vec.tanh(v1))
end

function vec.arg(v)
  return math.atan2(v.y, v.x)
end

function vec.magSq(v)
  return v.x*v.x + v.y*v.y
end

function vec.mag(v)
  return math.sqrt(v.x*v.x + v.y*v.y)
end

function vec.nor(v)
  local m = vec.mag(v)
  return vec.new(v.x/m, v.y/m)
end

function vec.dst(v1,v2)
  local diff = vec.sub(v2,v1)
  return vec.mag(diff)
end

function vec.dot(v1, v2)
  return v1.x * v2.x + v1.y * v2.y
end

function vec.hat(v)
  return vec.new(v.y, v.x)
end


return vec
