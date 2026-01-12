-- Button module
--
--  Image spec:
--     0        1/3       2/3       1.0
--     +---------+---------+---------+
--     | Normal  | Hover   | Click   |
--     +---------+---------+---------+
--

local utf8 = require("utf8")
local Common = require("lib.common")

local Button = {}

Button.__index = Button

function Button.new(args)

    local self = setmetatable({}, Button)
    local image = love.graphics.newImage(args.file)

    self.file = args.file
    self.image = image
    self.top = args.top
    self.left = args.left
    self.width = image:getWidth() / 3
    self.height = image:getHeight()
    self.quad = love.graphics.newQuad(0, 0, self.width, self.height, self.image:getDimensions())
    self.callback = args.callback
    self.opacity = args.opacity or 1
    self.class = args.class
    self.canceled = false
    return self
end

function Button:mousereleased(x, y, button, istouch, presses)
    if Common.is_in_rect(x, y, self.left, self.top, self.width, self.height) then
        -- Hover
        self.quad:setViewport(self.width, 0, self.width, self.height)
    end
end

function Button:mousemoved(x, y, dx, dy, istouch)
    if Common.is_in_rect(x, y, self.left, self.top, self.width, self.height) then
        -- Hover
        self.quad:setViewport(self.width, 0, self.width, self.height)
    else
        -- Normal
        self.quad:setViewport(0, 0, self.width, self.height)
    end
end

-- Click
function Button:mousepressed(x, y, button)
    if self.canceled then return end
    if Common.is_in_rect(x, y, self.left, self.top, self.width, self.height) then
        self.quad:setViewport(self.width * 2, 0, self.width, self.height)
        if self.callback then self.callback(self) end
    end
end

function Button:update(dt)
end

function Button:draw()
    love.graphics.setColor(1, 1, 1, self.opacity)
    love.graphics.draw(self.image, self.quad, self.left, self.top)
end

return Button
