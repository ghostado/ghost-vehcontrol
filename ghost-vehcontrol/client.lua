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

local estadoJanela1 = true
local estadoJanela2 = true
local estadoJanela3 = true
local estadoJanela4 = true

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        -- jogador
        local jogador = GetPlayerPed(-1)
        -- obter o veiculo onde se encontra o jogador
		local veiculo = GetVehiclePedIsIn(jogador, false)

        if IsPedInAnyVehicle(jogador, false) and not IsEntityDead(jogador) then
            Citizen.Wait(100)

            if IsControlPressed(2, Keys['F']) then
                -- deixar motor ligado se o 'F' for pressionado por mais de 2 segundos
                SetVehicleEngineOn(veiculo, true, true, false)
                -- jogador sai do carro
                TaskLeaveVehicle(jogador, veiculo, 0)
                
            elseif IsControlJustPressed(0, Keys['F']) and not IsEntityDead(jogador) then
                -- desliga o motor do veiculo
                SetVehicleEngineOn(veiculo, false, true, false)
                -- jogador sai do carro
                TaskLeaveVehicle(jogador, veiculo, 0)
            end
        end

        if IsPedInAnyVehicle(GetPlayerPed(-1), false)then
			if GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0) == GetPlayerPed(-1) then
				if GetIsTaskActive(GetPlayerPed(-1), 165) then
					SetPedIntoVehicle(GetPlayerPed(-1), GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
				end
			end
		end
    end
end)

-- motor ["/motor"]
function ControlarMotor()
    -- jogador
    local jogador = GetPlayerPed(-1)
    -- veiculo
    local veiculo = GetVehiclePedIsIn(jogador, false)

    if IsPedInAnyVehicle(jogador, false) then
        if GetPedInVehicleSeat(veiculo, -1) then
            SetVehicleEngineOn(veiculo, (not GetIsVehicleEngineRunning(veiculo)), false, true)
        end
    end
end

-- luzes interiores ["/luzesinterior"]
function ControlarLuzesInteriores()
    -- jogador
    local jogador = GetPlayerPed(-1)
    -- veiculo
    local veiculo = GetVehiclePedIsIn(jogador, false)

    if IsPedInAnyVehicle(jogador, false) then
        if GetPedInVehicleSeat(veiculo, -1) or GetPedInVehicleSeat(veiculo, 0)then
            if IsVehicleInteriorLightOn(veiculo) then
                SetVehicleInteriorlight(veiculo, false)
            else
                SetVehicleInteriorlight(veiculo, true)
            end
        end
    end
end

-- portas ["/porta [id]"]
function ControlarPortas(porta)
    -- jogador
    local jogador = GetPlayerPed(-1)
    -- veiculo
    local veiculo = GetVehiclePedIsIn(jogador, false)

	if GetVehicleDoorAngleRatio(veiculo, porta) > 0.0 then
		SetVehicleDoorShut(veiculo, porta, false)
	else
		SetVehicleDoorOpen(veiculo, porta, false)
	end
end

-- sentar no veiculo ["/assento [id]"]
function ControlarAssento(assento)
	-- jogador
    local jogador = GetPlayerPed(-1)
    -- veiculo
    local veiculo = GetVehiclePedIsIn(jogador, false)

    if IsPedSittingInAnyVehicle(jogador) then
        if GetPedInVehicleSeat(veiculo, -1) == jogador or GetPedInVehicleSeat(veiculo, 0) == jogador then
            if assento == -1 or assento == 0 then
                if IsVehicleSeatFree(veiculo, assento) then
                    -- colocar jogador no assento desejado
                    SetPedIntoVehicle(jogador, veiculo, assento)
                end
            end 
        elseif GetPedInVehicleSeat(veiculo, 1) == jogador or GetPedInVehicleSeat(veiculo, 2) == jogador then
            if assento == 1 or assento == 2 then
                if IsVehicleSeatFree(veiculo, assento) then
                    -- colocar jogador no assento desejado
                    SetPedIntoVehicle(jogador, veiculo, assento)
                end
            end
        end
    end
end

-- controlar janelas ["/janela [i]"]
function ControlarJanela(janela, porta) 
    -- jogador
    local jogador = GetPlayerPed(-1)
    -- veiculo
    local veiculo = GetVehiclePedIsIn(jogador, false)

    if janela == 0 then
        if estadoJanela1 == true and DoesVehicleHaveDoor(veiculo, porta) then
            -- descer a janela
            RollDownWindow(veiculo, janela)
            -- estado da janela
            estadoJanela1 = false
        else
            RollUpWindow(veiculo, janela)
            -- estado da janela
            estadoJanela1 = true
        end
    elseif janela == 1 then
        if estadoJanela2 == true and DoesVehicleHaveDoor(veiculo, porta) then
            -- descer a janela
            RollDownWindow(veiculo, janela)
            -- estado da janela
            estadoJanela2 = false
        else
            RollUpWindow(veiculo, janela)
            -- estado da janela
            estadoJanela2 = true
        end
    elseif janela == 2 then
        if estadoJanela3 == true and DoesVehicleHaveDoor(veiculo, porta) then
            -- descer a janela
            RollDownWindow(veiculo, janela)
            -- estado da janela
            estadoJanela3 = false
        else
            RollUpWindow(veiculo, janela)
            -- estado da janela
            estadoJanela3 = true
        end
    elseif janela == 3 then
        if estadoJanela4 == true and DoesVehicleHaveDoor(veiculo, porta) then
            -- descer a janela
            RollDownWindow(veiculo, janela)
            -- estado da janela
            estadoJanela4 = false
        else
            RollUpWindow(veiculo, janela)
            -- estado da janela
            estadoJanela4 = true
        end
    end
