-- Text Link module
--

local utf8 = require("utf8")
local Common = require("lib.common")

local Link = {}

Link.__index = Link

function Link.new(args, style)
    local self = setmetatable({}, Link)

    self.text = args.text
    self.top = args.top
    self.left = args.left
    self.width = args.width
    self.align = style.align or "left"
    self.callback = args.callback
    self.height = args.height or love.graphics.getFont():getHeight()
    self.hover_color = style.hover or {0.2, 0.2, 0.2, 1}
    self.click_color = style.click or {1, 1, 1, 1}
    self.normal_color = style.color or {0, 0, 0, 1}
    self.color = self.normal_color    -- current color
    self.on_hover = false
    self.class = style.class or args.class or nil
    self.opacity = style.opacity or args.opacity or 1
    self.selected = false

    return self
end

function Link:mousereleased(x, y, Link, istouch, presses)
    if Common.is_in_rect(x, y, self.left, self.top, self.width, self.height) then
        self.color = self.hover_color
    end
end

function Link:mousemoved(x, y, dx, dy, istouch)
    if Common.is_in_rect(x, y, self.left, self.top, self.width, self.height) then
        self.on_hover = true
        self.color = self.hover_color
    else
        self.on_hover = false
        self.color = self.normal_color
    end
end

function Link:mousepressed(x, y, Link)
    if Common.is_in_rect(x, y, self.left, self.top, self.width, self.height) and (not self.selected) then
        self.color = self.click_color
        self.selected = true
        if self.callback then self.callback(self) end
    end
end

function Link:update(dt)
end

function Link:draw()
    self.color[4] = self.opacity

    love.graphics.setColor(0, 0, 0, 0.3 * self.opacity)
    love.graphics.rectangle("fill", self.left, self.top, self.width, self.height)
    love.graphics.setColor(self.color)
    love.graphics.printf(self.text, self.left, self.top, self.width, self.align)

    if self.on_hover then
        love.graphics.setColor(0, 0, 0, 0.3 * self.opacity)
        love.graphics.rectangle("fill", self.left, self.top, self.width, self.height)
    end
end

return Link
