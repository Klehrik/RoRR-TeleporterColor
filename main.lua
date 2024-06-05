-- Teleporter Color v1.0.0
-- Klehrik

log.info("Successfully loaded ".._ENV["!guid"]..".")
mods.on_all_mods_loaded(function() for k, v in pairs(mods) do if type(v) == "table" and v.hfuncs then Helper = v end end end)

local frame = 0
local particles = {}

local choice = 1
local choices = {
    "Yellow",
    "Cyan",
    "Blue",
    "White",
    "RGB"
}
local colors = {
    gm.make_color_hsv(60, 255, 255),
    gm.make_color_hsv(128, 255, 255),
    gm.make_color_hsv(170, 255, 255),
    gm.make_color_hsv(0, 0, 255),
    gm.make_color_hsv(0, 0, 0)
}



-- ========== Functions ==========

function get_rgb()
    return gm.make_color_hsv(frame % 255, 255, 255)
end



-- ========== Main ==========

gui.add_imgui(function()
    if ImGui.Begin("Teleporter Color") then
        for i, c in ipairs(choices) do
            value, pressed = ImGui.RadioButton(c, choice, i)
            if pressed then choice = value end
        end
    end

    ImGui.End()
end)


gm.pre_code_execute(function(self, other, code, result, flags)
    if code.name:match("pTeleporter_Draw_0") then
        frame = frame + 1

        -- Draw surrounding particles
        for _, p in ipairs(particles) do
            -- Move
            p.x = p.x + (gm.dcos(p.dir) * p.speed)
            p.y = p.y + (-gm.dsin(p.dir) * p.speed)

            -- Change alpha
            p.alpha = p.alpha + (p.fade_speed * p.fade_dir)
            if p.alpha >= 1.0 then p.fade_dir = -1
            elseif p.alpha <= 0.0 then table.remove(particles, _)
            end

            -- Draw
            local col = colors[choice]
            if choice == 5 then col = get_rgb() end
            gm.draw_set_alpha(p.alpha)
            gm.draw_circle_color(p.x, p.y, p.size, col, col, p.hollow)
            gm.draw_set_alpha(1.0)
        end


        if self.active == 0.0 then
            -- Override Draw event and manually draw teleporter
            gm.shader_set(gm.constants.shd_change_outline)

            local col = colors[choice]
            if choice == 5 then col = get_rgb() end
            
            local col_vec3 = gm.array_create(3)
            gm.array_set(col_vec3, 0, gm.color_get_red(col) /255.0)
            gm.array_set(col_vec3, 1, gm.color_get_green(col) /255.0)
            gm.array_set(col_vec3, 2, gm.color_get_blue(col) /255.0)

            local u_col = gm.shader_get_uniform(gm.constants.shd_change_outline, "u_col")
            gm.shader_set_uniform_f_array(u_col, col_vec3)

            gm.draw_sprite(self.sprite_index, self.image_index, self.x-1, self.y)
            gm.draw_sprite(self.sprite_index, self.image_index, self.x+1, self.y)
            gm.draw_sprite(self.sprite_index, self.image_index, self.x, self.y-1)
            gm.draw_sprite(self.sprite_index, self.image_index, self.x, self.y+1)
            
            gm.shader_reset()
            
            gm.draw_sprite(self.sprite_index, self.image_index, self.x, self.y)


            -- Add particles
            if Helper.chance(4 /60.0) then  -- numerator is avg. parts per second
                local dir = gm.random_range(0, 360)
                local offset = gm.random_range(150, 500)

                table.insert(particles, {
                    x           = self.x + (gm.dcos(dir) * offset),
                    y           = self.y + (-gm.dsin(dir) * offset),
                    dir         = dir - 180,
                    speed       = gm.random_range(0.1, 0.35),
                    alpha       = 0.0,
                    fade_speed  = gm.random_range(0.5 /60.0, 1.5 /60.0),
                    fade_dir    = 1.0,
                    size        = gm.irandom_range(1, 3),
                    hollow      = gm.choose(true, false)
                })
            end

            return false
        end

    end
end)