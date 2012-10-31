-- The advanced base core, only use if you are a MORE ADVANCED PERSON! Thank you, Dr. Matt.
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
/*---------------------------------------------------------
	START EDITABLE AREA
---------------------------------------------------------*/
ENT.PrintName		= "Adv Base Core" -- The name the Core will come up as in the Spawnmenu
ENT.Author			= "Matt J" -- Self Explanatory, The author of the addon, AKA Your name.
ENT.Contact			= "Facepunch (MattJeanes)" -- Your contact, Perhaps an email address or a Steam username
ENT.Purpose			= "This is what I do!" -- The purpose of the entity
ENT.Instructions	= "Instruct me!" -- The instructions of the entity, Perhaps "Insert 1 chocolate cookie to activate."
ENT.Category		= "Portal 2 Cores"
ENT.Animation		= "sphere_idle_happy" -- Set's the animation of the core, Look in Portal 2 Authoring Tools for more info.
ENT.Dir				= "base" -- The name of your sub-folder, must be 4 characters.
ENT.ModelPath		= "models/cores/base/core.mdl"
ENT.MusicCore		= false
ENT.AutomaticFrameAdvance = true
if ( CLIENT ) then

	function ENT:Draw()
		self.Entity:DrawModel()
	end
	
elseif ( SERVER ) then

	AddCSLuaFile()
	
	
	
	// This is the spawn function. It's called when a client calls the entity to be spawned.
	// If you want to make your SENT spawnable you need one of these functions to properly create the entity
	//
	// ply is the name of the player that is spawning it
	// tr is the trace from the player's eyes 
	//
	function ENT:SpawnFunction( ply, tr )

		if ( !tr.Hit ) then return end
		
		local SpawnPos = tr.HitPos + tr.HitNormal * 16
		
		local ent = ents.Create( ClassName )
		ent:SetPos( SpawnPos )
		ent:Spawn()
		ent:Activate()
		
		return ent
		
	end

	/*---------------------------------------------------------
	   Name: Initialize
	---------------------------------------------------------*/
	function ENT:Initialize()
	
		self.SayTimer = CurTime()
		self.Entity:SetModel( self.ModelPath )
		//self.Entity:SetModel( "models/cores/basecore.mdl" )
		local anim = self.Entity:LookupSequence(self.Animation)
		self.Entity:ResetSequence(anim)
		self.Entity:PhysicsInit( SOLID_VPHYSICS )
		self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
		self.Entity:SetSolid( SOLID_VPHYSICS )
		if (self.AnimSpeed) then
			self.Entity:SetPlaybackRate(self.AnimSpeed)
		end
		if (self.Skin) then
			self.Entity:SetSkin(self.Skin)
		end

		local phys = self.Entity:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
		end
		
		self.Sounds = {}
		self.SoundLengths = {}
		self.Sounds1 = file.Find( "sound/cores/".. self.Dir .. "/*", "GAME" )
		
		if #self.Sounds1 > 1 and self.MusicCore then
			print("ERROR: Too many sounds for a Music-based Core! - Only 1 sound please!")
		elseif #self.Sounds1 == 1 and self.MusicCore then
			self.MusicSound = "cores/".. self.Dir .. "/".. self.Sounds1[1]
			util.PrecacheSound(self.MusicSound)
			self.Music = CreateSound(self.Entity, self.MusicSound )
			self.Music:Play()
		end

		if not self.MusicCore then
			for k,v in ipairs(self.Sounds1) do
				table.insert(self.Sounds, "cores/".. self.Dir .. "/".. v)
			end
			
			for k,v in pairs(self.Sounds) do 
				util.PrecacheSound(v) -- Precaches all the ENT.Sounds1 for use.
				table.insert(self.SoundLengths, SoundDuration(v)) -- New! This automatically get's the sound lengths to eliminate a lot of time and effort!
			end
		end
		
		local f = file.Open( "sound/cores/"..self.Dir.."/special/dmg.wav", "r", "GAME" )
		if ( f ) then self.DmgSound = true f:Close() end
		
		local f = file.Open( "sound/cores/"..self.Dir.."/special/use.wav", "r", "GAME" )
		if ( f ) then self.UseSound = true f:Close() end
		
		
		local f = file.Open( "sound/cores/"..self.Dir.."/special/undo.wav", "r", "GAME" )
		if ( f ) then self.UndoSound = true f:Close() end
		
		local f = nil
		
		if #self.Sounds1 == 0 then
			print("WARNING: No sounds are included with the core, expect errors!")
		end
		
		self.CustomInitialize(self)
		
	end
	
	function ENT.CustomInitialize()
		// This function is empty, and may be overridden by the core itself.
	end
	/*---------------------------------------------------------
	   Name: PhysicsCollide
	---------------------------------------------------------*/
	function ENT:PhysicsCollide( data, physobj )
		//Nothing here
	end

	/*---------------------------------------------------------
	   Name: OnTakeDamage
	---------------------------------------------------------*/
	function ENT:OnTakeDamage( dmginfo )
		local snd = "cores/"..self.Dir.."/special/dmg.wav"
		if self.DmgSound then
			self.Entity:EmitSound(snd)
		end
	end


	/*---------------------------------------------------------
	   Name: Use
	---------------------------------------------------------*/
	function ENT:Use( activator, caller, Player )
		local snd = "cores/"..self.Dir.."/special/use.wav"
		if self.UseSound then
			self.Entity:EmitSound(snd)
		end
	end

	/*---------------------------------------------------------
	   Name: OnRemove
	---------------------------------------------------------*/
	function ENT:OnRemove( )
		local snd = "cores/"..self.Dir.."/special/undo.wav"
		if self.UndoSound then
			self.Entity:EmitSound(snd)
		end
		if self.MusicCore then
			self.Music:Stop()
		end
	end

	/*---------------------------------------------------------
	   Name: Think
	---------------------------------------------------------*/

	local LastRandom = 0
	
	function ENT:Think()
		if not self.Playing and not self.MusicCore then
			local r = math.Round(math.random(1,#self.Sounds))
			if r == self.LastRandom then
				r = math.Round(math.random(1,#self.Sounds))
			end
			self.LastRandom = r
			self.Entity:EmitSound(self.Sounds[r])
			self.Playing = true
			timer.Simple(self.SoundLengths[r] + self.Delay, function()
				self.Playing = false
			end)
		end
		self:NextThink( CurTime() + 0.1 )
		return true
	end
end