pd = peripheral.wrap("right")
cb = peripheral.wrap("left")
rr1 = peripheral.wrap("redstone_relay_0")
rr2 = peripheral.wrap("redstone_relay_1")




function max(numbers)
    highestValue = numbers[1]
    for _, value in ipairs(numbers) do
        if value > highestValue then
            highestValue = value
        end
    end
    return highestValue

end

function min(numbers)
    lowestValue = numbers[1]
    for _, value in ipairs(numbers) do
        if value < lowestValue then
            lowestValue = value
        end
    end
    return lowestValue
end

function race(players,rings)
    racing = true
    tplayers = 0
    fplayers = 0
    max_laps = 1
    for i in ipairs(players) do
        if players[i].player == "x" then
        else
            tplayers = tplayers + 1
        end
    end
    while racing do
        for i in ipairs(players) do
            
            pos = pd.getPlayerPos(players[i].player)
            if pos.x == nil then
            else
                prev_sector = players[i].sector
                for ringnr in ipairs(rings) do
                    if ringnr == players[i].ring then
                    else
                        if pos.x >= rings[ringnr].x1 and pos.y >= rings[ringnr].y1 and pos.z >= rings[ringnr].z1 and pos.x <= rings[ringnr].x2 and pos.y <= rings[ringnr].y2 and pos.z <= rings[ringnr].z2 then
                            if ringnr == players[i].ring + 1 then
                                --cb.sendMessageToPlayer("ring: " .. ringnr,players[i].player)
                                players[i].ring = ringnr
                                players[i].sector = rings[ringnr].sector
                            elseif ringnr == 1 and players[i].ring == #rings then
                                players[i].ring = ringnr
                                players[i].sector = rings[ringnr].sector
                            else
                                cb.sendMessageToPlayer("you skipped a ring!",players[i].player)
                            end
                        end
                    end
                end
                if players[i].ring > 0 then
                    players[i].racetime = players[i].racetime + 1
                end
                if players[i].sector == prev_sector then
                else
                    if prev_sector == 1 then
                        players[i].s1time = players[i].racetime / 5
                        cb.sendMessageToPlayer("Sector 1 time: " .. players[i].s1time .. " sec",players[i].player)
                    elseif prev_sector == 2 then
                        players[i].s2time = players[i].racetime / 5 - players[i].s1time
                        cb.sendMessageToPlayer("Sector 2 time: " .. players[i].s2time .. " sec",players[i].player)
                    elseif prev_sector == 3 then
                        players[i].s3time = players[i].racetime / 5 - players[i].s1time - players[i].s2time
                    end
                end
                if players[i].lap < max_laps and players[i].sector == 1 and prev_sector == 3 then
                    table.insert(players[i].laptimes,players[i].racetime)
                    players[i].racetime = 0
                    cb.sendMessageToPlayer("Sector 3 time: " .. players[i].s3time .. " sec \n" .. "Lap time: " .. players[i].laptimes[players[i].lap] / 5 .. " sec",players[i].player)
                    players[i].sector = 1
                    players[i].ring = 0
                    players[i].lap = players[i].lap + 1
                elseif players[i].lap >= max_laps and players[i].sector == 1 and prev_sector == 3 then 
                    fplayers = fplayers + 1
                    players[i].ring = 0
                    table.insert(players[i].laptimes,players[i].racetime)
                    cb.sendMessageToPlayer("Sector 3 time: " .. players[i].s3time .. " sec \n" .. "Lap time: " .. players[i].laptimes[players[i].lap] / 5 .. " sec and finished",players[i].player)
                end  
            end
        end
        if fplayers == tplayers then 
            racing = false
        end
    end
    return players
end

tracks = {}
local trackfiles = fs.list("tracks/")
for t, name in ipairs(trackfiles) do
    if not fs.isDir(name) then
        name = string.gsub(name,".json","")
        table.insert(tracks,name)
    end
end

function get_racer_data()
    racersfile = fs.open("racers.json","r")
    racersjson = racersfile.readAll()
    rd = textutils.unserialiseJSON(racersjson)
    racersfile.close()
    return rd
end

players = {}
player1 = "x"
player2 = "x"
player3 = "x"

racers_data = get_racer_data()
local basalt = require("basalt")
local elementManager = basalt.getElementManager()
local main = basalt.getMainFrame()
local track_select = basalt.createFrame()
local race_start = basalt.createFrame()
local player_select = basalt.createFrame()
local player_1_select = basalt.createFrame()
local player_2_select = basalt.createFrame()
local player_3_select = basalt.createFrame()
local history = basalt.createFrame()
local leaderboard = basalt.createFrame()
local lapm = basalt.createFrame()
local s1m = basalt.createFrame()
local s2m = basalt.createFrame()
local s3m = basalt.createFrame()
elementManager.configure({
    autoLoadMissing = true,
    allowRemoteLoading = true,
    allowDiskLoading = true,
    useGlobalCache = true
})

