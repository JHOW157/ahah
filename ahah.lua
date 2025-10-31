local imgui = require "mimgui"
local new = imgui.new
local widgets = require("widgets")

function getDPIScale()
    local w, h = getScreenResolution()
    local base_w = 1920
    return w / base_w
end

local ui_scale = imgui.new.float(1.0)
local DPI = 1.0
local BotaoMob = imgui.ImVec2(380 * DPI, 40 * DPI)

imgui.OnInitialize(function()
    DPI = getDPIScale() * ui_scale[0]
end)

local GUI = {
    AbrirMenu = imgui.new.bool(false),
}

imgui.OnFrame(function() return GUI.AbrirMenu[0] end, function()
    DPI = getDPIScale() * 1.0 -- Assumindo scale 1.0
    imgui.SetNextWindowPos(imgui.ImVec2(320 * DPI, 100 * DPI), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowSize(imgui.ImVec2(960 * DPI, 720 * DPI), imgui.Cond.Always)
    
    imgui.Begin("##menu_atualizacao", nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)
    
    local drawList = imgui.GetWindowDrawList()
    local windowPos = imgui.GetWindowPos()
    local windowSize = imgui.GetWindowSize()
    drawList:AddRectFilled(windowPos, imgui.ImVec2(windowPos.x + windowSize.x, windowPos.y + windowSize.y), imgui.GetColorU32Vec4(imgui.ImVec4(0.0, 0.0, 0.0, 1.0)))
    
    imgui.SetCursorPosY(250 * DPI)
    imgui.SetCursorPosX((windowSize.x - imgui.CalcTextSize("ATUALIZAÇÃO, HEX DUMP TEAM").x) / 2)
    imgui.TextColored(imgui.ImVec4(1.0, 1.0, 1.0, 1.0), "ATUALIZAÇÃO, HEX DUMP TEAM")
    
    imgui.SetCursorPosY(350 * DPI)
    imgui.SetCursorPosX((windowSize.x - imgui.CalcTextSize("Menu em atualização, Voltamos 31/10/2025 ás 15:00").x) / 2)
    imgui.TextColored(imgui.ImVec4(1.0, 0.0, 0.0, 1.0), "Menu em atualização, Voltamos 31/10/2025 ás 15:00")
    
    imgui.End()
end)

function main()
    while not isSampAvailable() do
        wait(100)
    end
    sampRegisterChatCommand("hexdump", function()
        GUI.AbrirMenu[0] = not GUI.AbrirMenu[0]
    end)
    while true do
        wait(0)
        if isWidgetSwipedLeft(WIDGET_RADAR) then
            GUI.AbrirMenu[0] = not GUI.AbrirMenu[0]
        end
    end
end
