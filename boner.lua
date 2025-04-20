--- @module "Sonson's Boner"
--- @version 1.0.0

local API = require("api")

local Boner = {
    constants = {
        scriptVersion = "1.0.0",
        bone = "Dragonkin bones",
        objects = {
            BANK_CHEST = {
                name = "Bank chest",
                id = 125115,
                type = 0
            }
        },
        ids = {
            POWDER_OF_BURIALS = 52805
        }
    },
    variables = {
        interval = 1,
        attemptThreshold = 5,
        status = "nil",
        timestamps = {
            bank = 0,
            buff = 0,
            bone = 0
        },
        attempts = {
            bank = 0,
            buff = 0,
            bone = 0
        }
    }
}

------------------------------------------
--# CORE METHODS
------------------------------------------

function Boner:getBones()
    if self:isOnCooldown(self.variables.timestamps.bank) then return end
    if self:exceededAttempts(self.variables.attempts.bank) then
        print("- Can't bone no more (NO BONES)")
        API.Write_LoopyLoop(false)
    end

    print("- No bones found in inventory")
    self.variables.status = "Getting bones"
    if Interact:Object(self.constants.objects.BANK_CHEST.name, "Load Last Preset from", 10) then
        print("+ Loading last preset")
        self.variables.attempts.bank = 0
        self.variables.timestamps.bank = API.Get_tick()
    end
end

function Boner:boneBuff()
    if self:isOnCooldown(self.variables.timestamps.buff) then return end
    if self:exceededAttempts(self.variables.attempts.buff) then
        print("- Can't bone no more (NO BUFFS)")
        API.Write_LoopyLoop(false)
    end

    print("- Powder of burials buff not found or expiring")
    self.variables.status = "Applying bone buff"
    if Inventory:DoAction(self.constants.ids.POWDER_OF_BURIALS, 1, API.OFF_ACT_GeneralInterface_route) then
        print("+ Reapplying buff")
        self.variables.attempts.buff = 0
        self.variables.timestamps.buff = API.Get_tick()
    end
end

function Boner:bone()
    if self:isOnCooldown(self.variables.timestamps.bone) then return end
    if self:exceededAttempts(self.variables.attempts.bone) then
        print("- Can't bone no more (NO BONES)")
        API.Write_LoopyLoop(false)
    end

    self.variables.status = "Boning"
    self.variables.attempts.bone = self.variables.attempts.bone + 1
    if API.DoAction_Ability(self.constants.bone, 1, API.OFF_ACT_GeneralInterface_route, false) then
        print("+ Boned")
        self.variables.timestamps.bone = API.Get_tick()
        self.variables.attempts.bone = 0
    end
end

------------------------------------------
--# HELPER METHODS
------------------------------------------

function Boner:isOnCooldown(timestamp)
    return not ((API.Get_tick() - timestamp) >= self.variables.interval)
end

function Boner:exceededAttempts(count)
    return count > self.variables.attemptThreshold
end

function Boner:burialBuffExists()
    local buff = API.Buffbar_GetIDstatus(self.constants.ids.POWDER_OF_BURIALS, false)
    return buff.found and (API.Bbar_ConvToSeconds(buff) > 30)
end

function Boner:hasBone()
    return Inventory:Contains(self.constants.bone)
end

------------------------------------------
--# DATA YUM
------------------------------------------

function Boner:trackBoning()
    local metrics = {
        { string.format("[%s] Sonson's Boner", self.constants.scriptVersion) },
        { "", "" },
        { "Boner information:", API.ScriptRuntimeString() },
        { "- Status:", self.variables.status },
    }
    API.SetDrawTrackedSkills(true)
    API.DrawTable(metrics)
end

------------------------------------------
--# MAIN LOOP
------------------------------------------

while API.Read_LoopyLoop() do
    -- Buff handling
    if not Boner:burialBuffExists() then
        Boner:boneBuff()
    end

    -- Inventory handling
    if not Boner:hasBone() then
        Boner:getBones()
    end

    -- Bone handling
    if Boner:hasBone() then
        Boner:bone()
    end

    -- Data is nice
    Boner:trackBoning()

    -- Other stuff handling
    API.DoRandomEvents(600, 0)
    API.RandomSleep2(100, 100, 200)
end

------------------------------------------
--# FIN
------------------------------------------

return Boner
