PLUGIN.name = "Improved Constructable Props"
PLUGIN.author = "SHOOTER#5269"
PLUGIN.description = "Adds the ability to construct props and entities"

function PLUGIN:LoadData()
	self:LoadConstructionProp()
end

function PLUGIN:SaveData()
	self:SaveConstructionProp()
end

if (SERVER) then
	function PLUGIN:SaveConstructionProp()
		local data = {}
		for _, v in ipairs(ents.FindByClass("prop_physics")) do
			data[#data + 1] = {
				pos = v:GetPos(),
				angles = v:GetAngles(),
				model = v:GetModel(),
			}
		end
		ix.data.Set("ConstructionProp", data)
	end

	function PLUGIN:LoadConstructionProp()
		for _, v in ipairs(ix.data.Get("ConstructionProp") or {}) do
			local prop = ents.Create( "prop_physics" )

			prop:SetModel( v.model )
			prop:SetPos( v.pos )
			prop:SetMoveType(MOVETYPE_VPHYSICS)
			prop:SetSolid(SOLID_VPHYSICS)
			prop:SetAngles(v.angles)
			prop:Spawn()
			prop:GetPhysicsObject():EnableMotion( false )
		end
	end
	
	function PLUGIN:PlayerSpawn(client)
		client:SetNWBool("ConstructablePropPlacing", false)
		client:SetNWBool("ConstructablePropReadytoPlace", false)
		client:SetNWString( "ConstructablePropModel", "nul")
		client:SetNWInt( "ConstructablePropID", 0 )
		client:SetNWInt( "ConstructablePropRotation", 0 )
		client:SetNWInt( "ConstructablePropRotationX", 0 )
	end

	function PLUGIN:PlayerDeath(client)
		client:SetNWBool("ConstructablePropPlacing", false)
		client:SetNWBool("ConstructablePropReadytoPlace", false)
		client:SetNWString( "ConstructablePropModel", "nul")
		client:SetNWInt( "ConstructablePropID", 0 )
		client:SetNWInt( "ConstructablePropRotation", 0 )
		client:SetNWInt( "ConstructablePropRotationX", 0 )
	end
	
	function PLUGIN:PlayerTick(ply, mv)
		local wep = ply:GetActiveWeapon()
		local ang = ply:GetAngles()
		local tr = ply:GetEyeTrace()
		local pos = ply:GetPos()
		if ply:GetNWBool("ConstructablePropPlacing", false) then
			if !ply:Crouching() and IsValid(ply) and ply:Alive() and IsValid(wep) and wep:GetClass() == "ix_hands" and pos:Distance(tr.HitPos) <= 250 then
				if not IsValid(ply.propConstructHolo) then
					ply.propConstructHolo = ents.Create("prop_physics")
					if IsValid(ply.propConstructHolo) then
						ply.propConstructHolo:SetAngles(Angle(0 - ply:GetNWInt( "ConstructablePropRotation" ), ply:EyeAngles().y - 180, 0 - ply:GetNWInt( "ConstructablePropRotationX" ) ))
						ply.propConstructHolo:SetPos(tr.HitPos - tr.HitNormal * ply.propConstructHolo:OBBMins().z)
						ply.propConstructHolo:SetColor(Color(0,204,204, 150))
						ply.propConstructHolo:SetModel(ply:GetNWString( "ConstructablePropModel"))
						ply.propConstructHolo:SetMaterial("models/shiny")
						ply.propConstructHolo:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
						ply.propConstructHolo:SetRenderMode(RENDERMODE_TRANSALPHA)
						ply.propConstructHolo:Spawn()
					else
						ply.propConstructHolo = nil
					end
				elseif IsValid(ply.propConstructHolo) then
					ply.propConstructHolo:SetPos(tr.HitPos - tr.HitNormal * ply.propConstructHolo:OBBMins().z)
					ply.propConstructHolo:SetAngles(Angle(0 - ply:GetNWInt( "ConstructablePropRotation" ), ply:EyeAngles().y - 180, 0 - ply:GetNWInt( "ConstructablePropRotationX" ) ))
					ply:SetNWBool("ConstructablePropReadytoPlace", true)
				end
			elseif ply.propConstructHolo != nil and IsValid(ply.propConstructHolo) then
				ply.propConstructHolo:Remove()
				ply.propConstructHolo = nil
				ply:SetNWBool("ConstructablePropPlacing", false)
			end
		end
	end
	function PLUGIN:KeyPress(ply, key)
		if key == IN_USE and IsValid(ply) and ply:Alive() and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "ix_hands" and ply:GetEyeTrace().HitPos:Distance(ply:GetPos()) <= 250 then
			if ply:GetNWBool("ConstructablePropPlacing") then
				local fortification = ents.Create("prop_physics")
				fortification:SetModel(ply:GetNWString( "ConstructablePropModel"))
				fortification:SetAngles(Angle(0 - ply:GetNWInt( "ConstructablePropRotation" ), ply:EyeAngles().y - 180, 0 - ply:GetNWInt( "ConstructablePropRotationX" )))
				fortification:SetPos(ply:GetEyeTrace().HitPos - ply:GetEyeTrace().HitNormal * fortification:OBBMins().z)
				fortification:SetMoveType(MOVETYPE_VPHYSICS)
				fortification:SetSolid(SOLID_VPHYSICS)
				fortification:Spawn()
				fortification:GetPhysicsObject():EnableMotion( false )
				ply.propConstructHolo:Remove()
				ply:GetCharacter():GetInventory():Remove(ply:GetNWInt( "ConstructablePropID" ))
				ply:SetNWBool("ConstructablePropPlacing", false)
				ply:SetNWString( "ConstructablePropModel", "nul")
			end
		end
		if key == IN_RELOAD and IsValid(ply) and ply:Alive() and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "ix_hands" and ply:GetEyeTrace().HitPos:Distance(ply:GetPos()) <= 250 then
			if ply:GetNWBool("ConstructablePropPlacing") then
				ply:SetNWString( "ConstructablePropModel", "nul")
				ply.propConstructHolo:Remove()
				ply:SetNWBool("ConstructablePropPlacing", false)
			end
		end
		if key == IN_ATTACK and IsValid(ply) and ply:Alive() and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "ix_hands" then
			if ply:GetNWBool("ConstructablePropPlacing") then
				if ply:GetNWInt( "ConstructablePropRotation" ) < 180 then
					ply:SetNWInt( "ConstructablePropRotation", ply:GetNWInt( "ConstructablePropRotation" ) + 15)
				else
					ply:SetNWInt( "ConstructablePropRotation", 0 )
				end
			end
		end
		if key == IN_ATTACK2 and IsValid(ply) and ply:Alive() and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "ix_hands" then
			if ply:GetNWBool("ConstructablePropPlacing") then
				if ply:GetNWInt( "ConstructablePropRotationX" ) < 180 then
					ply:SetNWInt( "ConstructablePropRotationX", ply:GetNWInt( "ConstructablePropRotationX" ) + 15)
				else
					ply:SetNWInt( "ConstructablePropRotationX", 0 )
				end
			end
		end
	end
	function PLUGIN:CanPlayerDropItem(client, item)
		if client:GetNWBool("ConstructablePropPlacing", false) and item == client:GetNWInt( "ConstructablePropID" ) then
			client.propConstructHolo:Remove()
			return false
		end
	end
end

if (CLIENT) then
	local w, h = ScrW(), ScrH()
	surface.CreateFont( "ConstructionPropFont", {
	font = "Arial",
	extended = false,
	size = 20 * h/500,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = true,
	} )
	
	function PLUGIN:HUDPaint()
		local lclient = LocalPlayer()
		local useBind = input.LookupBinding("+use") or "E"
		local reloadBind = input.LookupBinding("+reload") or "R"
		if lclient:GetNWBool("ConstructablePropPlacing", false) then
			
			draw.SimpleText("PLACING MODE ENABLED", "ConstructionPropFont", w/2, h/7, Color(255, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			
			if lclient:GetActiveWeapon():GetClass() != "ix_hands" then
				draw.SimpleText("Please have hands equipped to begin placing", "ConstructionPropFont", w/2, h/1.1, Color(255, 150, 150, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		
			if lclient:GetActiveWeapon():GetClass() == "ix_hands" then
				draw.SimpleText("LMB: Tilt Foward | RMB: Tilt Right | " .. string.upper(useBind) .. ": Place | " .. string.upper(reloadBind) .. ": Exit Placing", "ConstructionPropFont", w/2, h/1.1, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end
	end
end