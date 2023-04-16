local weather = "EXTRASUNNY" -- Default weather
local time = 0 


local mysql = exports["mysql-async"]
mysql:execute("CREATE TABLE IF NOT EXISTS server_settings (id INT AUTO_INCREMENT PRIMARY KEY, weather VARCHAR(32), time INT)")


mysql:execute("SELECT * FROM server_settings LIMIT 1", {}, function(result)
    if result[1] then
        weather = result[1].weather
        time = result[1].time
        TriggerClientEvent("syncTimeWeather", -1, time, weather)
    end
end)


RegisterServerEvent("syncTimeWeather")
AddEventHandler("syncTimeWeather", function(newTime, newWeather)
    time = newTime
    weather = newWeather
    mysql:execute("UPDATE server_settings SET weather = @weather, time = @time WHERE id = 1", {["@weather"] = weather, ["@time"] = time})
    TriggerClientEvent("syncTimeWeather", -1, time, weather)
end)


AddEventHandler("chatMessage", function(source, author, message)
    if message:sub(1, 6) == "/time " then
        local newTime = tonumber(message:sub(7))
        if newTime and newTime >= 0 and newTime <= 23 then
            time = newTime
            mysql:execute("UPDATE server_settings SET time = @time WHERE id = 1", {["@time"] = time})
            TriggerClientEvent("syncTimeWeather", -1, time, weather)
        end
    elseif message:sub(1, 8) == "/weather " then
        local newWeather = message:sub(9)
        if newWeather then
            weather = newWeather
            mysql:execute("UPDATE server_settings SET weather = @weather WHERE id = 1", {["@weather"] = weather})
            TriggerClientEvent("syncTimeWeather", -1, time, weather)
        end
    end
end)