local w,h = term.getSize()
-- scroll pages
local history_scroll = history:addScrollFrame({
    x = 0,
    y = 0,
    width = w,
    height = h
}
)



tr = nil

basalt.LOGGER.setEnabled(true)
basalt.LOGGER.setLogToFile(true)

hlaps_list = {}
hs1_list = {}
hs2_list = {}
hs3_list = {}
te = {}
for k,v in pairs(racers_data[1]) do
    hlaps_list[v.name] = {}
    hs1_list[v.name] = {}
    hs2_list[v.name] = {}
    hs3_list[v.name] = {}
    for x,y in pairs(tracks) do
        hlaps_list[v.name][y] = {"a","b","c"}
        hs1_list[v.name][y] = {"a","b","c"}
        hs2_list[v.name][y] = {"a","b","c"}
        hs3_list[v.name][y] = {"a","b","c"}
    end
end
-- history menu
history:addLabel():setText("Race History - racers"):setPosition(2,2)
history:addButton():setText("back"):setPosition(2,19):setSize(10,1):setBackground(colors.red):setForeground(colors.white):onClick(function() basalt.setActiveFrame(main) end)
history_racers_list = {}
history_racers_scroll = {}
i = 0


for k,v in pairs(racers_data[1]) do
    i = i + 1
    history_racers_list[v.name] = basalt.createFrame()
    history_racers_scroll[v.name] = history_racers_list[v.name]:addScrollFrame({
    x = 0,
    y = 0,
    width = w,
    height = h})
    history_racers_scroll[v.name]:addLabel():setText("Race History - " .. v.name):setPosition(2,2)
    history_racers_list[v.name]:addButton():setText("back"):setPosition(2,19):setSize(10,1):setBackground(colors.red):setForeground(colors.white):onClick(function() basalt.setActiveFrame(history) end)
    for x,y in pairs(tracks) do
        if v[y] then
            history_racers_list[v.name][y] = basalt.createFrame()
            history_racers_scroll[v.name]:addButton():setText(y):setPosition(2,2+x*2):setSize(10,1):setBackground(colors.gray):setForeground(colors.white):onClick(function()
                racers_datan = get_racer_data()
                for o = 1,3 do
                    hlaps_list[v.name][y][o]:setText(racers_datan[1][v.name][y].h_lap[o] .. " sec")
                    hs1_list[v.name][y][o]:setText(racers_datan[1][v.name][y].h_s1[o] .. " sec")
                    hs2_list[v.name][y][o]:setText(racers_datan[1][v.name][y].h_s2[o] .. " sec")
                    hs3_list[v.name][y][o]:setText(racers_datan[1][v.name][y].h_s3[o] .. " sec")
                end
                basalt.setActiveFrame(history_racers_list[v.name][y]) 
            end)
            for l = 1,3 do 
                hlaps_list[v.name][y][l] = history_racers_list[v.name][y]:addLabel():setText(" sec"):setPosition(10 + (l - 1) * 10,6)
                hs1_list[v.name][y][l] = history_racers_list[v.name][y]:addLabel():setText(" sec"):setPosition(10 + (l - 1) * 10,8)
                hs2_list[v.name][y][l] = history_racers_list[v.name][y]:addLabel():setText(" sec"):setPosition(10 + (l - 1) * 10,10)
                hs3_list[v.name][y][l] = history_racers_list[v.name][y]:addLabel():setText(" sec"):setPosition(10 + (l - 1) * 10,12)
            end
            history_racers_list[v.name][y]:addLabel():setText("lap -"):setPosition(2,6)
            history_racers_list[v.name][y]:addLabel():setText("S1  -"):setPosition(2,8)
            history_racers_list[v.name][y]:addLabel():setText("S2  -"):setPosition(2,10)
            history_racers_list[v.name][y]:addLabel():setText("S3  -"):setPosition(2,12)

            history_racers_list[v.name][y]:addButton():setText("back"):setPosition(2,19):setSize(10,1):setBackground(colors.red):setForeground(colors.white):onClick(function() basalt.setActiveFrame(history_racers_list[v.name]) end)
            history_racers_list[v.name][y]:addLabel():setText(v.name .. " - " .. y):setPosition(2,2)
            history_racers_list[v.name][y]:addLabel():setText("race 1"):setPosition(10,4)
            history_racers_list[v.name][y]:addLabel():setText("race 2"):setPosition(20,4)
            history_racers_list[v.name][y]:addLabel():setText("race 3"):setPosition(30,4)
        end
    end
    history_scroll:addButton():setText(v.name):setPosition(2,2+i*2):setSize(20,1):setBackground(colors.gray):setForeground(colors.white):onClick(function()
        basalt.setActiveFrame(history_racers_list[v.name])
    end)
