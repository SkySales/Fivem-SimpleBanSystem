--------------YOU CAN RENAME THIS HAMPASLUPA HAHAHAH------------- BTW ENJOY!
function BanPlayer(src, reason) 
    local config = LoadResourceFile(GetCurrentResourceName(), "storm.json")
    local cfg = json.decode(config)
    local ids = ExtractIdentifiers(src);
    local IP = ids.ip;
    local Steam = ids.steam;
    local License = ids.license;
    local Xbl = ids.xbl;
    local LiveID = ids.live;
    local Dc_ID = ids.discord;
    local banData = {};
    banData['ID'] = tonumber(getNewBanID());
    banData['reason'] = reason;
    banData['license'] = "NONE";
    banData['steam'] = "NONE";
    banData['xbl'] = "NONE";
    banData['live'] = "NONE";
    banData['discord'] = "NONE";
    if IP ~= nil and IP ~= "nil" and IP ~= "" then 
        banData['ip'] = tostring(IP);
    end
    if License ~= nil and License ~= "nil" and License ~= "" then 
        banData['license'] = tostring(License);
    end
    if Steam ~= nil and Steam ~= "nil" and Steam ~= "" then 
        banData['steam'] = tostring(Steam);
    end
    if Xbl ~= nil and Xbl ~= "nil" and Xbl ~= "" then 
        banData['xbl'] = tostring(Xbl);
    end
    if LiveID ~= nil and LiveID ~= "nil" and LiveID ~= "" then 
        banData['live'] = tostring(LiveID);
    end
    if Dc_ID ~= nil and Dc_ID ~= "nil" and Dc_ID ~= "" then 
        banData['discord'] = tostring(Dc_ID);
    end
    cfg[tostring(GetPlayerName(src))] = banData;
    SaveResourceFile(GetCurrentResourceName(), "storm.json", json.encode(cfg, { indent = true }), -1)
    print('^2[STORMBAN] ^1Player Success Ban form the server^0')
end

function getNewBanID()
    local config = LoadResourceFile(GetCurrentResourceName(), "storm.json")
    local cfg = json.decode(config)
    local banID = 0;
    for k, v in pairs(cfg) do 
        banID = banID + 1;
    end
    return (banID + 1);
end

function GetBans()
    local config = LoadResourceFile(GetCurrentResourceName(), "storm.json")
    local cfg = json.decode(config)
    return cfg;
end

local playTracker = {}

Citizen.CreateThread(function()
    while true do 
        Wait(0);
        for _, id in pairs(GetPlayers()) do 
            local ip = ExtractIdentifiers(id).ip;
            if playTracker[ip] ~= nil then 
                playTracker[ip] = playTracker[ip] + 1;
            else 
                playTracker[ip] = 1;
            end
        end
        Wait((1000 * 60));
    end
end)

Citizen.CreateThread(function()
    while true do 
        Wait(10000);
        local bans = GetBans();
        for _, id in pairs(GetPlayers()) do 
            local IP = ExtractIdentifiers(id).ip;
            if bans[tostring(IP)] ~= nil then 
                DropPlayer(id, "StormBan " .. bans[tostring(IP)]);
            end
        end
    end
end)

function isBanned(src)
    local config = LoadResourceFile(GetCurrentResourceName(), "storm.json")
    local cfg = json.decode(config)
    local ids = ExtractIdentifiers(src);
    local playerIP = ids.ip;
    local playerSteam = ids.steam;
    local playerLicense = ids.license;
    local playerXbl = ids.xbl;
    local playerLive = ids.live;
    local playerDisc = ids.discord;
    for k, v in pairs(cfg) do 
        local reason = v['reason']
        local id = v['ID']
        local ip = v['ip']
        local license = v['license']
        local steam = v['steam']
        local xbl = v['xbl']
        local live = v['live']
        local discord = v['discord']
        if tostring(ip) == tostring(playerIP) then return { ['banID'] = id, ['reason'] = reason } end;
        if tostring(license) == tostring(playerLicense) then return { ['banID'] = id, ['reason'] = reason } end;
        if tostring(steam) == tostring(playerSteam) then return { ['banID'] = id, ['reason'] = reason } end;
        if tostring(xbl) == tostring(playerXbl) then return { ['banID'] = id, ['reason'] = reason } end;
        if tostring(live) == tostring(playerLive) then return { ['banID'] = id, ['reason'] = reason } end;
        if tostring(discord) == tostring(playerDisc) then return { ['banID'] = id, ['reason'] = reason } end;
    end
    return false;
