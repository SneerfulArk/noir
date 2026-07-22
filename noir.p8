pico-8 cartridge // http://www.pico-8.com
version 43
__lua__

--#region 1. MAIN

    --palette
    pal_global = {
        main = {
        {1,  129}, --Cobalt    to  Dark-Blue
        {2,  128}, --Bergundy  to  Dark-Brown
        {15, 134}, --Beige     to  Dark-Beige
        {4,  133}, --Brown     to  Choc-Brown
        {10, 135}, --Yellow    to  Light-yellow
        {14, 136}, --Pink      to  Blood-Red
        {8,  2},   --Red       to  Dark-Red
        {9,  4},   --Orange    to  Brown
        {12, 1},   --LightBlue to  Cobalt
        }
    }
    pal_flash = {
        plr = {
        {0,   2},
        {2,   4},
        {4,   9},
        {15,  7},
        },
        en = {
        {0,   2},
        {4,   9},
        {15,  7},
        }
    }

    --enemy animations
    walk = {4,2,6,2}
    punch = {8,8,10,10,10,10,10}

    function _init()
        game = "play"
        debug = false
        --sfx(3)
        init_clock()
        init_bg()
        init_player()
        init_enemies()
        init_combat()
        init_vfx()
    end

    function _update60()
        ticks += 1

        --state
        if game == "menu" then
            update_menu()
        elseif game == "play" then
            update_play()
        end
    end

    function _draw()
        cls(0)
        doshake()
        apply_global_pal()
        
        --state
        if game == "menu" then
            draw_menu()
        elseif game == "play" then
            draw_play()
        end
        
        --borders
        rectfill(-2,-2,129,39,0)
        rectfill(-2,167,129,125,0)

        --debug
        if debug == true then
            print("ticks:"..ticks, 1, 21, 6)
            print("time_elapsed:"..flr(time_elapsed), 1, 27, 6)
            print("gt:"..gt, 1, 33, 6)
            cprint("NOIR", 120, 20, 6)
            if target_en != nil then
                print("distance:"..target_en.dist, 1, 127, 6)
            end
            if plr.state == "combat" then
                print("cframe:"..flr(cframe), 1, 133, 6)
            end
            
            --[[if last_takedown != nil and second_last_takedown != nil then
                print("last_tk:"..last_takedown, 1, 127, 6)
                print("2nd_last_tk:"..second_last_takedown, 1, 133, 6)
            end]]

            --[[line(63,0,63,127,12) --vertical debug line
            line(64,0,64,127)
            line(0,63,127,63) --horizontal debug line
            line(0,64,127,64)--]]
        end
    end


--#region 2. CLOCK

    function init_clock()
        ticks = 0
        gt = 1
        full_spd = 1
        time_slow = true
        time_elapsed = 0
        slow_dist = 30
        stop_dist = 12
        slow_spd = 0.945
        return_spd = 1.080
    end

    function update_clock()
        time_elapsed += gt

        --time slow
        if target_en != nil then
            if time_slow==true and target_en.dist<=slow_dist then
                gt *= slow_spd
                if target_en.dist<=stop_dist then
                    gt = 0 
                end
            elseif time_slow==false then
                if gt <= full_spd/10 then
                    gt = full_spd/10
                end
                if gt <= full_spd-0.01 then
                    gt *= return_spd
                else
                    gt = full_spd
                end
            end
        end
    end


--#region 3. PLAYER

    function init_player()
        plr={
            x      = 57,
            y      = 93,
            w      = 2,
            h      = 3,
            spr    = 0,
            spd    = 0,
            facing = 1,
            fx     = false,
            cent   = 64,
            state  = "idle"
        }
    end

    function update_player()

        plr.cent = plr.x+7
        if plr.facing == 1 then
            plr.fx = false

        elseif plr.facing == 0 then
            plr.fx = true
        end

        if target_en != nil then
            if target_en.cent > plr.cent then
                plr.facing = 1
            elseif target_en.cent < plr.cent then
                plr.facing = 0
            end
        end

        if plr.state == "idle" then
            plr.w = 2
            plr.h = 3
            plr.spr = 0
        end

    end

    function draw_player()
        flash_pal(pal_flash.plr)
        draw_obj(plr)
        reset_draw_pal()
    end