end 

-- main menu
main:addButton():setText("start race setup"):setPosition(2,2):setSize(20,3):setBackground(colors.green):setForeground(colors.white):onClick(function() basalt.setActiveFrame(race_start) end)
main:addButton():setText("history"):setPosition(24,2):setSize(20,3):setBackground(colors.blue):setForeground(colors.white):onClick(function()
    for k,v in pairs(racers_data[1]) do
        for x,y in pairs(tracks) do
            if v[y] then
                racers_datan = get_racer_data()
                for o = 1,3 do
                    hlaps_list[v.name][y][o]:setText(racers_datan[1][v.name][y].h_lap[o] .. " sec")
                    hs1_list[v.name][y][o]:setText(racers_datan[1][v.name][y].h_s1[o] .. " sec")
                    hs2_list[v.name][y][o]:setText(racers_datan[1][v.name][y].h_s2[o] .. " sec")
                    hs3_list[v.name][y][o]:setText(racers_datan[1][v.name][y].h_s3[o] .. " sec")
                end
            end
        end
    end
    basalt.setActiveFrame(history)
end)
main:addButton():setText("leaderboard"):setPosition(2,6):setSize(20,3):setBackground(colors.orange):setForeground(colors.white):onClick(function() basalt.setActiveFrame(leaderboard) end)

-- track select menu
track_select:addLabel():setText("Select Track"):setPosition(2,2)
for k,v in pairs(tracks) do
    track_select:addButton():setText(v):setPosition(2,2+k*2):setSize(20,1):setBackground(colors.gray):setForeground(colors.white):onClick(function() 
        local ringsfile = fs.open("tracks/" .. v .. ".json","r")
        ringsjson = ringsfile.readAll()
        rings = textutils.unserialiseJSON(ringsjson)
        ringsfile.close()
        track_label:setText("Track: " .. v)
        basalt.setActiveFrame(race_start)
        tr = v
    end)
end
track_select:addButton():setText("back"):setPosition(2,19):setSize(10,1):setBackground(colors.red):setForeground(colors.white):onClick(function() basalt.setActiveFrame(race_start) end)

-- leaderboard menu
leaderboard:addLabel():setText("Leaderboard"):setPosition(2,2)
leaderboard:addButton():setText("back"):setPosition(2,19):setSize(10,1):setBackground(colors.red):setForeground(colors.white):onClick(function() basalt.setActiveFrame(main) end)
leaderboard:addButton():setText("Lap"):setPosition(2,4):setSize(10,1):setBackground(colors.gray):setForeground(colors.white):onClick(function() basalt.setActiveFrame(lapm) end)
leaderboard:addButton():setText("Sector 1"):setPosition(2,6):setSize(10,1):setBackground(colors.gray):setForeground(colors.white):onClick(function() basalt.setActiveFrame(s1m) end)
leaderboard:addButton():setText("Sector 2"):setPosition(2,8):setSize(10,1):setBackground(colors.gray):setForeground(colors.white):onClick(function() basalt.setActiveFrame(s2m) end)
leaderboard:addButton():setText("Sector 3"):setPosition(2,10):setSize(10,1):setBackground(colors.gray):setForeground(colors.white):onClick(function() basalt.setActiveFrame(s3m) end)
lapm:addButton():setText("back"):setPosition(2,19):setSize(10,1):setBackground(colors.red):setForeground(colors.white):onClick(function() basalt.setActiveFrame(leaderboard) end)
lapm:addLabel():setText("select track"):setPosition(2,2)
s1m:addButton():setText("back"):setPosition(2,19):setSize(10,1):setBackground(colors.red):setForeground(colors.white):onClick(function() basalt.setActiveFrame(leaderboard) end)
s1m:addLabel():setText("select track"):setPosition(2,2)
s2m:addButton():setText("back"):setPosition(2,19):setSize(10,1):setBackground(colors.red):setForeground(colors.white):onClick(function() basalt.setActiveFrame(leaderboard) end)
s2m:addLabel():setText("select track"):setPosition(2,2)
s3m:addButton():setText("back"):setPosition(2,19):setSize(10,1):setBackground(colors.red):setForeground(colors.white):onClick(function() basalt.setActiveFrame(leaderboard) end)
s3m:addLabel():setText("select track"):setPosition(2,2)

lapm_track_list = {}
lapm_track_label_list = {}
i = 0 
leaderboard_track = nil
track_new_racer_lap = {}
track_new_racer_s1 = {}
track_new_racer_s2 = {}
track_new_racer_s3 = {}
for x,y in pairs(tracks) do
    track_new_racer_lap[y] = 0 
    track_new_racer_s1[y] = 0 
    track_new_racer_s2[y] = 0 
    track_new_racer_s3[y] = 0 
