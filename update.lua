startup_Url = "https://raw.githubusercontent.com/turboblitz181/cobblemon-racing/refs/heads/main/startup.lua"
tracks_Url = "https://raw.githubusercontent.com/turboblitz181/cobblemon-racing/refs/heads/main/tracks/"
racers_Url = "https://raw.githubusercontent.com/turboblitz181/cobblemon-racing/refs/heads/main/racers.json"

local basalt = require("basalt")
local main = basalt.getMainFrame()
basalt.LOGGER.setEnabled(true)
basalt.LOGGER.setLogToFile(true)

main:addButton():setText("update startup"):setPosition(2,4):setSize(20,3):setBackground(colors.blue):setForeground(colors.white):onClick(function() 
    local request = http.get(startup_Url)
    if not request then
        print("error getting startup file")
        return
    end
    local file = fs.open("startup.lua", "w+")
    file.write(request.readAll())
    file.close()
    request.close()
    basalt.stop()
end)

tracks = {}
local trackfiles = fs.list("tracks/")
for t, name in ipairs(trackfiles) do
    if not fs.isDir(name) then
        name = string.gsub(name,".json","")
        table.insert(tracks,name)
    end
end

for k,v in pairs(tracks) do
    
    main:addButton():setText("update " .. v):setPosition(24,0 + 4 * k):setSize(20,3):setBackground(colors.blue):setForeground(colors.white):onClick(function() 
        local request = http.get(tracks_Url .. v .. ".json")
        if not request then
                basalt.LOGGER.debug("error")
            return
        end
        local file = fs.open("tracks/"  .. v .. ".json", "w+")
        file.write(request.readAll())
        file.close()
        request.close()
        basalt.stop()
    end)
end

add_track_frame = basalt.createFrame()
track_name = add_track_frame:addInput():setPosition(2,4):setSize(20,1)
add_track_frame:addButton():setText("confirm"):setPosition(12,6):setSize(10,2):setBackground(colors.green):setForeground(colors.white):onClick(function() 
    local request = http.get(tracks_Url .. track_name:getText() .. ".json")
    if not request then
        print("error getting startup file")
        return
    end
    local file = fs.open("tracks/" .. track_name:getText() .. ".json", "w+")
    file.write(request.readAll())
    file.close()
    request.close()
    basalt.stop()
end)

add_track_frame:addButton():setText("back"):setPosition(2,17):setSize(20,1):setBackground(colors.red):setForeground(colors.white):onClick(function() 
    basalt.setActiveFrame(main)
end)

main:addButton():setText("add track"):setPosition(2,8):setSize(20,3):setBackground(colors.blue):setForeground(colors.white):onClick(function() 
    basalt.setActiveFrame(add_track_frame)
end)

main:addButton():setText("update racers"):setPosition(2,12):setSize(20,3):setBackground(colors.blue):setForeground(colors.white):onClick(function() 
    local request = http.get(racers_Url)
    if not request then
        print("error getting racers file")
        return
    end
    local file = fs.open("racers.json", "w+")
    file.write(request.readAll())
    file.close()
    request.close()
    basalt.stop()
end)

basalt.run()
