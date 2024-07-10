return {
   intervalBetweenAirdrops = 20, --time in minutes

   progressbarDuration = 10000, -- miliseconds

    --locations here can airdrops drop
    Locs = {
        vec3(266.44, 2043.73, 122.75),
        vec3(191.6, 2240.89, 88.97),
        vec3(-188.84, 2244.0, 118.63),
    },

    AirCraft = {
        PilotModel = "s_m_m_pilot_01", -- Pilot model
        PlaneModel = "titan", -- Plane model
        Height = 450.0, -- Plane Height
        Speed = 92.0, -- Plane Speed
    },

    --location here aircraft can spawn
    aircraftSpawnPoint = vec3(3562.5, 1356.43, 450.0),

    --items that you can get in airdrop
    LootTable= {

        "weapon_combatpistol",
        "weapon_assaultrifle",
        "weapon_smg",
        "weapon_heavypistol",
        "weapon_carbinerifle",
        "weapon_machinepistol",
        "weapon_pistol",
        
    },

    amountOfItems = math.random(4,5), --amount of items you can get in airdrop

    timetodeletebox = 0.2, --time to delete the airdrop after looted in minutes

    falldownSpeed = 0.1, -- you can set it like 0.01 to get very slow you 0.2 to get faster
}