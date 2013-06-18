--[[

parsnip <333333333333333

]]--

--Start of config
local psEspCvar = CreateClientConVar( "ps_esp", 1, true, false )
local psCroCvar = CreateClientConVar( "ps_xhair", 1, true, false )
--End of config

local printers = {"golden_printer", "diamond_printer", "quantum_printer", "emerald_printer",
                   "money_pallet", "factory_printer", "gold_silo", "quantum_silo",
                   "diamond_silo", "diamond_factory", "diamond_pallet", "emerald_silo",
                   "christmas_silo", "christmas_factory", "drug_lab", "normal_money_printer",
                   "gold_money_printer", "ruby_money_printer", "donator_money_printer"}
 

local function FillRGBA(x,y,w,h,col)
    surface.SetDrawColor( col.r, col.g, col.b, col.a );
    surface.DrawRect( x, y, w, h );
end

local function OutlineRGBA(x,y,w,h,col)
    surface.SetDrawColor( col.r, col.g, col.b, col.a );
    surface.DrawOutlinedRect( x, y, w, h );
end

local function DrawCrosshair()
    local w = ScrW() / 2;
    local h = ScrH() / 2;
    
    FillRGBA( w - 5, h, 11, 1, Color( 255, 0, 0, 255 ) );
    FillRGBA( w, h - 5, 1, 11, Color( 255, 0, 0, 255 ) );
end

function DrawESP()
    if psEspCvar:GetInt() == 1 then
        for k, v in pairs(ents.GetAll()) do
            if( v:IsValid() and v ~= LocalPlayer() ) then
                if( v:IsNPC() ) then
                    local drawColor = Color(255, 255, 255, 255);
                    local drawPosit = v:GetPos():ToScreen();
                    
                    drawColor = Color( 255, 0, 0, 255 );
                    
                    local textData = {}
                    
                    textData.pos = {}
                    textData.pos[1] = drawPosit.x;
                    textData.pos[2] = drawPosit.y;
                    textData.color = drawColor;
                    textData.text = v:GetClass();
                    textData.font = "DefaultFixed";
                    textData.xalign = TEXT_ALIGN_CENTER;
                    textData.yalign = TEXT_ALIGN_CENTER;
                    draw.Text( textData );
                    
                elseif( v:IsPlayer() and v:Health() > 0 and v:Alive() ) then
                    local drawColor = team.GetColor(v:Team());
                    local drawPosit = v:EyePos():ToScreen();
                    
                    drawColor.r = drawColor.r/255*230 + 25
                    drawColor.g = drawColor.r/255*230 + 25
                    drawColor.b = drawColor.r/255*230 + 25
                    drawColor.a = 255;
                    
		            if v:GetFriendStatus() == "friend" then
                        draw.SimpleTextOutlined(v:GetName(),
                                                "DefaultFixed",
                                                drawPosit.x,
                                                drawPosit.y,
                                                Color(255,0,0,255),
                                                TEXT_ALIGN_CENTER,
                                                TEXT_ALIGN_CENTER,
                                                1,
                                                Color(0,0,255,255))
                    else
                        draw.SimpleTextOutlined(v:GetName(),
                                                "DefaultFixed",
                                                drawPosit.x,
                                                drawPosit.y,
                                                drawColor,
                                                TEXT_ALIGN_CENTER,
                                                TEXT_ALIGN_CENTER,
                                                1,
                                                Color(0,0,0,255))
                    end
                    
                    local max_health = 100;
                    
                    if( v:Health() > max_health ) then
                        max_health = v:Health();
                    end
                    
                    local mx = max_health / 4;
                    local mw = v:Health() / 4;
                    
                    local drawPosHealth = drawPosit;
                    
                    drawPosHealth.x = drawPosHealth.x - ( mx / 2 );
                    drawPosHealth.y = drawPosHealth.y + 10;
                    
                    FillRGBA( drawPosHealth.x - 1, drawPosHealth.y - 1, mx + 2, 4 + 2, Color( 0, 0, 0, 255 ) );
                    FillRGBA( drawPosHealth.x, drawPosHealth.y, mw, 4, drawColor );
                elseif( table.HasValue(printers, v:GetClass()) ) then
                    
                    local drawColor = Color(255, 255, 128, 255);
                    local drawPosit = v:GetPos():ToScreen();
      
                    draw.SimpleTextOutlined(v:GetClass() .. v:EntIndex(),
                                            "DefaultFixed",
                                            drawPosit.x,
                                            drawPosit.y,
                                            drawColor,
                                            TEXT_ALIGN_CENTER,
                                            TEXT_ALIGN_CENTER,
                                            1,
                                            Color(0,0,0,255) )
                end
                
            end
        end
    end
end

function DrawXHair()
    if( psCroCvar:GetInt() == 1 ) then
        DrawCrosshair();
    end
end

concommand.Add("+bhop",function()
    hook.Add("Think","hook",function()
        RunConsoleCommand(((LocalPlayer():IsOnGround() or LocalPlayer():WaterLevel() > 0) and "+" or "-").."jump")
    end)
end)

concommand.Add("-bhop",function()
    RunConsoleCommand("-jump")
    hook.Remove("Think","hook")
end)

hook.Add( "HUDPaint", "DrawESP", DrawESP );
hook.Add( "HUDPaint", "DrawXHair", DrawXHair );  
