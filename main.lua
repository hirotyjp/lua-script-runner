
--local Config = require("lib.config")
local Common = require("lib.common")
local Init = require("lib.init")
local Runner = require("lib.runner")
local runner

function love.load()

    Init.init()

    runner = Runner.new()

    runner:load_config("./data/config.txt")
    runner:load_scean_files({
        "data/splash.txt",
        "data/start.txt",
        "data/prologue.txt",
    })

    runner:start("data/start.txt")

end

function love.keypressed(key)
    runner:keypressed(key)
end

function love.mousemoved(...)
    runner:mousemoved(...)
end

function love.mousepressed(...)
    runner:mousepressed(...)
end

function love.mousereleased(...)
    runner:mousereleased(...)
end

function love.update(dt)
    runner:update(dt)
end

function love.draw()
    runner:draw()
end

function love.quit()
  -- return Init.quit()
end