end

for x,y in pairs(tracks) do 
    lapm_track_list[y] = basalt.createFrame()
    lapm_track_list[y]:addLabel():setText("Leaderboard - lap - " .. y):setPosition(2,2)
    lapm:addButton():setText(y):setPosition(2,2+x*2):setSize(20,1):setBackground(colors.gray):setForeground(colors.white):onClick(function()
        leaderboard_track = y
        best_list = {}
        racers_data = get_racer_data()
        basalt.LOGGER.debug(track_new_racer_lap[leaderboard_track])
        if track_new_racer_lap[leaderboard_track] > 0 then
            while track_new_racer_lap[leaderboard_track] > 0 do
                basalt.LOGGER.debug("new racer")
                new_lapm_track_label = lapm_track_list[leaderboard_track]:addLabel():setText(" "):setPosition(2,2 + 2 * (#lapm_track_label_list[leaderboard_track] + 1))
                table.insert(lapm_track_label_list[leaderboard_track],new_lapm_track_label)
                track_new_racer_lap[leaderboard_track] = track_new_racer_lap[leaderboard_track] - 1
            end
        end
        for k,v in pairs(racers_data[1]) do
            if v[leaderboard_track] then
                table.insert(best_list, {name = v.name, time = v[leaderboard_track].best_lap})
            end
        end
        table.sort(best_list,function(a,b) return a.time < b.time end)
        l = 0
        for k,v in pairs(best_list) do
            l = l + 1
            if lapm_track_label_list[leaderboard_track][l] then
                lapm_track_label_list[leaderboard_track][l]:setText(v.name .. " - " .. v.time)
            end
        end
        basalt.setActiveFrame(lapm_track_list[y])
    end)
    lapm_track_list[y]:addButton():setText("back"):setPosition(2,19):setSize(10,1):setBackground(colors.red):setForeground(colors.white):onClick(function() basalt.setActiveFrame(lapm) end)
    lapm_track_label_list[y] = {}
    i = 0
    for k,v in pairs(racers_data[1]) do
        if v[y] ~= nil then
            i = i + 1
            lapm_track_label_list[y][i] = lapm_track_list[y]:addLabel():setText(v.name .. " - " .. v[y].best_lap):setPosition(2,2 + 2 * i)
        end
    end
end 

s1m_track_list = {}
s1m_track_label_list = {}
for x,y in pairs(tracks) do 
    s1m_track_list[y] = basalt.createFrame()
    s1m_track_list[y]:addLabel():setText("Leaderboard - s1 - " .. y):setPosition(2,2)
    s1m:addButton():setText(y):setPosition(2,2+x*2):setSize(20,1):setBackground(colors.gray):setForeground(colors.white):onClick(function()
        leaderboard_track = y
        best_list = {}
        racers_data = get_racer_data()
        basalt.LOGGER.debug(track_new_racer_s1[leaderboard_track])
        if track_new_racer_s1[leaderboard_track] > 0 then
            while track_new_racer_s1[leaderboard_track] > 0 do
                basalt.LOGGER.debug("new racer")
                new_s1m_track_label = s1m_track_list[leaderboard_track]:addLabel():setText(" "):setPosition(2,2 + 2 * (#s1m_track_label_list[leaderboard_track] + 1))
                table.insert(s1m_track_label_list[leaderboard_track],new_s1m_track_label)
                track_new_racer_s1[leaderboard_track] = track_new_racer_s1[leaderboard_track] - 1
            end
        end
        for k,v in pairs(racers_data[1]) do
            if v[leaderboard_track] then
                table.insert(best_list, {name = v.name, time = v[leaderboard_track].best_s1})
            end
        end
        table.sort(best_list,function(a,b) return a.time < b.time end)
        l = 0
        for k,v in pairs(best_list) do
            l = l + 1
            if s1m_track_label_list[leaderboard_track][l] then
                s1m_track_label_list[leaderboard_track][l]:setText(v.name .. " - " .. v.time)
            end
        end
        basalt.setActiveFrame(s1m_track_list[y])
    end)
    s1m_track_list[y]:addButton():setText("back"):setPosition(2,19):setSize(10,1):setBackground(colors.red):setForeground(colors.white):onClick(function() basalt.setActiveFrame(s1m) end)
    s1m_track_label_list[y] = {}
    i = 0
    for k,v in pairs(racers_data[1]) do
        if v[y] ~= nil then
            i = i + 1
            s1m_track_label_list[y][i] = s1m_track_list[y]:addLabel():setText(v.name .. " - " .. v[y].best_s1):setPosition(2,2 + 2 * i)
        end
    end
end 

s2m_track_list = {}
s2m_track_label_list = {}
for x,y in pairs(tracks) do 
    s2m_track_list[y] = basalt.createFrame()
    s2m_track_list[y]:addLabel():setText("Leaderboard - s2 - " .. y):setPosition(2,2)
    s2m:addButton():setText(y):setPosition(2,2+x*2):setSize(20,1):setBackground(colors.gray):setForeground(colors.white):onClick(function()
        leaderboard_track = y
        best_list = {}
        racers_data = get_racer_data()
        basalt.LOGGER.debug(track_new_racer_s2[leaderboard_track])
        if track_new_racer_s2[leaderboard_track] > 0 then
            while track_new_racer_s2[leaderboard_track] > 0 do
                basalt.LOGGER.debug("new racer")
                new_s2m_track_label = s2m_track_list[leaderboard_track]:addLabel():setText(" "):setPosition(2,2 + 2 * (#s2m_track_label_list[leaderboard_track] + 1))
                table.insert(s2m_track_label_list[leaderboard_track],new_s2m_track_label)
                track_new_racer_s2[leaderboard_track] = track_new_racer_s2[leaderboard_track] - 1
            end
        end
        for k,v in pairs(racers_data[1]) do
            if v[leaderboard_track] then
                table.insert(best_list, {name = v.name, time = v[leaderboard_track].best_s2})
            end
        end
        table.sort(best_list,function(a,b) return a.time < b.time end)
        l = 0
        for k,v in pairs(best_list) do
            l = l + 1
            if s2m_track_label_list[leaderboard_track][l] then
                s2m_track_label_list[leaderboard_track][l]:setText(v.name .. " - " .. v.time)
            end
        end
        basalt.setActiveFrame(s2m_track_list[y])
    end)
    s2m_track_list[y]:addButton():setText("back"):setPosition(2,19):setSize(10,1):setBackground(colors.red):setForeground(colors.white):onClick(function() basalt.setActiveFrame(s2m) end)
    s2m_track_label_list[y] = {}
    i = 0
    for k,v in pairs(racers_data[1]) do
        if v[y] ~= nil then
            i = i + 1
            s2m_track_label_list[y][i] = s2m_track_list[y]:addLabel():setText(v.name .. " - " .. v[y].best_s2):setPosition(2,2 + 2 * i)
        end
    end
end 

s3m_track_list = {}
s3m_track_label_list = {}
for x,y in pairs(tracks) do 
    s3m_track_list[y] = basalt.createFrame()
    s3m_track_list[y]:addLabel():setText("Leaderboard - s3 - " .. y):setPosition(2,2)
    s3m:addButton():setText(y):setPosition(2,2+x*2):setSize(20,1):setBackground(colors.gray):setForeground(colors.white):onClick(function()
        leaderboard_track = y
        best_list = {}
        racers_data = get_racer_data()
        basalt.LOGGER.debug(track_new_racer_s3[leaderboard_track])
        if track_new_racer_s3[leaderboard_track] > 0 then
            while track_new_racer_s3[leaderboard_track] > 0 do
                basalt.LOGGER.debug("new racer")
                new_s3m_track_label = s3m_track_list[leaderboard_track]:addLabel():setText(" "):setPosition(2,2 + 2 * (#s3m_track_label_list[leaderboard_track] + 1))
                table.insert(s3m_track_label_list[leaderboard_track],new_s3m_track_label)
                track_new_racer_s3[leaderboard_track] = track_new_racer_s3[leaderboard_track] - 1
            end
        end
        for k,v in pairs(racers_data[1]) do
            if v[leaderboard_track] then
                table.insert(best_list, {name = v.name, time = v[leaderboard_track].best_s3})
            end
        end
        table.sort(best_list,function(a,b) return a.time < b.time end)
        l = 0
        for k,v in pairs(best_list) do
            l = l + 1
            if s3m_track_label_list[leaderboard_track][l] then
                s3m_track_label_list[leaderboard_track][l]:setText(v.name .. " - " .. v.time)
            end
        end
        basalt.setActiveFrame(s3m_track_list[y])
    end)
    s3m_track_list[y]:addButton():setText("back"):setPosition(2,19):setSize(10,1):setBackground(colors.red):setForeground(colors.white):onClick(function() basalt.setActiveFrame(s3m) end)
    s3m_track_label_list[y] = {}
    i = 0
    for k,v in pairs(racers_data[1]) do
        if v[y] ~= nil then
            i = i + 1
            s3m_track_label_list[y][i] = s3m_track_list[y]:addLabel():setText(v.name .. " - " .. v[y].best_s3):setPosition(2,2 + 2 * i)
        end
    end
end

-- player select menu
player_select:addLabel():setText("Select Players"):setPosition(2,2)

player_select:addButton():setText("player 1"):setPosition(2,5):setSize(20,3):setBackground(colors.blue):setForeground(colors.white):onClick(function() 
    basalt.setActiveFrame(player_1_select)
end)
player_1_label = player_select:addLabel():setText(" - x "):setPosition(24, 6)

player_select:addButton():setText("player 2"):setPosition(2,8):setSize(20,3):setBackground(colors.blue):setForeground(colors.white):onClick(function() 
    basalt.setActiveFrame(player_2_select)
end)
player_2_label = player_select:addLabel():setText(" - x "):setPosition(24, 9)

player_select:addButton():setText("player 3"):setPosition(2,11):setSize(20,3):setBackground(colors.blue):setForeground(colors.white):onClick(function() 
    basalt.setActiveFrame(player_3_select)
end)
player_3_label = player_select:addLabel():setText(" - x "):setPosition(24, 12)

player_select:addButton():setText("back"):setPosition(2,19):setSize(10,1):setBackground(colors.red):setForeground(colors.white):onClick(function()
    players_label:setText("Players: " .. #players) 
    basalt.setActiveFrame(race_start)
end)
-- player 1 select menu
player_1_select:addLabel():setText("player 1 name: "):setPosition(2,2)
player1 = player_1_select:addInput():setPosition(2,4):setSize(20,1)
player_1_select:addButton():setText("back"):setPosition(2,19):setSize(10,1):setBackground(colors.red):setForeground(colors.white):onClick(function() 
    player_1_label:setText(" - x")
    basalt.setActiveFrame(player_select)
end)
player_1_select:addButton():setText("Confirm"):setPosition(2,8):setSize(10,3):setBackground(colors.green):setForeground(colors.white):onClick(function() 
    players[1] = {player = player1:getText(),ring = 0,sector = 1,racetime = 0,s1time = 0,s2time = 0,s3time = 0,ftime = 0,laptimes = {},lap = 1}
    player_1_label:setText(" - " .. player1:getText())
    basalt.setActiveFrame(player_select)
end)

-- player 2 select menu
player_2_select:addLabel():setText("player 2 name: "):setPosition(2,2)
player2 = player_2_select:addInput():setPosition(2,4):setSize(20,1)
player_2_select:addButton():setText("back"):setPosition(2,19):setSize(10,1):setBackground(colors.red):setForeground(colors.white):onClick(function() 
    player_2_label:setText(" - x")
    basalt.setActiveFrame(player_select)
end)
player_2_select:addButton():setText("Confirm"):setPosition(2,8):setSize(10,3):setBackground(colors.green):setForeground(colors.white):onClick(function() 
    players[2] = {player = player2:getText(),ring = 0,sector = 1,racetime = 0,s1time = 0,s2time = 0,s3time = 0,ftime = 0,laptimes = {},lap = 1}
    player_2_label:setText(" - " .. player2:getText())
    basalt.setActiveFrame(player_select)
end)

-- player 3 select menu
player_3_select:addLabel():setText("player 3 name: "):setPosition(2,2)
player3 = player_3_select:addInput():setPosition(2,4):setSize(20,1)
player_3_select:addButton():setText("back"):setPosition(2,19):setSize(10,1):setBackground(colors.red):setForeground(colors.white):onClick(function() 
    player_3_label:setText(" - x")
    basalt.setActiveFrame(player_select)
end)
player_3_select:addButton():setText("Confirm"):setPosition(2,8):setSize(10,3):setBackground(colors.green):setForeground(colors.white):onClick(function() 
    players[3] = {player = player3:getText(),ring = 0,sector = 1,racetime = 0,s1time = 0,s2time = 0,s3time = 0,ftime = 0,laptimes = {},lap = 1}
    player_3_label:setText(" - " .. player3:getText())
    basalt.setActiveFrame(player_select)
end)

-- race start menu
race_start:addButton():setText("Select Track"):setPosition(2,6):setSize(20,3):setBackground(colors.gray):setForeground(colors.white):onClick(function() basalt.setActiveFrame(track_select) end)
race_start:addButton():setText("select players"):setPosition(2,10):setSize(20,3):setBackground(colors.blue):setForeground(colors.white):onClick(function() basalt.setActiveFrame(player_select) end)
race_start:addButton():setText("back"):setPosition(2,19):setSize(10,1):setBackground(colors.red):setForeground(colors.white):onClick(function() basalt.setActiveFrame(main) end)

track_label = race_start:addLabel():setText("Track: none"):setPosition(24, 7)
players_label = race_start:addLabel():setText("Players: " .. #players):setPosition(24, 11)

race_start:addButton():setText("start race"):setPosition(2,2):setSize(20,3):setBackground(colors.green):setForeground(colors.white):onClick(function() 
    if #players > 0 and #rings > 0 then
        if not players[2] then
            players[2] = {player = "x",ring = 0,sector = 1,racetime = 0,s1time = 0,s2time = 0,s3time = 0,ftime = 0,laptimes = {},lap = 1}
        end
        if not players[3] then
            players[3] = {player = "x",ring = 0,sector = 1,racetime = 0,s1time = 0,s2time = 0,s3time = 0,ftime = 0,laptimes = {},lap = 1}
        end
        basalt.LOGGER.debug("race is ready to start")
        rr2.setOutput("bottom",true)
        cb.sendMessage("race is starting! get to your positions!")
        pos1 = false
        pos2 = false
        pos3 = false
        start= false
        while start == false do
            sleep(0.1)
            if rr1.getInput("left") == true or players[2].player == "x" then
                pos2 = true
            end
            if rr1.getInput("right") == true or players[3].player == "x" then
                pos3 = true
            end
            if rr1.getInput("back") == true then
                pos1 = true
            end
            if pos1 and pos2 and pos3 then
                start = true
            end
        end
        cb.sendMessage("3!")
        sleep(1)
        cb.sendMessage("2!")
        sleep(0.5)   
        rr2.setOutput("bottom",false)
        sleep(0.5)
        cb.sendMessage("1!")

        sleep(1)
        cb.sendMessage("START!!")

        players = race(players,rings)
        for x in pairs(players) do
            players[x].ftime = 0
            for y in pairs(players[x].laptimes) do
                players[x].ftime = players[x].ftime + players[x].laptimes[y]
            end
        end
        endresult = {p1 = "",p2 = "",p3 = "",p1time = 0,p2time = 0,p3time = 0}
        if fplayers == 3 then
            p3 = max({players[1].ftime,players[2].ftime,players[3].ftime})
            p1 = min({players[1].ftime,players[2].ftime,players[3].ftime})
            if players[1].ftime == p1 then
                endresult.p1 = players[1].player
                endresult.p1time = players[1].ftime
            elseif players[1].ftime == p3 then
                endresult.p3 = players[1].player 
                endresult.p3time = players[1].ftime  
            else
                endresult.p2 = players[1].player
                endresult.p2time = players[1].ftime      
            end 
            if players[2].ftime == p1 then
                endresult.p1 = players[2].player
                endresult.p1time = players[2].ftime
            elseif players[2].ftime == p3 then
                endresult.p3 = players[2].player   
                endresult.p3time = players[2].ftime
            else
                endresult.p2 = players[2].player  
                endresult.p2time = players[2].ftime    
            end 
            if players[3].ftime == p1 then
                endresult.p1 = players[3].player
                endresult.p1time = players[3].ftime
            elseif players[3].ftime == p3 then
                endresult.p3 = players[3].player  
                endresult.p3time = players[3].ftime 
            else
                endresult.p2 = players[3].player  
                endresult.p2time = players[3].ftime    
            end   
            cb.sendMessage("end results: \n" .. endresult.p1 .. "\n" .. endresult.p2 .. "\n" .. endresult.p3)
            --mon.clear()
            --mon.setCursorPos(1,1)
            --mon.write("end results: \n")
            --mon.setCursorPos(1,3)
            --mon.write("1 : " .. endresult.p1 .. " - " .. endresult.p1time / 10 / 5 .. " sec")
            --mon.setCursorPos(1,5)
            --mon.write("2 : " .. endresult.p2 .. " - " .. endresult.p2time / 10 / 5 .. " sec")
            --mon.setCursorPos(1,7)
            --mon.write("3 : " .. endresult.p3 .. " - " .. endresult.p3time / 10 / 5 .. " sec")

        elseif fplayers == 2 then
            p1 = min({players[1].ftime,players[2].ftime})
            if players[1].ftime == p1 then
                endresult.p1 = players[1].player
                endresult.p1time = players[1].ftime
            else
                endresult.p2time = players[1].ftime
                endresult.p2 = players[1].player          
            end
            if players[2].ftime == p1 then
                endresult.p1 = players[2].player
                endresult.p1time = players[2].ftime
            else
                endresult.p2 = players[2].player
                endresult.p2time = players[2].ftime          
            end
            cb.sendMessage("end results: \n" .. endresult.p1 .. "\n" .. endresult.p2)
            --mon.clear()
            --mon.setCursorPos(1,1)
            --mon.write("end results: \n")
            --mon.setCursorPos(1,3)
            --mon.write("1 : " .. endresult.p1 .. " - " .. endresult.p1time / 10 / 5 .. " sec")
            --mon.setCursorPos(1,5)
            --mon.write("2 : " .. endresult.p2 .. " - " .. endresult.p2time / 10 / 5 .. " sec")

        elseif fplayers == 1 then
            endresult.p1 = players[1].player
            endresult.p1time = players[1].ftime
            cb.sendMessage("end results: \n" .. endresult.p1)
            --mon.clear()
            --mon.setCursorPos(1,1)
            --mon.write("end results: \n")
            --mon.setCursorPos(1,3)
            --mon.write("1 : " .. endresult.p1 .. " - " .. endresult.p1time / 10 / 5 .. " sec")
        end
        racersold = get_racer_data()
        local racersfile = fs.open("racers.json","w+")
        for _,a in pairs(players) do
            if a.player == "x" then
            else
                exists = false
                --print(a.player)
                for x,b in pairs(racersold[1]) do
                    if a.player == b.name and racersold[1][a.player][tr] then
                        basalt.LOGGER.debug("a")
                        ftime = a.ftime / 5
                        s1time = a.s1time 
                        s2time = a.s2time 
                        s3time = a.s3time
                        exists = true
                        if s1time < b[tr].best_s1 then
                            --print("new s1 pb")
                            racersold[1][x][tr].best_s1 = a.s1time       
                        end
                        if s2time < b[tr].best_s2 then
                            --print("new s2 pb")
                            racersold[1][x][tr].best_s2 = a.s2time        
                        end
                        if s3time < b[tr].best_s3 then
                            --print("new s3 pb")
                            racersold[1][x][tr].best_s3 = a.s3time
                        end
                        if ftime < racersold[1][x][tr].best_lap then
                            --print("new lap pb")
                            racersold[1][x][tr].best_lap = ftime
                        end
                        racersold[1][x][tr].h_s1[3] = racersold[1][x][tr].h_s1[2]
                        racersold[1][x][tr].h_s1[2] = racersold[1][x][tr].h_s1[1]
                        racersold[1][x][tr].h_s1[1] = s1time

                        racersold[1][x][tr].h_s2[3] = racersold[1][x][tr].h_s2[2]
                        racersold[1][x][tr].h_s2[2] = racersold[1][x][tr].h_s2[1]
                        racersold[1][x][tr].h_s2[1] = s2time

                        racersold[1][x][tr].h_s3[3] = racersold[1][x][tr].h_s3[2]
                        racersold[1][x][tr].h_s3[2] = racersold[1][x][tr].h_s3[1]
                        racersold[1][x][tr].h_s3[1] = s3time

                        racersold[1][x][tr].h_lap[3] = racersold[1][x][tr].h_lap[2]
                        racersold[1][x][tr].h_lap[2] = racersold[1][x][tr].h_lap[1]
                        racersold[1][x][tr].h_lap[1] = ftime
                    elseif a.player == b.name and not racersold[1][a.player][tr] then
                        exists = true
                        basalt.LOGGER.debug("b")
                        racersold[1][a.player][tr] = {"a"}
                        ftime = a.ftime / 5
                        s1time = a.s1time 
                        s2time = a.s2time
                        s3time = a.s3time
                        track_new_racer_lap[tr] = track_new_racer_lap[tr] + 1
                        track_new_racer_s1[tr] = track_new_racer_s1[tr] + 1
                        track_new_racer_s2[tr] = track_new_racer_s2[tr] + 1
                        track_new_racer_s3[tr] = track_new_racer_s3[tr] + 1
                        track_data = {best_lap = ftime, best_s1 = s1time, best_s2 = s2time, best_s3 = s3time, h_s1 = {s1time,0,0}, h_s2 = {s2time,0,0}, h_s3 = {s3time,0,0}, h_lap = {ftime,0,0}}
                        racersold[1][a.player][tr] = track_data
                    end
                end
                if exists == false then
                    basalt.LOGGER.debug("c")
                    ftime = a.ftime / 5
                    s1time = a.s1time 
                    s2time = a.s2time
                    s3time = a.s3time
                    track_data = {best_lap = ftime, best_s1 = s1time, best_s2 = s2time, best_s3 = s3time, h_s1 = {s1time,0,0}, h_s2 = {s2time,0,0}, h_s3 = {s3time,0,0}, h_lap = {ftime,0,0}}
                    track_new_racer_lap[tr] = track_new_racer_lap[tr] + 1
                    track_new_racer_s1[tr] = track_new_racer_s1[tr] + 1
                    track_new_racer_s2[tr] = track_new_racer_s2[tr] + 1
                    track_new_racer_s3[tr] = track_new_racer_s3[tr] + 1
                    racersold[1][a.player] = {name = a.player}
                    if not racersold[1][a.player][tr] then
                        racersold[1][a.player][tr] = {}
                    end
                    racersold[1][a.player][tr] = track_data
                end
            end
        end
        racers = racersold
        racersfile.write(textutils.serializeJSON(racers))
        racersfile.close()
    else
        cb.sendMessage("please select a track and at least 1 player")
    end
    end)



basalt.run()
