local Config = require 'config.config'
local QBCore = exports['qb-core']:GetCoreObject()

local waitTime = Config.intervalBetweenAirdrops * 60000
local loc = nil
local looted = false

CreateThread(function()
  while true do
      Wait(waitTime)
      looted = false
      TriggerClientEvent("mad-airdrops:client:clearStuff", -1)
      local randomloc = math.random(1, #Config.Locs)
      loc = Config.Locs[randomloc]  
      TriggerClientEvent("mad-airdrops:client:startAirdrop", -1, loc)
  end
end)


RegisterNetEvent("mad-airdrops:server:sync:loot", function()
  looted = true
end)

RegisterNetEvent("mad-airdrops:server:getLoot", function()
  local src = source
  if not looted then return end
  if #(loc - GetEntityCoords(GetPlayerPed(src))) > 10 then DropPlayer(src, "What are u doing lil bro?") return end
  
  local Player = QBCore.Functions.GetPlayer(src)
  for i = 1, Config.amountOfItems, 1 do
    local randItem = Config.LootTable[math.random(1, #Config.LootTable)]
    Player.Functions.AddItem(randItem, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[randItem], 'add')
    Wait(500)
  end
  Wait(Config.timetodeletebox * 60000)
  TriggerClientEvent("mad-airdrops:client:clearStuff", -1)
end)


lib.callback.register('mad-airdrops:server:getLootState', function()
  return looted
end)


--test command

RegisterCommand("test", function(source, args, rawCommand)
  looted = false
  TriggerClientEvent("mad-airdrops:client:clearStuff", -1)
  local randomloc = math.random(1, #Config.Locs)
  loc = Config.Locs[randomloc]    
  
  TriggerClientEvent("mad-airdrops:client:startAirdrop", -1, loc)
end)
