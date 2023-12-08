pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
board={}
pregame=true
mines=0
started_at=0
ci=1
cj=1
gameover=false

maxmines=50
nds={
 {-1,-1},{-1,0},{-1,1},
 { 0,-1},       { 0,1},
 { 1,-1},{ 1,0},{ 1,1}
}
function nbrs(i, j)
		ns={}
		for nd in all(nds) do
		  i2=i+nd[1]
		  j2=j+nd[2]
		  if i2>0 and i2<=14 	and j2>0 and j2<=16 then
		    add(ns, {i2, j2, board[i2][j2]})
		  end
		end
		return ns
end

function isnbr(i,j,i2,j2)
  return (i2==i or i2==i-1 or i2==i+1) and
    (j2==j or j2==j-1 or j2==j+1)
end

function count(ns)
  c=0
  for n in all(ns) do
    if n[3][2] then
      c=c+1
    end
  end
  return c
end

function shuffle(t)
  for i=#t,2,-1 do
    j=flr(rnd(i))
    t[i],t[j]=t[j],t[i]
  end
end

function emptyboard()
  board={}
  for i=1, 14 do
		  row={}
		  for j=1, 16 do
		    add(row,{0, false, 0})
		  end
		  add(board, row)
		end
end

function buildboard()
  board={}
  ixs={}
		for i=1, 14 do
		  row={}
		  for j=1, 16 do
		    add(row,{0, false, 0})
		    if not isnbr(i,j,ci,cj) then
						  add(ixs,{i,j})
						end
		  end
		  add(board, row)
		end
		shuffle(ixs)
		for i=1,maxmines do
				ix=deli(ixs)
				board[ix[1]][ix[2]][2]=true
		end
		for i=1, 14 do
	   for j=1, 16 do
	     ns=nbrs(i,j)
	     board[i][j][3]=count(ns)
	   end
	 end
end

function reset()
  gameover=false
  started_at=time()
  pregame=true
  mines=maxmines
  ci=1
  cj=1
  emptyboard()
end

function endgame()
  gameover=true
  gametime=flr(time()-started_at)
  for row in all(board) do
    for b in all(row) do
      if b[2] then
        b[1] = 1
      end
    end
  end
end

function uncover_nbrs(i,j)
  b=board[i][j]
  if b[1]!=0 then
    return
  end
  if b[2] then
    endgame()
    return
  end
  b[1]=1
  if b[3]==0 then
    for n in all(nbrs(i,j)) do
      uncover_nbrs(n[1],n[2])
    end
  end
end

function uncover()
  if pregame then
    buildboard()
    pregame=false
  end
  if gameover then
    return
  end
  if board[ci][cj][1]!=0 then
    return
  end
  if board[ci][cj][2] then
    endgame()
  else
    uncover_nbrs(ci,cj)
  end
end

function bulk_uncover()
  if board[ci][cj][1]!=1 then
    return
  end
  f=0
  ns=nbrs(ci,cj)
  for n in all(ns) do
    if n[3][1]==2 then
      f=f+1
    end
  end
  if f==board[ci][cj][3] then
    for n in all(ns) do
      if n[3][1]==0 then
        uncover_nbrs(n[1],n[2])
      end
    end
  end
end

function mark()
  b=board[ci][cj]
  if b[1]==0 then
    mines=mines-1
    b[1]=2
  elseif b[1]==2 then
    mines=mines+1
    b[1]=3
  elseif b[1]==3 then
    b[1]=0
  end
end

function _init()
	 reset()
end

function checkwon()
  ended=true
  for row in all(board) do
    for b in all(row) do
      if not b[2] and b[1]!=1 then
        ended=false
      end
    end
  end
  if ended then
    gamewon=true
		  gametime=flr(time()-started_at)
  end
end

function _update()
  if gameover or gamewon then
    if btnp(🅾️) or btnp(❎) then
      reset()
    end
  else
		  if btnp(⬅️) and cj>1 then
		    cj=cj-1
		  end
		  if btnp(➡️) and cj<16 then
		    cj=cj+1
		  end
		  if btnp(⬆️) and ci>1 then
		    ci=ci-1
		  end
		  if btnp(⬇️) and ci<14 then
		    ci=ci+1
		  end
		  if btnp(🅾️) and btnp(❎) then
		    bulk_uncover()
		  elseif btnp(🅾️) then
		    uncover()
		  elseif btnp(❎) then
		    mark()
		  end
		  checkwon()
		end
end

function drawbox(x,y)
 	line(x,y,x+13,y,5)
 	line(x,y,x,y+7,5)
 	line(x,y+8,x+13,y+8,7)
  line(x+14,y,x+14,y+8,7)
 	rectfill(x+1,y+1,x+13,y+7,0)
end

function drawnum(n,x,y,c)
 	if n<10 then
 	  print("00",x,y,c)
 	  print(n,x+8,y,c)
  elseif n<100 then
 	  print("0",x,y,c)
 	  print(n,x+4,y,c)
 	else
 	  print(n,x,y,c)
 	end
end

function _draw()
		rectfill(0, 0, 128, 128, 5)
 	rectfill(0, 0, 128, 16, 6)
 	line(0, 15, 128, 15, 5)
 	line(127, 0, 127, 16, 5)
 	line(0, 0, 128, 0, 7)
 	line(0, 0, 0, 16, 7)
 	rectfill(56, 4, 63, 11, 0)
 	if gameover then
 	  spr(14, 56, 4)
 	elseif gamewon then
 	  spr(16, 56, 4)
 	else
 			spr(13, 56, 4)
 	end
 	

  drawbox(3,4)
 	drawnum(mines,5,6,8)
 	
 	drawbox(110,4)
 	drawnum(flr(time()-started_at),112,6,8)

	 for i=1, 14 do
	   for j= 1, 16 do
	   		x=j*8-8
	   		y=8+i*8
	   		b=board[i][j]
  		  rectfill(x, y, x+7, y+7, 0)
	   		if b[1]==0 then
			     spr(12, x, y)
			   elseif b[1]==1 then
			   		if b[2] then
			       spr(11, x, y)
			     else
			       spr(b[3], x, y)
			     end
			   elseif b[1]==2 then
						  spr(9, x, y)
						else
						  spr(10, x, y) 
			   end
			   if not gameover and ci==i and cj==j then
			     spr(15, x, y)
			   end
	   end
	 end
end
__gfx__
55555555555555555555555555555555555555555555555555555555555555555555555577777777777777775555555577777777777777777777777788888888
5666666656666666566666665666666656666666566666665666666656666666566666667668866576600665566606667666666576aaaa6576aaaa6580000008
56666666566cc6665633336656888866561661665622226656dddd665600000656555566768886657606606556600066766666657a0aa0a57a0aa0a580000008
566666665666c6665666636656666866561661665626666656d666665666660656566566766886657666066556070006766666657aaaaaa57aaaaaa580000008
566666665666c6665633336656888866561111665622226656dddd665666606656555566766606657660666550000000766666657a0aa0a57aa00aa580000008
566666665666c6665636666656666866566661665666626656d66d665666066656566566766000657666666556000006766666657aa00aa57a0aa0a580000008
56666666566ccc665633336656888866566661665622226656dddd6656606666565555667666666576606665566000667666666576aaaa6576aaaa6580000008
56666666566666665666666656666666566666665666666656666666566666665666666655555555555555555666066675555555555555555555555588888888
77777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76aaaa65000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70700705000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7a0aa0a5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7aaaaaa5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7a0000a5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76a00a65000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100001705017050170501705017050170501705017050170501705000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
