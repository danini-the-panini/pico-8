pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
in_menu=true
game_over=false
score=0
vx=0
vy=0
maxv=4
a=0.2
x=0
y=60

nstars=50
stars={{},{},{}}
starcol={1,13,7}

fire_time=10
last_fire=0
bullet_speed=3
bullets={}

enemy_time_min=50
enemy_time_max=100
enemy_f_time_min=20
enemy_f_time_max=50
enemy_min_speed=1
enemy_max_speed=2
last_enemy=0
enemies={}
enemy_bullet_speed=3
enemy_bullets={}

pcount=50
pspeed_min=1
pspeed_max=2
plife_min=10
plife_max=20
particles={}

function init_stars()
  for s in all(stars) do
    for i=1, nstars, 1 do
      add(s, {x=rnd(129), y=rnd(129)})
    end
  end
end

function _init()
  init_stars()
end

function update_stars()
  for s=1, 3, 1 do
    for star in all(stars[s]) do
      star.x -= s
      if star.x < 0 then
        star.x=128
        star.y=rnd(129)
      end
    end
  end  
end

function move_ship()
  ax=0
  ay=0
  if (btn(0)) ax-=1
  if (btn(1)) ax+=1
  if (btn(2)) ay-=1
  if (btn(3)) ay+=1
  vx += ax * a
  vy += ay * a
  if (vx < -maxv) vx=-maxv
  if (vx > maxv) vx=maxv
  if (vy < -maxv) vy=-maxv
  if (vy > maxv) vy=maxv
  x+=vx
  y+=vy
  if x < 0 then
    x = 0
    vx = 0
  end
  if x > 120 then
    x = 120
    vx = 0
  end
  if y < 0 then
    y = 0
    vy = 0
  end
  if y > 120 then
    y = 120
    vy = 0
  end
end

function fire_gun()
  if last_fire<=0 then
    last_fire=fire_time
    add(bullets, {x=x+8, y=y+3})
    sfx(0)
  end
end

function collides_enemy(bullet, enemy)
  if (bullet.x+4 < enemy.x) return false
  if (bullet.x > enemy.x+8) return false
  if (bullet.y+3 < enemy.y) return false
  if (bullet.y > enemy.y+8) return false
  return true
end

function gen_particle(x, y, cols)
  speed=pspeed_min+rnd(pspeed_max-pspeed_min)
  dir=rnd(1.0)
  return {
    x=x,
    y=y,
    vx=cos(dir) * speed,
    vy=sin(dir) * speed,
    life=plife_min+rnd(plife_max-plife_min),
    col=rnd(cols)
  }
end

function explode(x, y, cols)
  for i=1, pcount, 1 do
    add(particles, gen_particle(x, y, cols))
  end
end

function update_bullets()
  for bullet in all(bullets) do
    bullet.x+=bullet_speed
    if bullet.x > 128 then
      del(bullets, bullet)
    end
    for enemy in all(enemies) do
      if collides_enemy(bullet, enemy) then
        del(bullets, bullet)
        del(enemies, enemy)
        sfx(2)
        explode(enemy.x+4, enemy.y+4, {3, 11})
        if not game_other then
          score+=1
        end
      end
    end
  end
end

function enemy_fire_time()
  return enemy_f_time_min+rnd(enemy_f_time_max-enemy_f_time_min)
end

function spawn_enemies()
  if last_enemy<=0 then
    last_enemy=enemy_time_min+rnd(enemy_time_max-enemy_time_min)
    add(enemies, {
      x=128,
      y=rnd(120),
      last_fire=enemy_fire_time(),
      speed=enemy_min_speed+rnd(enemy_max_speed-enemy_min_speed)
    })
  end
  last_enemy-=1
end

function fire_enemy_gun(enemy)
  if enemy.last_fire<=0 then
    enemy.last_fire=enemy_fire_time()
    add(enemy_bullets, {x=enemy.x-4, y=enemy.y+3})
    sfx(1)
  end
  enemy.last_fire-=1
end

function enemy_collides_player(enemy)
  if (enemy.x+8 < x) return false
  if (enemy.x > x+8) return false
  if (enemy.y+8 < y) return false
  if (enemy.y > y+8) return false
  return true
