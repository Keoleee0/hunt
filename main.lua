--[[
    ██████╗  █████╗ ██╗  ████████╗██╗  ██╗ █████╗ ███████╗ █████╗ ██████╗ 
    ██╔══██╗██╔══██╗██║  ╚══██╔══╝██║  ██║██╔══██╗╚══███╔╝██╔══██╗██╔══██╗
    ██████╔╝███████║██║     ██║   ███████║███████║  ███╔╝ ███████║██████╔╝
    ██╔══██╗██╔══██║██║     ██║   ██╔══██║██╔══██║ ███╔╝  ██╔══██║██╔══██╗
    ██████╔╝██║  ██║███████╗██║   ██║  ██║██║  ██║███████╗██║  ██║██║  ██║
    ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  
    
    Balthazar HBE + ESP Suite
    Fecha: 30/7/26
    Versión: 1.0.0
]]

-- ═══════════════════════════════════════════════════════
-- PROTECCIÓN CONTRA DOBLE EJECUCIÓN
-- ═══════════════════════════════════════════════════════
if getgenv().BalthazarHBELoaded ~= nil then
    return
end
getgenv().BalthazarHBELoaded = false

if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- ═══════════════════════════════════════════════════════
-- CARGA DE DEPENDENCIAS
-- ═══════════════════════════════════════════════════════
if not getgenv().MTAPIMutex then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/RectangularObject/MT-Api-v2/main/__source/mt-api%20v2.lua", true))()
end

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/RectangularObject/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/RectangularObject/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/RectangularObject/LinoriaLib/main/addons/SaveManager.lua"))()

SaveManager:SetLibrary(Library)
SaveManager:SetFolder("BalthazarHBE")
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("BalthazarHBE")

-- ═══════════════════════════════════════════════════════
-- SERVICIOS
-- ═══════════════════════════════════════════════════════
local Teams = game:GetService("Teams")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = Workspace.CurrentCamera
local WorldToViewportPoint = Camera.WorldToViewportPoint
local lPlayer = Players.LocalPlayer
local players = {}
local entities = {}

-- ═══════════════════════════════════════════════════════
-- FUNCIONES DE ACTUALIZACIÓN
-- ═══════════════════════════════════════════════════════
local function updatePlayers()
    if not getgenv().BalthazarHBELoaded then return end
    for _, v in pairs(players) do
        task.spawn(function()
            v:Update()
        end)
    end
end

RunService:BindToRenderStep("balthazarESP", Enum.RenderPriority.Camera.Value - 1, function()
    if not getgenv().BalthazarHBELoaded then return end
    Camera = Workspace.CurrentCamera
    for _, v in pairs(players) do
        task.spawn(function()
            v:UpdateESP()
        end)
    end
end)

