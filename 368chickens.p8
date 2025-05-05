pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
function _init()
  bgs={1,2,3,4}
  startgame()
end

function startgame()
		ci=1
		cj=1
  chickens = 368
  board = {
    {0,0,0,0,0,0},
    {0,1,2,3,4,0},
    {0,0,0,0,0,0},
    {0,0,0,0,0,0},
    {0,0,0,0,0,0},
    {0,0,0,0,0,0}
  }
  addpiece()
end

function gameover()
  game_over = true
end

function canplace()
  for i=1,6 do
    for j=1,6 do
      if validate(i,j) then return true end
    end
  end
end

function addpiece()
		p1=rnd(bgs)
		p2=rnd(bgs)
  hrz=rnd({t,f})
  if canplace() then return true end
  hrz=not hrz
  if canplace() then return true end
  gameover()
  return false
end

function validate(i,j)
  if board[i][j] ~= 0 then return false end
  if hrz and j<6 then
    return board[i][j+1] == 0
  end
  if not hrz and i<6 then
    return board[i+1][j] == 0
  end
  return false
end

function drawtext()
	 local s = ""..chickens.." chickens remaining"
	 print(s, 64-#s*2, 8, 7)
end

function _draw()
		palt(0, false)
		palt(11, true)
  rectfill(0,0,128,128,12)
		drawtext()
		rect(40,40,89,89,1)
		for i=1,6 do
		  for j=1,6 do
		  		local x = 32+j*8
		  		local y = 32+i*8
		    rect(x,y,x+8,y+8,1)
		    rectfill(x+1,y+1,x+8,y+8,13)
		    spr(board[i][j],x,y)
		  end
		end
		local cx=32+cj*8
		local cy=32+ci*8
		rect(cx+1,cy+1,cx+8,cy+8,0)
		rect(cx,cy,cx+7,cy+7,7)
		if not game_over then
		  print("game over", 46, 96)
		  rectfill(35, 110, 64, 120, 7)
--		  rectfill(48, 103, 83, 119, 7)
		  print("❎ play again", 38, 112, 1)
		else
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
