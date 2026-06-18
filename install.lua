startup_Url = "https://raw.githubusercontent.com/turboblitz181/cobblemon-racing/refs/heads/main/startup.lua"
racers_Url = "https://raw.githubusercontent.com/turboblitz181/cobblemon-racing/refs/heads/main/racers.json"
track_1_Url = "https://raw.githubusercontent.com/turboblitz181/cobblemon-racing/refs/heads/main/tracks/track_1.json"
update_Url = "https://raw.githubusercontent.com/turboblitz181/cobblemon-racing/refs/heads/main/update.lua"

local request = http.get(startup_Url)
if not request then
    print("error getting startup file")
    return
end
local file = fs.open("startup.lua", "w")
file.write(request.readAll())
file.close()
request.close()

local request = http.get(racers_Url)
if not request then
    print("error getting racers file")
    return
end
local file = fs.open("racers.json", "w")
file.write(request.readAll())
file.close()
request.close()

local request = http.get(track_1_Url)
if not request then
    print("error getting track_1 file")
    return
end
local file = fs.open("tracks/track_1.json", "w")
file.write(request.readAll())
file.close()
request.close()

local request = http.get(update_Url)
if not request then
    print("error getting update file")
    return
end
local file = fs.open("update.lua", "w")
file.write(request.readAll())
file.close()
request.close()

if not fs.exists("basalt") then
    shell.run("wget run https://raw.githubusercontent.com/Pyroxenium/Basalt2/main/install.lua")
end
