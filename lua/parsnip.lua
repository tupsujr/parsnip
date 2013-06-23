--[[

parsnip <333333333333333

]]--
local trigger_toggle = false
local cvar_printer = CreateClientConVar("parsnip_printer", "1", false, false)
local cvar_friend = CreateClientConVar("parsnip_friend", "0", false, false)
local cvar_bhop = CreateClientConVar("parsnip_bhop", "1", false, false)
local old_yaw = 0
local old_dir = 0
local bhop_on = false

local printers = {"golden_printer", "diamond_printer", "quantum_printer", "emerald_printer",
                   "money_pallet", "factory_printer", "gold_silo", "quantum_silo",
                   "diamond_silo", "diamond_factory", "diamond_pallet", "emerald_silo",
                   "christmas_silo", "christmas_factory", "drug_lab", "normal_money_printer",
                   "gold_money_printer", "ruby_money_printer", "donator_money_printer",
                   "money_printer", "spawned_money", "ttt_c4"}

surface.CreateFont("ParsnipFont", {
    font = "DefaultBold",
    size = 14
})

local function DrawCrosshair()
    local w = ScrW() / 2;
    local h = ScrH() / 2;
    
    surface.SetDrawColor(Color(200,0,0,200))
    surface.DrawLine( w - 5, h, w + 6, h);
    surface.DrawLine( w, h - 5, w, h + 6);
    
    if bhop_on then
        surface.SetDrawColor(Color(0,0,250,200))
        if old_dir == 1 then
            surface.DrawLine( w, h, w + 30, h);
        elseif old_dir == -1 then
            surface.DrawLine( w, h, w - 30, h);
        end
    end
end

local function GetDrawColor(ply)
    local color = Color(255, 0, 255, 255)
    
    if ply.IsTraitor and ply:IsTraitor() then
        color = Color(255,0,0,255)
    elseif ply:GetFriendStatus() ~= "friend" then
        color = team.GetColor(ply:Team())
        color.r = color.r/255*200 + 55
        color.g = color.g/255*200 + 55
        color.b = color.b/255*200 + 55
    end
    
    return color
end

local function DrawPlayerEsp()
    for k, v in pairs(player.GetAll()) do
        if v ~= LocalPlayer() and v:Health() > 0 and
            not (cvar_friend:GetBool() and v:GetFriendStatus() ~= "friend") then
            
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
                math.min(v:Health()*0.4, 40),
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
    if cvar_printer:GetBool() then
        DrawPrinterEsp()
    end
    DrawCrosshair()
end

function ParsnipVersion()
    local version = file.Read("parsnip_version.txt", "DATA")
    return version:match("(.-)%s*$")
end

function ParsnipCheckVersion()
   http.Fetch("http://raw.github.com/tarjoilija/parsnip/master/data/parsnip_version.txt",
	function(HTML)
	    latest = HTML:match("(.-)%s*$")
	    current = ParsnipVersion()
	    if latest == current then
	        print("Parsnip is up to date " .. current)
	    else
	        print("Parsnip version " .. current .. ", available in github " .. latest)
	    end
	end,
	function()
		print("Parsnip version checking failed")
	end
 ); 
end

ParsnipCheckVersion()

function ParsnipMenu()
    local Form = vgui.Create("DFrame")
    Form:SetSize(400, 150)
    Form:Center()
    Form:SetTitle("parsnip " .. ParsnipVersion())
    Form:SetVisible(true)
    Form:ShowCloseButton(true)
    Form:MakePopup()
    
    local List = vgui.Create("DPanelList", Form)
    List:SetPos(15, 35)
    List:SetSize(400, 150)
    List:SetSpacing(10)
    List:EnableHorizontal(false)
    
    local CheckPrinter = vgui.Create("DCheckBoxLabel")
    CheckPrinter:SetText("Show printers")
    CheckPrinter:SetConVar("parsnip_printer")
    CheckPrinter:SizeToContents()
    List:AddItem(CheckPrinter)
    
    local CheckFriend = vgui.Create("DCheckBoxLabel")
    CheckFriend:SetText("Show steam friends only")
    CheckFriend:SetConVar("parsnip_friend")
    CheckFriend:SizeToContents()
    List:AddItem(CheckFriend)
    
    local CheckBhop = vgui.Create("DCheckBoxLabel")
    CheckBhop:SetText("Bhop script jumping")
    CheckBhop:SetConVar("parsnip_bhop")
    CheckBhop:SizeToContents()
    List:AddItem(CheckBhop)
end

concommand.Add("parsnip_menu", ParsnipMenu)

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
    old_yaw = LocalPlayer():GetAimVector().yaw
    old_dir = 0
    bhop_on = true
    hook.Add("Think","ParsnipBhop",function()
    
        if cvar_bhop:GetBool() then    
            RunConsoleCommand(((LocalPlayer():IsOnGround() or LocalPlayer():WaterLevel() > 0) and "+" or "-").."jump")
        else
            RunConsoleCommand("+jump")
        end
        
        
        -- BHOP AUTO-TURNING
        local dir = 0
        local yaw = LocalPlayer():EyeAngles().yaw
        local ang = (yaw - old_yaw) % 360
        if ang > 180 then
            ang = ang - 360
        end
        
        old_yaw = yaw
        if ang < 0 then
            dir = 1
        elseif ang > 0 then
            dir = -1
        end
        
        if dir ~= old_dir then
            if old_dir == 1 then
                RunConsoleCommand("-moveright")
            elseif old_dir == -1 then
                RunConsoleCommand("-moveleft")
            end
            
            if dir == 1 then
                RunConsoleCommand("+moveright")
            elseif dir == -1 then
                RunConsoleCommand("+moveleft")
            end
            old_dir = dir
        end
    end)
end)

concommand.Add("-bhop",function()
    bhop_on = false
    RunConsoleCommand("-jump")
    
    if old_dir == 1 then
        RunConsoleCommand("-moveright")
    elseif old_dir == -1 then
        RunConsoleCommand("-moveleft")
    end
    old_dir = 0
    old_yaw = 0
    hook.Remove("Think","ParsnipBhop")
end)

hook.Add("HUDPaint", "ParsnipPaint", ParsnipPaint);

