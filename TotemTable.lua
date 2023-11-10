_, Core = ...
Core.Totems = {}
local Totems = Core.Totems

-- print("Totem table1")
------------------------
-- Totem Specific Buffs
------------------------
-- EarthbindTotemBuff = {0} -- Not a buff
-- TremorTotemBuff = {0} -- Not a buff
-- StoneskinTotemBuff = {0} -- Not a buff
-- StoneclawTotemBuff = {0} -- Not a buff
-- MagmaTotemBuff = {0} -- Not a buff
-- CleansingTotemBuff = {0} -- Not a buff
-- HealingStreamTotemBuff = {0} -- Not a buff
StoneskinTotemBuff = {0}
WrathOfAirTotemBuff = {0}

------------------------
-- Totem Slot IDs
------------------------
TotemSlotElementsFire       = 133
TotemSlotElementsEarth      = 134
TotemSlotElementsWater      = 135
TotemSlotElementsAir        = 136
TotemSlotAncestorsFire      = 137
TotemSlotAncestorsEarth     = 138
TotemSlotAncestorsWater     = 139
TotemSlotAncestorsAir       = 140
TotemSlotSpiritsFire        = 141
TotemSlotSpiritsEarth       = 142
TotemSlotSpiritsWater       = 143
TotemSlotSpiritsAir         = 144

------------------------
-- Totem Tables
------------------------
TotemNone = {name="No Totem", buff=nil, spellID=nil, icon=nil, req=nil, slot=nil}
TotemSearing = {name = "Searing Totem", buff=nil, spellID=58704, icon=nil, req=nil, slot=TotemSlotElementsFire}
TotemFrostResist = {name = "Frost Resistance Totem", buff=FrostResistance, spellID=58745, icon=nil, req=nil, slot=TotemSlotElementsFire}
TotemMagma = {name = "Magma Totem", buff=nil, spellID=58734, icon=nil, req=nil, slot=TotemSlotElementsFire}
TotemFlametongue = {name = "Flametongue Totem", buff=Spellpower, spellID=58656, icon=nil, req=nil, slot=TotemSlotElementsFire}
TotemWrath = {name = "Totem of Wrath", buff=Spellpower, spellID=30706, icon=nil, req=Spec_Shaman_Elemental, slot=TotemSlotElementsFire}
TotemTableFire = {TotemSearing,TotemFrostResist,TotemMagma,TotemFlametongue,TotemWrath}

TotemStoneskin = {name = "Stoneskin Totem", buff=StoneskinTotemBuff, spellID=58753, icon=nil, req=nil, slot=TotemSlotElementsEarth}
TotemEarthbind = {name = "Earthbind Totem", buff=nil, spellID=2484, icon=nil, req=nil, slot=TotemSlotElementsEarth}
TotemStrengthOfEarth = {name = "Strength of Earth Totem", buff=StrengthAndAgility, spellID=58643, icon=nil, req=nil, slot=TotemSlotElementsEarth}
TotemTremor = {name = "Tremor Totem", buff=nil, spellID=8143, icon=nil, req=nil, slot=TotemSlotElementsEarth}
TotemTableEarth = {TotemStoneskin, TotemEarthbind, TotemStrengthOfEarth, TotemTremor}

TotemHealingStream = {name = "Healing Stream Totem", buff=nil, spellID=58757, icon=nil, req=nil, slot=TotemSlotElementsWater}
TotemManaSpring = {name = "Mana Spring Totem", buff=ManaPer5, spellID=58774, icon=nil, req=nil, slot=TotemSlotElementsWater}
TotemFireResist = {name = "Fire Resistance Totem", buff=FireResistance, spellID=58739, icon=nil, req=nil, slot=TotemSlotElementsWater}
TotemCleansing = {name = "Cleansing Totem", buff=nil, spellID=8170, icon=nil, req=nil, slot=TotemSlotElementsWater}
TotemManaTide = {name = "Mana Tide Totem", buff=nil, spellID=16190, icon=nil, req=Spec_Shaman_Restoration, slot=TotemSlotElementsWater}
TotemTableWater = {TotemHealingStream, TotemManaSpring, TotemFireResist, TotemCleansing, TotemManaTide}

