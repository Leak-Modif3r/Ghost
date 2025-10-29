local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ESPs = {}

local boneConnections = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"}
}

local function CreateESP(player)
    if player == LocalPlayer or not player then return end
    
    local Lines = {}
    for i = 1, #boneConnections do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Color = Color3.new(1, 1, 1)
        line.Thickness = 1
        line.Transparency = 1
        Lines[i] = line
    end
    
    ESPs[player] = {Lines = Lines}
end

local function UpdateESP()
    for player, esp in pairs(ESPs) do
        if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local character = player.Character
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if not rootPart then continue end
            local rootPos = rootPart.Position
            local vec, onScreen = Camera:WorldToViewportPoint(rootPos)
            
            if onScreen and vec.Z > 0 then
                local distance = (Camera.CFrame.Position - rootPos).Magnitude
                local thickness = math.clamp(20 / distance, 0.5, 1)
                
                local lineIndex = 1
                for _, connection in ipairs(boneConnections) do
                    local part1 = character:FindFirstChild(connection[1])
                    local part2 = character:FindFirstChild(connection[2])
                    
                    if part1 and part2 then
                        local pos1, vis1 = Camera:WorldToViewportPoint(part1.Position)
                        local pos2, vis2 = Camera:WorldToViewportPoint(part2.Position)
                        
                        if vis1 and vis2 and pos1.Z > 0 and pos2.Z > 0 then
                            esp.Lines[lineIndex].From = Vector2.new(pos1.X, pos1.Y)
                            esp.Lines[lineIndex].To = Vector2.new(pos2.X, pos2.Y)
                            esp.Lines[lineIndex].Thickness = thickness
                            esp.Lines[lineIndex].Visible = true
                            lineIndex = lineIndex + 1
                        end
                    end
                end
                
                for i = lineIndex, #boneConnections do
                    esp.Lines[i].Visible = false
                end
            else
                for i = 1, #boneConnections do
                    esp.Lines[i].Visible = false
                end
            end
        else
            for i = 1, #boneConnections do
                esp.Lines[i].Visible = false
            end
        end
    end
end

for _, player in pairs(Players:GetPlayers()) do
    CreateESP(player)
end

Players.PlayerAdded:Connect(CreateESP)

Players.PlayerRemoving:Connect(function(player)
    if ESPs[player] then
        for _, line in ipairs(ESPs[player].Lines) do
            line:Remove()
        end
        ESPs[player] = nil
    end
end)

RunService.RenderStepped:Connect(UpdateESP)
