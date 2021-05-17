local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local Colors = {
	['superadmin'] = 'red',
	['admin'] = 'orange',
	['_dev'] = 'blueviolet',
	['mod'] = 'yellow',
	['user'] = 'deepskyblue'
}

ESX = nil
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

local IsNuiActive = false
local IsDisplaying = nil
local Timer = 0
local Prop = nil

local Id = nil
local IsAdmin = nil
local Counters = nil
local Players = nil
local IsDead = false

local Ped = {
	Active = false,
	Id = 0,
	Exists = false,
	Spectate = nil
}
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(200)

		Ped.Active = not IsPauseMenuActive()
		if Ped.Active then
			Ped.Id = PlayerPedId()
			Ped.Exists = DoesEntityExist(Ped.Id)
		end
	end
end)

Citizen.CreateThread(function()
	while not HasAnimDictLoaded("amb@world_human_clipboard@male@idle_a") do
		RequestAnimDict("amb@world_human_clipboard@male@idle_a")
		Citizen.Wait(0)
	end

	while true do
		Citizen.Wait(0)
        for _, player in ipairs(GetActivePlayers()) do
            N_0x31698aa80e0223f8(player)
        end

		local found = false
		if Ped.Active and Ped.Exists then
			found = true
			if IsControlJustPressed(0, Keys['Z']) then
				IsDisplaying = false
				if IsEntityVisible(Ped.Id) then
					local coords = GetEntityCoords(Ped.Id)

					TriggerServerEvent('esx_rpchat:sendProximityMessage', nil, 45.0, "", { 221, 153, 254 }, "^*Obywatel[" .. GetPlayerServerId(PlayerId()) .. "] przegląda wykaz mieszkańców.", nil)
					if not IsPedInAnyVehicle(Ped.Id, false) and not IsDead and not IsPedFalling(Ped.Id) and not IsPedDiving(Ped.Id) and not IsPedInCover(Ped.Id, false) and not IsPedInParachuteFreeFall(Ped.Id) and GetPedParachuteState(Ped.Id) < 1 then
						TaskPlayAnim(Ped.Id, "amb@world_human_clipboard@male@idle_a", "idle_a", 8.0, -8.0, -1, 1, 0.0, false, false, false)
						IsDisplaying = true

						ESX.Game.SpawnObject('p_cs_clipboard', {
							x = coords.x,
							y = coords.y,
							z = coords.z + 2
						}, function(object)
							AttachEntityToEntity(object, Ped.Id, GetPedBoneIndex(Ped.Id, 36029), 0.1, 0.015, 0.12, 45.0, -130.0, 180.0, true, false, false, false, 0, true)
							Prop = object
						end)						
					end
				end
			end

			if IsDisplaying ~= nil then
				if IsDisplaying == false or IsEntityPlayingAnim(Ped.Id, "amb@world_human_clipboard@male@idle_a", "idle_a", 3) then
					PlayerList()
					local ped = Ped.Id
					if Ped.Spectate then
						ped = GetPlayerPed(Ped.Spectate)
					end

					local pid = PlayerId()
					for _, player in ipairs(GetActivePlayers()) do
						if id ~= player then
							local playerPed = GetPlayerPed(player)
							if IsEntityVisible(playerPed) then
								local coords1 = GetEntityCoords(ped, true)
								local coords2 = GetEntityCoords(playerPed, true)
								if #(coords1 - coords2) < 40.0 then
									DrawText3D(coords2.x, coords2.y, coords2.z + 1.2, GetPlayerServerId(player), (NetworkIsPlayerTalking(player) and {0, 0, 255} or {255, 255, 255}))
                                end
							end
						end  
					end
				end

				if IsControlJustReleased(0, Keys['Z']) and GetLastInputMethod(2) then
					SendNUIMessage({})
					if IsDisplaying == true then
						StopAnimTask(Ped.Id, "amb@world_human_clipboard@male@idle_a", "idle_a", 1.0)
						DeleteObject(Prop)
						Prop = nil
					end

					IsDisplaying = nil
					IsNuiActive = false
				end
			end
		end

		if not found and IsDisplaying ~= nil then
			SendNUIMessage({})
			if IsDisplaying == true and Ped.Exists then
				StopAnimTask(Ped.Id, "amb@world_human_clipboard@male@idle_a", "idle_a", 1.0)
				DeleteObject(Prop)
				Prop = nil
			end

			IsDisplaying = nil
			IsNuiActive = false
		end

		if Ped.Exists and Prop and not IsControlPressed(0, Keys['Z']) then
			DeleteObject(Prop)
			Prop = nil
		end
	end
end)

