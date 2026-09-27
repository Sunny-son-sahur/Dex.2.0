-- Made by QSTAR
-- Simple Spy - Title: SIMPLE JEW
-- Compatible with Xeno, Madium, JJSploit

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")

--// Variables
local RemoteArgs = {} -- Stores last args for each remote
local Hooked = {} -- Tracks hooked remotes to avoid duplicates
local Dumping = false -- Prevents multiple dumps
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SimpleSpy"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

--// Main GUI
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 600, 0, 450) -- Increased height for dump button
Main.Position = UDim2.new(0.5, -300, 0.5, -225)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderColor3 = Color3.fromRGB(60, 60, 60)
Main.Parent = ScreenGui

--// Title Bar
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.BorderSizePixel = 0
Title.Text = "SIMPLE JEW"
Title.TextColor3 = Color3.fromRGB(255, 215, 0) -- Gold
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 24
Title.Parent = Main

--// Credit Label
local Credit = Instance.new("TextLabel")
Credit.Size = UDim2.new(1, 0, 0, 25)
Credit.Position = UDim2.new(0, 0, 0, 40)
Credit.BackgroundTransparency = 1
Credit.Text = "Made by QSTAR"
Credit.TextColor3 = Color3.fromRGB(200, 200, 200)
Credit.Font = Enum.Font.SourceSans
Credit.TextSize = 16
Credit.Parent = Main

--// Remotes List Container
local ListContainer = Instance.new("ScrollingFrame")
ListContainer.Size = UDim2.new(1, -20, 1, -150) -- Adjusted for dump button
ListContainer.Position = UDim2.new(0, 10, 0, 70)
ListContainer.BackgroundTransparency = 1
ListContainer.ScrollBarThickness = 6
ListContainer.Parent = Main

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 4)
ListLayout.Parent = ListContainer

--// Refresh Button
local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(0, 100, 0, 30)
RefreshBtn.Position = UDim2.new(1, -110, 1, -40)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
RefreshBtn.BorderColor3 = Color3.fromRGB(80, 80, 80)
RefreshBtn.Text = "Refresh"
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBtn.Font = Enum.Font.SourceSans
RefreshBtn.TextSize = 16
RefreshBtn.Parent = Main

--// Dump Game Button
local DumpBtn = Instance.new("TextButton")
DumpBtn.Size = UDim2.new(0, 100, 0, 30)
DumpBtn.Position = UDim2.new(1, -220, 1, -40) -- Below refresh button
DumpBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 100) -- Blue-ish
DumpBtn.BorderColor3 = Color3.fromRGB(100, 100, 150)
DumpBtn.Text = "Dump Game"
DumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DumpBtn.Font = Enum.Font.SourceSans
DumpBtn.TextSize = 16
DumpBtn.Parent = Main

--// Status Label (for dump progress)
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 20)
StatusLabel.Position = UDim2.new(0, 10, 1, -30) -- Above bottom
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Ready"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 14
StatusLabel.Parent = Main

--// Functions
local function hookRemote(remote)
    if Hooked[remote] then return end
    Hooked[remote] = true

    local old = remote.__namecall
    remote.__namecall = function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" or method == "InvokeServer" then
            local args = {...}
            RemoteArgs[remote] = args
        end
        return old(self, ...)
    end
end

local function createRemoteButton(remote, isEvent)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 35)
    Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Button.BorderColor3 = Color3.fromRGB(60, 60, 60)
    Button.Text = (isEvent and "[Event] " or "[Function] ") .. remote:GetFullName()
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.SourceSans
    Button.TextSize = 14
    Button.Parent = ListContainer

    Button.MouseButton1Click:Connect(function()
        local args = RemoteArgs[remote] or {}
        print(("SIMPLE JEW: %s %s"):format(isEvent and "Event" or "Function", remote:GetFullName()))
        print("Last args:", unpack(args))

        -- Fire remote with last args
        local success, result = pcall(function()
            if isEvent then
                return remote:FireServer(unpack(args))
            else
                return remote:InvokeServer(unpack(args))
            end
        end)

        if success then
            print("FIRED SUCCESSFULLY")
            if not isEvent then
                print("Result:", result)
            end
        else
            print("ERROR:", result)
        end
    end)
