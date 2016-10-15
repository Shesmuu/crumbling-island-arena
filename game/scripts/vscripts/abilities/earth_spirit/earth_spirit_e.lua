earth_spirit_e = class({})

LinkLuaModifier("modifier_earth_spirit_e", "abilities/earth_spirit/modifier_earth_spirit_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_earth_spirit_e_animation", "abilities/earth_spirit/modifier_earth_spirit_e", LUA_MODIFIER_MOTION_NONE)

function earth_spirit_e:GetBehavior()
    if self:GetCaster():HasModifier("modifier_earth_spirit_stand") then
        return DOTA_ABILITY_BEHAVIOR_POINT
    end

    return bit.bor(DOTA_ABILITY_BEHAVIOR_POINT, DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES)
end

function earth_spirit_e:OnSpellStart()
    Wrappers.DirectionalAbility(self, 600)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local targetRemnant = EarthSpirit:FindNonStandRemnantCursor(self, target)
    local hadStand = false

    if targetRemnant then
        target = targetRemnant:GetPos()
    end

    if hero:HasRemnantStand() then
        hadStand = true
        hero:GetRemnantStand():SetStandingHero(nil)
    end

    ESDash(targetRemnant, hero, target, 900, {
        loopingSound = "Arena.Earth.CastE.Loop",
        modifier = { name = "modifier_earth_spirit_e", ability = self },
        forceFacing = true,
        noFixedDuration = true,
        arrivalFunction = function()
            if targetRemnant and not targetRemnant.destroyed and not targetRemnant.standingHero then
                targetRemnant:SetStandingHero(hero)
                target = targetRemnant:GetPos()
                hero:SetPos(Vector(target.x, target.y, target.z + 150))
                self:EndCooldown()

                Timers:CreateTimer(function()
                    hero:AreaEffect({
                        filter = Filters.Area(hero:GetPos(), 256),
                        onlyHeroes = true,
                        hitAllies = true,
                        action = function(target)
                            if target ~= hero then
                                target:FindClearSpace(target:GetPos(), false)
                            end
                        end
                    })
                end)
            end
        end,
        heightFunction = function(dash, current)
            local d = (dash.from - dash.to):Length2D()
            local x = (dash.from - current):Length2D()
            local y0 = 0
            local y1 = 0

            if hadStand then
                y0 = 150
            end

            if targetRemnant and not targetRemnant.destroyed and not targetRemnant.standingHero then
                y1 = 150
            end

            return ParabolaZ2(y0, y1, 100, d, x)
        end
    })
end


ESDash = ESDash or class({}, nil, Dash)

function ESDash:constructor(targetRemnant, ...)
    getbase(ESDash).constructor(self, ...)

    self.targetRemnant = targetRemnant
end

function ESDash:Update()
    getbase(ESDash).Update(self)

    if self.targetRemnant and not self.targetRemnant.destroyed then
        self.to = self.targetRemnant:GetPos()
    end
end