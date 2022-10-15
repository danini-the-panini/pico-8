pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
-- sprites
headh=0
oheadh=1
headv=32
oheadv=33
bodyh=2
bodyv=3
tailh=34
tailv=35
bend=4
bendf=5
bodyf=36
egg=37

--directions
up=1
right=2
down=3
left=4

intro=true
game_over=false
score=0
snake={}
curdir=right
nextdir=nil
level=1
snake_step=0
max_snake_step=5
cur_egg=nil

function peq(a,b)
  return a[1]==b[1] and a[2]==b[2]
end

function _init()
end

function start_game()
  score=0
  snake_step=max_snake_step
  nextdir=nil
  snake={
    {9,14,false},
    {10,14,false},
    {11,14,false},
    {12,14,false},
    {13,14,false},
    {14,14,false},
    {15,14,false}
  }
  spawn_egg()
end

function do_game_over()
  sfx(1)
  game_over=true
end

function next_snake_pt()
  local h=snake[#snake]
  local nh={h[1],h[2]}
  if curdir==up then
    nh[2]-=1
  elseif curdir==down then
    nh[2]+=1
  elseif curdir==left then
    nh[1]-=1
  elseif curdir==right then
    nh[1]+=1
  end
  nh[1]%=30
  nh[2]%=28
  return nh
end

function move_snake()
  local nh=next_snake_pt()
  if on_snake(nh) then
    do_game_over()
    return
  end
  if peq(nh,cur_egg) then
    sfx(0)
    score+=5
    spawn_egg()
    add(snake,{nh[1],nh[2],true})
  else
    add(snake,{nh[1],nh[2],false})
    del(snake,snake[1])
  end
end

function update_snake()
  if snake_step<=0 then
    snake_step=max_snake_step
    if (nextdir) curdir=nextdir
    nextdir=nil
    move_snake()
  else
    snake_step-=1
  end
end

function direct_snake()
  if (nextdir) return
  if curdir==up or curdir==down then
    if btnp(0) then
      nextdir=left
    end
    if btnp(1) then
      nextdir=right
    end
  end
  if curdir==left or curdir==right then
    if btnp(2) then
      nextdir=up
    end
    if btnp(3) then
      nextdir=down
    end
  end
end

function gen_egg_spot()
  return {flr(rnd(30)),flr(rnd(28))}
end

function on_snake(xy)
  for s in all(snake) do
    if peq(s,xy) then
      return true
    end
  end
  return false
end

function find_egg_spot()
  local xy
  repeat
    xy=gen_egg_spot()
  until not on_snake(xy)
  return xy
end

function spawn_egg()
  cur_egg=find_egg_spot()
end

function _update()
  if intro then
    if btnp(5) then
      intro=false
      start_game()
    end
  elseif not game_over then
    update_snake()
    direct_snake()
  else
    if btnp(4) or btnp(5) then
      game_over=false
      intro=true
    end
  end
end

function spr4(n, x, y, fx, fy)
  sspr(
    (n%32)*4,flr(n/32)*4,
    4,4,
    x,y,
    4,4,
    fx,fy
  )
end

function calc_dir(dx,dy)
  if (dx==-1) return left
  if (dx==1) return right
  if (dy==-1) return up
  if (dy==1) return down
  if (dx<-1) return right
  if (dx>1) return left
  if (dy<-1) return down
  if (dy>1) return up
end

function snspr(n,x,y,fx,fy)
  spr4(n,4+x*4,12+y*4,fx,fy)
end

function draw_tail(x,y,dirn)
  if dirn==up then
    snspr(tailv,x,y,false,true)
  elseif dirn==down then
    snspr(tailv,x,y,false,false)
  elseif dirn==left then
    snspr(tailh,x,y,true,false)
  elseif dirn==right then
    snspr(tailh,x,y,false,false)
  end
end

function draw_head(x,y,dirp)
  local sn=0
  local fx=false
  local fy=false
  if dirp==up then
    sn=headv
  elseif dirp==down then
    sn=headv
    fy=true
  elseif dirp==left then
    sn=headh
  elseif dirp==right then
    sn=headh
    fx=true
  end
  if cur_egg and peq(next_snake_pt(),cur_egg) then
    if (sn==headh) sn=oheadh
    if (sn==headv) sn=oheadv
  end
  snspr(sn,x,y,fx,fy)
end

function draw_body(x,y,full,dirp,dirn)
  local fx=false
  local fy=false
  if dirp==up then
    if dirn==down then
      sn=bodyv
    elseif dirn==left then
      sn=bend
      fx=true
      fy=true
    elseif dirn==right then
      sn=bend
      fy=true
    end
  elseif dirp==down then
    if dirn==up then
      sn=bodyv
      fy=true
    elseif dirn==left then
      sn=bend
      fx=true
    elseif dirn==right then
      sn=bend
    end
  elseif dirp==left then
    if dirn==up then
      sn=bend
      fx=true
      fy=true
    elseif dirn==down then
      sn=bend
      fx=true
    elseif dirn==right then
      sn=bodyh
    end
  elseif dirp==right then
    if dirn==up then
      sn=bend
      fy=true
    elseif dirn==down then
      sn=bend
    elseif dirn==left then
      sn=bodyh
      fx=true
    end
  end
  if full then
    if sn==bend then
      sn=bendf
    else
      sn=bodyf
    end
  end    
  snspr(sn,x,y,fx,fy)
end

function draw_snake()
  for i=1,#snake,1 do
    local sx=snake[i][1]
    local sy=snake[i][2]
    local full=snake[i][3]
    local dirp=0
    local dirn=0
    if i>1 then
      dirp=calc_dir(
        snake[i-1][1]-sx,
        snake[i-1][2]-sy
      )
    end
    if i<#snake then
      dirn=calc_dir(
        snake[i+1][1]-sx,
        snake[i+1][2]-sy
      )
    end
    if i==1 then
      draw_tail(sx,sy,dirn)
    elseif i==#snake then
      draw_head(sx,sy,dirp)
    else
      draw_body(sx,sy,full,dirp,dirn)
    end
  end
end

function draw_egg()
  local x=cur_egg[1]
  local y=cur_egg[2]
  spr4(egg,4+x*4,12+y*4,false,false)
end

function _draw()
  cls(11)
  if intro then
    spr(64, 0, 16, 16, 8)
    print("press ❎ to play", 32, 96, 3)
  else
    print(score, 2, 3, 3)
    rect(2, 10, 125, 125, 3)
    draw_snake()
    draw_egg()
    if game_over then
      print("game over", 90, 3, 3)
    end
  end
end
__gfx__
3bbb3b3bbbbbb33bbbbbbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b33bb3bb33b3b3bbbb33bb3300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
333b33bb3b33bb3bb3b3b3b300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbb3bbbbbb33bb33bb33300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b3b3b3b3bbbbbb3bb33bb3bb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b33bb33bbb33bb3b33b33b3b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b33b3bb33333b33b3b33b3bb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbb33bb33bbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbb33bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33bbbbbbbbbbbbbbbbbbbbb333bbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbb3333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbbb333bbbbbbbbbbbbbbbb3333bbbbbbbbbbbbbb333333bb33bbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbb333333bbbbbbbbbbbbbbbbbbb3333bbbbbbb3333bbbbbbb3333bbbbbbbb3bbbbb333333bbbbbbbbbb33333bbbbbbb33bbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbb3333333bbbbbbbb333bbbbbb333333bbbbb3333333bbbb333333bbbbbbb333bbb33333333bbbbb33333bbbbbbbbbbb33bbbbbbbbbbbb
bbbbbbbbbbbbbbbbbb3333333333bbb3333333bbbbbb333333bbbb33333333bbb3333333bbbbbb333333b33333333333333bbbbbbbbbbbbbbb33bbbbbbbbbbbb
bbbbbbbbbbbbbbbbb33333333333bbb3333333bbbbbb333333bbbb33333333bbb3333333bbbbbb3333333b33333333bbbbbbbbbbbbbbbbb33333bbbbbbbbbbbb
bbbbbbbbbbbbbbbb333333333333bbb33333333bbbb3333333bbb333333333bbbb3333333bbbb3333333b3333bb3bbbbbbbbbbbb33bbbb33333bbbbbbbbbbbbb
bbbbbbbbbbbbbbb333333333333bbbb33333333bbbb333333bbbb333333333bbbb3333333bbb333333bb3333bbb3bbbbbbbbb33333bbbb33bbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbb333333333bbbbbbb333333333bbb333333bbb33333333333bbbbbb3333bb333333b3333bbbbb33bbbbbbbb33333bbbb33bbbbbbbbbbbbbbbb
bbbbbbbbbbbbbb333333333bbbbbbb3333333333bbb333333bbb33333bb3333bbbb3b3333b333333b33333bbbbbb333333bbb33bb3bbbb33bbbbbbbbbbbbbbbb
bbbbbbbbbbbbbb3333333bbbbbbbbb3333333333bbb333333bbb3333bbb3333bb333b33333333333b33333bbbbbbb33333bbb33bb3bbbb33bbbbbbbbbbbbbbbb
bbbbbbbbbbbbb3333333bbbbbbbbbb33333333333bb333333bb33333bbb3333333333bb33333333bb33333bbb3bbbbbbb3bbb33bb3bbbb33bbbbbbbbbbbbbbbb
bbbbbbbbbbbbb33333bbbbbbbbbbbbb33333b3333bb333333bb33333bbbb333333333bb3333333bbb33333b3333bbbbbb3bbb33bb3bbbb33bbbbbbbbbbbbbbbb
bbbbbbbbbbbb33333bbbbbbb333333bbb333b33333b333333b33333bbbbb333333333bb333333bbbbb333333333bbbbbb3bbb33bb3bbbb33bbbbbbbbbbbbbbbb
bbbbbbbbbbbb33333bbb33333333333bb333bb3333b333333b33333bbbb33333333bbbb333333bbbbb3333333bbbbbbbb3bbb33bb3bbbb33bbbbbbbbbbbbbbbb
bbbbbbbbbbbb3333333333333333333bb333bb33333333333b33333b333333333bbb3333333333bbbb333333bbbbbbbbb3bbb33bb3bbbb33333bbbbbbbbbbbbb
bbbbbbbbbbbb3333333333333333333bb333bbb3333333333b333333333333333bbb33333333333bbbbb3333bb333bbbb3bbb33bb3bbbb33bb33bbbbbbbbbbbb
bbbbbbbbbbbbb3333333bbbbb333333bb333bbbb33333333b33333333333333333bb333333333333bbbb3333b3333bbbb3bbb3333bbbbbbbbb33bbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbb3333333bb333bbbb33333333b33333333bbbb33333bb333333b333333bbb333333333bbbb3bbb33bbbbbbbbbbb33bbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbb3333333b33333bbbbb3333333b33333bbbbbbb33333bb333333bb33333bbbb3333333bb3333bbbbbbbbbbbbb33333bbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbb33333333b33333bbbbb333bbbbb33333bbbbbbbb3bbbbbb33333bbb333bbbbb33333bb33bbbbbbbbbbbbb33333333bbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbb333333333b333333bbbbbbbbbbb3333333bbbbbbbbbb3333b33333bbbb3bbbbbb3333bbb3bbbbbbbbbbb33333333bbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbb33333333333b33333bbbbbbbbbbbbb333333bbbbbbbbb333bb3bbbbb3bbbbbbbbbbbb3bbbbb3bbbbbbbb3333333bbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbb3333333333333bb33bbbbbbbbbbbbbbbbbbb3bbbbbbbbbb33bbbb33333bbbbbbbbbbbbbbbbbbbb33bbbb3333333bbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbb333333333333bbbbbbbbbbbbbbbbbbbbbbbbbb3333b33333bb333bbbb333333bbbbbbbbbbbbbbbb333333333bbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbb3333333333bbbbbbbbbbbbbbbbbbbbbbbbbbb33bbb333bbbb33bbbbbbbbbbb33bbbbbbbbbbbbbbbb33333bbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbb33333333bbbbbbbbbbbbbbbbbbbbbbbbbbbbb3b33bbbb3bb333bbbbbbbbbbbb3bbbbbbbbbbbbbbbbb33bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbb33333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33b33bbbbb3b33b3bbbbbbbbbb33bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbb33bbbbbbbbbbbbbbbbbbbbb3333333333333b3b33b33b3bbbb3bbb33333bbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3333b3b3b33b3b3b333bbb333bb33bbbb333b3bbbbb33bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333b3b3b3b3bb3b3333bbbbbbbbbbbbbbbbbbbb33bbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbb33333b3b3b3b3b3b33333bbbbbbbbbbbbbbbbbbbbbbbb3bbbb33bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbb3333b3bb3b3b3b3b3b3333333333333333bbbbbbbbbbb333333333333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbb33b3b3b33b3b3b3b3333333bbbbbbbbbbbb3bbb333333333bbb3b3b3b33333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbb33b3b3b3bb3b333333bbbbb33bbbbbbbbbbbbb333bb3bbbbbbbb33b3b3b33b33bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbb33b3b3b3b33333bbbbbbbbbbb333bbbbbbbbb33b3bb33bbbbbbb33b3b3b3bb3b33bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbb3b333333333bb333bbbbbbbbbb3b3333333333bb3b33bbbbbbb333333b3b333333333333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbb333b3b33333b33b3bbbbbbbbbb3bb3b33bbbbb3b333bbbbbbb33bbbbb33333bbbbbbbbb3333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbb333b333b3b3333b33bbbbbbbbbbb3b3b33bbbbbb333bbbbbb333bbbb333bbbbbbbbbbbbbbb3333bbbb333bbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbb33b3bbb333bb3b33bbbbbbbbbbbbb33b33bbbbbb33bbbbbb333bbb333bbbbbbbbbbbbbbbbbbbb3bb33bbb3bbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbb3333b3b3bbb3333b3b33bbbbbbbbbbbbbb333bbbbb33bbbbbb333bbb33bbbbbbbbb33333333bbbbbb333bbbbb3bbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbb33333b3b3b3b333333333333bbbbbbbbbbb33b3bbbb33bbbbbb33bbbb33bbbbbb3333333b3b333bbbbb33b33bbbb33bbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbb33b33b3b3b3b333333b3b3333333333333b3bbb3bb333bbbbbb33bbbb33bbbbb333bbb33b3b33b3bbbbbb3bb33bbbbb3bbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbb33b3bb33333b3b3b3bb3b333b3b3b3bb3b3bbbb3bb333bbbbbb33bbbb33bbbbb33b3333b33b3b3b33bbbbb333333bbbbb3bbbbbbbbbbbbbbbb
bbbbbbbbbbbbbb3b3b3333b333b3b3b33b3b3b3b3b3b33b33bbbbbb33bbbbbbb33bbb333bbbbb33b33bbbb3b3b333b3bbbbb3bb3333bbbb3bbbbbbbbbbbbbbbb
bbbbbbbbbbbbbb33b333333b3b3b3b3bb3b3b3b3b3b3bb333bbbbb33bbbbbbb33bbbb33bbbbb33b3bbbb3333b3b333333b3b33bbbb3bbbbb33bbbbbbbbbbbbbb
bbbbbbbbbbbbbb3b3b33b3b3b3b3b3b33b3b3b3b3b3b3333bbbbb33bbbbbbb33bbbb333bbbb33b33b333333b3b33333bb3bb33333b33bbbb3b3bbbbbbbbbbbbb
bbbbbbbbbbbbbb33b3bb333b3b3b3333333333b3333333b3bbbb33bbbbbbb33bbbbb3bbbbb33bb3bbb333333333333b33b333333bb33bbbb3b3bbbbbbbbbbbbb
bbbbbbbbbbbbbb3b3b33b3333333333bbb3bb333bbb3bbb3bbb33bbbbbbb33bbbbbb3bbbbb3bbb33b3bbbbb3333333333333bbbbb333bbbbb3bbbbbbbbbbbbbb
bbbbbbbbbbbbbbb333bb3b333333333bbb3bb3bbbbb3bb3bbb33bbbbbbb33bb3333b3bbbbb33bbb33b33bbbbbbbbbbbbbbbbbb3b3b3333bbb3bbbbbbbbbbbbbb
bbbbbbbbbbbbbbbb3333b3b3333333333b3b3b3333b333bbbb3bbbbbb333bb33333b3bbbbbb33bb3b3bb3bbbbbbbbbbbbbbb33b3b33333bbb33bbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbb333b3b3333333bb3bbbbb3bbbbb3b33bbbbb333bb333333b333bbbbb33bb3b3333333bbbbbbbbb33333b333333bbbb3bbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbb333b3b33333333bbb33b333333bb3bbbbb33bbb3333333bb333bbbbb33bb3bb3bbb33333333333bb3b3b333333bbb3bbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbb33bbb33b3b333333b3b3b3b333333b33bbbbb3bbb333333333bbb33bbbbb33bb33bbbbbbbbbbbbbbbb3b3b3333333bbb3bbbbbbbbbbbbb
bbbbbbbbbbbbbbb3333333bb33b3b33bbbb33bb3bb33333b3bbbbb33bbb3333333333bbb33bbbbb33bbb3bbbbbbbbbbbbbb3b3b3b333333bbb3bbbbbbbbbbbbb
bbbbbbbbbbbbb3333333333bb33b3b333b3333333b33333b3bbbbb33bbbb33333333333bb33bb3bb33bbb3bbbbbbbbbbbbbbb33b3333333bbb3bbbbbbbbbbbbb
bbbbbbbbbbbb333333333333bb33b3b333333b3b3b33333b3bbbbb33333bbb3333333333bb33b3bbb3bbbb3333bbbbbbb33333b33bb3333bbb3bbbbbbbbbbbbb
bbbbbbbbbbbb3333333333333bb33b3bb33333b33b33333b3bbbbb3bb3333bbbbbb33333bbb33bbbb333b3bbb333333333bb3b3b33bb333bbb3bbbbbbbbbbbbb
bbbbbbbbbbbb33333333333333bb33b33b333333bb33333b33bbbbbbbbbb333333bbbbbbb333bbbbbb33bb3bbbbbbbbbbb3bb3b33b3bbb3bb3bbbbbbbbbbbbbb
bbbbbbbbbbbb333333333333333bb3333b33333bb333333bb33bbbbbbbbbbbbbb333333333bbbbbbbb33b3bbbbbbbbbbbbbb3b33bbb333333bb3bbbbbbbbbbbb
bbbbbbbbbbbbb333333333333333bbbbbbb33bbb33333333bb33bbbbbbbbbbbbbbbbbbbbbbbbbbbbb333b33333bbbbbbb33333bbbbbbbbbbbb33bbbbbbbbbbbb
bbbbbbbbbbbbbbb3333333333333333333b333bb333333333bb3333bbbbbbbbbbbbbbbbbbbbbbbbb33bbbbbbb333333333bbbbb333333333333bbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbb3333333333333333b3333bb333333333bbbb333333bbbbbbbbbbbbbbbbb3333bbb3333bbbbbbbbbbb3333333333333bbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbb333333333333b3bb3b333333333333bbbbbb3333333333333333333bbbb3333333333333333333333333bbbbbbbbbbbbbbbbbbbbb
__sfx__
000100003e0703e050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000d2500d2501b2501b2500d2500d2501b2501b2501b2001b2000d2000d2001b2000d2001b2000d2001b2000d2001b2000d20000200002001d200002000020000200002000020000200002000020000200
