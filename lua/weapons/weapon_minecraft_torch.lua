
AddCSLuaFile( "effects/rb655_torch_break.lua" )

if ( SERVER ) then resource.AddWorkshop( "104607519" ) end

SWEP.PrintName = "Minecraft Torch"
SWEP.Author = "Robotboy655"
SWEP.Category = "Robotboy655's Weapons"
SWEP.Contact = "http://steamcommunity.com/profiles/76561197996891752"
SWEP.Purpose = "To spread fire!"
SWEP.Instructions = "Primary break torch, secondary place, reload delete all, shift-primary ignite, shift-secondary throw."

SWEP.Slot = 0
SWEP.SlotPos = 4

SWEP.Spawnable = true
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.DrawWeaponInfoBox = false

SWEP.ViewModel = "models/minecraft/torch_v.mdl"
SWEP.WorldModel = "models/minecraft/torch_w.mdl"
SWEP.ViewModelFOV = 55
SWEP.HoldType = "melee"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

local gMCEmitter

if ( CLIENT ) then
	gMCEmitter = ParticleEmitter( vector_origin )
end

function SWEP:Initialize()

	self:SetHoldType( self.HoldType )

	if ( SERVER ) then return end

	self.SmoothLight = math.random( 256, 512 )

end

cleanup.Register( "mc_torches" )

function SWEP:PrimaryAttack()

	local owner = self:GetOwner()
	if ( IsFirstTimePredicted() ) then

		self:SetNextPrimaryFire( CurTime() + 0.5 )
		self:SetNextSecondaryFire( CurTime() + 0.5 )

		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		owner:SetAnimation( PLAYER_ATTACK1 )

	end

	if ( CLIENT ) then return end

	local tr
	if ( owner:IsNPC() ) then
		tr = util.TraceLine( {
			start = owner:GetShootPos(),
			endpos = owner:GetShootPos() + owner:GetAimVector() * 16384,
			filter = owner
		} )
	else
		tr = owner:GetEyeTrace()
	end

	self:Idle()

	local ent = tr.Entity
	if ( !IsValid( ent ) ) then return end

	if ( !owner:IsNPC() and !owner:KeyDown( IN_SPEED ) and ent:GetClass() == "ent_minecraft_torch" ) then
		ent:Remove()
	elseif ( !ent:IsPlayer() and owner:EyePos():Distance( tr.HitPos ) < 100 and owner:WaterLevel() < 3 ) then
		ent:Fire( "IgniteLifetime", math.random( 10, 30 ) )
	end
end

