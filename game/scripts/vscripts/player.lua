Player = class({
    id = 0,
    hero = nil,
    player = nil,
    score = 0,
    team = 0,
    fow,
    selectionLocked = false,
    selectedHero = nil
})

function Player:SetPlayerID(id)
    self.id = id
end

function Player:SetTeam(i)
    self.team = i

    if PlayerResource:GetCustomTeamAssignment(self.id) == 0 and i then
        PlayerResource:SetCustomTeamAssignment(self.id, i)
    end

    self.fow = CreateUnitByName("npc_fow", Vector(0, 0), false, nil, nil, i)
    self.fow:SetDayTimeVisionRange(8000)
    self.fow:SetNightTimeVisionRange(8000)
end

function Player:Blind(caster, duration)
    self.fow:AddNewModifier(caster, nil, "modifier_blind", { duration = duration })
end

function Player:ReturnVision(caster)
    self.fow:RemoveModifierByNameAndCaster("modifier_blind", caster)
end

function Player:IsConnected()
    return PlayerResource:GetConnectionState(self.id) == DOTA_CONNECTION_STATE_CONNECTED or IsInToolsMode()
end