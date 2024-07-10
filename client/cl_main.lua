local Config = require 'config.config'
local QBCore = exports['qb-core']:GetCoreObject()

local airdropBlip = nil
local radius = nil
local Plane = nil
local Pilot = nil
local planeblip = nil
local effect = nil
local drop = nil

RegisterNetEvent('mad-airdrops:client:startAirdrop',function(coords)
  QBCore.Functions.Notify("Airdrop incoming!", 5000)
  PlaySoundFrontend(-1, 'Mission_Pass_Notify', 'DLC_HEISTS_GENERAL_FRONTEND_SOUNDS', false)
  airdropBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
  SetBlipSprite (airdropBlip, 550)
  SetBlipDisplay(airdropBlip, 4)
  SetBlipScale  (airdropBlip, 0.7)
  SetBlipAsShortRange(airdropBlip, true)
  SetBlipColour(airdropBlip, 1)
  BeginTextCommandSetBlipName("STRING")
  AddTextComponentSubstringPlayerName("Air Drop")
  EndTextCommandSetBlipName(airdropBlip)

  radius = AddBlipForRadius(coords, 120.0)
  SetBlipColour(radius, 1)
  SetBlipAlpha(radius, 80)

  lib.requestNamedPtfxAsset("scr_biolab_heist")
  SetPtfxAssetNextCall("scr_biolab_heist")
  effect = StartParticleFxLoopedAtCoord("scr_heist_biolab_flare", coords, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
  
  spawnAirPlane(coords)
end)


function spawnAirPlane(coords)
  local dropped = false

  lib.requestModel(Config.AirCraft.PlaneModel)
  lib.requestModel(Config.AirCraft.PilotModel)

  Plane = CreateVehicle(GetHashKey(Config.AirCraft.PlaneModel), Config.aircraftSpawnPoint.x, Config.aircraftSpawnPoint.y, Config.aircraftSpawnPoint.z, heading, false, true)
	Pilot = CreatePed(4, GetHashKey(Config.AirCraft.PilotModel), Config.aircraftSpawnPoint.x, Config.aircraftSpawnPoint.y, Config.aircraftSpawnPoint.z, heading, false, true)

  lib.waitFor(function()
		if DoesEntityExist(Plane) and DoesEntityExist(Pilot) then
			return true
		end
	end, "entity does not exist")

  planeblip = AddBlipForEntity(Plane)
  SetBlipSprite(planeblip,307)
	SetBlipRotation(planeblip,GetEntityHeading(Pilot))
  SetPedIntoVehicle(Pilot, Plane, -1)

	ControlLandingGear(Plane, 3)
	SetVehicleEngineOn(Plane, true, true, false)
  SetEntityVelocity(Plane, 0.9 * Config.AirCraft.Speed, 0.9 * Config.AirCraft.Speed, 0.0)

  while DoesEntityExist(Plane) do
    if not NetworkHasControlOfEntity(Plane) then
			NetworkRequestControlOfEntity(Plane)
			Wait(10)
		end

    SetBlipRotation(planeblip, Ceil(GetEntityHeading(Plane)))
    if not dropped then
      TaskPlaneMission(Pilot, Plane, 0, 0, coords.x, coords.y, coords.z + 250, 6, 0, 0, GetEntityHeading(Pilot), 3000.0, 500.0)
    end
		local activeCoords = GetEntityCoords(Plane)
    local dist = #(activeCoords - coords)
    if dist < 300 or dropped then
      Wait(1000)
      TaskPlaneMission(Pilot, Plane, 0, 0, -2194.32, 5120.9, Config.AirCraft.Height, 6, 0, 0, GetEntityHeading(Pilot), 3000.0, 500.0)
      if not dropped then
        spawnCrate(coords)
        dropped = true
        print("dropped")
      end
      if dist > 2000 then 
        DeleteEntity(Plane)
        DeleteEntity(Pilot)
        Plane = nil
        Pilot = nil
        dropped = false
        print("deleted")
        break
      end
    end

    Wait(1000)
  end



end


function spawnCrate(coords)
  Wait(1000)
  print("spawnou prop")
  lib.requestModel('prop_drop_armscrate_01')
  drop = CreateObject('prop_drop_armscrate_01', coords.x, coords.y, coords.z + 200, false, true)

  lib.waitFor(function()
		if DoesEntityExist(drop) then
			return true
		end
	end, "entity does not exist")
  SetObjectPhysicsParams(drop,80000.0, 0.1, 0.0, 0.0, 0.0, 700.0, 0.0, 0.0, 0.0, 0.1, 0.0)
	SetEntityLodDist(drop, 1000)
	ActivatePhysics(drop)
	SetDamping(drop, 2, 0.1) -- no idea but Rockstar uses it
	SetEntityVelocity(drop, 0.0, 0.0, -7000.0)

  exports.ox_target:addLocalEntity(drop, {{
    name = 'airdrop_box',
    icon = 'fa-solid fa-user-secret',
    label = "Loot Supplies",
    distance = 1.5,
    debug = false,
    onSelect = function()
      local state = lib.callback.await('mad-airdrops:server:getLootState', false)
      if not state then
        TriggerServerEvent("mad-airdrops:server:sync:loot")
        if lib.progressBar({
          label = "Looting",
          duration = Config.progressbarDuration,
          position = 'bottom',
          canCancel = false,
          disable = {
              move = true,
              combat = true,
          },
          anim = {
              dict = 'missexile3',
              clip = 'ex03_dingy_search_case_base_michael',
              flag = 1,
              blendIn = 1.0
          },
        }) 
        then
          TriggerServerEvent('mad-airdrops:server:getLoot')
        end

      else
        QBCore.Functions.Notify("This was already looted or beeing looted", "error")
      end
    end
  }})
end


RegisterNetEvent('mad-airdrops:client:clearStuff',function()
  StopParticleFxLooped(effect, 0)
  DeleteEntity(drop)
  DeleteEntity(Pilot)
  DeleteEntity(Plane)
  RemoveBlip(airdropBlip)
  RemoveBlip(radius)
  exports.ox_target:removeLocalEntity(drop)
end)

AddEventHandler('onResourceStop', function(resourceName)
  if (GetCurrentResourceName() ~= resourceName) then
    return
  end
  StopParticleFxLooped(effect, 0)
  DeleteEntity(drop)
  DeleteEntity(Pilot)
  DeleteEntity(Plane)
  RemoveBlip(airdropBlip)
  RemoveBlip(radius)
  exports.ox_target:removeLocalEntity(drop)
end)