end

function OnPlayerConnecting(name, setKickReason, deferrals)
    deferrals.defer();
    print("[StormBan] Checking their Ban Data");
    local src = source;
    local banned = false;
    local ban = isBanned(src);
    local ids = ExtractIdentifiers(src);
    local IP = ids.ip;
    local SteamID = ids.steam;
    local Steam = ids.steam:gsub("steam:", "");
    local steamDec = tostring(tonumber(Steam,16));
    Steam = "https://steamcommunity.com/profiles/" .. steamDec;
    local License = ids.license;
    local Xbl = ids.xbl;
    local LiveID = ids.live;
    local Dc_ID = ids.discord;
    Citizen.Wait(100);
    if ban then 
        local reason = ban['reason'];
        local printMessage = nil;
        if string.find(reason, "[StormBan]") then 
            printMessage = "" 
        else 
            printMessage = "[StormBan] " 
        end 
        print("[BANNED PLAYER] Player " .. GetPlayerName(src) .. " tried to join, but was banned for: " .. reason);
        deferrals.done(printMessage .. "(BAN ID: " .. ban['banID'] .. ") " .. reason);
        local title = "StormBan > This player try to join your server!"
        local loginfo = {
            ["color"] = "77777", 
            ["author"] = {
                name = "Strom Ban System",
                icon_url = Storm.WebImg
            },
            ["title"] = "" .. title, 
            ["description"] =  "**IP : **" ..IP.. "\n **SteamID: **" ..SteamID .. "\n **SteamURL: **" .. Steam .. "\n **Xbox Live : **" .. Xbl .. "\n **Live ID: **" .. LiveID .. "\n **License : **" .. License .. "\n **Discord: **<@" .. Dc_ID:gsub('discord:', '') .. ">", 
            ["footer"] = { 
                ["text"] = "StormBanSystem | " ..os.date("%m/%d/%Y") 
            }
        }
        PerformHttpRequest(Storm.PlayerBan, function(err, text, headers) end, "POST", json.encode({username = " SKY LOGS MADAFAKA",avatar_url = Storm.WebImg, embeds = {loginfo}}), {["Content-Type"] = "application/json"})
        banned = true;
        CancelEvent();
        return;
    end
    if not banned then 
        deferrals.done();
    end
end

RegisterCommand("stormban", function(source, args, raw)
    local src = source;
    if IsPlayerAceAllowed(src, "Storm.Access") then 
        if #args < 2 then 
			TriggerClientEvent('chat:addMessage', source, {
				template = '<div class="chat-message">^5StormBan Proper usage of ban command is ^1/stormban (id) (reason)</div>',
				args = { }
			});
            return;
        end
        local id = args[1]
        if ExtractIdentifiers(args[1]) ~= nil then 
            local ids = ExtractIdentifiers(id);
            local SteamID = ids.steam;
            local Steam = ids.steam:gsub("steam:", "");
            local steamDec = tostring(tonumber(Steam,16));
            Steam = "https://steamcommunity.com/profiles/" .. steamDec;
            local gameLicense = ids.license;
            local discord = ids.discord;
            local reason = table.concat(args, ' '):gsub(args[1] .. " ", "");
            BanPlayer(args[1], reason);
            DropPlayer(id, "StormBan: Banned by Admin " .. GetPlayerName(src) .. " for reason: " .. reason);
			sendToDisc("Player Banned fron the Server [Storm Ban System]", 
                'Reason: **' .. reason .. '**\n' ..
                'SteamURL: **' .. Steam .. '**\n' ..
                'SteamID: **' .. SteamID .. '**\n' ..
                'License: **' .. gameLicense .. '**\n' ..
                'Discord: **<@' .. discord:gsub('discord:', '') .. '>**\n' .. 
                'Discord ID: **' .. discord:gsub('discord:', '') .. '**\n');
        else 
			TriggerClientEvent('chat:addMessage', source, {
				template = '<div class="chat-message">^5StormBan No players were found with the id.</div>',
				args = { }
			});
        end
    end
end)