end

local function scanForRemotes(obj)
    for _, child in ipairs(obj:GetChildren()) do
        if child:IsA("RemoteEvent") then
            hookRemote(child)
            createRemoteButton(child, true)
        elseif child:IsA("RemoteFunction") then
            hookRemote(child)
            createRemoteButton(child, false)
        end
        scanForRemotes(child)
    end
end

local function refreshList()
    -- Clear existing buttons
    for _, child in ipairs(ListContainer:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    -- Reset tracking
    RemoteArgs = {}
    Hooked = {}

    -- Rescan
    scanForRemotes(game)
end

--// Game Dumping Functions
local function dumpInstance(instance, indent)
    local indentStr = string.rep("  ", indent)
    local result = indentStr .. "- **" .. instance.ClassName .. "** `" .. instance.Name .. "`\n"

    -- List children
    local children = instance:GetChildren()
    if #children > 0 then
        result = result .. indentStr .. "  Children:\n"
        for _, child in ipairs(children) do
            result = result .. dumpInstance(child, indent + 2)
        end
    end

    return result
end

local function getGameName()
    local success, name = pcall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId).Name
    end)
    if success and name and name ~= "" then
        return name:gsub("[^%w%s%-_]", "") -- Remove problematic characters for filename
    end
    return "Game_" .. tostring(game.PlaceId)
end

local function saveDumpToDesktop(dumpContent)
    local gameName = getGameName()
    local filePath = "/home/sunny/Desktop/" .. gameName .. ".md"

    -- Try to write file using standard Lua IO
    local file, err = io.open(filePath, "w")
    if file then
        file:write(dumpContent)
        file:close()
        return true, "Saved to: " .. filePath
    else
        -- Fallback: try executor's writefile if available
        if typeof(writefile) == "function" then
            pcall(function()
                writefile(gameName .. ".md", dumpContent)
            end)
            return true, "Saved via writefile (check executor workspace)"
        else
            return false, "Failed to save: " .. tostring(err)
        end
    end
end

local function dumpGame()
    if Dumping then
        StatusLabel.Text = "Already dumping..."
        return
    end

    Dumping = true
    StatusLabel.Text = "Dumping game... (this may take a moment)"
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 100) -- Yellow

    -- Generate dump content
    local dumpContent = "# Game Dump: " .. getGameName() .. "\n\n"
    dumpContent = dumpContent .. "**Place ID:** " .. tostring(game.PlaceId) .. "\n\n"
    dumpContent = dumpContent .. "## Instance Hierarchy\n\n"
    dumpContent = dumpContent .. dumpInstance(game, 0)

    -- Save to file
    local success, message = saveDumpToDesktop(dumpContent)

    if success then
        StatusLabel.Text = "Dump complete! " .. message
        StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100) -- Green
        print("[SIMPLE JEW] " .. message)
    else
        StatusLabel.Text = "Dump failed: " .. message
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100) -- Red
        print("[SIMPLE JEW] Dump failed: " .. message)
    end

    Dumping = false
end

--// Make Title Bar Draggable
do
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                 startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    Title.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

--// Initialization
print("Made by QSTAR")
refreshList()

--// Connect Buttons
RefreshBtn.MouseButton1Click:Connect(refreshList)
DumpBtn.MouseButton1Click:Connect(dumpGame)

--// Auto-refresh on new descendants (optional)
game.DescendantAdded:Connect(function(desc)
    if desc:IsA("RemoteEvent") or desc:IsA("RemoteFunction") then
        -- Small delay to avoid duplicate hooks
        task.wait(0.1)
        refreshList()
    end
end)