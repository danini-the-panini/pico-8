pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
function filt(t,fn)
  local t2={}
  for k,v in pairs(t) do
    if fn(k,v) then
      t2[k]=v
    end
  end
  return t2
end

function _init()
  clrs={4,10,9,7}
  prts={}
  bgs={1,2,3,4}
  dirs={
    {i=1,j=0},
    {i=0,j=1}
  }
  attempts=0
  startgame()
  board={
    {0,0,0,0,0,0},
    {0,0,0,0,0,0},
    {0,0,1,1,0,0},
    {0,0,0,0,0,0},
    {0,0,0,0,0,0},
    {0,0,0,0,0,0}
  }
  p1=2
  p2=1
  hrz=false
  tutorial=true
end

function startgame()
  ci=1
  cj=1
  chickens=368
  board={
    {0,0,0,0,0,0},
    {0,0,0,0,0,0},
    {0,0,0,0,0,0},
    {0,0,0,0,0,0},
    {0,0,0,0,0,0},
    {0,0,0,0,0,0}
  }
  addpiece()
  game_over=false
end

function gameover()
  sfx(2)
  game_over=true
end

function canplace()
  for i=1,6 do
    for j=1,6 do
      if validate(i,j) then return true end
    end
  end
  return false
end

function addpiece()
  p1=rnd(bgs)
  p2=rnd(bgs)
  hrz=rnd()>0.5
  if canplace() then return true end
  hrz=not hrz
  if canplace() then return true end
  gameover()
  return false
end

function validate(i,j)
  if board[i][j]~=0 then return false end
  if hrz and j<6 then
    return board[i][j+1]==0
  end
  if not hrz and i<6 then
    return board[i+1][j]==0
  end
  return false
end

function droppiece()
  tutorial=false
  board[ci][cj]=p1
  if hrz then
    board[ci][cj+1]=p2
  else
    board[ci+1][cj]=p2
  end
  clearbirds()
  if addpiece() then
    if hrz and cj==6 then cj=5 end
    if not hrz and ci==6 then ci=5 end
  end
end

function clearbirds()
  local toclear={}
  for i=1,6 do
    for j=1,6 do
      local p = board[i][j]
      if board[i][j]~=0 then
        for _,d in ipairs(dirs) do
          local l={}
          for s=0,5 do
            local ni=i+d.i*s
            local nj=j+d.j*s
            if ni<1 or ni>6 or nj<1 or nj>6 then break end
            if board[ni][nj]~=p then break end
            add(l,{ni,nj,p})
          end
          if #l>2 then
            for _,e in ipairs(l) do
              add(toclear,e)
            end
          end
        end
      end
    end
  end
  
  if #toclear<=0 then
    sfx(0)
    return false
  end
  
  for _,b in ipairs(toclear) do
    if board[b[1]][b[2]]~=0 then
      local x=32+b[2]*8
      local y=16+b[1]*8
      for i=1,flr(rnd(5))+5 do
        local prt={
          x=x+4,y=y+4,
          r=rnd(1.0),
          l=flr(rnd(5))+10,
          v=rnd(0.25)+0.75,
          s=flr(rnd(2)),
          c=clrs[b[3]]
        }
        add(prts,prt)
      end
       board[b[1]][b[2]]=0
       chickens-=1
       if chickens<=0then
         chickens=0
       end
     end
  end
  
  if chickens<=0 then
  	 prts={}
    sfx(3)
    return true
  end
  
  sfx(1)
  
  return true
end

function _update()
  prts=filt(prts,function(_,p)
    p.l-=1
    p.x+=p.v*cos(p.r)
    p.y+=p.v*sin(p.r)
    return p.l>0
  end)

  if chickens<=0 then return end

  if game_over then
    if btnp(❎) then
      attempts+=1
      startgame()
    end
  else
    if btnp(⬅️) and cj>1 then
      cj-=1
      sfx(4)
    end
    if btnp(➡️) and ((hrz and cj<5) or (not hrz and cj<6)) then
      cj+=1
      sfx(4)
    end
    if btnp(⬆️) and ci>1 then
      ci-=1
      sfx(4)
    end
    if btnp(⬇️) and ((hrz and ci<6) or (not hrz and ci<5)) then
      ci+=1
      sfx(4)
    end
    if btnp(🅾️) and validate(ci,cj) then
      droppiece()
    end
  end
end

