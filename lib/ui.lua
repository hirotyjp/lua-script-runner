-- UI module
-- 

local utf8 = require("utf8")
local Common = require("lib.common")
local Message = require("lib.message")
local Button = require "lib.button"
local Link = require "lib.link"
local Timer = require "lib.timer"
local UI = {}

UI.__index = UI

function UI.new()
    local self = setmetatable({}, UI)

    self.timer = Timer.new()
    self.transition = 0
    self.interval = 0.03
    self.index = 0

    self.layer = {}
    self.layer.bg = {}
    self.layer.fg = {}
    self.layer.controls = {}
    self.layer.msg = {}

    self.style = {}

    return self
end

function UI:mousemoved(...)
    for i, v in ipairs(self.layer.controls) do
        v:mousemoved(...)
    end
end

function UI:mousepressed(...)
    for i, v in ipairs(self.layer.controls) do
        v:mousepressed(...)
    end
end

function UI:mousereleased(...)
    for i, v in ipairs(self.layer.controls) do
        v:mousereleased(...)
    end
end

function UI:set_font(file, size)
    local font = love.graphics.newFont(file, size)
    love.graphics.setFont(font)
end

function UI:is_blocking()
    return (self.transition > 0)
end

function UI:set_transition(args)

    local hit = false
    local begin_trans = function()
        self.transition = self.transition + 1
    end

    local end_trans = function()
        self.transition = self.transition - 1
    end

    local target_layer = {
        self.layer.bg,
        self.layer.fg,
        self.layer.controls,
        self.layer.msg,
    }

    for _, t in ipairs(target_layer) do
        for _, v in pairs(t) do
            if v.class and v.class == args.class then
                begin_trans()
                self.timer:tween(args.duration, v, args.target, args.method or "linear", end_trans)
                hit = true
            end
        end
    end

    if not hit then
        log("Warning: Class not found: " .. args.class)
    end
end
--
--  Debug
--
function UI:show_screen_status()
    for i, v in ipairs(self.layer.bg) do
        print(i, "Layer: GB, Type: ", (v.image or v.shader), "File:", v.file, "Class: ", v.class)
    end
    for i, v in ipairs(self.layer.fg) do
        print(i, "Layer: FG, Type: ", (v.image or v.shader), "File:", v.file, "Class: ", v.class)
    end
end

--
--  Layer
--
function UI:purge_layer(args)
    if args.layer == "bg" then
        local latest = nil
        for i = #self.layer.bg, 1, -1 do
            if self.layer.bg[i].image then
                latest = self.layer.bg[i]
                break
            end
        end

        if latest then
            self.layer.bg = {latest}  -- Keeping latest image
        end

    elseif args.layer == "fg" then
        print("Not implemented yet")
    else
        log("Error: unknown layer:" .. args.layer)
    end

end

--
--  Shader
--
function UI:set_shader(args)
    if args.file then
        args.shader = love.graphics.newShader(args.file)
    else
        args.unset_shader = true
    end
    table.insert(self.layer.bg, args)
end

--
-- Image
--
function UI:insert_image(t, args)
    for i = 1, #t do
        if ( args.z or 0) < (t[i].z or 0) then
            table.insert(t, i, args)
            return
        end
    end
    table.insert(t, args)
end

function UI:set_image(args)
    args.image = love.graphics.newImage(args.file)

    -- Forcefully set a opacity if omitted
    if args.opacity == nil then
        args.opacity = 1
    end

    if args.layer == "bg" then
        table.insert(self.layer.bg, args)
    elseif args.layer == "fg" then
        self:insert_image(self.layer.fg, args)
    else
        log("Error: unknown layer:" .. args.layer)
    end
end

function UI:clear_image(args)
    if args.layer == "bg" or args.layer == "all" then
        self.layer.bg = {}
    end
    if args.layer == "fg" or args.layer == "all" then
        self.layer.fg = {}
    end
    if args.layer == "controls" or args.layer == "all" then
        self.layer.controls = {}
    end
    if args.layer == "msg" or args.layer == "all" then
        self.layer.msg = {}
    end

end

function UI:set_style(args)
    self.style = args
end

--
-- Message
--
function UI:set_message_window(args)
    table.insert(self.layer.msg, Message.new(args))
end

function UI:set_message(args)
    if #self.layer.msg == 0 then
        self:set_message_window({})
    end
    self.layer.msg[args.target or 1]:set_message(args)
end

--
-- Control
--
function UI:add_button(args)
    table.insert(self.layer.controls, Button.new(args))
end

function UI:add_link(args)
    table.insert(self.layer.controls, Link.new(args, self.style))
end

--
-- Core functions
--
function UI:update(dt)
    self.timer:update(dt)

    -- Message Layer
    for i,v in ipairs(self.layer.msg) do
        v:update(dt)
    end
end

function UI:draw()

    -- Back-ground Layer
    for i, v in ipairs(self.layer.bg) do

        if v.image then
            love.graphics.setColor(1, 1, 1, v.opacity)
            love.graphics.draw(v.image, v.left, v.top)

        elseif v.shader then
            if v.progress then
                v.shader:send("progress", v.progress)
            end
            love.graphics.setShader(v.shader)

        elseif v.unset_shader then
            love.graphics.setShader()

        end

    end

    -- Fore-ground Layer
    for i,v in ipairs(self.layer.fg) do
    
        -- todo : shader
        love.graphics.setColor(1, 1, 1, v.opacity)
        love.graphics.draw(v.image, v.left, v.top)
    end

    -- Control Layer
    for i,v in ipairs(self.layer.controls) do
        v:draw()
    end

    -- Message Layer
    for i,v in ipairs(self.layer.msg) do
        v:draw()
    end

end

return UI


