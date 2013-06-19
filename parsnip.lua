--[[

parsnip <333333333333333

]]--

local printers = {"golden_printer", "diamond_printer", "quantum_printer", "emerald_printer",
                   "money_pallet", "factory_printer", "gold_silo", "quantum_silo",
                   "diamond_silo", "diamond_factory", "diamond_pallet", "emerald_silo",
                   "christmas_silo", "christmas_factory", "drug_lab", "normal_money_printer",
                   "gold_money_printer", "ruby_money_printer", "donator_money_printer"}

surface.CreateFont("ParsnipFont", {
    font = "DefaultBold",
    size = 14
})

local function DrawCrosshair()
    local w = ScrW() / 2;
    local h = ScrH() / 2;
    
    FillRGBA( w - 5, h, 11, 1, Color( 255, 0, 0, 255 ) );
    FillRGBA( w, h - 5, 1, 11, Color( 255, 0, 0, 255 ) );
end

local function GetDrawColor(ply)
    local color = Color(255, 0, 255, 255)
    
    if ply:GetFriendStatus() ~= "friend" then
        color = team.GetColor(ply:Team())
        color.r = color.r/255*200 + 55
        color.g = color.g/255*200 + 55
        color.b = color.b/255*200 + 55
    end
    
    return color
end

local function DrawPlayerEsp()
    for k, v in pairs(player.GetAll()) do
        if v ~= LocalPlayer() and v:Health() > 0 then
            local color = GetDrawColor(v)
            local pos = v:EyePos():ToScreen();
            
            draw.SimpleTextOutlined(
                v:GetName(),
                "ParsnipFont",
                pos.x,
                pos.y,
                color,
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_CENTER,
                1,
                Color(0,0,0,255))
            surface.SetDrawColor(Color(0,0,0,200))
            surface.DrawRect(
                pos.x-21,
                pos.y+5,
                42,
                5)
            surface.SetDrawColor(Color(200,0,0,200))
            surface.DrawRect(
                pos.x-20,
                pos.y+6,
                v:Health()*0.4,
                3)
        end
    end
end

local function DrawPrinterEsp()
    for k, v in pairs(ents.GetAll()) do
        if v:IsValid() and table.HasValue(printers, v:GetClass()) then
            local pos = v:GetPos():ToScreen()
            draw.SimpleTextOutlined(
                v:GetClass(),
                "ParsnipFont",
                pos.x,
                pos.y,
                Color(255,0,255,255),
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_CENTER,
                1,
                Color(255,255,0,255))
            
        end 
    end
end

function ParsnipPaint()
    DrawPlayerEsp()
    DrawPrinterEsp()
end

local trigger_toggle = false
concommand.Add("+trigger", function()
    local wpn = LocalPlayer():GetActiveWeapon()
    if wpn:IsValid() and wpn.Primary then
        wpn.Primary.Recoil = 0
    end
    
    hook.Add("Think", "ParsnipTrigger", function()
        local target = LocalPlayer():GetEyeTrace().Entity
        
        if target:IsPlayer() or target:IsNPC() then
            if !trigger_toggle then
                RunConsoleCommand("+attack")
            else
                RunConsoleCommand("-attack") 
            end
            trigger_toggle = !trigger_toggle
        else
            if trigger_toggle then
                RunConsoleCommand("-attack")
                trigger_toggle = false
            end
        end
    end)
end)

concommand.Add("-trigger", function()
    RunConsoleCommand("-attack")
    hook.Remove("Think", "ParsnipTrigger")
end)

concommand.Add("+bhop",function()
    hook.Add("Think","hook",function()
        RunConsoleCommand(((LocalPlayer():IsOnGround() or LocalPlayer():WaterLevel() > 0) and "+" or "-").."jump")
    end)
end)

concommand.Add("-bhop",function()
    RunConsoleCommand("-jump")
    hook.Remove("Think","hook")
end)

hook.Add("HUDPaint", "ParsnipPaint", ParsnipPaint);

