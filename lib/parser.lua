----------------------------------------------------------------------------------------------------------
---- Scenario Script parser
----
----------------------------------------------------------------------------------------------------------

local Func = require("functions")
----------------------------------------------------------------------------------------------------------
---- Pramaters
----------------------------------------------------------------------------------------------------------

local parser = {}
parser.__index = parser

local command_list = {
    -- true > return current position
    -- false > proceed next automatically
    CMD    = false,
    CALL   = false,
    RETURN = false,
    JUMP   = false,
    IF     = false,
    ELSE   = false,
    ENDIF  = false,
    ELSEIF = false,
    LOG    = false,
    TEXT   = true,
    LINK   = true,
    STOP   = true,
    WAIT   = true,
    LAYER  = true,
    ERROR  = true,
    IMAGE  = true,
    TRANS  = true,
    WAIT   = true,
    PAUSE  = true,
    CLEAR  = true,
    STYLE  = true,
    MESSAGE = true,
    SHADER = true,
    PURGE = true,
}

----------------------------------------------------------------------------------------------------------
---- Private local method
----------------------------------------------------------------------------------------------------------
local function is_comment(s)
    if s:find("^[#;]") or s:len() == 0 then
        return true
    end
end

local function parse_command(line)
    local cmd_name = line:match("^@(%S+)"):upper()
    local script = line:match("^@%S+%s+(.*)") or ""

    if command_list[cmd_name] ~= nil then
        return cmd_name, script
    end
    
    return nil -- undefined command
end

local function store_label(self, filename, content, line_num)
    if self.labels[filename][content] then
        error(string.format("Syntax error: Label '%s' is duplicated, File: %s, Line: %d", content, filename, line_num))
    end
    self.labels[filename][content] = line_num
end