TotemGrounding = {name = "Grounding Totem", buff=nil, spellID=8177, icon=nil, req=nil, slot=TotemSlotElementsAir}
TotemNatureResistance = {name = "Nature Resistance Totem", buff=NatureResistance, spellID=58749, icon=nil, req=nil, slot=TotemSlotElementsAir}
TotemWindfury = {name = "Windfury Totem", buff=MeleeHaste, spellID=8512, icon=nil, req=nil, slot=TotemSlotElementsAir}
TotemWrathOfAir = {name = "Wrath of Air Totem", buff=WrathOfAirTotemBuff, spellID=3738, icon=nil, req=nil, slot=TotemSlotElementsAir}
TotemTableAir = {TotemGrounding, TotemNatureResistance, TotemWindfury, TotemWrathOfAir}

TotemTableAll = {TotemTableFire, TotemTableEarth, TotemTableWater, TotemTableAir}

function Totems:TotemFetchIcons()
    for i = 1,#TotemTableAll do
        local totemGroup = TotemTableAll[i]
        for totemIdx = 1,#totemGroup do
            local totem = totemGroup[totemIdx]
            local totemid = totem["spellID"]
            local _, _, icon, _, _, _, _, _ = GetSpellInfo(totemid)
            TotemTableAll[i][totemIdx]["icon"] = icon
        end
    end
end

function Totems:SetPlayerTotemByName(totemSlot, totemName)
    local totemtable = nil
    if totemSlot == TotemSlotElementsEarth then
        totemtable = TotemTableEarth
    elseif totemSlot == TotemSlotElementsFire then
        totemtable = TotemTableFire
    elseif totemSlot == TotemSlotElementsWater then
        totemtable = TotemTableWater
    elseif totemSlot == TotemSlotElementsAir then
        totemtable = TotemTableAir
    end

    local totemid = nil
    if totemtable then
        for i = 1,#totemtable do
            local totem = totemtable[i]
            if totem.name == totemName then
                totemid = totem.spellID
                break
            end
        end
    end

    if totemid then
        SetMultiCastSpell(totemSlot, totemid)
    end
end
------------------------
-- Spell IDs
------------------------
-- nil no totem
-- fire
-- searingtotem 58704
-- 58745 frost resist
-- 58734 magma 
-- 58656 flametongue
-- 2894 fire elemental
-- 30706 totem of wrath
-- earth
-- 58753 stoneskin
-- 2484 earthbind
-- 58582 stoneclaw
-- 58643 strength of earth
-- 8143 tremor
-- 2062 stone elemental
-- water
-- 58757 healing stream
-- 58774 mana spring
-- 58739 fire resist
-- 8170 cleansing
-- 16190 mana tide
-- air
-- 8177 grounding
-- 58749 nature resist
-- 8512 windfury
-- 6495 sentry
-- 3738 wrath of air


------------------------
-- Spell IDs
------------------------
-- nil no totem
-- fire
-- searingtotem 58704
-- 58745 frost resist
-- 58734 magma 
-- 58656 flametongue
-- 2894 fire elemental
-- earth
-- 58753 stoneskin
-- 2484 earthbind
-- 58582 stoneclaw
-- 58643 strength of earth
-- 8143 tremor
-- 2062 stone elemental
-- water
-- 58757 healing stream
-- 58774 mana spring
-- 58739 fire resist
-- 8170 cleansing
-- 16190 mana spring
-- air
-- 8177 grounding
-- 58749 nature resist
-- 8512 windfury
-- 6495 sentry
-- 3738 wrath of air
-- print("Totem table2")