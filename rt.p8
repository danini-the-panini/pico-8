pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
inf=32767.999
pi=3.1415926535897932385

function d2r(d) return d*pi/180 end
function rand(a,b) return a+rnd(b-a) end
function clamp(x,a,b)
  if(x<a) return a
  if(x>b) return b
  return x
end

vec3={
  __add=function(a,b)
    return vec3(a.x+b.x,a.y+b.y,a.z+b.z)
  end,
  __sub=function(a,b)
    return vec3(a.x-b.x,a.y-b.y,a.z-b.z)
  end,
  __mul=function(a,b)
    return vec3(a.x*b.x,a.y*b.y,a.z*b.z)
  end,
  __div=function(v,t)
    return vec3(v.x/t,v.y/t,v.z/t)
  end,
  __unm=function(a)
    return vec3(-a.x,-a.y,-a.z)
  end,
  __tostring=function(v)
    return "("..v.x..","..v.y..","..v.z..")"
  end
}
vec3.__index=vec3
function vec3:add(v)
  self.x+=v.x
  self.y+=v.y
  self.z+=v.z
  return self
end
function vec3:sub(v)
  self.x-=v.x
  self.y-=v.y
  self.z-=v.z
  return self
end
function vec3:mul(v)
  self.x*=v.x
  self.y*=v.y
  self.z*=v.z
  return self
end
function vec3:div(t)
  self.x/=t
  self.y/=t
  self.z/=t
  return self
end
function vec3:scale(t)
  self.x*=t
  self.y*=t
  self.z*=t
  return self
end
function vec3:muls(t)
  return vec3(self.x*t,self.y*t,self.z*t)
end
function vec3:divs(t)
  return vec3(self.x/t,self.y/t,self.z/t)
end
function vec3:len()
  return sqrt(self:lensq())
end
function vec3:lensq()
  return self.x*self.x+self.y*self.y+self.z*self.z
end
function vec3:dot(v)
  return self.x*v.x+self.y*v.y+self.z*v.z
end
function vec3:cross(v)
  return vec3(
    self.y*v.z-self.z*v.y,
    self.z*v.x-self.x*v.z,
    self.x*v.y-self.y*v.x
  )
end
function vec3:unit()
  return self/self:len()
end
function vec3:clamp(a,b)
  self.x=clamp(self.x,a,b)
  self.y=clamp(self.y,a,b)
  self.z=clamp(self.z,a,b)
  return self
end
nzero=0.0002
function vec3:zero()
  return abs(self.x)<nzero and
    abs(self.y)<nzero and
    abs(self.z)<nzero
end
function vec3:refl(n)
  return self-n:muls(2*self:dot(n))
end

function vrand(a,b)
  return vec3(rand(a,b),rand(a,b),rand(a,b))
end
function vrands()
  local p
  repeat
    p=vrand(-1,1)
  until p:lensq()<1
  return p
end
function vrandu()
  return vrands():unit()
end

function vec3.new(x,y,z)
 return setmetatable({x=x,y=y,z=z}, vec3)
end
setmetatable(vec3,{__call=function(_,...) return vec3.new(...) end})

ray={
  __tostring=function(r)
    return r.orig.."->"..r.dir
  end
}
ray.__index=ray
function ray:at(t)
  return self.orig + self.dir:muls(t)
end

function ray.new(orig,dir)
  return setmetatable({orig=orig,dir=dir},ray)
end
setmetatable(ray,{__call=function(_,...) return ray.new(...) end})
-->8
cam={}
cam.__index=cam
function cam:ray(u,v)
  return ray(self.o,self.c+self.hrz:muls(u)+self.vrt:muls(v)-self.o)
end
function cam.new()
  w=2
  h=2
  f=1
  o=vec3(0,0,0)
  hrz=vec3(w,0,0)
  vrt=vec3(0,h,0)
  c=o-hrz:divs(2)-vrt:divs(2)-vec3(0,0,f)
  return setmetatable({
    o=o,hrz=hrz,vrt=vrt,c=c
  },cam)
end
setmetatable(cam,{__call=function(_,...) return cam.new(...) end})

lamb={}
lamb.__index=lamb
function lamb:scat(r,rec)
  local sdir=rec.n+vrandu()
  if sdir:zero() then
    sdir=rec.n
  end
  return {r=ray(rec.p,sdir),a=self.a}
end
function lamb.new(a)
  return setmetatable({a=a},lamb)
end
setmetatable(lamb,{__call=function(_,...) return lamb.new(...) end})

metal={}
metal.__index=metal
function metal:scat(r,rec)
  local ref=r.dir:unit():refl(rec.n)
  local sr=ray(rec.p,ref+vrands():muls(self.f))
  if sr.dir:dot(rec.n) > 0 then
    return {r=sr,a=self.a}
  end
  return nil
end
function metal.new(a,f)
  return setmetatable({a=a,f=f},metal)
end
setmetatable(metal,{__call=function(_,...) return metal.new(...) end})

function facenorm(rec,r,n)
  rec.f=r.dir:dot(n)<0
  if rec.f then
    rec.n=n
  else
    rec.n=-n
  end
end

