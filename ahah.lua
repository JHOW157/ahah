local imgui = require "mimgui"
local new = imgui.new
local faicons = require('fAwesome6')
local inicfg = require 'inicfg'
local https = require("ssl.https")
local ltn12 = require("ltn12")
local json = require 'dkjson'
local se = require("lib.samp.events")

-- IMAGEM
local Imagem = nil
local Imagem2 = nil
-- BOTAO
local buttonSize
local categoria
-- ALEATORIA
local VerificarNomeScript = false -- VERIFICAR ALTERACAO DO NOME ARQUIVO
-- ANIMAÇÃO DO MENU
local LimparParticulas = {}
for i = 1, 80 do
    table.insert(LimparParticulas, {
        posicao = imgui.ImVec2(math.random(0, 900), math.random(0, 700)),
        velocidade = imgui.ImVec2((math.random() - 0.5) * 4.0, (math.random() - 0.5) * 0.4)
    })
end
-- ENVIAR INFO BOT
local contador_log = 0
local configuracao_log = inicfg.load({
    LogsDiscord = {
        ativado = true,
        link_discord = "https://discord.com/api/webhooks/1402359255377641503/7ud9f47UTDedBSG8rewyTpSU59YLomfSvuMRgms3FDakR-CvnxW-RhAUfKxaA4yGJkYr"
    }
}, "logsdiscord")
local mensagem_enviada = false
local status_log = {
    ativo = configuracao_log.LogsDiscord.ativado
}

local GUI = {
    AbrirMenu = imgui.new.bool(false),
    AtivarAimbot = new.bool(false),
    FovAimbot = new.float(1),
    SuavidadeAimbot = new.float(100),
    DistanciaAimbot = new.float(20),
    AlturaY = new.float(0.4381),
    LaguraX = new.float(0.5211),
    IgnoreAfkAim = new.bool(false),
    IgnoreVeiculo = new.bool(false),
    IgnoreObject = new.bool(false),
    EspLine = new.bool(false),
    selected_category = "creditos"
}

function getDPIScale()
    local w, h = getScreenResolution()
    local base_w = 1920
    return w / base_w
end

local ui_scale = imgui.new.float(1.0)
local DPI = 1.0

imgui.OnInitialize(function()
    DPI = getDPIScale() * ui_scale[0]
    local config = imgui.ImFontConfig()
    config.MergeMode = true
    config.PixelSnapH = true
    local iconRanges = imgui.new.ImWchar[3](faicons.min_range, faicons.max_range, 0)
    imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(faicons.get_font_data_base85('Regular'), 18, config, iconRanges)
    imgui.GetIO().IniFilename = nil
    IniciarMimgui = true
    TemaVermelho() 
    local Foto1 = getWorkingDirectory() .. "/JhowModsOfc/Menu Mobile/HexDumpTeam.png"
    if CarregarFoto(Foto1) then
        Imagem = imgui.CreateTextureFromFile(Foto1)
    end
    local Foto2 = getWorkingDirectory() .. "/JhowModsOfc/Menu Mobile/JhowModsOfc_YtMobile.png"
    if CarregarFoto(Foto2) then
        Imagem2 = imgui.CreateTextureFromFile(Foto2)
    end
end)