AddEventHandler("playerConnecting", OnPlayerConnecting) 

function sendToDisc(title, message)
    local embed = {}
    embed = {
        {
            ["color"] = 77777,
            ["author"] = {
                name = "Strom Ban System",
                icon_url = Storm.WebImg
            },
            ["title"] = "**".. title .."**",
            ["description"] = "" .. message ..  "",
            ["footer"] = { 
                ["text"] = "StormBanSystem | " ..os.date("%m/%d/%Y") 
            },
        }
    }

    PerformHttpRequest(Storm.SendBan,function(err, text, headers) end, 'POST', json.encode({username = 'Storm Ban System', embeds = embed, avatar_url = Storm.WebImg}), { ['Content-Type'] = 'application/json' })

end

function ExtractIdentifiers(src)
    local identifiers = {
        steam = "",
        ip = "",
        discord = "",
        license = "",
        xbl = "",
        live = ""
    }

    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)

        if string.find(id, "steam") then
            identifiers.steam = id
        elseif string.find(id, "ip") then
            identifiers.ip = id
        elseif string.find(id, "discord") then
            identifiers.discord = id
        elseif string.find(id, "license") then
            identifiers.license = id
        elseif string.find(id, "xbl") then
            identifiers.xbl = id
        elseif string.find(id, "live") then
            identifiers.live = id
        end
    end

    return identifiers
end

AddEventHandler('onResourceStart', function(resourceName)
    Citizen.Wait(1)

    if GetCurrentResourceName() ~= "StormBanSystem" then
        print('^1RESOURCE NAME NOT FOUND!^0')
    else
        local loginfo = {
            ["color"] = "77777", 
            ["author"] = {
                name = "Strom Ban System",
                icon_url = Storm.WebImg
            },
            ["title"] = "StormBanSystem Activated", 
            ["footer"] = { 
                ["text"] = "StormBanSystem | " ..os.date("%m/%d/%Y") 
            }
        }
        PerformHttpRequest(Storm.SendBan, function(err, text, headers) end, "POST", json.encode({username = " SKY LOGS MADAFAKA",avatar_url = Storm.WebImg, embeds = {loginfo}}), {["Content-Type"] = "application/json"})

        print([[
    ^2        /$$    /$$                 /$$  /$$$$$$            /$$                    
    ^2        /$$$$$$ | $$                | $$ /$$__  $$          | $$                    
    ^2       /$$__  $$| $$   /$$ /$$   /$$| $$| $$  \__/  /$$$$$$ | $$  /$$$$$$   /$$$$$$$
    ^2      | $$  \__/| $$  /$$/| $$  | $$|__/|  $$$$$$  |____  $$| $$ /$$__  $$ /$$_____/
    ^2      |  $$$$$$ | $$$$$$/ | $$  | $$ /$$ \____  $$  /$$$$$$$| $$| $$$$$$$$|  $$$$$$ 
    ^2       \____  $$| $$_  $$ | $$  | $$| $$ /$$  \ $$ /$$__  $$| $$| $$_____/ \____  $$
    ^2       /$$  \ $$| $$ \  $$|  $$$$$$$| $$|  $$$$$$/|  $$$$$$$| $$|  $$$$$$$ /$$$$$$$/
    ^2      |  $$$$$$/|__/  \__/ \____  $$|__/ \______/  \_______/|__/ \_______/|_______/ 
    ^2       \_  $$_/            /$$  | $$                                                
    ^2         \__/             |  $$$$$$/                                                
                                        \______/      
        ]]) 
    end
    --MAG THANK YOU KA NMN SAKIN KUNG KOKOPYAHIN MO TO HAHAHAHA COPY AND PASTE PA MORE
end) 