--#region 4. ENEMIES

    function init_enemies()
        enemies = {}
        corpses = {}
        target_en = nil
    end

    function update_enemies()
        
        if #enemies <= 0 then
            en = make_en(-14,93,2,3,1,0.2)
            add(enemies,en)
            en = make_en(128,93,2,3,1,0.2)
            add(enemies,en)
        elseif #enemies < 2 then
            if plr.facing == 0 then
                en = make_en(-46,93,2,3,1,0.2)
                add(enemies,en)
            elseif plr.facing == 1 then
                en = make_en(160,93,2,3,1,0.2)
                add(enemies,en)
            end
        end

        if #enemies > 0 then
            for en in all(enemies) do
                en.cent = en.x+7
                en.dist = abs(flr(plr.cent)-flr(en.cent))
                en.muz_dist = abs(flr(muz_x)-flr(en.cent))
                if en.state == "dead" then
                    en.spd = 0
                end
                if en != target_en then --non targets stop and wait
                    if en.dist >= 30 then
                        move_obj(en)
                        animate(en)
                    end
                elseif en == target_en then
                    move_obj(en)
                    animate(en)
                end
                if en.cent <=14 then
                    en.facing = 1
                    en.dx    = 1
                    en.fx    = false
                end
                if en.cent >= 113 then
                    en.facing = 0
                    en.dx    = -1
                    en.fx    = true
                end
            end
            if target_en == nil then
                local min_dist = 999
                for en in all(enemies) do
                    if en.state != "dead" then
                        if en.dist <= min_dist then
                            min_dist = en.dist
                            target_en = en
                        end
                    end
                end
            end
        end
    end

    function update_corpses()
        if #corpses > 0 then
            for corpse in all(corpses) do
                corpse.delay -= gt
                if corpse.delay <= 0 then
                    if #corpse.list > 0 then
                        local rnd_index = flr(rnd(#corpse.list-1)+1)
                        local target_pixel = corpse.list[rnd_index]
                        target_pixel.dust = true
                        corpse.delay = 1
                        deli(corpse.list,rnd_index) --delete chosen pixel from list
                    end
                end
                
                for p in all(corpse.pixels) do
                    p.muz_dist = abs(flr(muz_x)-flr(p.x))
                    if p.dust == true then
                        local rnd_clr = flr(rnd())+1
                        local life = flr(p.life)
                        --dust movement and life countdown
                        p.x += p.vx*gt
                        p.y -= p.vy*gt
                        p.life -= gt
                        --randomized dust colour
                        if life >= 75 and p.clr != 14 and p.clr != 8 then 
                            if rnd_clr == 1 then
                                p.clr = 4
                            elseif rnd_clr == 2 then
                                p.clr = 2
                            end
                        end
                        --dust life colour cycle
                        if life == 60 and p.clr == 2 then
                            p.clr = 0
                        elseif life == 60 and p.clr == 4 then
                            p.clr = 2
                        end
                        if life == 25 and p.clr == 2 then
                            p.clr = 0
                        end
                        if life == 40 and p.clr == 8 then
                            p.clr = 2
                        end
                        if life == 75 and p.clr == 14 then
                            p.clr = 8
                        end
                        --dust deletion
                        if life <= 0 then
                            del(corpse.pixels,p)
                        end
                    end
                end
            end
        end
    end

    function draw_enemies()
        if #enemies > 0 then
            for en in all(enemies) do
                if en.muz_dist <= 18 then
                    flash_pal(pal_flash.en)
                end
                draw_obj(en)
                reset_draw_pal()
            end
        end
        if #corpses > 0 then
            for corpse in all(corpses) do
                for p in all(corpse.pixels) do
                    if p.muz_dist <= 18 then
                        flash_pal(pal_flash.en)
                    end
                end
                draw_corpse(corpse)
                reset_draw_pal()
            end
        end
    end


--#region 5. COMBAT

    function init_combat()

        shake=0
        muzzle=0
        muz_x=0
        muz_y=0
        flash=0
        rainstop=0
        punch_dist=24
        counter=false
        cframe=0
        second_last_takedown=nil
        last_takedown=nil
        current_takedown=nil

        takedown_pool={
            "parry_leg",
            "double_chest",
            "pistol_whip",
            "gunned_down",
        }

        takedowns={
            parry_leg={
                spr_x=4,
                spr_y=121,
                spr_w=20,
                spr_h=7,
                spr_offset=5,
                length=78,
                key_frames={
                    [01] = {
                        spr=48,
                        sprw=3,
                        sfx=0,
                        rstop=5,
                    },
                    [17] = {
                        spr=48,
                        sprw=3,
                        shake=11,
                        muzzle=3,
                        muz_offsetx=7,
                        muz_offsety=15,
                        sfx=1,
                        flash=3,
                        rstop=6,
                    },
                    [26] = {
                        spr=51,
                        sprw=3,
                    },
                    [71] = {
                        spr=51,
                        sprw=3,
                        shake=12,
                        muzzle=3,
                        muz_offsetx=7,
                        muz_offsety=9,
                        sfx=2,
                        flash=4,
                        rstop=6,
                    },
                    [73] = {
                        spr=54,
                        sprw=3,
                    },
                    [78] = {
                        spr=57,
                        sprw=4,
                    },
                }
            },
            double_chest={
                spr_x=28,
                spr_y=121,
                spr_w=20,
                spr_h=7,
                spr_offset=5,
                length=86,
                key_frames={
                    [01] = {
                        spr=96,
                        sprw=3,
                        sfx=0,
                        rstop=4,
                    },
                    [17] = {
                        spr=99,
                        sprw=3,
                    },
                    [27] = {
                        spr=102,
                        sprw=3,
                        shake=10,
                        muzzle=3,
                        muz_offsetx=2,
                        muz_offsety=12,
                        sfx=2,
                        flash=3,
                        rstop=6,
                    },
                    [43] = {
                        spr=102,
                        sprw=3,
                        shake=10,
                        muzzle=3,
                        muz_offsetx=2,
                        muz_offsety=12,
                        sfx=1,
                        flash=3,
                        rstop=6,
                    },
                    [53] = {
                        spr=105,
                        sprw=3,
                    },
                    [59] = {
                        spr=108,
                        sprw=4,
                    },
                    [86] = {
                        spr=108,
                        sprw=4,
                        shake=12,
                        muzzle=3,
                        muz_offsetx=8,
                        muz_offsety=13,
                        sfx=2,
                        flash=3,
                        rstop=6,
                    },
                }
            },
            pistol_whip={
                spr_x=52,
                spr_y=121,
                spr_w=20,
                spr_h=7,
                spr_offset=10,
                length=53,
                key_frames={
                    [01] = {
                        spr=144,
                        sprw=3,
                    },
                    [7] = {
                        spr=61,
                        sprw=3,
                        rstop=6,
                        sfx=3
                    },
                    [13] = {
                        spr=12,
                        sprw=4,
                    },
                    [18] = {
                        spr=147,
                        sprw=5,
                    },
                    [38] = {
                        spr=147,
                        sprw=5,
                        shake=10,
                        muzzle=3,
                        muz_offsetx=9,
                        muz_offsety=12,
                        sfx=2,
                        flash=3,
                        rstop=6,
                    },
                    [53] = {
                        spr=147,
                        sprw=5,
                        shake=10,
                        muzzle=3,
                        muz_offsetx=9,
                        muz_offsety=12,
                        sfx=1,
                        flash=3,
                        rstop=6,
                    },
                }
            },
            gunned_down={
                spr_x=76,
                spr_y=121,
                spr_w=20,
                spr_h=7,
                spr_offset=13,
                length=62,
                key_frames={
                    [01] = {
                        spr=152,
                        sprw=3,
                    },
                    [10] = {
                        spr=192,
                        sprw=3,
                        shake=10,
                        muzzle=3,
                        muz_offsetx=9,
                        muz_offsety=9,
                        sfx=1,
                        flash=3,
                        rstop=6,
                    },
                    [22] = {
                        spr=195,
                        sprw=4,
                        shake=10,
                        muzzle=3,
                        muz_offsetx=9,
                        muz_offsety=9,
                        sfx=2,
                        flash=3,
                        rstop=6,
                    },
                    [52] = {
                        spr=199,
                        sprw=4,
                        shake=12,
                        muzzle=3,
                        muz_offsetx=9,
                        muz_offsety=10,
                        sfx=1,
                        flash=3,
                        rstop=6,
                    },
                    [58] = {
                        spr=203,
                        sprw=4,
                    },
                    [62] = {
                        spr=155,
                        sprw=5,
                    },
                }
            },
        }
    end

    function update_combat()

        --effects
        if shake >= 1 then shake -= gt end
        if muzzle >= 1 then muzzle -= (gt/2) end
        if flash >= 1 then flash -= 1 end
        if rainstop >= 1 then rainstop -= 1 end

        --enemy punch
        if target_en != nil then
            if target_en.dist == punch_dist then
                target_en.ani = punch
                target_en.frame = 1
            elseif target_en.dist > punch_dist then
                target_en.ani = walk
            end

        --player counter
            if btn(5) and target_en.dist <= 30 then
                counter = true
                time_slow = false
            end
            if target_en.dist == 11 and counter == true and plr.state != "combat" then
                local rnd_index
                if #takedown_pool > 1 then
                    repeat rnd_index = takedown_pool[flr(rnd(#takedown_pool))+1]
                    until rnd_index != last_takedown and rnd_index != second_last_takedown
                else
                    rnd_index = takedown_pool[flr(rnd(#takedown_pool))+1]
                end
                
                current_takedown = rnd_index
                second_last_takedown = last_takedown
                last_takedown = current_takedown
                
                plr.state = "combat"
            end
            if plr.state == "combat" then
                cframe += gt
                takedown()
                counter = false
            else
                cframe = 0
            end
        end
    end

    function takedown()
        local c = flr(cframe) --current combat frame
        local sequence = takedowns[current_takedown]
        local kf = sequence.key_frames[c] --keyframe table

        if kf != nil then
            plr.h = 3
            plr.spr = kf.spr
            
            if kf.sprw != nil then
                plr.w = kf.sprw
            else
                plr.w = 3
            end

            if kf.shake != nil then
                shake = kf.shake
            end
            if kf.muzzle != nil then
                muzzle = kf.muzzle
                if plr.facing == 0 then
                    muz_x = plr.cent - kf.muz_offsetx
                else
                    muz_x = plr.cent + kf.muz_offsetx
                end
                muz_y = plr.y + kf.muz_offsety
            end
            if kf.sfx != nil then
                sfx(kf.sfx)
            end
            if kf.flash != nil then
                flash = kf.flash
            end
            if kf.rstop != nil then
                rainstop = kf.rstop
            end
        end

        if c >= 1 then
            target_en.state = "dead"
        end
        if c == sequence.length then
            plr.state = "idle"
            local offset
            if plr.facing == 1 then offset = sequence.spr_offset
            elseif plr.facing == 0 then offset = -sequence.spr_offset end

            local sx = sequence.spr_x
            local sy = sequence.spr_y
            local sw = sequence.spr_w or 20
            local sh = sequence.spr_h or 7

            corpse = make_corpse(plr.cent+offset,plr.y+17,plr.facing,sx,sy,sw,sh)
            add(corpses,corpse)
            time_slow = true

            for en in all(enemies) do
                if en.state == "dead" then
                    del(enemies,en)
                    target_en = nil
                end
            end
        end
    end

--#region 6. VFX

    function init_vfx()
        rain = {}  
        rt = gt --rain time
        for r=1,8 do --rows
            local row = {
                drops = {}
            }
            for d=1, 64 do --drops
                local drop = {
                    x = -64+d*4+(4*r),
                    y = -55+(19*r)+flr(rnd(4)+1),
                    w = 6,
                    h = flr(16+(rnd(4)+1))
                }
                add(row.drops, drop)
            end
            add(rain, row)
        end
    end

    function update_vfx()
        --rain
        if rainstop >=1 then
            rt = 0
        else
            rt = gt
        end
        for row in all (rain) do
            for drop in all (row.drops) do
                drop.x += 0.4*rt
                drop.y += 1.8*rt
                if drop.y >= 136 then
                    drop.y = drop.y-152
                    drop.x = drop.x-33.8
                end
            end
        end
    end

    function draw_vfx()
        --muzzle
        if muzzle >= 1 then
            muzflash()
        end
        --rain
        for row in all (rain) do
            for drop in all (row.drops) do
                line(flr(drop.x),flr(drop.y),flr(drop.x+drop.w),flr(drop.y+drop.h),0)
            end
        end
    end


--#region 7. BACKGROUND

    function init_bg()
        stars = {}
        for i=1,7 do
            local star={}
            star.x = 30+flr(rnd(72))
            star.y = flr(rnd(10))+40
            star.clr = 6
            add(stars,star)
        end
        buildings = {}
        make_building(40,58,45,69,4,3)
        make_building(47,49,52,69,9,3)
        make_building(53,55,59,69,5,3)
        make_building(61,43,66,69,12,3)
        make_building(68,53,73,69,5,3)
        make_building(75,52,80,69,8,3)
        make_building(81,54,86,69,6,3)
    end

    function update_bg()
        if btnp(4) then
            if debug == false then
                debug = true
            elseif debug == true then
                debug = false
            end
        end
        if #corpses <= 0 and game == "menu" then
            corpse = make_corpse(60,plr.y,1,3,0,9,24,330)
            add(corpses,corpse)
            corpse = make_corpse(10,plr.y+23,1,52,121,20,7,60)
            add(corpses,corpse)
            corpse = make_corpse(55,plr.y+15,0,4,121,20,7,90)
            add(corpses,corpse)
            corpse = make_corpse(70,plr.y+24,1,28,121,20,7,120)
            add(corpses,corpse)
            corpse = make_corpse(95,plr.y+16,0,52,121,20,7,150)
            add(corpses,corpse)
            corpse = make_corpse(100,plr.y+22,1,4,121,20,7,180)
            add(corpses,corpse)
        end
        if #buildings > 0 then
            for b in all(buildings) do
                if flr(time_elapsed)%30 == 0 and gt > 0.5 then
                    local rnd_light = flr(rnd(#b.lights)+1)
                    local light = b.lights[rnd_light]
                    local rnd_clr = flr(rnd(6)+1)
                    local clr
                    if rnd_clr == 1 then
                        light.clr = 0
                    elseif rnd_clr == 2 then
                        light.clr = 1
                    elseif rnd_clr == 3 then
                        light.clr = 12
                    elseif rnd_clr == 4 then
                        light.clr = 10
                    elseif rnd_clr == 5 then
                        light.clr = 6
                    elseif rnd_clr == 6 then
                        light.clr = 7
                    end
                end
            end
        end
    end

    function draw_bg()
        --stars
        for star in all(stars) do
            pset(star.x,star.y,star.clr)
        end
        --distant buildings
        if #buildings > 0 then 
            for b in all(buildings) do
                rectfill(b.x0,b.y0,b.x1,b.y1,5)
                for l in all(b.lights) do
                    pset(l.x,l.y,l.clr)
                end
            end
        end
        --close buildings & ground
        rectfill(-1,70,128,128,5) --ground
        rectfill(39,70,90,81,0)
        for i=0,25 do --upper ground lines
            line(64,70,64+(i*5),128,0)
            line(64,70,64-(i*5),128,0)
        end

        line(40,20,40,70,0) --left side lines
        line(41,21,41,70,5)
        line(42,25,42,60,5)
        
        line(35,7,35,88,0)
        line(36,7,36,88,0)
        line(37,9,37,85,5)
        line(38,12,38,80,5)
        line(39,15,39,75,5)

        line(31,-1,31,107,5)
        line(32,1,32,102,5)
        line(33,3,33,97,5)
        line(34,6,34,93,5)
        
        line(87,19,87,70,0) --right side lines
        line(86,20,86,70,5)
        line(85,24,85,60,5)

        line(92,12,92,88,0)
        line(91,12,91,88,0)
        line(90,14,90,85,5)
        line(89,17,89,80,5)
        line(88,20,88,75,5)

        line(96,-1,96,107,5)
        line(95,1,95,102,5)
        line(94,3,94,97,5)
        line(93,6,93,93,5)

        rectfill(-1,-1,30,109,5) --left
        line(30,-1,30,110,0)
        rectfill(97,-1,128,109,5) --right
        line(97,-1,97,110,0)
    end


--#region 8. UTILITIES

    function cprint(txt,x,y,clr) --centered print
        print(txt,x-#txt*2,y,clr)
    end

    function apply_global_pal()
        palt(0,false)
        palt(3,true)
        local palette = pal_global.main
        for clr in all(palette) do
            pal(clr[1], clr[2], 1)
        end
    end
    
    function flash_pal(palette)
        if flash >= 1 then
            for clr in all(palette) do
                pal(clr[1], clr[2])
            end
        end
    end

    function reset_draw_pal()
        for clr = 0,15 do
            pal(clr, clr, 0)
        end
    end

    function make_en(en_x,en_y,en_w,en_h,en_spd,en_anispd)
        local en={}
            --general properties
            en.x      = en_x
            en.y      = en_y
            en.w      = en_w or 2
            en.h      = en_h or 3
            en.spd    = en_spd or 0.7
            en.dx     = -1
            en.facing = 0
            en.cent   = en_x+7
            en.state  = "approach"
            en.dist   = nil
            --sprite/animation
            en.ani    = walk
            en.frame  = 1
            en.anispd = en_anispd or 0.15
            en.fx     = true
            en.spr    = 64
        return en
    end

    function make_corpse(corpse_x,corpse_y,corpse_facing,spr_x,spr_y,spr_w,spr_h,corpse_delay)
        local corpse={}
            corpse.x       = corpse_x
            corpse.y       = corpse_y
            corpse.w       = spr_w
            corpse.h       = spr_h
            corpse.facing  = corpse_facing
            corpse.delay   = corpse_delay or 45
            corpse.dist    = nil
            corpse.pixels  = {}
            corpse.list    = {}

            for row=0,corpse.h-1 do
                for column=0,corpse.w-1 do
                    local clr = sget(spr_x+column,spr_y+row)
                    if clr != 3 then
                        local px, py
                        if corpse.facing == 1 then
                            px = corpse.x + (column)
                            py = corpse.y + (row)
                        elseif corpse.facing == 0 then
                            px = corpse.x - (column)
                            py = corpse.y + (row)
                        end
                        local new_pixel = {
                            x    = px,
                            y    = py,
                            clr  = clr,
                            vx   = rnd(0.5)+0.2,
                            vy   = rnd(0.05)+0.05,
                            dust = false,
                            life = 75,
                            muz_dist = 18
                        }
                    add(corpse.pixels,new_pixel)
                    add(corpse.list,new_pixel)
                    end
                end
            end
        return corpse
    end

    function draw_corpse(corpse)
        for p in all(corpse.pixels) do
            pset(p.x,p.y,p.clr)
        end
    end

    function move_obj(obj)
        obj.x+=(obj.spd*gt*obj.dx)
    end

    function animate(obj)
        obj.frame += (obj.anispd*gt)
        if flr(obj.frame) > #obj.ani then
            obj.frame=1
        end
        if flr(obj.frame) <= 0 then --for possible reverse time
            obj.frame=#obj.ani
        end
        obj.spr=obj.ani[flr(obj.frame)]
    end

    function draw_obj(obj)
        local offset = 0
        if obj.facing == 0 then
            if cframe >= 1 then
                if obj.w == 3 then
                    offset = 9
                elseif obj.w == 4 then
                    offset = 17
                elseif obj.w == 5 then
                    offset = 25
                elseif obj.w == 6 then
                    offset = 33
                end
            else
                offset = 1
            end
        else offset = 0
        end
        if obj.state != "dead" then
            spr(obj.spr,obj.x-offset,obj.y,obj.w,obj.h,obj.fx)
        end
    end

    function doshake()

        local shakex=rnd(shake)-(shake/2)
        local shakey=rnd(shake)-(shake/2)+20
        
        camera(shakex,shakey)
        
        if shake>10 then
            shake *= 0.9
        else
            shake -= 1
            if shake<1 then
                shake = 0
            end
        end

    end

    function muzflash()
        circfill(muz_x,muz_y,muzzle,10) --outer
        circfill(muz_x,muz_y,muzzle-1,7) --inner
    end

    function make_building(x0,y0,x1,y1,lr,lc)
        local building={}
        building.x0 = x0
        building.y0 = y0
        building.x1 = x1
        building.y1 = y1
        building.lights = {}
        building.lights_pool = {}
        for row=0,lr-1 do
            for column=0,lc-1  do
                local light = {}
                local rnd_clr = flr(rnd(6)+1)
                light.x = building.x0+1+(column*2)
                light.y = building.y0+1+(row*2)
                if rnd_clr == 1 then
                    light.clr = 0
                elseif rnd_clr == 2 then
                    light.clr = 1
                elseif rnd_clr == 3 then
                    light.clr = 12
                elseif rnd_clr == 4 then
                    light.clr = 10
                elseif rnd_clr == 5 then
                    light.clr = 6
                elseif rnd_clr == 6 then
                    light.clr = 7
                end
                add(building.lights,light)
                add(building.lights_pool,light)
            end
        end
        add(buildings,building)
    end

--#region 9. STATE

    --menu state
    function update_menu()
        update_clock()
        update_bg()
        update_corpses()
        update_vfx()
        if btn(5) then game = "play" end
    end

    function draw_menu()
        draw_bg()
        draw_enemies()
        draw_vfx()
    end

    --play state
    function update_play()
        update_clock()
        update_bg()
        update_player()
        update_enemies()
        update_corpses()
        update_combat()
        update_vfx()
    end

    function draw_play()
        draw_bg()
        draw_player()
        draw_enemies()
        draw_vfx()
    end


      




















__gfx__
33333300003333333333333222233333333333333333333333333333333333333333333222233333333333333333333333333333333333333333333333333333
33333000003333333333332222233333333333322223333333333332222333333333332222233333333333322223333333333330000333333333333333333333
33332222222333333333344444443333333333222223333333333322222333333333344444443333333333222223333333333300000333333333333333333333
33300000000033333333222222222333333334444444333333333444444433333333222222222333333334444444333333333222222233333333333333333333
33333000003333333333330000033333333322222222233333332222222223333333330000033333333322222222233333330000000003333333333333333333
33334000003333333003330000033333333333000003333333333300000333333333330000033333333333000003333333333300000333333333333333333333
33333400003333333023330000033333300333000003333330033300000333333333330000033333333333000003333333334300000333333333334333333333
3333444fff4333333222222fff233333302333000003333330233300000333333322002fff233333333333000003333333333444000333333333333442233333
33334444f023333333222222f043333332222222f043333332222222f043333333222022f0433333333322220043333333334444ff4333333333332224423333
33344442f043333333322224f023333333222224f023333333222224f023333333322224f0233333333222220023333333334444442333333333303002243333
33344444f043333333322222f023333333322222f023333333322222f023333333322222f023333333322222f023333333334444444433333332333000023333
33344444f043333333332222f023333333322222f023333333322222f023333333332222f023333333322222f023333333334444444440333233232000003333
33344444f043333333332222f023333333332222f043333333332222f043333333332222f023333333332222f043333333334444f04440033323322200033333
33344444f023333333332222f043333333332224f023333333332224f023333333332222f043333333332224f023333333334444f02303303333222220f33333
33334242f043333333332224f023333333332222f023333333332222f022333333332224f023333333332222f023333333334242f043333323322f240f233333
33332444ff43333333332222ff23333333332222ff23333333332222ff20333333332222ff23333333332222ff23333333332444ff43333333222220ff233333
33334444ff23333333332222ff43333333332222ff23333333332222ff43333333332222ff43333333332222ff43333333334444ff2333333302200ff2233333
33334442f043333333332224f223333333332224f223333333332224f223333333332224f223333333332224f223333333334442f04333323332222f43333333
3333444400433333333332000033333333332000003333333333320000033333333332000033333333333200003333333333444400433333232224ff23333333
3333444400433333333330030033333333330033003333333333300330033333333330030033333333333003003333333333444400433333322f2fff23333333
333344030033333333333003003333333333003300333333333330033003333333333003003333333333300300333333333344030033333332222f4233333333
33333003003333333333300300333333333300330033333333333003300333333333300300333333333330030033333333333003003333303002ff2333333333
333330030033333333333003003333333333003300333333333330033003333333333003003333333333300300333333333330030033333300002f2333333333
33333003003333333333300300333333333300330033333333333003300333333333300300333333333330030033333333333003003333330000033333333333
33333300003333332222333333333000033333333333333333333000033333333333333333333000033333333333333333333333333333333333333333333333
33333000003333332222233333330000033333333333333333330000033333333333333333330000033333333333333333333333333333300003333222233333
33332222222333344444443333322222223333333333333333322222223333333333333333322222223333333333333333333333333333000003333222223333
33300000000033222222222333000000000333333333333333000000000333333333333333000000000333333333333333333333333332222222334444444333
33333000003333330000033333330000033333333333333333330000033333333333333333330000033333333333333333333333333300000000022222222233
33334000003333330000033333340000033333322223333333340000033333333333333333340000033333333333333333333333333333000003333000003333
33333400003333330000033333334000033333322222333333334000033333333333333333334000033333333333333333333333333343000003333000003333
3333444fff432232fff22233333444fff433334444444333333444fff433333333333333333444fff43333333333333333333333333334440003000000003333
33334444f0244002222222233334444f02333222222222333334444f02333333323332333334444f023333333333333333333333333344444444000ff2223333
33334442f04440222222222333344444043000000000333333344444043000033342222333344444043000033333333333333333333344444444020f22222333
33334444f04443320f22223333344444444003300000333333344444444003303e24444233344444444003333333333333333333333344444443320f42222333
33334444404333320f222233333444444440333000003333333444444440333300e002423334444444403333333333333333333333334444f043320f22222333
33334444444333320f2222333334444f043333320f2223333334444f04332330300000243334444f04333333333333333333333333334444f043340002222333
33334444444003340f2222333334444f023333340f2222333334444f02333233000000233334444f02333333333333333333333333334444f023320002223333
33334244f44000320f4222333334242f043333320f4222333334242f04333320f0f208333334242f04333333333333333333333333334242f043320f22223333
33332444ff000302ff2222333332444f043333320f2222333332444f043323220f8222333332444f04333333333333333333333333332444ff4332ff22223333
33334444ff233334ff2222333334444ff23333340f2222333334444ff23332284f2222333334444ff2333333333333333333333333334444ff2334ff22223333
33334442f04333322f4222333334442f043333320f4222333334442f043330f0842222333334442f04333333333333333333233333334442f043322f42223333
3333444400433333000023333334444004333334ff222233333444400432300f0222233333344440043333333342422423332433333344440043330000233333
33334444004333330030033333344440043333322f400233333444400433220400223333333444400433333332fff80000002422333344440043330030033333
33334403003333330030033333344030033333330000233333344030033020ef4023333333344030033300000fff00fff00e2422333344030033330030033333
3333300300333333003003333333003003333333003e0333333300300303000e2333333333330030033300000424224280002422333330030033330030033333
333330030033333300300333333300300333333300008003333300300330000083333333333300300333000e0222222220002422333330030033330030033333
33333003003333330030033333330030033333330000000333330030030003003333333333330030033300800022222220082423333330030033330030033333
33333300003333322223333333333000033222233333333333333000033333333333333333333000033333333333333333333300003333333333333333333333
33333000003333322222333333330000033222223333333333330000032222333333333333330000003333333333333333333000003333333333333333333333
33332222222333444444433333322222224444444333333333322222222222233333333333322222223333333333333333332222222333333333333333333333
33300000000032222222223333000000000222222233333333000000000444443333333333000000000333333333333333300000000033333333333333333333
33333000003333300000333333330000033000003333333333330000022222222333333333330000033333333333333333333000003333333333333333333333
33334000003333300000333333340000033000003333333333340000030000033333333333340000033333333333333333334000003333333333333333333333
33333400003333300000333333334000043000003333333333334000040000033333333333334000033333333244242333333400003333333333333333333333
3333444fff43332fff222333333444fff42fff2223333333333444fff400000233333333333444fff4333333222222243333444fff4333333333333333333333
33334444f0244040f22222333334444f0240f222223333333334444f0240f222223333333334444f024333333200022233334444f02333333333333333333333
33334442f0444020222222333344442f0420f422223333333344442f0420f422223333333344442f044403333000000233334444404333333333333333333333
3333444440443320222223333344444f0420f222223333333344444f0420f822223333333344444f044003333000002233334444444333333333333333333333
333344444443330022222333344444440420f22223333333344444440420f222223333333344444404333333224f222333334444444400333333333333333333
333344444440000022222333344444000020f2222333333334444400002ef2222233333333444444000033332f0f822333334444444400033333333333333333
3333444444400300f2222333334444004440f02223333333334444004440822222333333334444440033333220ff422333334444f02000303333333333333333
33334244f0403320f4222333333424044420f00223333333333424044420f4222233333333342444043333220ef2222333334242404333333333333333333333
33332444ff43332ff22223333332444ff42ff222233333333332444ff48ff222003333333332444ff433332f0f82222333332444f04333333333333333333333
33334444ff23334ff22223333334444ff24ff222233333333334444ff24ff222233333333334444ff4333020ff42223333334444ff2333333333333333333333
33334442f0433322f42223333334442f0422f422233333333334442f0422f422233333333334442f043330820222233333334442f04333333333333333332333
333344440043333000023333333444400430000233333333333444400430000233333333333444400433324f0022233333334444004333333348422423332433
333344440043333003003333333444400430030033333333333444400430030033333333333444400433322f42223333333344440043333332fff0e000002422
33334403003333300300333333344030033003003333333333344030033003003333333333344030033330002222333333334403003300000fff08fff8002422
33333003003333300300333333330030033003003333333333330030033003003333333333330030033300000023333333333003003300000424228220002422
33333003003333300300333333330030033003003333333333330030033003003333333333330030033000000023333333333003003300000222222220002422
33333003003333300300333333330030033003003333333333330030033003003333333333330030033003000333333333333003003300000022222220002423
33333000033333333333333333333300003333333333333333333333333333333333300003333333333333333333300003333333333333333333333333333333
33330000033333222233333333333000003333333333333333333333333333333333000003333322223333333333000003333333333333333333333333333333
33322222223333222223333333332222222333333333333333333333333333333332222222333322222333333332222222333333333333333333333333333333
33000000000334444444333333300000000033333333333333333333333333333300000000033444444433333300000000033333333333333333333333333333
33330000033322222222233333333000003333333333333333333333333333333333000003332222222223333333000003333333333333333333333333333333
33030000033333000003333333334000003333333333333333333333333333333334000003333300000333333334000003333333333333333333333333333333
30034000033333000003333333333400003333333333333333333333333333333333400003333300000333333333400003333333333333333333333333333333
300444fff433330000033333333344444f433333333333333333333333333333333444fff433330000033333333444fff4333333333333333333333333333333
3044444f023333400222233333334444444333333333333333333333333333333334444f02333340022223333334444f02333333333333333333333333333333
3344424f043333200222223333334444444433333333333333333333333333333334444404300000022222333334444404300003333333333333333333333333
3334444f04333320f222223333334442444440333333333333333333333333333334444444400320f22222333334444444400333333333333333333333333333
3334444f04333320f222223333334444f04440033333333333333333333333333334444444403320f22222333334444444403333333333333333333333333333
3334444f04333340f222233333334444f04303303333333333333333333333333334444f04333340f22223333334444f04333333333333333333333333333333
3334444f02333320f422233333334444f02333333333333333333333333333333334444f02333320f42223333334444f02333333333333333333333333333333
3332424f04333320f222233333334242f04333333333333333333333333333333334242f04333320f22223333334242f04333333333333333333333333333333
3334444ff433332ff222233333332444ff4333333333333333333333333333333332444f0433332ff22223333332444f04333333333333333333333333333333
3334444ff233334ff222233333334444ff2333333333333333333333333333333334444ff233334ff22223333334444ff2333333333333333333333333333333
3334424f04333322f422233333334442f04333333333333333333333333333333334442f04333322f42223333334442f04333333333333333333333333332333
33344440043333300002333333334444004333333333333333222233323333333334444004333330000233333334444004333333333333333342428423332433
333444400433333003003333333344440043333333333322222222000242333333344440043333300300333333344440043333333333333332fff00e00002422
33344030033333300300333333334403003333333000002222222200024223333334403003333330030033333334403003333333333300000fff0feff0002422
333300300333333003003333333330030033333330000042422222000242233333330030033333300300333333330030033333333333000004242242e0002422
3333003003333330030033333333300300333333300000fff00fff00024223333333003003333330030033333333003003333333333300000222282220002422
33330030033333300300333333333003003333333000002ff0000000024233333333003003333330030033333333003003333333333300000022222220802423
33333000033333333333333333333000033333333333333333333333333330000333333333333333333333333333300003333333333333333333333333333333
33330000033333332222333333330000033333333322223333333333333300000333333333332222333333333333000003333333333333333333333333333333
33322222223333332222233333322222223333333322222333333333333222222233333333332222233333333332222222333333333333333333333333333333
33000000000333344444443333000000000333333444444433333333330000000003333333344444443333333300000000033333333333333333233333333333
33330000033333222222222333330000033333332222222223333333333300000333333333222222222333333333000003333333333333333334222333333333
33340000033333330000033333340000033333333300000333333333333400000333333333330000033333333334000003333333333333333324442233333333
33334000033333330000033333334000033333333300000333333333333340000333333333330000033333333333400003333333333333333332244433333333
333444fff433333300000333333444fff43333333300000333333333333444fff43333333333000083333333333444fff4333333333333333300022433333333
3334444f0233333340f222233334444f023333333340f822233333333334444f02333333333340fe222333333334444f02333333333333333300000233333333
33344444043000032ef222223334444404300003332ef22222333333333444440430000333332ef2222233333334444404300003333333333440008333333333
33344444444003332002222233344444444003333320e222223333333334444444400333333320e222223333333444444440033333333333320fe00333333333
33344444444033338002222233344444444033333380f222223333333334444444403333333380f22222333333344444444033333333333322ef222333333333
3334444f0433333340f222233334444f043333333340f222233333333334444f04333333333340f2822233333334444f043333333333333380fe222333333333
3334444f0233333320f422233334444f023333333320f022233333333334444f02333333333320f2222333333334444f023333333333333240f2222333333333
3334242f0433333320f222233334242f043333333320f002233333333334242f04333333333320f2022333333334242f04333333333333320f22222333333333
3332444f043333332ff222233332444f04333333332ff222233333333332444f0433333333332ff2002333333332444f04333333333333220f28223333333333
3334444ff23333334ff222233334444ff2333333334ff222233333333334444ff233333333334ff2222333333334444ff23333333333334ff202223333333333
3334442f0433333322f422233334442f043333333322f422233333333334442f04333333333322f4222333333334442f043333333333322ff200233333333333
333444400433333330000203333444400433333333300002333333333334444004333333333300000233333333344440043333333333330f4222333333333333
33344440043333333003300333344440043333333330030033333333333444400433333333330033003333333334444004333333333333000222333333333333
33344030033333333003300333344030033333333330030033333333333440300333333333330033003333333334403003333333333330030022333333333333
33330030033333333003300333330030033333333330030033333333333300300333333333330033003333333333003003333333333330030033333333333333
33330030033333333003300333330030033333333330030033333333333300300333333333330033003333333333003003333333333300300033333333333333
33330030033333333003300333330030033333333330030033333333333300300333333333330033003333333333003003333333333300300333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333233333333333333333333333233333333333333333333333333333333333333333333333233333333333333333333333333333333333
33333333334242242333243333333333334842242333243333333333333333333333233333333333334242842333243333333333333333333333333333333333
3333333332fff800000024223333333332fff0e00000242233333333322222e2200024233333333332fff00e0000242233333333333333333333333333333333
333300000fff00fff00e2422333300000fff08fff8002422333300000222822220002422333300000fff0feff00e242233333333333333333333333333333333
3333000004242242800024223333000004242282200024223333000004242222200024223333000004242242e000242233333333333333333333333333333333
3333000e0222222220002422333300000222222220002422333300000fff00fff000242233330000022228222000242233333333333333333333333333333333
3333008000222222200824233333000000222222200024233333000002ff00080000242333330000002222222080242333333333333333333333333333333333
__sfx__
900100002961229612096120961005615046100761003600036000060000600006000060000600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
58020000164731767011473084731767015675126750e6650c6650965506655036450164500635006250061500605006050060500605006050000500001000011700100001000000000000000000000000000000
54020000164731767011473084731767015675126750e6650c6650965506655036450164500635006250061500605006050060500605006050000500001000011700100001000000000000000000000000000000
900100002965229652096520965005655046400763003600036000060000600006000060000600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