end

function ControlarJanelasFrontais()
    -- jogador
    local jogador = GetPlayerPed(-1)
    -- veiculo
    local veiculo = GetVehiclePedIsIn(jogador, false)

    if estadoJanela1 == true or estadoJanela2 == true then
        -- descer janelas
        RollDownWindow(veiculo, 0)
        RollDownWindow(veiculo, 1)
        -- estado das janelas
        estadoJanela1 = false
        estadoJanela2 = false
    else
        -- subir janelas
        RollUpWindow(veiculo, 0)
        RollUpWindow(veiculo, 1)
        -- estado das janelas
        estadoJanela1 = true
        estadoJanela2 = true
    end
end

function ControlarJanelasTraseiras()
    -- jogador
    local jogador = GetPlayerPed(-1)
    -- veiculo
    local veiculo = GetVehiclePedIsIn(jogador, false)

    if estadoJanela3 == true or estadoJanela4 == true then
        -- descer janelas
        RollDownWindow(veiculo, 2)
        RollDownWindow(veiculo, 3)
        -- estado das janelas
        estadoJanela3 = false
        estadoJanela4 = false
    else
        -- subir janelas
        RollUpWindow(veiculo, 2)
        RollUpWindow(veiculo, 3)
        -- estado das janelas
        estadoJanela3 = true
        estadoJanela4 = true
    end
end

function ControlarTodasAsJanelas()
    -- jogador
    local jogador = GetPlayerPed(-1)
    -- veiculo
    local veiculo = GetVehiclePedIsIn(jogador, false)

    if estadoJanela1 == true or estadoJanela2 == true or estadoJanela3 == true or estadoJanela4 == true then
        RollDownWindow(veiculo, 0)
        RollDownWindow(veiculo, 1)
        RollDownWindow(veiculo, 2)
        RollDownWindow(veiculo, 3)

        estadoJanela1 = false
        estadoJanela2 = false
        estadoJanela3 = false
        estadoJanela4 = false
    else
        RollUpWindow(veiculo, 0)
        RollUpWindow(veiculo, 1)
        RollUpWindow(veiculo, 2)
        RollUpWindow(veiculo, 3)

        estadoJanela1 = true
        estadoJanela2 = true
        estadoJanela3 = true
        estadoJanela4 = true
    end
end




-- MOTOR
TriggerEvent('chat:addSuggestion', '/motor', 'Ligar/Desligar motor')

RegisterCommand("motor", function(source, args, rawCommand)
	ControlarMotor()
end, false)


-- CAPO
TriggerEvent('chat:addSugestion', '/capo', 'Abrir/Fechar capô')

RegisterCommand('capo', function(source, args, rawCommand)
    ControlarPortas(4)
end, false)


-- BAGAGEIRA
TriggerEvent('chat:addSuggestion', '/bagageira', 'Abrir/Fechar bagageira')

RegisterCommand("bagageira", function(source, args, rawCommand)
	ControlarPortas(5)
end, false)


-- LUZES INTERIOR
TriggerEvent('chat:addSuggestion', '/luzesinterior', 'Ligar/Desligar luzes do interior do carro')

RegisterCommand("luzesinterior", function(source, args, rawCommand)
	ControlarLuzesInteriores()
end, false)


-- PORTAS
TriggerEvent('chat:addSuggestion', '/p', 'Abrir/Fechar porta')

RegisterCommand('p', function(source, args, rawCommand)
    -- qual é a porta a fechar
    local idPorta = tonumber(args[1])

    if idPorta > 0 then
        ControlarPortas(idPorta - 1)
    end  
end, false)


-- ASSENTO
TriggerEvent('chat:addSuggestion', '/assento', 'Trocar de assento')

RegisterCommand('assento', function(source, args, rawCommand)
    -- assento para trocar
    local idAssento = tonumber(args[1])

    if idAssento > 0 then
        ControlarAssento(idAssento - 2)
    end
end, false)


-- JANELA
TriggerEvent('chat:addSuggestion', '/janela', 'Abrir/Fechar janela')

RegisterCommand('janela', function(source, args, rawCommand)
    -- assento para trocar
    local idJanela = tonumber(args[1])
    
    if idJanela > 0 then
        ControlarJanela(idJanela - 1, idJanela - 1)
    end
end, false)


-- JANELAS FRONTEIRAS
TriggerEvent('chat:addSuggestion', '/janelasf', 'Abrir/Fechar janelas frontais')

RegisterCommand('janelasf', function(source, args, rawCommand)
    ControlarJanelasFrontais()
end, false)


-- JANELAS TRASEIRAS
TriggerEvent('chat:addSuggestion', '/janelast', 'Abrir/Fechar janelas traseiras')

RegisterCommand('janelast', function(source, args, rawCommand)
    ControlarJanelasTraseiras()
end, false)