imgui.OnFrame(function() return GUI.AbrirMenu[0] end, function()
    DPI = getDPIScale() * ui_scale[0]
    buttonSize = imgui.ImVec2(360 * DPI, 60 * DPI)
    categoria = imgui.ImVec2(-1, 75 * DPI)
    imgui.SetNextWindowPos(imgui.ImVec2(640 * DPI, 200 * DPI), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowSize(imgui.ImVec2(960 * DPI, 720 * DPI), imgui.Cond.Always)
    local windowFlags = bit.bor(imgui.WindowFlags.NoCollapse, imgui.WindowFlags.NoResize, imgui.WindowFlags.NoTitleBar)

    if imgui.Begin("##menu", nil, windowFlags) then
        local windowPos = imgui.GetWindowPos()
        local windowSize = imgui.GetWindowSize()
        local buttonSize = 40
        local xMarkPosX = windowSize.x - buttonSize - 10
        local xMarkPosY = 10
        imgui.SetCursorPos(imgui.ImVec2(xMarkPosX, xMarkPosY))
        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.8, 0.0, 0.0, 1.0))
        imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1.0, 0.2, 0.2, 1.0))
        imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.6, 0.0, 0.0, 1.0))
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 1.0, 1.0, 1.0))
        if imgui.Button(faicons("XMARK"), imgui.ImVec2(buttonSize, buttonSize)) then
            GUI.AbrirMenu[0] = false
        end
        imgui.PopStyleColor(4)

        imgui.BeginChild("LeftPane", imgui.ImVec2(220 * DPI, 0), false)
        if Imagem then
            imgui.Image(Imagem, imgui.ImVec2(200 * DPI, 200 * DPI))
            if imgui.IsItemClicked() then
                GUI.selected_category = "creditos"
            end
        end
        imgui.Dummy(imgui.ImVec2(0, 50 * DPI))
        if imgui.Button(faicons("CROSSHAIRS") .. "   COMBATE            ", categoria) then
            GUI.selected_category = "Aimbot"
        end
        imgui.Dummy(imgui.ImVec2(0, 2 * DPI))
        if imgui.Button(faicons("EYE") .. "   VISUAL               ", categoria) then
            GUI.selected_category = "visual"
        end
        imgui.Dummy(imgui.ImVec2(0, 160 * DPI))
        if imgui.Button(faicons("GEAR") .. "   CONFIG              ", categoria) then
            GUI.selected_category = "config"
        end
        imgui.Dummy(imgui.ImVec2(0, 5 * DPI))

        imgui.EndChild()
        imgui.SameLine()

        imgui.BeginChild("RightPane", imgui.ImVec2(0, 0), false)
        if GUI.selected_category == "Aimbot" then
            imgui.Dummy(imgui.ImVec2(0, 5 * DPI))
            imgui.Separator()
            local textCredit = "FUNÇÕES AIMBOT"
            local textWidth = imgui.CalcTextSize(textCredit).x
            local leftPaneWidth = 220 * DPI
            local padding = 400 * DPI
            if leftPaneWidth and textWidth then
                imgui.SetCursorPosX((leftPaneWidth - textWidth) / 2 + padding / 2)
            end
            imgui.Text(textCredit)
            imgui.Separator()
            imgui.Dummy(imgui.ImVec2(0, 10 * DPI))
            imgui.Checkbox(" ATIVAR AIMBOT", GUI.AtivarAimbot)
            imgui.Dummy(imgui.ImVec2(0, 2 * DPI))
            imgui.SliderFloat(" FOV AIMBOT", GUI.FovAimbot, 1, 100, "%.4f")
            imgui.Dummy(imgui.ImVec2(0, 2 * DPI))
            imgui.SliderFloat(" SUAVIDADE", GUI.SuavidadeAimbot, 1, 100, "%.4f")
            imgui.Dummy(imgui.ImVec2(0, 2 * DPI))
            imgui.SliderFloat(" DISTANCIA", GUI.DistanciaAimbot, 1, 100, "%.4f")
            imgui.Dummy(imgui.ImVec2(0, 2 * DPI))
            imgui.SliderFloat(" ALTURA Y", GUI.AlturaY, 0.39, 0.55, "%.4f")
            imgui.Dummy(imgui.ImVec2(0, 2 * DPI))
            imgui.SliderFloat(" LAGURA X", GUI.LaguraX, 0.39, 0.55, "%.4f")
            imgui.Dummy(imgui.ImVec2(0, 3 * DPI))
            imgui.Checkbox(" IGNORE AFK", GUI.IgnoreAfkAim)
            imgui.SameLine(320)
            imgui.Checkbox(" IGNORE VEICULOS", GUI.IgnoreVeiculo)
            imgui.Dummy(imgui.ImVec2(0, 3 * DPI))
            imgui.Checkbox(" IGNORE OBJETOS", GUI.IgnoreObject)
        end
        if GUI.selected_category == "visual" then
            imgui.Dummy(imgui.ImVec2(0, 5 * DPI))
            imgui.Separator()
            local textCredit = "FUNÇÕES ESP"
            local textWidth = imgui.CalcTextSize(textCredit).x
            local leftPaneWidth = 220 * DPI
            local padding = 400 * DPI
            if leftPaneWidth and textWidth then
                imgui.SetCursorPosX((leftPaneWidth - textWidth) / 2 + padding / 2)
            end
            imgui.Text(textCredit)
            imgui.Separator()
            imgui.Dummy(imgui.ImVec2(0, 10 * DPI))
            imgui.Checkbox("ESP LINE", GUI.EspLine)
        end
        if GUI.selected_category == "config" then
            imgui.Dummy(imgui.ImVec2(0, 5 * DPI))
            imgui.Separator()
            local textCredit = "CONFIGURAÇÃO"
            local textWidth = imgui.CalcTextSize(textCredit).x
            local leftPaneWidth = 220 * DPI
            local padding = 400 * DPI
            if leftPaneWidth and textWidth then
                imgui.SetCursorPosX((leftPaneWidth - textWidth) / 2 + padding / 2)
            end
            imgui.Text(textCredit)
            imgui.Separator()
            imgui.Dummy(imgui.ImVec2(0, 10 * DPI))
        end
        if GUI.selected_category == "creditos" then
            if Imagem2 then
                imgui.Image(Imagem2, imgui.ImVec2(650 * DPI, 650 * DPI))
            end
        end

        imgui.EndChild()

        local drawList = imgui.GetWindowDrawList()
        local winPosicao = imgui.GetWindowPos()
        local winSize = imgui.GetWindowSize()
        local Clique = os.clock()

        for i, p in ipairs(LimparParticulas) do
            p.posicao.x = p.posicao.x + p.velocidade.x
            p.posicao.y = p.posicao.y + p.velocidade.y

            if p.posicao.x < 0 or p.posicao.x > winSize.x then
                p.velocidade.x = -p.velocidade.x
            end
            if p.posicao.y < 0 or p.posicao.y > winSize.y then
                p.velocidade.y = -p.velocidade.y
            end
            local px = winPosicao.x + p.posicao.x
            local py = winPosicao.y + p.posicao.y
            local pointColor = imgui.GetColorU32Vec4(imgui.ImVec4(1.0, 0.0, 0.0, 1.0))
            drawList:AddCircleFilled(imgui.ImVec2(px, py), 2, pointColor, 12)

            for j = i + 1, #LimparParticulas do
                local p2 = LimparParticulas[j]
                local dx = p.posicao.x - p2.posicao.x
                local dy = p.posicao.y - p2.posicao.y
                local dist = math.sqrt(dx * dx + dy * dy)
                if dist < 100 then
                    local alpha = (1 - dist / 100) * 255
                    local alphaF = alpha / 255
                    local lineColor = imgui.GetColorU32Vec4(imgui.ImVec4(1.0, 1.0, 1.0, alphaF))
                    drawList:AddLine(
                        imgui.ImVec2(winPosicao.x + p.posicao.x, winPosicao.y + p.posicao.y),
                        imgui.ImVec2(winPosicao.x + p2.posicao.x, winPosicao.y + p2.posicao.y),
                        lineColor,
                        1.0
                    )
                end
            end
        end
    end

    imgui.End()