-- Parser for pre syntax check
local function parse_single_file(self, filename)
    local cond_level = 0

    self.labels[filename] = {}
    self.scripts[filename] = {}

    for line_num, line in ipairs(Func.read_lines(filename)) do

        local mode
        local head = line:sub(1,1)

        if is_comment(line) then
            goto continue
        end

        if head == "*" then
            if cond_level > 0 then
                error(string.format("Syntax error: Putting a label in a IF condition is not acceptable, File: %s, Line: %d", filename, line_num))
            end
        
            mode = "LABEL"
            content = line
            store_label(self, filename, content, #self.scripts[filename] + 1)

        elseif head == "@" then
            mode, content = parse_command(line)

            if mode == "IF" then
                cond_level = cond_level + 1

            elseif mode == "ENDIF" then
                cond_level = cond_level - 1
                if cond_level < 0 then
                    error(string.format("Syntax error: Too many ENDIF, File: %s, Line: %d", filename, line_num))
                end

            elseif mode == "ELSE" then
                if cond_level < 1 then
                    error(string.format("Syntax error: ELSE is not expected, File: %s, Line: %d", filename, line_num))
                end
            end

            if mode == nil then
                error(string.format("Syntax error: Undefined command, File: %s, Line: %d, Content: %s", filename, line_num, line))
            end

        else
            mode = "TEXT"
            content = "text=" .. line

        end

        table.insert(self.scripts[filename], {mode, content})

        ::continue::
    end
    
    if cond_level ~= 0 then
        error("Syntax error: IF condition is not closed properly")
    end
end

local function get_pos_from_label(self, filename, label)
    -- self.current_file should not be used
    if label then
        if self.labels[filename][label] then
            return self.labels[filename][label]
        else
            error("Syntax error: Label not found: " .. label)
        end
    else
        return 1
    end
end

-- For condition --   Skip to ENDIF
local function find_endif(self)
    local filename = self.current_file
    while true do
        self.current_pos = self.current_pos + 1
        local cmd, content = table.unpack(self.scripts[filename][self.current_pos])

        if cmd == "IF" then
            find_endif(self)
        elseif cmd == "ENDIF" then
            return
        end
    end
end

-- For false condition in previous expression only 
--   Skip to next ELSEIF, ELSE or ENDIF 
local function find_next_elseif_condition(self)
    local filename = self.current_file
    while true do
        self.current_pos = self.current_pos + 1
        
        local cmd, content = table.unpack(self.scripts[filename][self.current_pos])

        if cmd == "IF" then
            find_endif(self) -- skip to ENDIF
        end

        if cmd == "ELSEIF" then
            local result = load("return " .. content, "command_condition", "t", {tt=self})()
            --print(" == ELSEIF RESULT: ", tostring(result), self.current_pos)

            if result then
                self.condition_stack[#self.condition_stack] = true
                return
            end
        end

        if cmd == "ELSE" or cmd == "ENDIF" then
            self.condition_stack[#self.condition_stack] = true
            return
        end
    end

end

----------------------------------------------------------------------------------------------------------
-- Command logics 
----------------------------------------------------------------------------------------------------------

local function command_condition(self, cmd, content)

    if cmd == "IF" then
        local result = load("return " .. content, "command_condition", "t", {tt=self})()
        --print(" == RESULT: ", tostring(result) )
        table.insert(self.condition_stack, result)

        if result then
            return -- true
        else
            find_next_elseif_condition(self) -- False
            return
        end

    elseif cmd == "ELSEIF" or cmd == "ELSE" then
        --Func.dump_table(self.condition_stack)
        if self.condition_stack[#self.condition_stack] then
            find_endif(self)
            return
        end

    elseif cmd == "ENDIF" then
        table.remove(self.condition_stack)

    end
end

local function command_call(self, args)

    table.insert(self.call_stack, {file=self.current_file, pos=self.current_pos})

    if args.file then
        self.current_file = args.file
    end

    self.current_pos = get_pos_from_label(self, self.current_file, args.label)

end

local function command_return(self)

    if #self.call_stack == 0 then
        error("Error: No call stack")
    end

    local pop = table.remove(self.call_stack)
    
    self.current_file = pop.file
    self.current_pos = pop.pos
end

local function command_jump(self, content)

    local filename = self.current_file
    local target = nil

    -- TODO
    if content:sub(1,1) == "*" then
        -- only label is specified
        filename = self.current_file
        target = content
    elseif string.find(content, ":") then
        -- both are specified
        filename, target = content:match("^(.+):(.+)$")
    else
        -- only filename is specified
        filename = content
    end

    self.current_pos = get_pos_from_label(self, filename, target)
    self.current_file = filename
end

local function command_logging(self, content)
    local val = load("return " .. content, "command_logging", "t", {tt=self})()
    print(string.format(" | LOGGING: %s=%s", content, val))
end

local function command_exec(self, content)
    load(content, "command_exec", "t", {tt=self})()
end

----------------------------------------------------------------------------------------------------------
---- Public method
----------------------------------------------------------------------------------------------------------
function parser:start_runner(filename, label)

    if not self.scripts[filename] then
        error(string.format("Scenario file '%s' does not exist.", filename))
    end

    self.current_file = filename
    self.current_pos = get_pos_from_label(self, filename, label)
end

-- Describes self table
--
function parser:desc()
    Func.dump_table(self)
end

-- Returns current position
--
function parser:tell()
    return self.current_file, self.current_pos
end


---------------------
function parser:jump(label)
    self:start_runner(self.current_file, label)
end

-- Returns next action for client
--
function parser:get_next()

    while true do

        local filename = self.current_file

        if self.scripts[filename] == nil then
            error("Scenario file not found: " .. filename)
        end

        if self.current_pos > #self.scripts[filename] then
            return nil
        end
        
        local cmd = self.scripts[filename][self.current_pos][1]
        local content = self.scripts[filename][self.current_pos][2]
        local args = nil

        -- TABLE Converter / TODO: Improvement
        if table.contains({
            "CALL","IMAGE", "TRANS", "PAUSE",
            "WAIT", "CLEAR", "MESSAGE", "SHADER", "PURGE"
        }, cmd) then
            args = Func.parse_line(content)

        elseif cmd == "TEXT" then
            args = Func.parse_text_line(content)

        elseif cmd == "LINK" then
            args = Func.parse_kv_japanese(content)

        elseif cmd == "STYLE" then
            args = Func.parse_mixed_line(content)

        end

        -- COMMAND
        if cmd == "ERROR" then
            error(string.format("Intentional Exception caused: %s, File:%s, Line:%d", content, filename, self.current_pos))

        elseif cmd == "STOP" then
            --return nil

        elseif cmd == "LOG" then
            command_logging(self, content)

        elseif cmd == "CMD" then
            command_exec(self, content)

        elseif cmd == "JUMP" then
            command_jump(self, content)
            goto continue

        elseif cmd == "CALL" then
            command_call(self, args)
            goto continue

        elseif cmd == "RETURN" then
            command_return(self)

        elseif table.contains({"IF","ELSEIF","ELSE","ENDIF"}, cmd) then
            command_condition(self, cmd, content)

        end

        self.current_pos = self.current_pos + 1

        -- can proceed next automatically or not
        if command_list[cmd] then
            return filename, cmd, args or content
        end
    
        ::continue::
    end
end


----------------------------------------------------------------------------------------------------------
---- constructor
----------------------------------------------------------------------------------------------------------
function parser.new(files)

    local self = setmetatable({}, parser)

    self.labels = {}
    self.scripts = {}
    self.current_file = nil
    self.current_pos = nil
    self.condition_stack = {}
    self.call_stack = {}

    for _, filename in ipairs(files) do
        parse_single_file(self, filename)
    end

    return self
end

----------------------------------------------------------------------------------------------------------
---- Returns table
----------------------------------------------------------------------------------------------------------
return parser

