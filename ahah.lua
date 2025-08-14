local imgui = require "mimgui"
local new = imgui.new
local widgets = require("widgets")
local faicons = require('fAwesome6')
local ffi = require("ffi")
local gtasa = ffi.load("GTASA")
local vector3d = require("vector3d")
local memory = require("SAMemory")
local se = require("samp.events")

-- AIMBOT
memory.require("CCamera")
local camera_principal = memory.camera
-- LOG DO SERVER
local MessagesLog = {}
local FonteLog = renderCreateFont("Arial", 12, 0)
-- IMAGEM
local Imagem = nil
local Imagem2 = nil
-- BOTAO
local buttonSize
local categoria
-- ANIMACAO DO MENU
local LimparParticulas = {}
for i = 1, 80 do
    table.insert(LimparParticulas, {
        posicao = imgui.ImVec2(math.random(0, 900), math.random(0, 700)),
        velocidade = imgui.ImVec2((math.random() - 0.5) * 4.0, (math.random() - 0.5) * 0.4)
    })
end

local GUI = {
    AbrirMenu = imgui.new.bool(false),
    AtivarAimbot = new.bool(false),
    FovAimbot = new.float(100),
    SuavidadeAimbot = new.float(100),
    DistanciaAimbot = new.float(100),
    AlturaY = new.float(0.4381),
    LaguraX = new.float(0.5211),
    IgnoreAfkAim = new.bool(false),
    IgnoreVeiculo = new.bool(false),
    IgnoreObject = new.bool(false),
    EspLine = new.bool(false),
    EspBox = new.bool(false),
    EspEsqueleto = new.bool(false),
    EspNome = new.bool(false),
    EspInfoCar = new.bool(false),
    EspCarro = new.bool(false),
    AtivarMessagesLog = new.bool(false),
    AtivarTelaEsticada = new.bool(false),
    AlterarFovTela = new.int(70),
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
    imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(faicons.get_font_data_base85('Regular'), 20 * DPI, config, iconRanges)
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
    imgui.SetNextWindowPos(imgui.ImVec2(540 * DPI, 300 * DPI), imgui.Cond.FirstUseEver)
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
                playSoundAtPlayerLocation()
            end
        end
        imgui.Dummy(imgui.ImVec2(0, 50 * DPI))
        if imgui.Button(     faicons("USER") .. " JOGADOR       ", categoria) then
            GUI.selected_category = "Jogador"
            playSoundAtPlayerLocation()
        end
        imgui.Dummy(imgui.ImVec2(0, 2 * DPI))
        if imgui.Button(     faicons("CROSSHAIRS") .. " COMBATE       ", categoria) then
            GUI.selected_category = "Aimbot"
            playSoundAtPlayerLocation()
        end
        imgui.Dummy(imgui.ImVec2(0, 2 * DPI))
        if imgui.Button(     faicons("EYE") .. " VISUAL          ", categoria) then
            GUI.selected_category = "visual"
            playSoundAtPlayerLocation()
        end
        imgui.Dummy(imgui.ImVec2(0, 80 * DPI))
        if imgui.Button(     faicons("GEAR") .. " CONFIG         ", categoria) then
            GUI.selected_category = "config"
            playSoundAtPlayerLocation()
        end
        imgui.Dummy(imgui.ImVec2(0, 2 * DPI))

        imgui.EndChild()
        imgui.SameLine()

        imgui.BeginChild("RightPane", imgui.ImVec2(0, 0), false)
        if GUI.selected_category == "Jogador" then
            imgui.Dummy(imgui.ImVec2(0, 5 * DPI))
            imgui.Separator()
            local textCredit = "JOGADORES"
            local textWidth = imgui.CalcTextSize(textCredit).x
            local leftPaneWidth = 220 * DPI
            local padding = 400 * DPI
            if leftPaneWidth and textWidth then
                imgui.SetCursorPosX((leftPaneWidth - textWidth) / 2 + padding / 2)
            end
            imgui.Text(textCredit)
            imgui.Separator()
            imgui.Dummy(imgui.ImVec2(0, 25 * DPI))
            if imgui.Checkbox(" ATIVAR FOV", GUI.AtivarTelaEsticada) then
                playSoundAtPlayerLocation()
            end
            imgui.Dummy(imgui.ImVec2(0, 15 * DPI))
            if imgui.SliderInt(" AJUSTAR FOV", GUI.AlterarFovTela, 10, 120) then
                if GUI.AtivarTelaEsticada[0] then
                    cameraSetLerpFov(GUI.AlterarFovTela[0], 101, 1000, true)
                end
            end
            imgui.Dummy(imgui.ImVec2(0, 15 * DPI))
        end
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
            imgui.Dummy(imgui.ImVec2(0, 25 * DPI))
            if imgui.Checkbox(" ATIVAR AIMBOT", GUI.AtivarAimbot) then
                playSoundAtPlayerLocation()
            end
            imgui.Dummy(imgui.ImVec2(0, 15 * DPI))
            imgui.SliderFloat(" FOV AIMBOT", GUI.FovAimbot, 1, 100, "%.4f")
            imgui.Dummy(imgui.ImVec2(0, 15 * DPI))
            imgui.SliderFloat(" SUAVIDADE", GUI.SuavidadeAimbot, 1, 100, "%.4f")
            imgui.Dummy(imgui.ImVec2(0, 15 * DPI))
            imgui.SliderFloat(" DISTANCIA", GUI.DistanciaAimbot, 1, 100, "%.4f")
            imgui.Dummy(imgui.ImVec2(0, 15 * DPI))
            imgui.SliderFloat(" ALTURA Y", GUI.AlturaY, 0.39, 0.55, "%.4f")
            imgui.Dummy(imgui.ImVec2(0, 15 * DPI))
            imgui.SliderFloat(" LAGURA X", GUI.LaguraX, 0.39, 0.55, "%.4f")
            imgui.Dummy(imgui.ImVec2(0, 15 * DPI))
            if imgui.Checkbox(" IGNORE AFK", GUI.IgnoreAfkAim) then
                playSoundAtPlayerLocation()
            end
            imgui.SameLine(320)
            if imgui.Checkbox(" IGNORE VEICULOS", GUI.IgnoreVeiculo) then
                playSoundAtPlayerLocation()
            end
            imgui.Dummy(imgui.ImVec2(0, 15 * DPI))
            if imgui.Checkbox(" IGNORE OBJETOS", GUI.IgnoreObject) then
                playSoundAtPlayerLocation()
            end
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
            imgui.Dummy(imgui.ImVec2(0, 25 * DPI))
            if imgui.Checkbox(" ESP LINE", GUI.EspLine) then
                playSoundAtPlayerLocation()
            end
            imgui.Dummy(imgui.ImVec2(0, 15 * DPI))
            if imgui.Checkbox(" ESP ESQUELETO", GUI.EspEsqueleto) then
                playSoundAtPlayerLocation()
            end
            imgui.Dummy(imgui.ImVec2(0, 15 * DPI))
            if imgui.Checkbox(" ESP BOX", GUI.EspBox) then
                playSoundAtPlayerLocation()
            end
            imgui.Dummy(imgui.ImVec2(0, 15 * DPI))
            if imgui.Checkbox(" ESP NOME", GUI.EspNome) then
                playSoundAtPlayerLocation()
            end
            imgui.Dummy(imgui.ImVec2(0, 15 * DPI))
            if imgui.Checkbox(" ESP INFO VEICULO", GUI.EspInfoCar) then
                playSoundAtPlayerLocation()
            end
            imgui.Dummy(imgui.ImVec2(0, 15 * DPI))
            if imgui.Checkbox(" ESP CARRO", GUI.EspCarro) then
                playSoundAtPlayerLocation()
            end
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
            imgui.Dummy(imgui.ImVec2(0, 25 * DPI))
            imgui.Checkbox(" LOG SERVIDOR", GUI.AtivarMessagesLog)
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
    EnviarSmS("{00FF00}Menu Mobile carregado com sucesso! Use /hexdump", -1)

    while true do
        if isWidgetSwipedLeft(WIDGET_RADAR) then
            GUI.AbrirMenu[0] = not GUI.AbrirMenu[0]
        end

        wait(0)
        Aimbot()
        EspLine()
        EspBoxCar()
        TelaEsticada()
        CarregarMessagesLog()
    end
end -- FIM MAIN

function EnviarSmS(text) -- TAG MESSAGEM
    tag = '{FF0000}[JhowModsOfc]: '
    sampAddChatMessage(tag .. text, -1)
end

-- AIMBOT
function obterPosicaoDoOsso(id_char, id_osso)
    local ponteiro_char = ffi.cast("void*", getCharPointer(id_char))
    local posicao_osso = ffi.new("RwV3d[1]")

    gtasa._ZN4CPed15GetBonePositionER5RwV3djb(ponteiro_char, posicao_osso, id_osso, false)

    return posicao_osso[0].x, posicao_osso[0].y, posicao_osso[0].z
end

local larguraTela, alturaTela = getScreenResolution()

function obterRotacaoDaCamera()
    local anguloHorizontal = camera_principal.aCams[0].fHorizontalAngle
    local anguloVertical = camera_principal.aCams[0].fVerticalAngle
    return anguloHorizontal, anguloVertical
end

function definirRotacaoDaCamera(anguloHorizontal, anguloVertical)
    camera_principal.aCams[0].fHorizontalAngle = anguloHorizontal
    camera_principal.aCams[0].fVerticalAngle = anguloVertical
end

function converterCoordenadasCartesianasParaEsfericas(posicao)
    local vetor = posicao - vector3d(getActiveCameraCoordinates())
    local comprimento = vetor:length()
    local anguloHorizontal = math.atan2(vetor.y, vetor.x)
    local anguloVertical = math.acos(vetor.z / comprimento)

    if anguloHorizontal > 0 then
        anguloHorizontal = anguloHorizontal - math.pi
    else
        anguloHorizontal = anguloHorizontal + math.pi
    end

    local anguloVerticalFinal = math.pi / 2 - anguloVertical
    return anguloHorizontal, anguloVerticalFinal
end

function obterPosicaoDoMiraNaTela()
    local largura, altura = getScreenResolution()
    local posicaoX = largura * GUI.LaguraX[0]
    local posicaoY = altura * GUI.AlturaY[0]
    return posicaoX, posicaoY
end

function obterRotacaoDoMira(distancia)
    distancia = distancia or 5
    local posicaoX, posicaoY = obterPosicaoDoMiraNaTela()
    local ponto3D = vector3d(convertScreenCoordsToWorld3D(posicaoX, posicaoY, distancia))
    return converterCoordenadasCartesianasParaEsfericas(ponto3D)
end

function mirarPontoComM16(ponto)
    local anguloHorizontal, anguloVertical = converterCoordenadasCartesianasParaEsfericas(ponto)
    local rotacaoHorizontal, rotacaoVertical = obterRotacaoDaCamera()
    local miraHorizontal, miraVertical = obterRotacaoDoMira()
    local novaRotacaoHorizontal = rotacaoHorizontal + (anguloHorizontal - miraHorizontal)
    local novaRotacaoVertical = rotacaoVertical + (anguloVertical - miraVertical)
    definirRotacaoDaCamera(novaRotacaoHorizontal, novaRotacaoVertical)
end

function mirarPontoComMiraTelescopica(ponto)
    local anguloHorizontal, anguloVertical = converterCoordenadasCartesianasParaEsfericas(ponto)
    definirRotacaoDaCamera(anguloHorizontal, anguloVertical)
end

function obterCharProximoAoCentro(distanciaMaxima)
    local charsProximos = {}
    local largura, altura = getScreenResolution()
    for _, char in ipairs(getAllChars()) do
        if isCharOnScreen(char) and char ~= PLAYER_PED and not isCharDead(char) then
            local coordX, coordY, coordZ = getCharCoordinates(char)
            local posX, posY = convert3DCoordsToScreen(coordX, coordY, coordZ)
            local distancia = getDistanceBetweenCoords2d(largura / 2 + 3, altura / 2 + 3, posX, posY)

            if isCurrentCharWeapon(PLAYER_PED, 34) then
                distancia = getDistanceBetweenCoords2d(largura / 2, altura / 2, posX, posY)
            end

            if distancia <= tonumber(distanciaMaxima and distanciaMaxima or altura) then
                table.insert(charsProximos, {
                    distancia,
                    char
                })
            end
        end
    end

    if #charsProximos > 0 then
        table.sort(charsProximos, function(a, b)
            return a[1] < b[1]
        end)
        return charsProximos[1][2]
    end
    return nil
end

function Aimbot()
    if GUI.AtivarAimbot[0] then
        local distanciaMaxima = math.floor((GUI.DistanciaAimbot[0] - 1) * (120 - 0) / (100 - 1))
        local modoCamera = camera_principal.aCams[0].nMode
        local suavidadeMaxia = math.floor(100 + (GUI.SuavidadeAimbot[0] - 1) * (250 - 100) / (100 - 1))
        local charProximo = obterCharProximoAoCentro(suavidadeMaxia)

        if charProximo then
            local result, playerId = sampGetPlayerIdByCharHandle(charProximo)
            
            if result and not isTargetAfkAim(playerId) and not isPlayerInVehicleAim(charProximo) then
                local posicaoX, posicaoY, posicaoZ = obterPosicaoDoOsso(charProximo, 5)
                local coordX, coordY, coordZ = getCharCoordinates(PLAYER_PED)
                local distanciaTotal = getDistanceBetweenCoords3d(coordX, coordY, coordZ, posicaoX, posicaoY, posicaoZ)

                if distanciaTotal < distanciaMaxima then
                    local charAlvo = charProximo
                    local alvoX, alvoY, alvoZ = obterPosicaoDoOsso(charAlvo, 5)

                    local myPos = {coordX, coordY, coordZ}
                    local enPos = {alvoX, alvoY, alvoZ}
                    if isClearObject(myPos, enPos) then
                        ponto = vector3d(alvoX, alvoY, alvoZ)

                        if modoCamera == 7 then
                            mirarPontoComMiraTelescopica(ponto)
                        elseif modoCamera == 53 then
                            mirarPontoComM16(ponto)
                        end
                    end
                end
            end
        end
    end
end

function isTargetAfkAim(playerId) -- IGNORE AFK AIMBOT
    if GUI.IgnoreAfkAim[0] then
        return sampIsPlayerPaused(playerId)
    end
    return false
end

function isPlayerInVehicleAim(charProximo) -- IGNORE VEICULO AIMBOT
    if GUI.IgnoreVeiculo[0] then
        return isCharInAnyCar(charProximo)
    end
    return false
end

function isClearObject(myPos, enPos) -- IGNORE OBJECT AIMBOT
    if GUI.IgnoreObject[0] then
        return isLineOfSightClear(myPos[1], myPos[2], myPos[3], enPos[1], enPos[2], enPos[3], true, false, false, true, false, false, false)
    end
    return true
end

ffi.cdef([[
    typedef struct RwV3d {
        float x, y, z;
    } RwV3d;
    void _ZN4CPed15GetBonePositionER5RwV3djb(void* thiz, RwV3d* posn, uint32_t bone, bool calledFromCam);
]])
-- FIM AIMBOT

function TelaEsticada() -- FOV TELA
    if GUI.AtivarTelaEsticada[0] then
        cameraSetLerpFov(GUI.AlterarFovTela[0], 101, 1000, true)
    end
end

function EspLine()
    if GUI.EspLine[0] then
        local playerX, playerY, playerZ = getCharCoordinates(PLAYER_PED)
        for playerId = 0, sampGetMaxPlayerId(false) do
            if sampIsPlayerConnected(playerId) then
                local result, playerPed = sampGetCharHandleBySampPlayerId(playerId)
                if result and doesCharExist(playerPed) and isCharOnScreen(playerPed) then
                    local targetX, targetY, targetZ = getCharCoordinates(playerPed)
                    local distance = getDistanceBetweenCoords3d(playerX, playerY, playerZ, targetX, targetY, targetZ)
                    if distance <= 300 then
                        local lineEndX, lineEndY = convert3DCoordsToScreen(targetX, targetY, targetZ)
                        local screenWidth, screenHeight = getScreenResolution()
                        local lineStartX = screenWidth / 2
                        local lineStartY = 0
                        renderDrawLine(lineStartX, lineStartY, lineEndX, lineEndY, 2, 0xFFFF0000)
                    end
                end
            end
        end
    end
end

function EspBoxCar()
    if GUI.EspCarro[0] then
        local playerX, playerY, playerZ = getCharCoordinates(PLAYER_PED)
        local x, y = convert3DCoordsToScreen(playerX, playerY, playerZ)
        for _, vehicle in ipairs(getAllVehicles()) do
            if isCarOnScreen(vehicle) then
                local carX, carY, carZ = getCarCoordinates(vehicle)
                local px, py = convert3DCoordsToScreen(carX, carY, carZ)

                local corners = {
                    { x = 1.5, y = 3, z = 1 },
                    { x = 1.5, y = -3, z = 1 },
                    { x = -1.5, y = -3, z = 1 },
                    { x = -1.5, y = 3, z = 1 },
                    { x = 1.5, y = 3, z = -1 },
                    { x = 1.5, y = -3, z = -1 },
                    { x = -1.5, y = -3, z = -1 },
                    { x = -1.5, y = 3, z = -1 }
                }

                local boxCorners = {}
                for _, offset in ipairs(corners) do
                    local worldX, worldY, worldZ = getOffsetFromCarInWorldCoords(vehicle, offset.x, offset.y, offset.z)
                    local screenX, screenY = convert3DCoordsToScreen(worldX, worldY, worldZ)
                    table.insert(boxCorners, { x = screenX, y = screenY })
                end

                for i = 1, 4 do
                    local nextIndex = (i % 4 == 0 and i - 3) or (i + 1)
                    renderDrawLine(boxCorners[i].x, boxCorners[i].y, boxCorners[nextIndex].x, boxCorners[nextIndex].y, 2, 0xFFFFFFFF)
                    renderDrawLine(boxCorners[i].x, boxCorners[i].y, boxCorners[i + 4].x, boxCorners[i + 4].y, 2, 0xFFFFFFFF)
                end

                for i = 5, 8 do
                    local nextIndex = (i % 4 == 0 and i - 3) or (i + 1)
                    renderDrawLine(boxCorners[i].x, boxCorners[i].y, boxCorners[nextIndex].x, boxCorners[nextIndex].y, 2, 0xFFFFFFFF)
                end
                renderDrawLine(x, y, px, py, 2, 0xFFFFFFFF)
            end
        end
    end
end

function CarregarMessagesLog() -- LOG DO SERVER
    if GUI.AtivarMessagesLog[0] then
        for i, MessagesLogString in ipairs(MessagesLog) do
            if FonteLog then
                renderFontDrawText(FonteLog, MessagesLogString, 1320 * DPI, 600 * DPI + (i - 1) * 24, 0xFFff004F)
            end
        end
    end
end

function se.onPlayerJoin(playerId, color, isNpc, nick)
    local MessagesLogString = string.format("{FFFFFF}%s[%d]{80FF00} ENTROU NO SERVER", nick, playerId)
    table.insert(MessagesLog, 1, MessagesLogString)
    if #MessagesLog > 6 then
        table.remove(MessagesLog, #MessagesLog)
    end
end

function se.onPlayerQuit(playerId, LRas)
    local nick = sampGetPlayerNickname(playerId)
    local LRasText = LOGSERVERMESS()
    local MessagesLogString = string.format("{FFFFFF}%s[%d]{FF0004} %s{FFFFFF}", nick, playerId, LRasText)
    table.insert(MessagesLog, 1, MessagesLogString)
    if #MessagesLog > 6 then
        table.remove(MessagesLog, #MessagesLog)
    end
end

function LOGSERVERMESS()
    local NomeLog = {
        [0] = "SAIU DO SERVER",
        [1] = "KICKADO",
        [2] = "SEM NET",
        [3] = "BANIDO"
    }
    return NomeLog[NomeLog] or "SAIU DO SERVER"
end -- FIM LOG DO SERVER

function CarregarFoto(path) -- CARREGAR AS FOTOS E OUTROS ARQUIVOS
    local file = io.open(path, "r")
    if not file then return nil end
    local size = file:seek("end")
    file:close()
    return size
end

function playSoundAtPlayerLocation() -- SOM
    local som = PLAYER_PED
    if som then
        local x, y, z = getCharCoordinates(som)
        addOneOffSound(x, y, z, 1139)
    end
end

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
    colors[clr.CheckMark] = ImVec4(0.00, 1.00, 0.00, 1.00)
end
