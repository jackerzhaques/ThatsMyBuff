_, Core = ...
Core.PallyBuffs = {}
local PallyBuffs = Core.PallyBuffs
PallyBuffs.PlayerTable = {}
local PlayerTable = PallyBuffs.PlayerTable
------------------------
-- Paladin Specific Buffs
------------------------
BlessingOfKingsBuff = {0}
BlessingOfSanctuaryBuff = {0}

JudgementLightBuff = {0}
JudgementWisdomBuff = {0}
JudgementJusticeBuff = {0}

AuraRetributionBuff = {0}
AuraConcentrationBuff = {0}
AuraCrusaderBuff = {0}

------------------------
-- Paladin Buff Tables
------------------------
BlessingNone = {name="No Blessing", buff=nil, spellID=nil, icon=nil, req=nil, slot=nil}
BlessingKings = {name="Blessing of Kings", buff=BlessingOfKingsBuff, spellID=20217, icon=nil, req=nil, slot=nil}
BlessingMight = {name="Blessing of Might", buff=BlessingOfKingsBuff, spellID=56520, icon=nil, req=nil, slot=nil}
BlessingWisdom = {name="Blessing of Wisdom", buff=ManaPer5, spellID=56521, icon=nil, req=nil, slot=nil}
BlessingSanctuary = {name="Blessing of Sanctuary", buff=BlessingOfSanctuaryBuff, spellID=20911, icon=nil, req=nil, slot=nil}
BlessingTableAll = {BlessingNone, BlessingKings, BlessingMight, BlessingWisdom, BlessingSanctuary}

JudgementOfLight = {name="Judgement of Light", buff=JudgementLightBuff, spellID=20271, icon=nil, req=nil, slot=nil}
JudgementOfWisdom = {name="Judgement of Wisdom", buff=JudgementWisdomBuff, spellID=53408, icon=nil, req=nil, slot=nil}
JudgementOfJustice = {name="Judgement of Justice", buff=JudgementJusticeBuff, spellID=53407, icon=nil, req=nil, slot=nil}
JudgementTableAll = {JudgementOfLight, JudgementOfWisdom, JudgementOfJustice}

AuraDevotion = {name="Devotion Aura", buff=ArmorFlat, spellID=48941, icon=nil, req=nil, slot=nil}
AuraRetribution = {name="Retribution Aura", buff=AuraRetributionBuff, spellID=10301, icon=nil, req=nil, slot=nil}
AuraConcentration = {name="Concentration Aura", buff=AuraConcentrationBuff, spellID=19746, icon=nil, req=nil, slot=nil}
AuraShadowResistance = {name="Shadow Resistance Aura", buff=ShadowResistance, spellID=48943, icon=nil, req=nil, slot=nil}
AuraFrostResistance = {name="Frost Resistance Aura", buff=FrostResistance, spellID=19898, icon=nil, req=nil, slot=nil}
AuraFireResistance = {name="Fire Resistance Aura", buff=FireResistance, spellID=27153, icon=nil, req=nil, slot=nil}
AuraCrusader = {name="Crusader Aura", buff=AuraCrusaderBuff, spellID=32223, icon=nil, req=nil, slot=nil}
AuraTableAll = {AuraDevotion, AuraRetribution, AuraConcentration, AuraShadowResistance, AuraFrostResistance, AuraFireResistance, AuraCrusader}

function PallyBuffs:FetchIcons()
    for i = 1,#BlessingTableAll do
        local blessing = BlessingTableAll[i]
        local spellid = blessing["spellID"]
        local icon = nil
        if spellid == nil then
            -- TODO: Find a better icon
            icon = "BlizzardInterfaceArt\\Interface\\ContainerFrame\\UI-Icon-QuestBorder.blp"
        else
            _, _, icon, _, _, _, _, _ = GetSpellInfo(spellid)
        end
        blessing["icon"] = icon
    end

    for i = 1,#JudgementTableAll do
        local judgement = JudgementTableAll[i]
        local spellid = judgement["spellID"]
        local icon = nil
        if spellid == nil then
            -- TODO: Find a better icon
            icon = "BlizzardInterfaceArt\\Interface\\ContainerFrame\\UI-Icon-QuestBorder.blp"
        else
            _, _, icon, _, _, _, _, _ = GetSpellInfo(spellid)
        end
        judgement["icon"] = icon
    end
    
    for i = 1,#AuraTableAll do
        local aura = AuraTableAll[i]
        local spellid = aura["spellID"]
        local icon = nil
        if spellid == nil then
            -- TODO: Find a better icon
            icon = "BlizzardInterfaceArt\\Interface\\ContainerFrame\\UI-Icon-QuestBorder.blp"
        else
            _, _, icon, _, _, _, _, _ = GetSpellInfo(spellid)
        end
        aura["icon"] = icon
    end

    local castFrame = CreateFrame("Button", "testname", UIParent, "SecureActionButtonTemplate")
    castFrame:SetAttribute("type", "spell")
    castFrame:SetAttribute("spell","Devotion Aura")
    -- castFrame:SetAttribute("unit", "player")
    castFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 400, 400)
    castFrame:SetSize(200,30)
    castFrame:Show();
    -- castFrame:Button_OnClick()
    print(castFrame.OnClick)
    PallyBuffs.castFrame = castFrame

    PlayerTable.aura = AuraDevotion
    PlayerTable.judgement = JudgementOfLight
    PlayerTable.blessings = {}
end

function PallyBuffs:GetAuraByName(auraName)
    local aura = nil

    for i = 1,#AuraTableAll do
        if AuraTableAll[i].name == auraName then
            aura = AuraTableAll[i]
            break
        end
    end

    return aura
end

function PallyBuffs:GetJudgementByName(judgementName)
    local judgement = nil

    for i = 1,#JudgementTableAll do
        if JudgementTableAll[i].name == judgementName then
            judgement = JudgementTableAll[i]
            break
        end
    end

    return judgement
end

function PallyBuffs:GetBlessingByName(blessingName)
    local blessing = nil

    for i = 1,#BlessingTableAll do
        if BlessingTableAll[i].name == blessingName then
            blessing = BlessingTableAll[i]
            break
        end
    end

    return blessing
end

function PallyBuffs:SetPlayerAuraByName(auraName)
    -- No longer being done, casting via api is protected and cannot be done
    -- Instead a user must press a button to cast
end