function PlayerList()
	if IsNuiActive then
		return
	end

	local timer = GetGameTimer()
	if timer - Timer > 1000 then
		Timer, Id, Players, Counters = timer, nil, nil, nil
		TriggerServerEvent('wyspa_scoreboard:players', IsAdmin == nil)
	end

	if Id then
		local nui = {
			data = {},
			duties = 'Obywatele: <span style="color:deepskyblue">' .. Counters['players'] .. '</span> | LSPD: ' .. ((Counters['police'] and Counters['police']) > 0 and '<span style="color:green">Tak</span> (' .. (Counters['police'] < 3 and 'max 2' or 'min 3') .. ')' or '<span style="color:red">Nie</span>') .. " | EMS: " .. ((Counters['ambulance'] and Counters['ambulance'] > 0) and '<span style="color:green">Tak</span> (' .. (Counters['ambulance'] < 4 and 'max 3' or 'min 4') .. ')' or '<span style="color:red">Nie</span>') .. "<br>Mechanik: " .. ((Counters['mechanic'] and Counters['mechanic'] > 0) and '<span style="color:green">Tak</span> ' .. (Counters['mechanic'] > 1 and '(min 2)' or '') or '<span style="color:red">Nie</span>')
		}
		for k, v in pairs(Players) do
			if Id == v.id then
				v.color = {51, 127, 36}
			elseif not IsAdmin then
				v.color = {255, 255, 255}
			end

			local color
			if v.group and Colors[v.group] then
				color = Colors[v.group]
			end

			table.insert(nui.data, '<tr' .. (IsAdmin and ' class="admin"' or '') .. '><td id="playerid">' .. v.id .. '</td><td id="steam" style="color: rgb(' .. v.color[1] .. ", " .. v.color[2] .. ", " .. v.color[3] .. ');">' .. v.identifier .. (IsAdmin and ' <span' .. (color and ' style="color: ' .. color .. '"' or '') .. '>' .. v.name .. '</span>' or '') .. '</td></tr>')
		end

		if IsAdmin then
			nui.admin = true
		end

		SendNUIMessage(nui)
		IsNuiActive = true
	end
end

RegisterNetEvent('wyspa_scoreboard:players')
AddEventHandler('wyspa_scoreboard:players', function(id, players, counters, isAdmin)
	Id = id
	if isAdmin ~= nil then
		IsAdmin = isAdmin
	else
		IsAdmin = nil
	end

	Players = players
	Counters = counters
end)

function DrawText3D(x, y, z, text, color)
    local onScreen, _x, _y = World3dToScreen2d(x,y,z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())

    local scale = (1 / #(vec3(px, py, pz) - vec3(x, y, z))) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov
    
    if onScreen then
        SetTextScale(1.0 * scale, 1.55 * scale)
        SetTextFont(0)
        SetTextColour(color[1], color[2], color[3], 255)
        SetTextDropshadow(0, 0, 5, 0, 255)
        SetTextDropShadow()
        SetTextOutline()
		SetTextCentre(1)

        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end

AddEventHandler('EasyAdmin:spectate', function(ped)
	Ped.Spectate = ped
end)

AddEventHandler('playerSpawned', function()
	IsDead = false
end)

AddEventHandler('esx:onPlayerDeath', function()
	IsDead = true
end)