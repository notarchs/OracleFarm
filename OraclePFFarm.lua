if not (require and debug and debug.getupvalue and syn and syn.queue_on_teleport and rconsoleprint and rconsoleclear) then
	return
end

local starttime = tick()

local function output(str)
	rconsoleprint("\n")
	for i, v in next, str:split("|") do
		rconsoleprint(i % 2 == 0 and v or "@@" .. v .. "@@")
	end
end

rconsoleclear()

output([[CYAN|======================================================

|WHITE|[|CYAN|Credits|WHITE|] Oracle PF Farm Beta

|WHITE|[|CYAN|Credits|WHITE|] Made By not.archs#6666
|WHITE|[|CYAN|Credits|WHITE|] Discord (OracleCheats): |LIGHT_GREEN|https://discord.gg/ZxmzWUDgY9

|WHITE|[|CYAN|Credits|WHITE|] Based on another farm but it gone :(
|WHITE|[|CYAN|Credits|WHITE|] Original Farm: |LIGHT_RED| Now Removed :(

|CYAN|======================================================
]])

output("WHITE|[|CYAN|Oracle|WHITE|] Waiting For Game To Load...")

repeat wait() until game:IsLoaded()

output("WHITE|[|CYAN|Oracle|WHITE|] Setting Up...")

local player = game:GetService("Players").LocalPlayer
local repfirst = game:GetService("ReplicatedFirst")
local heartbeat = game:GetService("RunService").Heartbeat

local function fastwait(delay)
	local elapsed = 0
	while elapsed < delay do
		elapsed = elapsed + heartbeat:Wait()
	end
end

output("WHITE|[|CYAN|Oracle|WHITE|] Waiting For You To Load In...")

repeat fastwait(1) until not player.PlayerGui:FindFirstChild("Loadscreen")

local network = require(repfirst.ClientModules.Old.framework.network)
local camera = require(repfirst.ClientModules.Old.framework.camera)

local playertable = debug.getupvalue(debug.getupvalue(camera.setspectate, 1).getplayerhit, 1)

local conn

while conn == nil do
	conn = getconnections(game:GetService("ControllerService").RemoteEvent.OnClientEvent)[1]
	if not conn then
		fastwait(1)
	end
end

local stats

for i, v in next, debug.getupvalue(conn.Function, 1) do
	local upv = debug.getupvalues(v)[1]
	if upv and type(upv) == "table" and rawget(upv, "stats") then
		stats = upv.stats
		break
    end
end

local initialexp = stats.experience

output("WHITE|[|CYAN|Oracle|WHITE|] Spawning In...")

network:send("spawn")

local attempts = 0
repeat fastwait(0.1)
	attempts = attempts + 1
	if attempts % 20 == 0 then
		network:send("spawn")
	end
until (player.Character and player.Character:IsDescendantOf(workspace.Players)) or attempts >= 100

if attempts < 100 then
	output("WHITE|[|CYAN|Oracle|WHITE|] Spawned In. Getting Targets...")
    fastwait(0.1)
	local validtargets, count = {}, 0
    for i, v in next, playertable do
		if i:FindFirstChild("HumanoidRootPart") and v.Team ~= player.Team then
			validtargets[i] = v
		end
	end
	for i, v in next, validtargets do
        if count == 4 or not (player.Character and player.Character:IsDescendantOf(workspace.Players)) then break end
        if playertable[i] then
			output("WHITE|[|CYAN|Oracle|WHITE|] Target Found: " .. v.Name)
            network:send("newgrenade", "FRAG", {
                time = tick(),
				blowuptime = 0,
				frames = { {
					t0 = 0,
					p0 = camera.basecframe.p,
					v0 = Vector3.new(),
					offset = i.HumanoidRootPart.Position - camera.basecframe.p,
					a = Vector3.new(0, -80, 0),
					rot0 = CFrame.new(),
					rotv = Vector3.new(),
					glassbreaks = {}
				} }
            })
            count = count + 1
            fastwait(0.1)
        end
    end
else
	output("WHITE|[|RED|Error|WHITE|] Failed To Spawn In.")
end

output("WHITE|[|CYAN|Oracle|WHITE|] Finished")

local finaltime, finalexp = math.floor((tick() - starttime) * 100) / 100, stats.experience - initialexp
local projectedexp = math.floor((finalexp / finaltime) * 3600)

output("WHITE|\n[|LIGHT_GREEN|Stats|WHITE|] Time Taken: " .. finaltime .. " Seconds")
output("WHITE|[|LIGHT_GREEN|Stats|WHITE|] Experience Gained: " .. finalexp .. " Exp")
output("WHITE|[|LIGHT_GREEN|Stats|WHITE|] Projected Earings: " .. projectedexp .. " Exp / Hour")

output("WHITE|\n[|CYAN|Oracle|WHITE|] Teleporting To New Server...")

player.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Started then
        (syn and syn.queue_on_teleport or queue_on_teleport)("loadstring(game:HttpGet('https://raw.githubusercontent.com/notarchs/OracleFarm/main/OraclePFFarm.lua'))()")
    end
end)

local validids = {}

for i, v in next, game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/292439477/servers/Public?limit=100")).data do
    if v.playing < v.maxPlayers - 1 and v.id ~= game.JobId then
		validids[#validids + 1] = v.id
    end
end

game:GetService("TeleportService"):TeleportToPlaceInstance(292439477, validids[math.random(1, #validids)])