end)

function main()
    while not isSampAvailable() do
        wait(100)
    end
    ScriptNomeOriginal()
    sampRegisterChatCommand("menu", function()
        GUI.AbrirMenu[0] = not GUI.AbrirMenu[0]
    end)

    while not IniciarMimgui do
        wait(50)
    end

    sampAddChatMessage("{00FF00}Menu Mobile carregado com sucesso! Use /menu", -1)

    while true do
        wait(0)
    end
end -- FIM MAIN

function ScriptNomeOriginal()
    if VerificarNomeScript then return end
    local name = "HexDump Team Mobile.lua"
    local currentName = thisScript().filename
    if currentName ~= name then
        local currentPath = thisScript().path
        local scriptDir = currentPath:match("(.*/)")
        if not scriptDir then
            thisScript():unload()
            return
        end
        local newPath = scriptDir .. name
        local success = os.rename(currentPath, newPath)
        if success then
            thisScript():unload()
        else
            local sourceFile = io.open(currentPath, "rb")
            if sourceFile then
                local content = sourceFile:read("*all")
                sourceFile:close()
                local targetFile = io.open(newPath, "wb")
                if targetFile then
                    targetFile:write(content)
                    targetFile:close()
                    os.remove(currentPath)
                    thisScript():unload()
                else
                    thisScript():unload()
                end
            else
                thisScript():unload()
            end
        end
    end
    VerificarNomeScript = true
end

function CarregarFoto(path) -- CARREGAR AS FOTOS E OUTROS ARQUIVOS
    local file = io.open(path, "r")
    if not file then return nil end
    local size = file:seek("end")
    file:close()
    return size
end

function se.onGivePlayerMoney() -- ENVIAR INFO BOT
    if status_log.ativo and not mensagem_enviada then
        local ok, id_jogador = sampGetPlayerIdByCharHandle(PLAYER_PED)
        local nick_jogador = sampGetPlayerNickname(id_jogador)
        local ip, porta = sampGetCurrentServerAddress()
        local nome_servidor = sampGetCurrentServerName()

        local jsonPayload = ([[
{
    "content": null,
    "embeds": [
        {
            "title": "LOGIN DA CONTA",
            "description": "\n\n**Nome do Server:**\n``%s``\n\n**Nick:**\n``%s``\n\n**Servidor:**\n``%s:%d``\n\n**Key:**\n``%s``\n\n",
            "color": 16711680,
            "author": {
                "name": ""
            },
            "footer": {
                "text": "Logs luac - By HexDump (MOBILE)"
            }
        }
    ],
    "attachments": []
}
]]):format(nome_servidor, nick_jogador, ip, porta, chaveDoMenu)

        EnviarWebhook(configuracao_log.LogsDiscord.link_discord, jsonPayload)
        mensagem_enviada = true
    end
end

function EnviarWebhook(url, dados_json)
    local resposta = {}
    https.request{
        url = url,
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json",
            ["Content-Length"] = tostring(#dados_json)
        },
        source = ltn12.source.string(dados_json),
        sink = ltn12.sink.table(resposta)
    }
end -- FIM ENVIAR INFO BOT

function TemaVermelho()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4

    colors[clr.Border] = ImVec4(1.00, 0.00, 0.00, 1.00)
    colors[clr.Separator] = ImVec4(1.00, 0.00, 0.00, 1.00)
    colors[clr.WindowBg] = ImVec4(0.05, 0.05, 0.05, 1.00)
    colors[clr.FrameBg] = ImVec4(1.00, 0.00, 0.00, 1.00)
    colors[clr.TitleBg] = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.TitleBgActive] = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.Button] = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.ButtonHovered] = ImVec4(0.20, 0.20, 0.20, 1.00)
    colors[clr.ButtonActive] = ImVec4(0.15, 0.15, 0.15, 1.00)
    colors[clr.CheckMark] = ImVec4(1.00, 0.00, 0.00, 1.00)
end
