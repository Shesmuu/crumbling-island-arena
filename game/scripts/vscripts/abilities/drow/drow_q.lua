drow_q = class({})
LinkLuaModifier("modifier_drow_q", "abilities/drow/modifier_drow_q", LUA_MODIFIER_MOTION_NONE)

function drow_q:OnChannelThink(interval)
    self.channelingTime = (self.channelingTime or 0) + interval

    local shots = self.shots or 0
    local hero = self:GetCaster():GetParentEntity()

    if self.channelingTime >= shots * 0.1 then
        local target = self:GetCursorPosition()
        hero:Animate(ACT_DOTA_ATTACK, 8.0)

        local dir = target - hero:GetPos()
        local offset = Vector(dir.y, -dir.x):Normalized() * RandomFloat(-80, 80)

        self.projectileCounter = (self.projectileCounter or 0) + 1
        self.damaged = self.damaged or {}

        DistanceCappedProjectile(hero.round, {
            ability = self,
            owner = hero,
            from = hero:GetPos() + Vector(0, 0, 96) + offset,
            to = target + Vector(0, 0, 96) + offset * 0.5,
            speed = 3000,
            distance = 1200,
            graphics = "particles/drow_a/drow_a.vpcf",
            damage = self:GetDamage(),
            hitSound = "Arena.Drow.HitA",
            hitFunction = function(_, victim)
                local modifier = victim:FindModifier("modifier_drow_q")

                if not modifier then
                    modifier = victim:AddNewModifier(hero, self, "modifier_drow_q", { duration = 2 })

                    if modifier then
                        modifier:SetStackCount(1)
                    end
                else
                    modifier:IncrementStackCount()
                    modifier:ForceRefresh()
                end

                self.damaged[victim] = (self.damaged[victim] or 0) + 1

                if self.damaged[victim] <= 3 then
                    victim:Damage(hero, self:GetDamage(), true)
                end
            end,
            knockback = { force = 20, decrease = 5.5 },
            destroyFunction = function()
                self.projectileCounter = (self.projectileCounter or 0) - 1

                if self.projectileCounter == 0 then
                    self.damaged = nil
                end
            end
        }):Activate()

        hero:EmitSound("Arena.Drow.CastA")

        --FX("particles/econ/items/windrunner/windrunner_ti6/windrunner_spell_powershot_channel_ti6_shock_ring.vpcf", PATTACH_ABSORIGIN, hero, {
           -- cp1 = { ent = hero, attach = PATTACH_ABSORIGIN },
            --release = true
        --})

        ScreenShake(hero:GetPos(), 5, 150, 0.15, 3000, 0, true)

        self.shots = shots + 1
    end

    if interval == 0 then
        --hero:EmitSound("Arena.WR.CastR.Voice")
        --hero:EmitSound("Arena.WR.CastR")
        --hero:AddNewModifier(hero, self, "modifier_wr_r", {})
    end
end

function drow_q:OnChannelFinish()
    self.channelingTime = 0
    self.soundPlayed = false
    self.shots = 0
    self.hitGroup = nil

    local hero = self:GetCaster():GetParentEntity()
    hero:StopSound("Arena.WR.CastR")
    --hero:RemoveModifier("modifier_wr_r")
end

function drow_q:GetChannelTime()
    return 0.5
end

if IsServer() then
    Wrappers.GuidedAbility(drow_q, true)
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(drow_q)