end

function player_death()
  sfx(2)
  sfx(3)
  explode(x+4, y+4, {8, 9})
  game_over=true
end

function update_enemies()
  for enemy in all(enemies) do
    enemy.x-=enemy.speed
    fire_enemy_gun(enemy)
    if enemy.x < -8 then
      del(enemies, enemy)
    end
    if not game_over and enemy_collides_player(enemy) then
      del(enemies, enemy)
      player_death()
    end
  end
end

function bullet_collides_player(bullet)
  if (bullet.x+4 < x) return false
  if (bullet.x > x+8) return false
  if (bullet.y+3 < y) return false
  if (bullet.y > y+8) return false
  return true  
end

function update_enemy_bullets()
  for bullet in all(enemy_bullets) do
    bullet.x-=enemy_bullet_speed
    if bullet.x < -4 then
      del(enemy_bullets, bullet)
    end
    if not game_over and bullet_collides_player(bullet) then
      del(enemy_bullets, bullet)
      player_death()
    end
  end
end

function update_particles()
   for p in all(particles) do
    p.x+=p.vx
    p.y+=p.vy
    p.life-=1
    if p.life < 0 then
      del(particles, p)
    end
  end
end

function update_menu()
  if btnp(4) then
    in_menu=false
    game_over=false
    enemies={}
    bullets={}
    enemy_bullets={}
    particles={}
    score=0
    x=0
    y=60
    vx=0
    vy=0
  end
end

function update_game()
  if btnp(5) then
    in_menu=true
    return
  end
  if not game_over then
    move_ship()
    if(btn(4)) fire_gun()
    if(last_fire>0) last_fire-=1
  elseif btnp(4) or btnp(5) then
    in_menu=true
    return
  end
  update_bullets()
  spawn_enemies()
  update_enemies()
  update_enemy_bullets()
  update_particles()
end

function _update()
  update_stars()
  if in_menu then
    update_menu()
  else
    update_game()
  end
end

function draw_stars()
  for s=1, 3, 1 do
    for star in all(stars[s]) do
      pset(star.x, star.y, starcol[s])
    end
  end  
end

function draw_ship()
  spr(0, x, y)
  if btn(0) then
    spr(17, x+8, y+1, 1, 1, true)
  end
  if btn(1) then
    spr(17, x-8, y+1)
  end
  if btn(2) then
    spr(16, x+1, y+9)
  end
  if btn(3) then
    spr(16, x+1, y-9, 1, 1, false, true)
  end
end

function draw_bullets()
  for b in all(bullets) do
    spr(1, b.x, b.y)
  end
end

function draw_enemies()
  for enemy in all(enemies) do
    spr(2, enemy.x, enemy.y)
  end
end

function draw_enemy_bullets()
  for b in all(enemy_bullets) do
    spr(3, b.x, b.y)
  end
end

function draw_particles()
  for p in all(particles) do
    pset(p.x, p.y, p.col)
  end
end

function rkd_print(text, x, y)
  print(text, x+1, y+1, 8)
  print(text, x, y, 9)
end

function draw_score()
  rkd_print("score: "..score, 2, 2)
end

function draw_menu()
  spr(5, 32, 32, 8, 4)
  rkd_print("press 🅾️ to start", 30, 80)
end

function draw_game_over()
  rkd_print("game over", 46, 50)
  rkd_print("press 🅾️ or ❎", 36, 70)
end

function draw_game()
  if not game_over then
    draw_ship()
  end
  draw_bullets()
  draw_enemies()
  draw_enemy_bullets()
  draw_particles()
  draw_score()
  if game_over then
    draw_game_over()
  end
end

function _draw()
  cls()
  draw_stars()
  if in_menu then
    draw_menu()
  else
    draw_game()
  end
