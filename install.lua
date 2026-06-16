local startupUrl = "https://raw.githubusercontent.com/turboblitz181/cobblemon-racing/refs/heads/main/startup.lua?token=GHSAT0AAAAAAEAEAEUPRJPZCYYUGWH4L7MI2RRLFMA"


local request = http.get(startupUrl)
if not request then
    print("error getting startup file")
    return
end
local file = fs.open("startup.lua", "w")
file.write(request.readAll())
file.close()
request.close()