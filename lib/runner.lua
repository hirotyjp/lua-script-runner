--  Script Runner
--

local Common = require("lib.common")
local Parser = require("lib.parser")
local UI = require("lib.ui")

local Runner = {}

local resume = nil     -- wait for some reason / todo: move to self

local CONST = {
    WAIT_TRANSITION = "wait_transition",
    WAIT_INPUT      = "wait_input",
    WAIT_INFINITY   = "wait_infinitiy",
}

Runner.__index = Runner

function Runner.new()
    local self = setmetatable({}, Runner)
    self.scenario_files = {}
    self.timeout = 0
    self.sequence = nil
    self.ui = nil
    self.bg = nil
    return self
end

function Runner:load_config(file)
    -- not yet implemented
    log(file)
end

function Runner:load_scean_files(files)
    self.scenario_files = files
end

function Runner:call()
    print("----- callback ------------------")
    vardump(self)
end

function Runner:start(file)

    local p = Parser.new(self.scenario_files)

    p:start_runner(file)

    self.ui = UI.new()
    self.ui:set_font("fonts/NotoSerifJP-SemiBold.ttf", 24)

    -- main sequence
    self.sequence = coroutine.create(function()

        while true do
            local file, cmd, args = p:get_next()

            local x,y = p:tell()

            -- For debugging
            log(string.format("%s : %s > %s ", x,y,cmd))

            if not cmd then break end

            -- Show LINK
            if cmd == "LINK" then
                args.callback = function(e)
                    p:jump(args.jump)
                    resume = nil -- any good solution!!
                end
                self.ui:add_link(args)

            -- STYLE
            elseif cmd == "STYLE" then    self.ui:set_style(args)

            -- IMAGE
            elseif cmd == "IMAGE" then    self.ui:set_image(args)
            elseif cmd == "CLEAR" then    self.ui:clear_image(args)
            elseif cmd == "PURGE" then    self.ui:purge_layer(args)

            -- SHADER
            elseif cmd == "SHADER" then   self.ui:set_shader(args)

            -- MESSAGE
            elseif cmd == "MESSAGE" then   self.ui:set_message_window(args)
            elseif cmd == "TEXT"    then   self.ui:set_message(args)

            -- TRANSITION
            elseif cmd == "TRANS" then   self.ui:set_transition(args)

            -- WAIT
            elseif cmd == "WAIT" then    self:wait_transition()      -- wait transition
            elseif cmd == "PAUSE" then   self:wait_input(args)       -- wait click
            elseif cmd == "STOP" then    self.wait_infinitiy(args)   -- stop compeltely

            end

        end
        
        log("INFO: Current Coroutine has been finished.")
    end)


end


function Runner:wait_transition()
    coroutine.yield(CONST.WAIT_TRANSITION)
end

function Runner:wait_input(args)
    self.timeout = args.timeout or nil -- Inifinity
    coroutine.yield(CONST.WAIT_INPUT)
end

function Runner:wait_infinitiy(args)
    --self.timeout = math.maxinteger
    coroutine.yield(CONST.WAIT_INFINITY)
end

function Runner:keypressed(key)
    if resume == CONST.WAIT_INPUT then
        resume = nil
    end
end

function Runner:mousemoved(x, y, dx, dy, istouch)
    self.ui:mousemoved(x, y, dx, dy, istouch)
end

function Runner:mousepressed(x, y, button, istouch, presses)
    log(string.format("Waiting: %s, Blocking: %s, Pointer: top=%d left=%d", resume, self.ui:is_blocking(), y, x))
    self.ui:show_screen_status()

    -- Do Resume! if WAIT INPUT
    if resume == CONST.WAIT_INPUT then
        resume = nil
    end

    if self.ui:is_blocking() then
        return
    end

    self.ui:mousepressed(x, y, button, istouch, presses)
end

function Runner:mousereleased(x, y, button, istouch, presses)
    self.ui:mousereleased(x, y, button, istouch, presses)
end

function Runner:update(dt)

    self.ui:update(dt)

    if self.timeout and self.timeout > 0 then
        self.timeout = self.timeout - dt
    end

    -- TODO: move to Function
    if self.sequence and coroutine.status(self.sequence) ~= "dead" then

        if resume == nil then
            ok, resume = coroutine.resume(self.sequence, dt)

            if not ok then
              local err = tostring(resume)
              local msg = debug.traceback(self.sequence, "Error in coroutine: "..err, 2)
              error(msg)
            end
        end
    end

    -- WAIT Transition / Resume after blocking is cleared
    if resume == CONST.WAIT_TRANSITION and self.ui:is_blocking() == false then
        resume = nil
    end

    -- Resume after Key input timeout
    if resume == CONST.WAIT_INPUT and self.timeout and self.timeout <= 0 then
        self.timeout = 0
        resume = nil
    end

end

function Runner:draw()
    self.ui:draw()
end

return Runner