function drawtitle(s)
   print(s, 64-#s*2, 8, 7)
end

function _draw()
  palt(0, false)
  palt(11, true)
  rectfill(0,0,128,128,12)
  if tutorial then
    drawtitle("line up 3 chickens to rescue")
    print("🅾️", 31, 26, 0)
    print("🅾️", 30, 25, 7)
  else
    drawtitle(""..chickens.." chickens remaining")
  end
  rect(40,24,89,73,1)
  for i=1,6 do
    for j=1,6 do
      local x=32+j*8
      local y=16+i*8
      rect(x,y,x+8,y+8,1)
      rectfill(x+1,y+1,x+8,y+8,13)
    end
  end
  for i=1,6 do
    for j=1,6 do
      local x=32+j*8
      local y=16+i*8
      spr(board[i][j],x+1,y+1)
    end
  end
  
  if chickens<=0 then
    rectfill(14,26,113,114,7)
    print("congratulations",20,32,1)
    print("")
    print("you rescued the")
    print("368 chickens")
    print("in "..attempts.." attempts.")
    print("")
    print("the chickens are")
    print("very grateful.")
    print("")
    print("now you have rescued")
    print("all the chickens")
    print("you can no longer play")
    print("the game. sorry")
  elseif game_over then
    print("game over",46,80,7)
    rectfill(36,93,90,103,7)
    rectfill(35,94,91,102,7)
    print("❎ play again",38,96,1)
  else
  local cx=32+cj*8
  local cy=16+ci*8
  rect(cx+1,cy+1,cx+8,cy+8,0)
  rect(cx,cy,cx+7,cy+7,7)
  
  if hrz then
  rect(cx+9,cy+1,cx+16,cy+8,0)
  rect(cx+8,cy,cx+15,cy+7,7)
    spr(p1,56,80)
    spr(p2,64,80)
  else
    rect(cx+1,cy+9,cx+8,cy+16,0)
    rect(cx,cy+8,cx+7,cy+15,7)
    spr(p1,60,80)
    spr(p2,60,88)
  end
  end
  for _,p in ipairs(prts) do
    if p.l>0 then
      circfill(p.x+1,p.y+1,p.s,0)
      circfill(p.x,p.y,p.s,p.c)
    end
  end
end
__gfx__
bbbbbbbbb8bbbbbbbbbaabbbbb9bbbbbb88bbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbba08bbbbbbbaaaabbb999bbbba07bbbb70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbb44bbbb4ba0aa0ab90909bb9b87bbb7b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbb4444444baaaffaaa89498999b77777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbb44fff44baaaaaaaa999999897777777b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbb444fff4bee66aaab9999989bb77777bb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbb44444bbbaaaaaabb99999bbbbba9bbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbb9b9bbbbbabbabbbb4b4bbbbbaa9bbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccc777c7ccc777cccccc77c7c7c777cc77c7c7c777c77ccc77ccccc777c777c777c777c777c77cc777c77ccc77ccccccccccccccccccccc
cccccccccccccccccccccc7c7ccc7c7ccccc7ccc7c7cc7cc7ccc7c7c7ccc7c7c7ccccccc7c7c7ccc777c7c7cc7cc7c7cc7cc7c7c7ccccccccccccccccccccccc
ccccccccccccccccccccc77c777c777ccccc7ccc777cc7cc7ccc77cc77cc7c7c777ccccc77cc77cc7c7c777cc7cc7c7cc7cc7c7c7ccccccccccccccccccccccc
cccccccccccccccccccccc7c7c7c7c7ccccc7ccc7c7cc7cc7ccc7c7c7ccc7c7ccc7ccccc7c7c7ccc7c7c7c7cc7cc7c7cc7cc7c7c7c7ccccccccccccccccccccc
cccccccccccccccccccc777c777c777cccccc77c7c7c777cc77c7c7c777c7c7c77cccccc7c7c777c7c7c7c7c777c7c7c777c7c7c777ccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc11111111111111111111111111111111111111111111111111cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1dddddddd1cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1dddddddd1cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1dddddddd1cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1dddddddd1cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1dddddddd1cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1dddddddd1cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1dddddddd1cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc11111111777777777777777711111111111111111111111111cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc1ddddddd70000007700000070ddddddd1ddddddd1dddddddd1cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc1ddddddd70ddddd770ddddd70ddddddd1ddddddd1dddddddd1cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc1ddddddd70ddddd770ddddd70ddddddd1ddddddd1dddddddd1cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc1ddddddd70ddddd770ddddd70ddddddd1ddddddd1dddddddd1cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc1ddddddd70ddddd770ddddd70ddddddd1ddddddd1dddddddd1cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc1ddddddd70ddddd770ddddd70ddddddd1ddddddd1dddddddd1cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc1ddddddd77777777777777770ddddddd1ddddddd1dddddddd1cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc11111111100000000000000001111111111111111111111111cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1dddddddd1cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1dddddddd1cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1dddddddd1cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1dddddddd1cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1dddddddd1cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1dddddddd1cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1dddddddd1cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc11111111111111111111111111111111111111111111111111cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1dddddddd1cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1dddddddd1cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1dddddddd1cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1dddddddd1cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1dddddddd1cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1dddddddd1cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1dddddddd1cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc11111111111111111111111111111111111111111111111111cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1dddddddd1cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1dddddddd1cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1dddddddd1cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1dddddddd1cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1dddddddd1cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1dddddddd1cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1dddddddd1cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc11111111111111111111111111111111111111111111111111cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1dddddddd1cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1dddddddd1cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1dddddddd1cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1dddddddd1cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1dddddddd1cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1dddddddd1cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1dddddddd1cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1dddddddd1cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc11111111111111111111111111111111111111111111111111cccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc9ccccccc9ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc999ccccc999cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccc90909cc990909cc9cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccc8949899989498999cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccc9999998999999989cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccc9999989c9999989ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc99999ccc99999cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc4c4ccccc4c4ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

__sfx__
00010000092500925009250092500925009250092500a2500a3000c3000e300103001130013300153001830000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002465024650246502465024650246502465024650246502465024650246502365022650206501e6501965017650126500f6500b6500764005640036400264001640016400063000630006200061000600
000300003f5503f5503f5503e5503d5503c550395503755034550305502b550245501c5501855015550125500f5500c5500a55008550065500455002550015500055000540005300051000500005000150000500
000200000a7500b7500c7500e750107501175011750137501475015750157501675017750197501a7501b7501d7501f75021750237502575027750287502a7502c7502f7503275034750377503a7503d7503f750
000100001915019150171501515013150101500e150061500015014100111000e1000a10009100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