-- ═══════════════════════════════════════════════════════
-- INTERFAZ DE USUARIO - MENÚ PRINCIPAL
-- ═══════════════════════════════════════════════════════
local mainWindow = Library:CreateWindow({
    Title = "⚔️ Balthazar Suite ⚔️",
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

-- ══════════════════════
-- TAB: HITBOX EXTENDER
-- ══════════════════════
local hitboxTab = mainWindow:AddTab("🎯 Hitbox")
local hbeMainGroup = hitboxTab:AddLeftGroupbox("⚡ Hitbox Extender")
local hbeSettingsGroup = hitboxTab:AddRightGroupbox("🔧 Configuración Avanzada")

hbeMainGroup:AddToggle("extenderToggled", {
    Text = "⚡ Activar Hitbox Extender",
    Default = false,
    Tooltip = "Activa/desactiva la extensión de hitboxes"
}):OnChanged(updatePlayers)

hbeMainGroup:AddDivider()

hbeMainGroup:AddSlider("extenderSize", {
    Text = "📏 Tamaño",
    Min = 2,
    Max = 100,
    Default = 10,
    Rounding = 1,
    Compact = false
}):OnChanged(updatePlayers)

hbeMainGroup:AddSlider("extenderTransparency", {
    Text = "👁️ Transparencia",
    Min = 0,
    Max = 1,
    Default = 0.5,
    Rounding = 2,
    Compact = false
}):OnChanged(updatePlayers)

hbeMainGroup:AddDivider()

hbeMainGroup:AddDropdown("extenderPartList", {
    Text = "🦴 Partes del Cuerpo",
    AllowNull = true,
    Multi = true,
    Values = {
        "Custom Part",
        "Head",
        "HumanoidRootPart",
        "Torso",
        "Left Arm",
        "Right Arm",
        "Left Leg",
        "Right Leg"
    },
    Default = "HumanoidRootPart"
}):OnChanged(updatePlayers)

hbeSettingsGroup:AddInput("customPartName", {
    Text = "📝 Nombre de Parte Custom",
    Default = "HeadHB",
    Placeholder = "Escribe el nombre..."
}):OnChanged(updatePlayers)

hbeSettingsGroup:AddDivider()

hbeSettingsGroup:AddToggle("collisionsToggled", {
    Text = "💥 Habilitar Colisiones",
    Default = false,
    Tooltip = "Permite colisiones con hitboxes extendidos"
}):OnChanged(updatePlayers)

-- ══════════════════════
-- TAB: ESP
-- ══════════════════════
local espTab = mainWindow:AddTab("👁️ ESP")
local espNameGroup = espTab:AddLeftGroupbox("📛 Nombres ESP")
local espChamsGroup = espTab:AddRightGroupbox("🌈 Chams / Highlights")

-- Nombres ESP
espNameGroup:AddToggle("espNameToggled", {
    Text = "📛 Mostrar Nombres",
    Default = false
}):AddColorPicker("espNameColor1", {
    Title = "Color del Texto",
    Default = Color3.fromRGB(255, 255, 255)
}):AddColorPicker("espNameColor2", {
    Title = "Color del Contorno",
    Default = Color3.fromRGB(0, 0, 0)
})
Toggles.espNameToggled:OnChanged(updatePlayers)
Options.espNameColor1:OnChanged(updatePlayers)
Options.espNameColor2:OnChanged(updatePlayers)

espNameGroup:AddDivider()

espNameGroup:AddToggle("espNameUseTeamColor", {
    Text = "🎨 Usar Color de Equipo",
    Default = false
}):OnChanged(updatePlayers)

espNameGroup:AddDropdown("espNameType", {
    Text = "📋 Tipo de Nombre",
    AllowNull = false,
    Multi = false,
    Values = { "Display Name", "Account Name" },
    Default = "Display Name"
}):OnChanged(updatePlayers)

-- Chams
espChamsGroup:AddToggle("espHighlightToggled", {
    Text = "🌈 Activar Chams",
    Default = false
}):AddColorPicker("espHighlightColor1", {
    Title = "Color de Relleno",
    Default = Color3.fromRGB(128, 0, 255)
}):AddColorPicker("espHighlightColor2", {
    Title = "Color del Contorno",
    Default = Color3.fromRGB(255, 0, 128)
})
Toggles.espHighlightToggled:OnChanged(updatePlayers)
Options.espHighlightColor1:OnChanged(updatePlayers)
Options.espHighlightColor2:OnChanged(updatePlayers)

espChamsGroup:AddDivider()

espChamsGroup:AddToggle("espHighlightUseTeamColor", {
    Text = "🎨 Usar Color de Equipo",
    Default = false
}):OnChanged(updatePlayers)

espChamsGroup:AddDropdown("espHighlightDepthMode", {
    Text = "📐 Modo de Profundidad",
    AllowNull = false,
    Multi = false,
    Values = { "Occluded", "AlwaysOnTop" },
    Default = "AlwaysOnTop"
}):OnChanged(updatePlayers)

espChamsGroup:AddSlider("espHighlightFillTransparency", {
    Text = "🔮 Transparencia Relleno",
    Min = 0,
    Max = 1,
    Default = 0.5,
    Rounding = 2
}):OnChanged(updatePlayers)

espChamsGroup:AddSlider("espHighlightOutlineTransparency", {
    Text = "✨ Transparencia Contorno",
    Min = 0,
    Max = 1,
    Default = 0,
    Rounding = 2
}):OnChanged(updatePlayers)

-- ══════════════════════
-- TAB: FILTROS
-- ══════════════════════
local filtersTab = mainWindow:AddTab("🔒 Filtros")
local ignoresGroup = filtersTab:AddLeftGroupbox("🚫 Ignorar Jugadores")
local teamIgnoresGroup = filtersTab:AddRightGroupbox("🏳️ Ignorar Equipos")

ignoresGroup:AddToggle("extenderSitCheck", {
    Text = "🪑 Ignorar Sentados",
    Default = false,
    Tooltip = "No extiende hitbox a jugadores sentados"
}):OnChanged(updatePlayers)

ignoresGroup:AddToggle("extenderFFCheck", {
    Text = "🛡️ Ignorar con ForceField",
    Default = false,
    Tooltip = "No extiende hitbox a jugadores con escudo"
}):OnChanged(updatePlayers)

ignoresGroup:AddDivider()

ignoresGroup:AddToggle("ignoreSelectedPlayersToggled", {
    Text = "👤 Ignorar Jugadores Seleccionados",
    Default = false
}):OnChanged(updatePlayers)

ignoresGroup:AddDropdown("ignorePlayerList", {
    Text = "Jugadores",
    AllowNull = true,
    Multi = true,
    Values = {}
}):OnChanged(updatePlayers)

teamIgnoresGroup:AddToggle("ignoreOwnTeamToggled", {
    Text = "🤝 Ignorar Propio Equipo",
    Default = false,
    Tooltip = "No afecta a compañeros de equipo"
}):OnChanged(updatePlayers)

teamIgnoresGroup:AddDivider()

teamIgnoresGroup:AddToggle("ignoreSelectedTeamsToggled", {
    Text = "🏳️ Ignorar Equipos Seleccionados",
    Default = false
}):OnChanged(updatePlayers)

teamIgnoresGroup:AddDropdown("ignoreTeamList", {
    Text = "Equipos",
    AllowNull = true,
    Multi = true,
    Values = {}
}):OnChanged(updatePlayers)

-- ══════════════════════
-- TAB: AJUSTES
-- ══════════════════════
local settingsTab = mainWindow:AddTab("⚙️ Ajustes")
local keybindsGroup = settingsTab:AddLeftGroupbox("⌨️ Atajos de Teclado")
local infoGroup = settingsTab:AddRightGroupbox("📊 Información")
local emergencyGroup = settingsTab:AddLeftGroupbox("🚨 Emergencia")

keybindsGroup:AddLabel("🔑 Abrir/Cerrar Menú"):AddKeyPicker("menuKeybind", {
    Default = "RightControl",
    NoUI = true,
    Text = "Tecla del Menú"
})

keybindsGroup:AddLabel("🔄 Forzar Actualización"):AddKeyPicker("forceUpdateKeybind", {
    Default = "Home",
    NoUI = true,
    Text = "Forzar Update"
})
Options.forceUpdateKeybind:OnClick(updatePlayers)
Library.ToggleKeybind = Options.menuKeybind

-- Info
infoGroup:AddLabel("⚔️ Balthazar HBE Suite")
infoGroup:AddDivider()
infoGroup:AddLabel("📅 Fecha: 30/7/26")
infoGroup:AddLabel("📦 Versión: 1.0.0")
infoGroup:AddLabel("🎮 Juego: Balthazar")
infoGroup:AddLabel("👥 Jugadores: " .. #Players:GetPlayers())
infoGroup:AddDivider()
infoGroup:AddLabel("💡 Tip: Ajusta el tamaño")
infoGroup:AddLabel("   según necesites.")

-- Emergencia
emergencyGroup:AddButton({
    Text = "🔍 Buscar Jugadores Faltantes",
    Func = function()
        local found = 0
        for _, player in ipairs(Players:GetPlayers()) do
            if players[player] or player == lPlayer then
                continue
            else
                found = found + 1
                addPlayer(player)
            end
        end
        if found > 0 then
            Library:Notify("✅ Encontrados " .. found .. " jugadores faltantes", 3)
        else
            Library:Notify("✅ No se encontraron jugadores faltantes", 3)
        end
        updatePlayers()
    end,
    DoubleClick = false,
    Tooltip = "Busca jugadores que no fueron detectados automáticamente"
})

emergencyGroup:AddButton({
    Text = "🗑️ Limpiar ESP",
    Func = function()
        for _, v in pairs(players) do
            task.spawn(function()
                v:DeleteVisuals()
            end)
        end
        Library:Notify("🗑️ ESP limpiado correctamente", 3)
    end,
    DoubleClick = true,
    Tooltip = "Doble clic para limpiar todos los visuales ESP (requiere reiniciar)"
})

emergencyGroup:AddButton({
    Text = "♻️ Recargar Hitboxes",
    Func = function()
        updatePlayers()
        Library:Notify("♻️ Hitboxes recargados", 2)
    end,
    DoubleClick = false,
    Tooltip = "Fuerza una recarga de todos los hitboxes"
})

-- Configuración y Temas
SaveManager:BuildConfigSection(settingsTab)
ThemeManager:ApplyToTab(settingsTab)

-- Cargar config automática
SaveManager:LoadAutoloadConfig()

-- ═══════════════════════════════════════════════════════
-- LÓGICA DE JUGADORES
-- ═══════════════════════════════════════════════════════
local function updateList(list)
    list:SetValues()
    list:Display()
end

local function addPlayer(player)
    table.insert(Options.ignorePlayerList.Values, player.Name)
    updateList(Options.ignorePlayerList)
    players[player] = {}
    local playerIdx = players[player]
    local playerChar = player.Character
    local defaultProperties = {}

    local function isTeammate()
        -- Detección genérica de equipos para Balthazar
        -- Puedes agregar lógica específica del juego aquí
        if lPlayer.Team and player.Team then
            return lPlayer.Team == player.Team
        end
        
        -- Detección por color de HumanoidRootPart (alternativa)
        if lPlayer.Character and playerChar then
            local lHRP = lPlayer.Character:FindFirstChild("HumanoidRootPart")
            local pHRP = playerChar:FindFirstChild("HumanoidRootPart")
            if lHRP and pHRP then
                return lHRP.Color == pHRP.Color
            end
        end
        
        return false
    end

    local function isDead()
        if not playerChar then return true end
        local humanoid = playerChar:FindFirstChildWhichIsA("Humanoid")
        if not humanoid then return true end
        return humanoid:GetState() == Enum.HumanoidStateType.Dead or humanoid.Health <= 0
    end

    local function isSitting()
        if not playerChar then return false end
        local humanoid = playerChar:FindFirstChildWhichIsA("Humanoid")
        return Toggles.extenderSitCheck.Value and humanoid ~= nil and humanoid.Sit == true
    end

    local function isFFed()
        if not playerChar then return false end
        local ff = playerChar:FindFirstChildWhichIsA("ForceField")
        return Toggles.extenderFFCheck.Value and ff ~= nil and ff.Visible == true
    end

    local function isIgnored()
        if not playerChar then return true end
        return (Toggles.ignoreOwnTeamToggled.Value and isTeammate()) or
            (Toggles.ignoreSelectedTeamsToggled.Value and table.find(Options.ignoreTeamList:GetActiveValues(), tostring(player.Team))) or
            (Toggles.ignoreSelectedPlayersToggled.Value and table.find(Options.ignorePlayerList:GetActiveValues(), tostring(player.Name)))
    end

    -- ══════════════════════
    -- HBE CORE
    -- ══════════════════════
    local debounce = false

    local function setup(part)
        defaultProperties[part.Name] = {}
        local properties = defaultProperties[part.Name]
        properties.Size = part.Size
        properties.Transparency = part.Transparency
        properties.Massless = part.Massless
        properties.CanCollide = part.CanCollide

        local getSizeHook = part:AddGetHook("Size", properties.Size)
        local getTransparencyHook = part:AddGetHook("Transparency", properties.Transparency)
        local getMasslessHook = part:AddGetHook("Massless", properties.Massless)
        local getCanCollideHook = part:AddGetHook("CanCollide", properties.CanCollide)

        local setSizeHook = part:AddSetHook("Size", function(_, value)
            properties.Size = value
            getSizeHook:Modify("Size", properties.Size)
            if Toggles.extenderToggled.Value then
                local size = Options.extenderSize.Value
                return Vector3.new(size, size, size)
            end
            return properties.Size
        end)

        local setTransparencyHook = part:AddSetHook("Transparency", function(_, value)
            properties.Transparency = value
            getTransparencyHook:Modify("Transparency", properties.Transparency)
            if Toggles.extenderToggled.Value then
                return Options.extenderTransparency.Value
            end
            return properties.Transparency
        end)

        local setMasslessHook = part:AddSetHook("Massless", function(_, value)
            properties.Massless = value
            getMasslessHook:Modify("Massless", properties.Massless)
            if Toggles.extenderToggled.Value then
                if part.Name ~= "HumanoidRootPart" then
                    return true
                end
            end
            return properties.Massless
        end)

        local setCanCollideHook = part:AddSetHook("CanCollide", function(_, value)
            properties.CanCollide = value
            getCanCollideHook:Modify("CanCollide", properties.CanCollide)
            if Toggles.extenderToggled.Value and not Toggles.collisionsToggled.Value then
                return false
            end
            return properties.CanCollide
        end)

        local changed = part.Changed:Connect(function(property)
            if debounce then return end
            if properties[property] then
                if properties[property] ~= part[property] then
                    properties[property] = part[property]
                end
                playerIdx:Update()
            end
        end)

        part.Destroying:Connect(function()
            getSizeHook:Remove()
            getTransparencyHook:Remove()
            getMasslessHook:Remove()
            getCanCollideHook:Remove()
            setSizeHook:Remove()
            setTransparencyHook:Remove()
            setMasslessHook:Remove()
            setCanCollideHook:Remove()
            changed:Disconnect()
        end)
    end

    local function isActive(part)
        local name = part.Name
        for _, v in pairs(Options.extenderPartList:GetActiveValues()) do
            if string.match(name, v) or
                (v == "Custom Part" and string.match(name, Options.customPartName.Value)) or
                (v == "Left Arm" and string.match(name, "Left") and (string.match(name, "Arm") or string.match(name, "Hand"))) or
                (v == "Right Arm" and string.match(name, "Right") and (string.match(name, "Arm") or string.match(name, "Hand"))) or
                (v == "Left Leg" and string.match(name, "Left") and (string.match(name, "Leg") or string.match(name, "Foot"))) or
                (v == "Right Leg" and string.match(name, "Right") and (string.match(name, "Leg") or string.match(name, "Foot"))) then
                return true
            end
        end
        return false
    end

    local function resize(part)
        if not defaultProperties[part.Name] then
            setup(part)
        end
        if Toggles.extenderToggled.Value and isActive(part) and not isIgnored() and not isSitting() and not isFFed() and not isDead() then
            if part.Name ~= "HumanoidRootPart" then
                part.Massless = true
            end
            if not Toggles.collisionsToggled.Value then
                part.CanCollide = false
            else
                part.CanCollide = defaultProperties[part.Name].CanCollide
            end
            local size = Options.extenderSize.Value
            part.Size = Vector3.new(size, size, size)
            part.Transparency = Options.extenderTransparency.Value
            if part.Name == "Head" then
                local face = part:FindFirstChild("face")
                if face then
                    face.Transparency = Options.extenderTransparency.Value
                end
            end
        else
            part.Massless = defaultProperties[part.Name].Massless
            part.CanCollide = defaultProperties[part.Name].CanCollide
            part.Size = defaultProperties[part.Name].Size
            part.Transparency = defaultProperties[part.Name].Transparency
            if part.Name == "Head" then
                local face = part:FindFirstChild("face")
                if face then
                    face.Transparency = defaultProperties["Head"].Transparency
                end
            end
        end
    end

    function playerIdx:Update()
        if not playerChar then return end
        debounce = true
        for _, v in pairs(playerChar:GetChildren()) do
            if v:IsA("BasePart") then
                resize(v)
            end
        end
        debounce = false
    end

    -- ══════════════════════
    -- ESP CORE
    -- ══════════════════════
    local function FindFirstChildMatching(parent, name)
        if not parent then return nil end
        for _, v in pairs(parent:GetChildren()) do
            if string.match(v.Name, name) then
                return v
            end
        end
    end

    local nameEsp = Drawing.new("Text")
    nameEsp.Center = true
    nameEsp.Outline = true
    nameEsp.Font = Drawing.Fonts.Plex

    local healthBar = Drawing.new("Line")
    healthBar.Thickness = 2

    local healthBarBg = Drawing.new("Line")
    healthBarBg.Thickness = 4
    healthBarBg.Color = Color3.fromRGB(0, 0, 0)

    local distanceText = Drawing.new("Text")
    distanceText.Center = true
    distanceText.Outline = true
    distanceText.Font = Drawing.Fonts.Plex

    local chams = Instance.new("Highlight")
    chams.Parent = game:GetService("CoreGui")

    function playerIdx:UpdateESP()
        if not playerChar or isIgnored() or isDead() then
            nameEsp.Visible = false
            chams.Enabled = false
            healthBar.Visible = false
            healthBarBg.Visible = false
            distanceText.Visible = false
            return
        end

        -- Nombre ESP
        if Toggles.espNameToggled.Value then
            local target = FindFirstChildMatching(playerChar, "Torso") or FindFirstChildMatching(playerChar, "UpperTorso") or playerChar:FindFirstChild("HumanoidRootPart")
            if target then
                local pos, vis = WorldToViewportPoint(Camera, target.Position + Vector3.new(0, 3, 0))
                if vis then
                    if Options.espNameType.Value == "Display Name" then
                        nameEsp.Text = player.DisplayName
                    else
                        nameEsp.Text = player.Name
                    end
                    if Toggles.espNameUseTeamColor.Value and player.Team then
                        nameEsp.Color = player.TeamColor.Color
                    else
                        nameEsp.Color = Options.espNameColor1.Value
                    end
                    nameEsp.OutlineColor = Options.espNameColor2.Value
                    nameEsp.Position = Vector2.new(pos.X, pos.Y)
                    nameEsp.Size = math.clamp(1000 / pos.Z + 10, 12, 28)
                    nameEsp.Visible = true

                    -- Distancia
                    if lPlayer.Character and lPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (lPlayer.Character.HumanoidRootPart.Position - target.Position).Magnitude
                        distanceText.Text = string.format("[%.0f studs]", dist)
                        distanceText.Color = Options.espNameColor1.Value
                        distanceText.OutlineColor = Options.espNameColor2.Value
                        distanceText.Position = Vector2.new(pos.X, pos.Y + nameEsp.Size + 2)
                        distanceText.Size = math.clamp(800 / pos.Z + 8, 10, 22)
                        distanceText.Visible = true
                    else
                        distanceText.Visible = false
                    end

                    -- Barra de vida
                    local humanoid = playerChar:FindFirstChildWhichIsA("Humanoid")
                    if humanoid then
                        local healthPercent = humanoid.Health / humanoid.MaxHealth
                        local barWidth = math.clamp(1200 / pos.Z + 15, 20, 60)
                        local barY = pos.Y + nameEsp.Size + distanceText.Size + 6

                        healthBarBg.From = Vector2.new(pos.X - barWidth / 2, barY)
                        healthBarBg.To = Vector2.new(pos.X + barWidth / 2, barY)
                        healthBarBg.Visible = true

                        healthBar.From = Vector2.new(pos.X - barWidth / 2, barY)
                        healthBar.To = Vector2.new(pos.X - barWidth / 2 + barWidth * healthPercent, barY)
                        healthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                        healthBar.Visible = true
                    else
                        healthBar.Visible = false
                        healthBarBg.Visible = false
                    end
                else
                    nameEsp.Visible = false
                    distanceText.Visible = false
                    healthBar.Visible = false
                    healthBarBg.Visible = false
                end
            else
                nameEsp.Visible = false
                distanceText.Visible = false
                healthBar.Visible = false
                healthBarBg.Visible = false
            end
        else
            nameEsp.Visible = false
            distanceText.Visible = false
            healthBar.Visible = false
            healthBarBg.Visible = false
        end

        -- Chams
        if Toggles.espHighlightToggled.Value then
            chams.Adornee = playerChar
            if Toggles.espHighlightUseTeamColor.Value and player.Team then
                chams.FillColor = player.TeamColor.Color
                chams.OutlineColor = player.TeamColor.Color
            else
                chams.FillColor = Options.espHighlightColor1.Value
                chams.OutlineColor = Options.espHighlightColor2.Value
            end
            chams.DepthMode = Enum.HighlightDepthMode[Options.espHighlightDepthMode.Value]
            chams.FillTransparency = Options.espHighlightFillTransparency.Value
            chams.OutlineTransparency = Options.espHighlightOutlineTransparency.Value
            chams.Enabled = true
        else
            chams.Enabled = false
        end
    end

    function playerIdx:DeleteVisuals()
        nameEsp:Remove()
        distanceText:Remove()
        healthBar:Remove()
        healthBarBg:Remove()
        chams:Destroy()
    end

    -- ══════════════════════
    -- CHARACTER HANDLING
    -- ══════════════════════
    local function WaitForFullChar(char)
        local startTime = tick()
        local humanoid = char:FindFirstChildWhichIsA("Humanoid")
        if not humanoid then
            repeat
                if char == nil then return false end
                humanoid = char:FindFirstChildWhichIsA("Humanoid")
                task.wait()
            until humanoid or tick() - startTime >= 2
        end
        if not humanoid then return false end
        local loaded = false
        startTime = tick()
        repeat
            local limbs = 0
            for _, v in pairs(char:GetChildren()) do
                if v:IsA("BasePart") then
                    local limb = humanoid:GetLimb(v)
                    if limb ~= Enum.Limb.Unknown then
                        limbs += 1
                    end
                end
            end
            if limbs >= 5 then
                loaded = true
            end
            task.wait()
        until loaded or tick() - startTime >= 3
        return true
    end

    player.CharacterAdded:Connect(function(character)
        playerChar = character
        defaultProperties = {}
        if WaitForFullChar(character) then
            playerIdx:Update()
            local humanoid = character:FindFirstChildWhichIsA("Humanoid")
            if humanoid then
                humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                    if humanoid.Health <= 0 then
                        playerIdx:Update()
                    end
                end)
                humanoid.StateChanged:Connect(function(_, newState)
                    if newState == Enum.HumanoidStateType.Dead then
                        playerIdx:Update()
                    end
                end)
            end
            if character:FindFirstChildWhichIsA("ForceField") then
                playerIdx:Update()
            end
            character.ChildAdded:Connect(function(child)
                if child:IsA("ForceField") then
                    playerIdx:Update()
                elseif child:IsA("BasePart") then
                    playerIdx:Update()
                end
            end)
            character.ChildRemoved:Connect(function(child)
                if child:IsA("ForceField") then
                    playerIdx:Update()
                end
            end)
        end
    end)

    player.CharacterRemoving:Connect(function()
        if playerIdx then
            defaultProperties = {}
        end
    end)

    player:GetPropertyChangedSignal("Team"):Connect(function()
        playerIdx:Update()
    end)
end

local function removePlayer(player)
    if not players[player] then return end
    players[player]:DeleteVisuals()
    local idx = table.find(Options.ignorePlayerList.Values, player.Name)
    if idx then
        table.remove(Options.ignorePlayerList.Values, idx)
    end
    updateList(Options.ignorePlayerList)
    players[player] = nil
end

-- ═══════════════════════════════════════════════════════
-- INICIALIZACIÓN
-- ═══════════════════════════════════════════════════════

-- Agregar jugadores existentes
for _, player in ipairs(Players:GetPlayers()) do
    if player == lPlayer then continue end
    addPlayer(player)
end

-- Agregar equipos existentes
for _, team in pairs(Teams:GetTeams()) do
    if team:IsA("Team") then
        table.insert(Options.ignoreTeamList.Values, team.Name)
        updateList(Options.ignoreTeamList)
    end
end

-- Conexiones de eventos
Players.PlayerAdded:Connect(function(player)
    addPlayer(player)
end)

Players.PlayerRemoving:Connect(function(player)
    removePlayer(player)
end)

Teams.ChildAdded:Connect(function(team)
    if team:IsA("Team") then
        table.insert(Options.ignoreTeamList.Values, team.Name)
        updateList(Options.ignoreTeamList)
    end
end)

Teams.ChildRemoved:Connect(function(team)
    if team:IsA("Team") then
        local idx = table.find(Options.ignoreTeamList.Values, team.Name)
        if idx then
            table.remove(Options.ignoreTeamList.Values, idx)
        end
        updateList(Options.ignoreTeamList)
    end
end)

lPlayer:GetPropertyChangedSignal("Team"):Connect(function()
    updatePlayers()
end)

lPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    updatePlayers()
end)

-- ═══════════════════════════════════════════════════════
-- FINALIZACIÓN
-- ═══════════════════════════════════════════════════════
getgenv().BalthazarHBELoaded = true
updatePlayers()

-- Notificaciones de bienvenida
Library:Notify("⚔️ Balthazar Suite cargado correctamente!", 4)
task.wait(0.5)
Library:Notify("📅 Fecha: 30/7/26 | v1.0.0", 3)
task.wait(0.3)
Library:Notify("⌨️ Presiona " .. tostring(Library.ToggleKeybind.Value) .. " para abrir el menú", 5)