function SWEP:SecondaryAttack()

	if ( #ents.FindByClass( "ent_minecraft*" ) > 31 ) then return end

	local owner = self:GetOwner()
	if ( IsFirstTimePredicted() ) then

		self:SetNextPrimaryFire( CurTime() + 0.5 )
		self:SetNextSecondaryFire( CurTime() + 0.5 )

		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		owner:SetAnimation( PLAYER_ATTACK1 )

	end

	if ( CLIENT ) then return end

	self:Idle()

	local tr = owner:GetEyeTrace()

	if ( !owner:KeyDown( IN_SPEED ) and tr.HitNormal.z >= 0 and owner:EyePos():Distance( tr.HitPos ) < 100 and tr.HitWorld and tr.Entity:GetClass() != "ent_minecraft_torch" ) then
		local ang = Angle( 0, 0, 0 )
		local pos = tr.HitPos
		if ( tr.HitNormal.z < 0.7 ) then
			ang = tr.HitNormal:Angle() + Angle( 30, 0, 0 )
			pos = pos + tr.HitNormal * 0.5
		end

		local ent = ents.Create( "ent_minecraft_torch" )
		if ( !IsValid( ent ) ) then return end
		ent:SetPos( pos )
		ent:SetAngles( ang )
		ent:SetOwner( owner )
		ent:Spawn()
		ent:Activate()
		ent.PhysgunDisabled = true
		ent:EmitSound( "minecraft/wood" .. math.random( 1, 4 ) .. ".wav" )
		ent:SetNWBool( "WeaponSpawned", true )

		local phys = ent:GetPhysicsObject()
		if ( IsValid( phys ) ) then phys:EnableMotion( false ) end

		cleanup.Add( owner, "mc_torches", ent )
		undo.Create( "mc_torch" )
		undo.AddEntity( ent )
		undo.SetPlayer( owner )
		undo.Finish()
	else
		local f = owner:EyeAngles():Forward()
		local r = owner:EyeAngles():Right()
		local u = owner:EyeAngles():Up()

		if ( !util.IsInWorld( owner:GetShootPos() + f * 16 + r * 16 + u * -24 ) ) then return end

		local ent = ents.Create( "ent_minecraft_torch" )
		if ( !IsValid( ent ) ) then return end
		ent:SetPos( owner:GetShootPos() + f * 14 + r * 16 + u * -24 )
		ent:SetAngles( owner:GetAngles() + Angle( 0, 0, math.random( -30, 30 ) ) )
		ent:SetPhysicsAttacker( owner )
		ent:Spawn()
		ent:Activate()
		ent:EmitSound( "Weapon_Crowbar.Single" )
		ent:SetNWBool( "WeaponSpawned", true )

		local phys = ent:GetPhysicsObject()
		if ( IsValid( phys ) ) then phys:SetVelocity( f * 512 + Vector( 0, 0, math.random( 0, 128 ) ) ) end

		cleanup.Add( owner, "mc_torches", ent )
		undo.Create( "mc_torch" )
		undo.AddEntity( ent )
		undo.SetPlayer( owner )
		undo.Finish()
	end
end

function SWEP:Reload()
	local owner = self:GetOwner()
	if ( !IsValid( owner ) or !owner:KeyPressed( IN_RELOAD ) or CLIENT ) then return end

	for id, ent in pairs( ents.FindByClass( "ent_minecraft*" ) ) do
		if ( ent:GetNWBool( "WeaponSpawned", false ) ) then
			owner:ConCommand( "gmod_cleanup mc_torches" )
			break
		end
	end
end

function SWEP:Deploy()

	self:SendWeaponAnim( ACT_VM_DRAW )

	self:Idle()

	return true
end

function SWEP:Holster()
	timer.Remove( "rb655_idle" .. self:EntIndex() )
	return true
end

function SWEP:DoIdle()
	self:SendWeaponAnim( ACT_VM_IDLE )
	timer.Adjust( "rb655_idle" .. self:EntIndex(), self:SequenceDuration(), 0, function()
		if ( !IsValid( self ) ) then timer.Remove( "rb655_idle" .. self:EntIndex() ) return end
		self:SendWeaponAnim( ACT_VM_IDLE )
	end )
end

function SWEP:Idle()
	if ( CLIENT or !IsValid( self:GetOwner() ) ) then return end

	timer.Create( "rb655_idle" .. self:EntIndex(), self:SequenceDuration(), 1, function()
		if ( !IsValid( self ) ) then return end
		self:DoIdle()
	end )
end

if ( SERVER ) then return end

language.Add( "Undone_mc_torch", "Undone " .. SWEP.PrintName )
language.Add( "Cleaned_mc_torches", "Cleaned " .. SWEP.PrintName .. "es" )
language.Add( "Cleanup_mc_torches", SWEP.PrintName .. "es" )

SWEP.WepSelectIcon = Material( "minecraft/torch_selection.png" )

function SWEP:DrawWeaponSelection( x, y, w, h, a )
	surface.SetDrawColor( 255, 255, 255, a )
	surface.SetMaterial( self.WepSelectIcon )

	local size = math.min( w, h )
	surface.DrawTexturedRect( x + w / 2 - size / 2, y, size, size )
end

function SWEP:DrawWorldModel()
	self:DrawModel()
	self:DrawEffects()
end

function SWEP:PostDrawViewModel()
	self:DrawEffects()
end

SWEP.NextEffect = 0.1
function SWEP:DrawEffects()
	local owner = self:GetOwner()
	if ( IsValid( owner ) and owner:WaterLevel() > 2 ) then return end

	local pos = self:GetPos()
	if ( self:LookupAttachment( "muzzle" ) ) then
		pos = self:GetAttachment( self:LookupAttachment( "muzzle" ) ).Pos
	end

	if ( IsValid( owner ) and !owner:ShouldDrawLocalPlayer() and owner == LocalPlayer() ) then
		local vm = owner:GetViewModel()
		if ( vm:LookupAttachment( "muzzle" ) ) then
			pos = vm:GetAttachment( vm:LookupAttachment( "muzzle" ) ).Pos
		end
	end

	self.SmoothLight = math.Approach( self.SmoothLight, math.random( 256, 512 ), 2.5 )

	local iTorchLight = DynamicLight( self:EntIndex() )
	if ( iTorchLight ) then
		iTorchLight.Pos = pos
		iTorchLight.r = 255
		iTorchLight.g = 128
		iTorchLight.b = 0
		iTorchLight.Brightness = 1
		iTorchLight.Size = self.SmoothLight
		iTorchLight.Decay = 2500
		iTorchLight.DieTime = CurTime() + 0.1
	end

	if ( CurTime() > self.NextEffect ) then
		self.NextEffect = CurTime() + math.Rand( 0.1, 0.5 )
		if ( gMCEmitter ) then
			local particle = gMCEmitter:Add( "minecraft/particle" .. math.random( 1, 4 ), pos )
			if ( particle ) then
				particle:SetDieTime( 0.8 )
				particle:SetStartAlpha( 255 )
				particle:SetEndAlpha( 0 )
				if ( IsValid( owner ) and !owner:ShouldDrawLocalPlayer() and owner == LocalPlayer() ) then
					particle:SetStartSize( 8 )
					particle:SetEndSize( 2 )
				else
					particle:SetStartSize( 4 )
					particle:SetEndSize( 1 )
				end
				particle:SetAirResistance( 256 )
				particle:SetGravity( Vector( 0, 0, 128 ) )
			end
		end
	end
end
