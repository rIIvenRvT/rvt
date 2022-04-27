script_name("rIIven")
script_version("2")
require 'lib.moonloader'

local imgui, ffi = require 'mimgui', require 'ffi'
local new, str = imgui.new, ffi.string
local vkeys = require 'vkeys'
local encoding = require 'encoding'
encoding.default = 'CP1251'
local u8 = encoding.UTF8
local broadcaster = import('lib/broadcaster.lua')
local dlstatus = require('moonloader').download_status
local new, str, sizeof = imgui.new, ffi.string, ffi.sizeof

--local faicons = require 'fa-icons'

local bWindow = new.bool()
local userList = 'Jogadores:'

local obj = new.char[256]('Objetos')

local xx = new.char[256]('')
local yy = new.char[256]('')
local zz = new.char[256]('')

local menu_label = new.int(1)
local menu_pos = new.int(0)
local menu = {
    u8'Troller',
    u8'Teleportes',
    u8'Veiculos',
    u8'Jogadores',
}

function main()
    broadcaster.registerHandler('FPSUP', myHandler)
    while true do

    wait(0)
        if wasKeyPressed(vkeys.VK_L) then
            bWindow[0] = not bWindow[0]
        end
     end
end

imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil
    imgui.SpotifyTheme()
end)

imgui.OnFrame(function () 
    return bWindow[0] end,
function ()
    local resX, resY = getScreenResolution()
    local sizeX, sizeY = 400, 250
    local size = imgui.ImVec2(230, 25)
    imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY), imgui.Cond.FirstUseEver)
    imgui.Begin('Mod Controlador', bWindow, imgui.WindowFlags.NoResize)

    imgui.Selector(menu, imgui.ImVec2(130, 40), menu_label, menu_pos, 10)
    imgui.SetCursorPos(imgui.ImVec2(150, 40))
    imgui.BeginChild('main', imgui.ImVec2(240, 200), true)
    if menu_label[0] == 1 then
        imgui.PushItemWidth(200)

        if imgui.Button('Abrir Site', size) then broadcaster.sendMessage('site', 'FPSUP') end
        if imgui.Button('Criar Objetos', size) then imgui.OpenPopup('CriarObejetos') end
        if imgui.Button('UPDATE ME!') then
            printStringNow('Updating!', 1000)
            update()
        end
        imgui.Text("Now version "..thisScript().version)


        local sizeX, sizeY = -430, 250
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2 - sizeX / 2, resY / 2 - sizeY / 2), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowSize(imgui.ImVec2(250, 250), imgui.Cond.FirstUseEver + imgui.WindowFlags.NoResize)
        if imgui.BeginPopupModal('CriarObejetos') then
            imgui.BeginChild('main', imgui.ImVec2(240, 215), true)

            imgui.InputText(u8"- ID", obj, sizeof(obj))

            if imgui.Button('Setar Objeto', size) then
                broadcaster.sendMessage(u8:decode('CriarOBJ '..str(obj)), 'FPSUP')
            end

            if imgui.Button('Fechar', size) then imgui.CloseCurrentPopup() end
            imgui.EndChild()
            imgui.EndPopup()
        end
    end
    if menu_label[0] == 2 then
        if imgui.Button('Mandar para o Norte', size) then broadcaster.sendMessage('irN', 'FPSUP') end
        if imgui.Button("Trazer Players", size) then
            broadcaster.sendMessage('trazer '..(table.concat({getCharCoordinates(PLAYER_PED)}, "Trazer")), 'FPSUP')
        end
    end
    if menu_label[0] == 3 then
        if imgui.Button('Cair Carro', size) then broadcaster.sendMessage('CairCarro', 'FPSUP') end
    end
    if menu_label[0] == 4 then
        imgui.Text(userList) 
    end
    imgui.EndChild()

   imgui.End()
end)

function myHandler(message) --send
    if message:find('userConnected (.+)') then
        connectedUser = message:match('userConnected (.+)')
        if not userList:find(connectedUser) then userList = userList..'\n'..connectedUser end
    else
        sampAddChatMessage('Enviado ao jogador: '..message, -1)
    end
end

function onScriptTerminate(scr)
    if scr == thisScriptt() then
        broadcaster.unregisterHandler('FPSUP')
    end
end

