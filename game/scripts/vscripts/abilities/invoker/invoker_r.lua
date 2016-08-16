invoker_r = class({})

function invoker_r:OnSpellStart()
    Wrappers.DirectionalAbility(self)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    hero:EmitSound("Arena.Invoker.CastR", target)

    ArcProjectile(self.round, {
        owner = hero,
        from = target + Vector(0, 0, 3000) - self:GetDirection() * 2000,
        to = target,
        speed = 2300,
        arc = 200,
        radius = 96,
        graphics = "particles/invoker_r/invoker_r.vpcf",
        hitFunction = function(projectile, hit)
            local particle = ParticleManager:CreateParticle("particles/econ/items/clockwerk/clockwerk_paraflare/clockwerk_para_rocket_flare_explosion.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
            ParticleManager:SetParticleControl(particle, 3, target)
            ParticleManager:ReleaseParticleIndex(particle)

            Spells:GroundDamage(target, 400)
            Spells:GroundDamage(target, 400)
            Spells:GroundDamage(target, 400)
            Spells:GroundDamage(target, 400)

            ScreenShake(target, 5, 150, 0.5, 4000, 0, true)

            projectile:EmitSound("Arena.Invoker.HitR")
        end,
        loopingSound = "Arena.Invoker.LoopR"
    }):Activate()
end

function invoker_r:GetCastAnimation()
    return ACT_DOTA_CAST_CHAOS_METEOR
end
