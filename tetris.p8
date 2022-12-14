pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
s_menu=0
s_playing=1
s_game_over=2
state=s_menu

m_level=0
m_show_next=1
menu_item=m_level

level=1
show_next=true

score=0
lines=0

board_width=10
board_height=20
board={}

piece=nil
next_piece=0
spawn_time=0
step_time=0

█=true
▒=false

pieces={
  {{
    {▒,▒},
    {█,█},
    {█,█}
  }},
  {{
    {▒,▒,▒,▒},
    {█,█,█,█},
    {▒,▒,▒,▒},
    {▒,▒,▒,▒}
  },{
    {▒,▒,█,▒},
    {▒,▒,█,▒},
    {▒,▒,█,▒},
    {▒,▒,█,▒}
  }},
  {{
    {▒,▒,▒},
    {█,█,█},
    {▒,█,▒}
  },{
    {▒,█,▒},
    {▒,█,█},
    {▒,█,▒}
  },{
    {▒,█,▒},
    {█,█,█},
    {▒,▒,▒}
  },{
    {▒,█,▒},
    {█,█,▒},
    {▒,█,▒}
  }},
  {{
    {▒,▒,▒},
    {▒,█,█},
    {█,█,▒}
  },{
    {▒,█,▒},
    {▒,█,█},
    {▒,▒,█}
  }},
  {{
    {▒,▒,▒},
    {█,█,▒},
    {▒,█,█}
  },{
    {▒,█,▒},
    {█,█,▒},
    {█,▒,▒}
  }},
  {{
    {▒,▒,▒},
    {█,█,█},
    {▒,▒,█}
  },{
    {▒,█,█},
    {▒,█,▒},
    {▒,█,▒}
  },{
    {█,▒,▒},
    {█,█,█},
    {▒,▒,▒}
  },{
    {▒,█,▒},
    {▒,█,▒},
    {█,█,▒}
  }},
  {{
    {▒,▒,▒},
    {█,█,█},
    {█,▒,▒}
  },{
    {▒,█,▒},
    {▒,█,▒},
    {▒,█,█}
  },{
    {▒,▒,█},
    {█,█,█},
    {▒,▒,▒}
  },{
    {█,█,▒},
    {▒,█,▒},
    {▒,█,▒}
  }}
}

function init_board()
  for i=1,board_height,1 do
    board[i]={}
    for j=1,board_width,1 do
      board[i][j]=0
    end
  end
end