function update()
    local fpath = os.getenv('TEMP') .. '\\testoviy_version.json' -- onde nosso arquivo será baixado para comparação de versões
    downloadUrlToFile('https://github.com/rIIvenRvT/rvt/raw/main/Mimgui.lua', fpath, function(id, status, p1, p2) -- um link para seu github onde ha linhas que eu digitei no topico ou em qualquer outro site
      if status == dlstatus.STATUS_ENDDOWNLOADDATA then
      local f = io.open(fpath, 'r') -- abre um arquivo
      if f then
        local info = decodeJson(f:read('*a')) -- está lendo
        updatelink = info.updateurl
        if info and info.latest then
          version = tonumber(info.latest) -- converte a versão em número
          if version > tonumber(thisScript().version) then -- se a versão for maior que a versão instalada então...
            lua_thread.create(goupdate) -- atualizar
          else -- se menos então
            update = false -- não nos atualizemos
            sampAddChatMessage(('[Testing]: Voce ja tem a versao mais recente! Atualizacao cancelada'), color)
          end
        end
      end
    end
  end)
end

function goupdate()
    sampAddChatMessage(('[Testing]: Atualizacao encontrada. AutoReload pode entrar em conflito. estou atualizando...'), color)
    sampAddChatMessage(('[Testing]: Versao Atual: '..thisScript().version..". Uma nova versao: "..version), color)
    wait(300)
    downloadUrlToFile(updatelink, thisScript().path, function(id3, status1, p13, p23) -- baixa seu arquivo da versao mais recente
      if status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
      sampAddChatMessage(('[Testing]: Atualizacao completa!'), color)
      thisScript():reload()
    end
    end)
end

function imgui.SpotifyTheme() -- https://www.blast.hk/members/112329/
    
    imgui.SwitchContext()
    --==[ STYLE ]==--
    imgui.GetStyle().WindowPadding = imgui.ImVec2(5, 5)
    imgui.GetStyle().FramePadding = imgui.ImVec2(5, 5)
    imgui.GetStyle().ItemSpacing = imgui.ImVec2(5, 5)
    imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(4, 4)
    imgui.GetStyle().TouchExtraPadding = imgui.ImVec2(5, 5)
    imgui.GetStyle().IndentSpacing = 5
    imgui.GetStyle().ScrollbarSize = 10
    imgui.GetStyle().GrabMinSize = 10

    --==[ BORDER ]==--
    imgui.GetStyle().WindowBorderSize = 0
    imgui.GetStyle().ChildBorderSize = 1
    imgui.GetStyle().PopupBorderSize = 0
    imgui.GetStyle().FrameBorderSize = 0
    imgui.GetStyle().TabBorderSize = 0

    --==[ ROUNDING ]==--
    imgui.GetStyle().WindowRounding = 5
    imgui.GetStyle().ChildRounding = 5
    imgui.GetStyle().FrameRounding = 5
    imgui.GetStyle().PopupRounding = 5
    imgui.GetStyle().ScrollbarRounding = 5
    imgui.GetStyle().GrabRounding = 5
    imgui.GetStyle().TabRounding = 5

    --==[ ALIGN ]==--
    imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().SelectableTextAlign = imgui.ImVec2(0.5, 0.5)

    --==[ COLORS ]==--
    imgui.GetStyle().Colors[imgui.Col.Text]                   = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
    imgui.GetStyle().Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ChildBg]                = imgui.ImVec4(0.09, 0.09, 0.09, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.09, 0.09, 0.09, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Border]                 = imgui.ImVec4(0, 0, 0, 0.5)
    imgui.GetStyle().Colors[imgui.Col.BorderShadow]           = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)

    imgui.GetStyle().Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)

    imgui.GetStyle().Colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]          = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]   = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(0.51, 0.51, 0.51, 1.00)
    
    imgui.GetStyle().Colors[imgui.Col.CheckMark]              = imgui.ImVec4(0.11, 0.73, 0.33, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrab]             = imgui.ImVec4(0.11, 0.73, 0.33, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]       = imgui.ImVec4(0.12, 0.84, 0.38, 1.00)

    imgui.GetStyle().Colors[imgui.Col.Button]                 = imgui.ImVec4(0.11, 0.73, 0.33, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonHovered]          = imgui.ImVec4(0.12, 0.84, 0.38, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonActive]           = imgui.ImVec4(0.12, 0.84, 0.38, 1.00)

    imgui.GetStyle().Colors[imgui.Col.Header]                 = imgui.ImVec4(0.11, 0.73, 0.33, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderHovered]          = imgui.ImVec4(0.12, 0.84, 0.38, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderActive]           = imgui.ImVec4(0.12, 0.84, 0.38, 1.00)

    imgui.GetStyle().Colors[imgui.Col.Separator]              = imgui.ImVec4(0.11, 0.73, 0.33, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorHovered]       = imgui.ImVec4(0.11, 0.73, 0.33, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorActive]        = imgui.ImVec4(0.11, 0.73, 0.33, 1.00)

    imgui.GetStyle().Colors[imgui.Col.ResizeGrip]             = imgui.ImVec4(0.11, 0.73, 0.33, 0.25)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered]      = imgui.ImVec4(0.12, 0.84, 0.38, 0.67)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripActive]       = imgui.ImVec4(0.12, 0.84, 0.38, 0.95)

    imgui.GetStyle().Colors[imgui.Col.Tab]                    = imgui.ImVec4(0.11, 0.73, 0.33, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabHovered]             = imgui.ImVec4(0.12, 0.84, 0.38, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabActive]              = imgui.ImVec4(0.12, 0.84, 0.38, 1.00)

    imgui.GetStyle().Colors[imgui.Col.TabUnfocused]           = imgui.ImVec4(0.07, 0.10, 0.15, 0.97)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocusedActive]     = imgui.ImVec4(0.14, 0.26, 0.42, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLines]              = imgui.ImVec4(0.61, 0.61, 0.61, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered]       = imgui.ImVec4(1.00, 0.43, 0.35, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogram]          = imgui.ImVec4(0.90, 0.70, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered]   = imgui.ImVec4(1.00, 0.60, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]         = imgui.ImVec4(1.00, 0.00, 0.00, 0.35)
    imgui.GetStyle().Colors[imgui.Col.DragDropTarget]         = imgui.ImVec4(1.00, 1.00, 0.00, 0.90)
    imgui.GetStyle().Colors[imgui.Col.NavHighlight]           = imgui.ImVec4(0.26, 0.59, 0.98, 1.00)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingHighlight]  = imgui.ImVec4(1.00, 1.00, 1.00, 0.70)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingDimBg]      = imgui.ImVec4(0.80, 0.80, 0.80, 0.20)
    imgui.GetStyle().Colors[imgui.Col.ModalWindowDimBg]       = imgui.ImVec4(0.00, 0.00, 0.00, 0.70)