end
__gfx__
00008000008000000000033303000000000000008888888888888800000000888888888000888888880088888888888888800000000000000000000000000000
000088008898000000033bb33b330000000000008999999999999888000000899999998008899999880089999999999999888000000000000000000000000000
8888898000800000033bbb3003000000000000008999999999999998800000899999998008999999800089999999999999998800000000000000000000000000
89999998000000003bbbb30000000000000000008999999999999999880000899999998008999999800089999999999999999880000000000000000000000000
89999998000000003bbbb30000000000000000008999999988899999988000899999998008999998800089999999888999999980000000000000000000000000
8888898000000000033bbb3000000000000000008999999980889999998000899999998088999998000089999999808899999988000000000000000000000000
000088000000000000033bb300000000000000008999999980089999998000899999998089999998000089999999800899999998000000000000000000000000
00008000000000000000033300000000000000008999999980089999998000899999998089999998000089999999800899999998000000000000000000000000
0ccc0000000cc0000000000000000000000000008999999980089999998000899999998889999998000089999999800899999998000000000000000000000000
cc1cc00000c1cc000000000000000000000000008999999980089999998000899999999999999988000089999999800899999998000000000000000000000000
c111c000cc111c000000000000000000000000008999999980089999998000899999999999999980000089999999800899999998000000000000000000000000
0c1c0000cc111c000000000000000000000000008999999980089999998000899999999999999980000089999999800899999998000000000000000000000000
00c0000000c1cc000000000000000000000000008999999980889999988000899999999999999980000089999999800899999998000000000000000000000000
00c00000000cc0000000000000000000000000008999999988899999880000899999999999999980000089999999800899999998000000000000000000000000
00000000000000000000000000000000000000008999999999999998800000899999999999999980000089999999800899999998000000000000000000000000
00000000000000000000000000000000000000008999999999999998000000899999999999999980000089999999800899999998000000000000000000000000
00000000000000000000000000000000000000008999999999999998800000899999999999999980000089999999800899999998000000000000000000000000
00000000000000000000000000000000000000008999999988889999880000899999999999999980000089999999800899999998000000000000000000000000
00000000000000000000000000000000000000008999999980089999988000899999999999999980000089999999800899999998000000000000000000000000
00000000000000000000000000000000000000008999999980089999998000899999999999999988000089999999800899999998000000000000000000000000
00000000000000000000000000000000000000008999999980089999998000899999999999999998000089999999800899999998000000000000000000000000
00000000000000000000000000000000000000008999999980089999998000899999999999999998000089999999800899999998000000000000000000000000
00000000000000000000000000000000000000008999999980089999998000899999998889999998000089999999800899999998000000000000000000000000
00000000000000000000000000000000000000008999999980089999998000899999998089999998800089999999800899999998000000000000000000000000
00000000000000000000000000000000000000008999999980089999998000899999998089999999800089999999800899999998000000000000000000000000
00000000000000000000000000000000000000008999999980089999998000899999998089999999800089999999800899999998000000000000000000000000
00000000000000000000000000000000000000008999999980089999998000899999998089999999800089999999808899999998000000000000000000000000
00000000000000000000000000000000000000008999999980089999998000899999998088999999880089999999888999999988000000000000000000000000
00000000000000000000000000000000000000008999999980089999998000899999998008999999980089999999999999999980000000000000000000000000
00000000000000000000000000000000000000008999999980089999998000899999998008999999980089999999999999999880000000000000000000000000
00000000000000000000000000000000000000008999999980089999998000899999998008999999988089999999999999988800000000000000000000000000
00000000000000000000000000000000000000008888888880088888888000888888888008888888888088888888888888880000000000000000000000000000
__sfx__
00011a003e2303c2303b2303a2303923037230362303323032230312302e2302c2302a230282302623023230212301d2301a23016230132300f2300a23005230002300023002330003300b0300a0300903008030
000112002215022150201501f1501e1501d1501c1501b1501915018150161501415012150101500d1500915004150001500015009250082500725006250052500425004250032500325002250012500125000000
360200003c617396273563732647306472d6572a6672866725657226571f6571d6571b657186571665714657116570f6570d6470c6370a6370862707617056170561705617056170461703617036170261701617
00050000205501f5501e5501c5501b550195501955018550175501655015550155501455013550135501255011550105500e5500c5500b5500955008550075500655004550035500255001550005500055000550