function set_next_piece()
  spawn_time=calc_step_time()*2
  next_piece=flr(rnd(#pieces))+1
end

function start_game()
  state=s_playing
  score=0
  lines=0
  set_next_piece()
  init_board()
end

function _init()
  init_board()
end

function calc_step_time()
  return max(3,flr((10-level)*2.5+1.5))
end

function set_step_time()
  step_time=calc_step_time()
end

function spawn_piece()
  tmp=pieces[next_piece]
  piece={
    t=next_piece,
    tmp=tmp,
    i=1,
    j=6-flr(#tmp[1]/2),
    r=1
  }
  if not valid(0, 0, piece.r) then
    piece.i-=1
    if not valid(0, 0, piece.r) then
      state=s_game_over
    end
  end
  set_next_piece()
  set_step_time()
end

function update_menu()
  if btnp(2) then
    menu_item-=1
  end
  if btnp(3) then
    menu_item+=1
  end
  menu_item%=2
  if menu_item==m_level then
    if btnp(0) then
      level-=1
      if (level<1) level=1
    end
    if btnp(1) then
      level+=1
      if (level>10) level=10
    end
  elseif menu_item==m_show_next then
    if btnp(0) or btnp(1) then
      show_next=not show_next
    end
  end
  if btnp(4) then
    start_game()
  end
end

function valid(di, dj, r)
  pi=piece.i+di
  pj=piece.j+dj
  tmp=piece.tmp[r]
  for ii=1,#tmp,1 do
    for jj=1,#tmp[1],1 do
      if tmp[ii][jj] then
        i=pi+ii-1
        j=pj+jj-1
        if (i<1) return false
        if (i>board_height) return false
        if (j<1) return false
        if (j>board_width) return false
        if (board[i][j]!=0) return false
      end
    end
  end
  return true
end

function clear_line(from_i)
  for i=from_i,2,-1 do
    for j=1,board_width,1 do
      board[i][j]=board[i-1][j]
    end
  end
  for j=1,board_width,1 do
    board[1][j]=0
  end
end

function level_up()
  level=min(10,max(level,ceil((lines+1)/10)))
end

function check_lines()
  lc=0
  for i=1,board_height,1 do
    full=true
    for j=1,board_width,1 do
      if board[i][j]==0 then
        full=false
      end
    end
    if full then
      clear_line(i)
      lc+=1
    end
  end
  if lc>0 then
    score+=(2^(lc-1)*100)*level
    lines+=lc
    level_up()
  end
end

function set_piece()
  pi=piece.i
  pj=piece.j
  tmp=piece.tmp[piece.r]
  for ii=1,#tmp,1 do
    for jj=1,#tmp[1],1 do
      if tmp[ii][jj] then
		      i=pi+ii-1
		      j=pj+jj-1
        board[i][j]=piece.t
      end
    end
  end
  check_lines()
  piece=nil
end

function move_left()
  if valid(0, -1, piece.r) then
    piece.j-=1
  end
end

function move_right()
  if valid(0, 1, piece.r) then
    piece.j+=1
  end
end

function move_down()
  if valid(1, 0, piece.r) then
    piece.i+=1
  else
    set_piece()
  end
end

function rotate()
  r=piece.r
  r+=1
  if (r>#piece.tmp) r=1
  if valid(0, 0, r) then
    piece.r=r
  end
end

function drop()
  di=0
  while valid(di+1, 0, piece.r) do
    di+=1
  end
  piece.i+=di
  set_piece()
end

function update_current_piece()
  step_time-=1
  if step_time<=0 then
    move_down()
    set_step_time()
  end
  if piece then
    if (btnp(0)) move_left()
    if (btnp(1)) move_right()
    if (btnp(2)) rotate()
    if (btnp(3)) drop()
  end
end

function update_game()
  if piece then
    update_current_piece()
  else
    spawn_time-=1
    if spawn_time<=0 then
      spawn_piece()
    end
  end
end

function update_game_over()
  if btnp(4) then
    state=s_menu
  end
end

function _update()
  if state==s_menu then
    update_menu()
  elseif state==s_playing then
    update_game()
  elseif state==s_game_over then
    update_game_over()
  end
end

function draw_background()
  cls(0)
  s=14+level*2
  if level>8 then
    s=48+(level-9)*2
  end
  for x=0,112,16 do
    for y=0,112,16 do
      spr(s, x, y, 2, 2)
    end
  end
end

function draw_box(x, y, w, h, c)
  rect(x-3,y-3,x+w+2,y+h+2,5)
  rect(x-3,y-3,x+w+1,y+h+1,7)
  rect(x-2,y-2,x+w+1,y+h+1,6)
  rect(x-1,y-1,x+w,y+h,7)
  rect(x-1,y-1,x+w-1,y+h-1,5)
  rectfill(x,y,x+w-1,y+h-1,c)
end

function btos(b)
  if (b) return "yes"
  return "no"
end

function draw_menu()
  draw_box(16,16,96,96,0)

  sspr(0, 40, 77, 20, 25, 25)
  print("level: "..level, 32, 64, 7)
  print("show next: "..btos(show_next), 32, 72, 7)
  print("press ❎ to play", 32, 96, 7)
  
  print("➡️", 20, 64+menu_item*8, 7)
end

function draw_block(i, j, t)
  spr(t-1, 58+j*6, -2+i*6)
end

function draw_board()
  draw_box(64, 4, 60, 120, 0)
  for i=1,board_height,1 do
    for j=1,board_width,1 do
      t=board[i][j]
      if t!=0 then
        draw_block(i, j, t)
      end
    end
  end
end

function draw_score_box()
  draw_box(8, 8, 36, 50, 6)
  print("score", 10, 10, 0)
  print(score, 12, 18, 1)
  print("lines", 10, 26, 0)
  print(lines, 12, 34, 1)
  print("level", 10, 42, 0)
  print(level, 12, 50, 1)
end

function draw_next_box()
  draw_box(8, 66, 36, 36, 0)
  print("next", 14, 72, 8)
  tmp=pieces[next_piece][1]
  for i=1,#tmp,1 do
    for j=1,#tmp[1],1 do
      if tmp[i][j] then
        spr(next_piece-1,8+j*6,72+i*6)
      end
    end
  end
end

function draw_game_over()
  draw_box(32, 48, 64, 32, 7)
  print("game over", 46, 56, 0)
  print("press ❎", 48, 68, 0)
end

function draw_current_piece()
  if (not piece) return

  tmp=piece.tmp[piece.r]
  i=piece.i
  j=piece.j
  for ii=1,#tmp,1 do
    for jj=1,#tmp[1],1 do
      if tmp[ii][jj] then
        draw_block(i+ii-1,j+jj-1,piece.t)
      end
    end
  end
end

function _draw()
  draw_background()
  if state==s_menu then
    draw_menu()
  else
    draw_board()
    draw_score_box()
    if show_next then
      draw_next_box()
    end
    if state==s_game_over then
      draw_game_over()
    else
      draw_current_piece()
    end
  end 
end
__gfx__
66666600eeeeee0077777700cccccc0077777700ffffff00aaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000
6cccc100e888820076666500cdddd1007bbbb300feeee200a9999400000000000000000000000000000000000000000000000000000000000000000000000000
6cccc100e888820076666500cdddd1007bbbb300feeee200a9999400000000000000000000000000000000000000000000000000000000000000000000000000
6cccc100e888820076666500cdddd1007bbbb300feeee200a9999400000000000000000000000000000000000000000000000000000000000000000000000000
6cccc100e888820076666500cdddd1007bbbb300feeee200a9999400000000000000000000000000000000000000000000000000000000000000000000000000
61111100e222220075555500c111110073333300f2222200a4444400000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
777777777777777050000000eeeee055ccccccccccc8cecc666111111168888800000eeeeee0000000000c000b00a000000c0000ee00ecc8000aaaaaa0ddddde
77eeeeeeeeeeee6050008888eeeee0550ccacecccbcceccc86ccc66166888888000eeaaaaaaee00000000c000b00a00000cc00000ee0bec8000aaaaaabddddde
787eeeeeeeeee62000088888eeeee000c0acecccccbec8cc88ccccca6668886e00e0a888888a0e00c000c00800b0a000cc0000bbbbebb0cc000aaaaaabddddd0
7887eeeeeeee62200088888888800000cacec8cacceccccc666ccc6aaaa1666e0e0a8cccccc8a0e0c000c0808aab0a0000000baa88ee0ee0008aaaaaabddddd0
78887eeeeee6222008888888888800ccccecccacceccbccceee6c6aaaaa616ee0ea8cccccccc8ae00c0c0800a8ab00ac000aabbbbbbeee00008888bbbb880000
788887eeee622220c888888888880ccccecccac8eccccbaceeee6aaaaaaa6eeeea8cccccccccc8ae0c0cbb0a008aba0cccca880a0ccccccc008888bbbb880000
7888887ee6222220cc8888888888ccccccccacce8cccaabceee66aa66aaaceeeea8cccc88cccc8ae00cb8aabb00aa0c0e0ccceeccc0bbae0008888bbbb880000
7888888762222220cc8888888888cccccccaccec8ccacccbeee88aabb6accceeea8ccc8008ccc8ae00cba0000bb0a8c00e0eccccaeeabea0c08888bbbccccccc
78888886d2222220c888888888880cccc8acceccc8acc0ecee8888bbbb6ccc6eea8ccc8008ccc8ae00aab0000cc0ac80ae0e0cc0bbeeeea0cccc88bbbccccccc
788888688d22222000888888888000ccca8cccccba8cce0ce888866bb6dcccc6ea8cccc88cccc8ae0a088b880c0cca800eee0ccc8000eeeecccc00bbbccccccc
7888868888d22220000888888bb00000ccc8cccccbceecc08888811b6dddcc88ea8cccccccccc8ae00aa00b0c8800a8000eecc0cc80ee000cccc00bbbccccccc
78886888888d222000008888bbbb0000cccc8ccccceccccc88886116ddddd8880ea8cccccccc8ae00000a8b8c880a8a0ee00cbbbccb0e000cccc00bbbb000000
788688888888d22050aaaa00bbbb0055cbcca8ccceabc0cc688611696dd6c6880e0a8cccccc8a0e000880aac000a08a0e0eec8888cceee00ccccaaaaab000000
7868888888888d2050aaaa000bb000550cbacc8ccaccbc0e788116666666666800e0a888888a0e008800000a00a008a8088c00000eeceee0000aaaaaab000eee
76888888888888d050aaaa00eeeee055c0abccc8accccee07661111168888888000eeaaaaaaee000000000cbaa0008a0080c0000e00ec00e000aaaaaa0000eee
000000000000000050000000eeeee055caccccca8ccceccc761111116888888800000eeeeee00000000000c0b00000a0800c0000e00eccc0000aaaaaa0000eee
77777777777777775555555555555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76666666666666655555555555555557000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76666666666666655566666666666677000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76666666666666655566666666666677000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76600000006666655560000000666677000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7660880cc06666655560880cc0666677000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7660880cc06666655560880cc0666677000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76600000000006655560000000000677000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7666660ee0bb06655566660ee0bb0677000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7666660ee0bb06655566660ee0bb0677000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76666600000006655566660000000677000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76666666666666655566666666666677000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76666666666666655566666666666677000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76666666666666655566666666666677000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76666666666666655777777777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
75555555555555557777777777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6666666666660eeeeeeeeeeee077777777777707777777777770ffffffffffff0aaaaaaaaaaaa000000000000000000000000000000000000000000000000000
6cc16cc16cc10e882e882e882076657665766507bb37bb37bb30fee2fee2fee20a994a994a994000000000000000000000000000000000000000000000000000
6cc16cc16cc10e882e882e882076657665766507bb37bb37bb30fee2fee2fee20a994a994a994000000000000000000000000000000000000000000000000000
6111611161110e222e222e222075557555755507333733373330f222f222f2220a444a444a444000000000000000000000000000000000000000000000000000
0000666600000eeee000000000000077770000077770000777700000ffff00000aaaa00000000000000000000000000000000000000000000000000000000000
00006cc100000e88200000000000007665000007bb300007bb300000fee200000a99400000000000000000000000000000000000000000000000000000000000
00006cc100000e88200000000000007665000007bb300007bb300000fee200000a99400000000000000000000000000000000000000000000000000000000000
0000611100000e222000000000000075550000073330000733300000f22200000a44400000000000000000000000000000000000000000000000000000000000
0000666600000eeeeeeeeeeee0000077770000077777777000000000ffff00000aaaaaaaaaaaa000000000000000000000000000000000000000000000000000
00006cc100000e882e882e882000007665000007bb37bb3000000000fee200000a994a994a994000000000000000000000000000000000000000000000000000
00006cc100000e882e882e882000007665000007bb37bb3000000000fee200000a994a994a994000000000000000000000000000000000000000000000000000
0000611100000e222e222e2220000075550000073337333000000000f22200000a444a444a444000000000000000000000000000000000000000000000000000
0000666600000eeee000000000000077770000077770000777700000ffff0000000000000aaaa000000000000000000000000000000000000000000000000000
00006cc100000e88200000000000007665000007bb300007bb300000fee20000000000000a994000000000000000000000000000000000000000000000000000
00006cc100000e88200000000000007665000007bb300007bb300000fee20000000000000a994000000000000000000000000000000000000000000000000000
0000611100000e222000000000000075550000073330000733300000f2220000000000000a444000000000000000000000000000000000000000000000000000
0000666600000eeeeeeeeeeee000007777000007777000077770ffffffffffff0aaaaaaaaaaaa000000000000000000000000000000000000000000000000000
00006cc100000e882e882e882000007665000007bb300007bb30fee2fee2fee20a994a994a994000000000000000000000000000000000000000000000000000
00006cc100000e882e882e882000007665000007bb300007bb30fee2fee2fee20a994a994a994000000000000000000000000000000000000000000000000000
0000611100000e222e222e222000007555000007333000073330f222f222f2220a444a444a444000000000000000000000000000000000000000000000000000