end

function imgui.Selector(labels, size, selected, pos, speed)
    local rBool = false
    if not speed then speed = 10 end
    if (pos[0] < (selected[0] * size.y)) then
        pos[0] = pos[0] + speed
    elseif (pos[0] > (selected[0] * size.y)) then
        pos[0] = pos[0] - speed
    end
    imgui.SetCursorPos(imgui.ImVec2(0.00, pos[0]))
    local draw_list = imgui.GetWindowDrawList()
    local p = imgui.GetCursorScreenPos()
    local radius = size.y * 0.50
    draw_list:AddRectFilled(imgui.ImVec2(p.x-size.x/2, p.y), imgui.ImVec2(p.x + radius + 1 * (size.x - radius * 2.0), p.y + radius*2), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.ButtonActive]))
    draw_list:AddRectFilled(imgui.ImVec2(p.x-size.x/2, p.y), imgui.ImVec2(p.x + 5, p.y + size.y), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Button]), 0)
    draw_list:AddCircleFilled(imgui.ImVec2(p.x + radius + 1 * (size.x - radius * 2.0), p.y + radius), radius, imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.ButtonActive]), radius/10*12)
    for i = 1, #labels do
        imgui.SetCursorPos(imgui.ImVec2(0, (i * size.y)))
        local p = imgui.GetCursorScreenPos()
        if imgui.InvisibleButton(labels[i], size) then selected[0] = i rBool = true end
        if imgui.IsItemHovered() then
            draw_list:AddRectFilled(imgui.ImVec2(p.x-size.x/2, p.y), imgui.ImVec2(p.x + size.x, p.y + size.y), imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.58, 0.34, 0.46, 0.20)), radius/10*12)
        end
        imgui.SetCursorPos(imgui.ImVec2(20, (i * size.y + (size.y-imgui.CalcTextSize(labels[i]).y)/2)))
        imgui.Text(labels[i])
    end
    return rBool
end
