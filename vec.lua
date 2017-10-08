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