sphere={}
sphere.__index=sphere
function sphere:hit(r,tmin,tmax)
  local oc=r.orig-self.c
  local a=r.dir:lensq()
  local hb=oc:dot(r.dir)
  local c=oc:lensq()-self.r*self.r

  local disc=hb*hb-a*c
  if (disc<0) return nil
  local sqrtd=sqrt(disc)
  
  local root = (-hb-sqrtd)/a
  if root<tmin or tmax<root then
    root=(-hb+sqrtd)/a
    if (root<tmin or tmax<root) return nil
  end
  
  local rec={}
  rec.t=root
  rec.p=r:at(rec.t)
  n=(rec.p-self.c)/self.r
  facenorm(rec,r,n)
  rec.m=self.m
  return rec
end
function sphere.new(c,r,m)
  return setmetatable({c=c,r=r,m=m},sphere)
end
setmetatable(sphere,{__call=function(_,...) return sphere.new(...) end})

hlist={}
hlist.__index=hlist
function hlist:add(o)
  add(self.objs,o)
end
function hlist:hit(r,tmin,tmax)
  local rec=nil
  local tbest=tmax
  for o in all(self.objs) do
    local trec=o:hit(r,tmin,tbest)
    if trec then
      rec=trec
      tbest=trec.t
    end
  end
  return rec
end
function hlist.new()
  return setmetatable({objs={}},hlist)
end
setmetatable(hlist,{__call=function(_,...) return hlist.new(...) end})

function ray_color(r,w,d)
  if (d<=0) return vec3(0,0,0)
  local rec=w:hit(r,0.001,inf)
  if rec then
    local s=rec.m:scat(r,rec)
    if s then
      return s.a*ray_color(s.r,world,d-1)
    end
    return vec3(0,0,0)
  end
  local u=r.dir:unit()
  local t=0.5*(u.y+1)
  return vec3(1,1,1):scale(1-t)+vec3(0.5,0.7,1.0):scale(t)
end
-->8
colors={
  [0]=vec3(0, 0, 0),
  vec3(0.1137254902, 0.168627451, 0.3254901961),
  vec3(0.4941176471, 0.1450980392, 0.3254901961),
  vec3(0, 0.5294117647, 0.3176470588),
  vec3(0.6705882353, 0.3215686275, 0.2117647059),
  vec3(0.3725490196, 0.3411764706, 0.3098039216),
  vec3(0.7607843137, 0.7647058824, 0.7803921569),
  vec3(1, 0.9450980392, 0.9098039216),
  vec3(1, 0, 0.3019607843),
  vec3(1, 0.6392156863, 0),
  vec3(1, 0.9254901961, 0.1529411765),
  vec3(0, 0.8941176471, 0.2117647059),
  vec3(0.1607843137, 0.6784313725, 1),
  vec3(0.5137254902, 0.462745098, 0.6117647059),
  vec3(1, 0.4666666667, 0.6588235294),
  vec3(1, 0.8, 0.6666666667)
}

dmap={
  {-0.4375, 0.0625, -0.3125, 0.1875},
  {0.3125, -0.1875, 0.4375, -0.0625},
  {-0.25, 0.25, -0.375, 0.125},
  {0.5, 0, 0.375, -0.125},
  {-0.4375, -0.4375, -0.4375, -0.4375}
}

spread=1/3
function dither(c, x, y)
  local d=spread*dmap[x%4+1][y%4+1]
  return vec3(c.x+d,c.y+d,c.z+d)
end

function find_color(rgb)
  local best=0
  local best_score=inf
  for i=0,15,1 do
    local s=(rgb-colors[i]):lensq()
    if s < best_score then
      best=i
      best_score=s
    end
  end
  return best
end

function pset_dith(x,y,rgb)
  local c=find_color(dither(rgb, x, y))
  pset(x,y,c)
end

-->8
world=hlist()
wcam=cam()
spp=4
dmax=50

function _init()
  mat_gnd=lamb(vec3(0.8,0.8,0))
  mat_c=lamb(vec3(0.7,0.3,0.3))
  mat_l=metal(vec3(0.8,0.8,0.8),0.3)
  mat_r=metal(vec3(0.8,0.6,0.2),1.0)
  
  world:add(sphere(vec3(0,-100.5,-1),100,mat_gnd))
  world:add(sphere(vec3(0,0,-1),0.5,mat_c))
  world:add(sphere(vec3(-1,0,-1),0.5,mat_l))
  world:add(sphere(vec3(1,0,-1),0.5,mat_r))
end

function psetm(x,y,c)
  c:div(spp)
  c=vec3(
    sqrt(c.x),
    sqrt(c.y),
    sqrt(c.z)
  )
  c:clamp(0,1)
  pset_dith(x, y, c)
end

cleared=false
raytracing=false
ry=0
function _draw()
  if not cleared then
    cls(0)
    cleared=true
    raytracing=true
  end
  if (not raytracing) return
  if ry<128 then
    local y=127-ry
    for x=0,127,1 do
      local c=vec3(0,0,0)
      for s=1,spp,1 do
	       local u=(x+rnd(1))/127
        local v=(y+rnd(1))/127
	       local r=wcam:ray(u,v)
	       c:add(ray_color(r,world,dmax))
	     end
	     psetm(x,ry,c)
    end
    ry+=1
  else
    raytracing=false
  end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
