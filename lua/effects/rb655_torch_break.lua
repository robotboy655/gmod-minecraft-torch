
EFFECT.Colors = {
	Color( 255, 216, 0 ),
	Color( 102, 73, 45 ),
	Color( 102, 73, 45 ),
	Color( 102, 73, 45 ),
	Color( 102, 73, 45 ),
	Color( 152, 120, 73 ),
	Color( 152, 120, 73 ),
	Color( 152, 120, 73 ),
	Color( 152, 120, 73 )
}

local teh_effect = ParticleEmitter( vector_origin )

function EFFECT:Init( data )

	self.origin = data:GetOrigin()
	self.up = data:GetNormal()

	if ( !teh_effect ) then return end

	for i = 2, 20 do
		local particle = teh_effect:Add( "minecraft/torch_break", self.origin + self.up * i )
		if ( particle ) then
			particle:SetVelocity( Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), math.Rand( -1, 1 ) ) * 64 )
			particle:SetDieTime( 4 )
			particle:SetGravity( Vector( 0, 0, -1024 ) )

			local c = self.Colors[ math.random( 1, #self.Colors ) ]
			particle:SetColor( c.r, c.g, c.b )
			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( 1.5 )
			particle:SetEndSize( 1.5 )
			particle:SetCollide( true )
			particle:SetBounce( 0.5 )
		end
	end

	--teh_effect:Finish()

end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
