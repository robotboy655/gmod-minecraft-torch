
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Minecraft Torch"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Category = "Robotboy655's Entities"
ENT.Spawnable = true
ENT.Editable = true

local gMCEmitter

if ( CLIENT ) then
	language.Add( "ent_minecraft_torch", ENT.PrintName )

	gMCEmitter = ParticleEmitter( vector_origin )
end

function ENT:SetupDataTables()

	self:NetworkVar( "Bool", 0, "Working", { Edit = { type = "Boolean", category = "Minecraft Torch", order = 10 } } )

	if ( SERVER ) then self:SetWorking( true ) end

end

function ENT:Initialize()
	if ( SERVER ) then
		self:SetModel( "models/minecraft/torch.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )

		local heat = ents.Create( "env_firesource" )

		local pos = self:GetPos()
		if ( self:LookupAttachment( "muzzle" ) > 0 ) then
			pos = self:GetAttachment( self:LookupAttachment( "muzzle" ) ).Pos
		end
		heat:SetPos( pos )

		heat:SetParent( self )
		heat:SetKeyValue( "fireradius", 32 )
		heat:SetKeyValue( "firedamage", 48 )
		heat:Spawn()
		heat:Input( "Enable" )

		self.Heat = heat
		return
	end

	self.SmoothLight = math.random( 200, 300 )

end

ENT.NextEffect = 0.1
function ENT:Think()
	local pos = self:GetPos()
	if ( self:LookupAttachment( "muzzle" ) > 0 ) then
		pos = self:GetAttachment( self:LookupAttachment( "muzzle" ) ).Pos
	end

	if ( SERVER ) then
		if ( self:WaterLevel() > 1 ) then self:SetWorking( false ) end

		if ( self:IsOnFire() ) then
			if ( self:WaterLevel() < 2 ) then self:SetWorking( true ) end
			self:Extinguish()
		end
	end

	if ( CLIENT && self:GetWorking() ) then
		self.SmoothLight = math.Approach( self.SmoothLight, math.random( 128, 384 ), 2.5 )

		local iTorchLight = DynamicLight( self:EntIndex() )
		if ( iTorchLight ) then
			iTorchLight.Pos = pos + self:GetUp() * 2
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
					particle:SetStartSize( 6 )
					particle:SetEndSize( 2 )
					particle:SetAirResistance( 256 )
					particle:SetGravity( Vector( 0, 0, 128 ) )
				end
			end
		end
	end
end

function ENT:OnTakeDamage( dmg )
	self:TakePhysicsDamage( dmg )
end

function ENT:OnRemove()
	if ( CLIENT ) then return end

	if ( IsValid( self.Heat ) ) then self.Heat:Remove() end

	local effectdata = EffectData()
	effectdata:SetOrigin( self:GetPos() )
	effectdata:SetNormal( self:GetUp() )
	util.Effect( "rb655_torch_break", effectdata )

	self:EmitSound( "minecraft/wood" .. math.random( 1, 4 ) .. ".wav" )
end

function ENT:PhysicsCollide( data, physobj )
	local ent = data.HitEntity
	if ( ent:IsOnFire() || ent:IsPlayer() || ent == self || math.random( 0, 100 ) < 65 || !self:GetWorking() ) then return end
	ent:Fire( "IgniteLifetime", math.random( 10, 30 ) )
end

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit || #ents.FindByClass( "ent_minecraft_torch" ) > 31 ) then return end

	local ent = ents.Create( self.ClassName )
	ent:SetPos( tr.HitPos + tr.HitNormal * 2 )
	ent:Spawn()
	ent:Activate()

	local phys = ent:GetPhysicsObject()
	if ( IsValid( phys ) ) then phys:Wake() end

	return ent
end
