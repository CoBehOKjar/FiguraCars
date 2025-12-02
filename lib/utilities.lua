local Utility = {}

function Utility.getVehicleType(v)
    if not v then return "none" end

    local t = v:getType()

    if t == "minecraft:bamboo_raft" then return "raft" end

    if t == "minecraft:oak_boat" then return "boat" end
    if t == "minecraft:birch_boat" then return "boat" end
    if t == "minecraft:spruce_boat" then return "boat" end
    if t == "minecraft:jungle_boat" then return "boat" end
    if t == "minecraft:dark_oak_boat" then return "boat" end
    if t == "minecraft:mangrove_boat" then return "boat" end
    if t == "minecraft:cherry_boat" then return "boat" end
    if t == "minecraft:pale_oak_boat" then return "boat" end

    if t == "minecraft:horse" then return "horse" end
    if t == "minecraft:donkey" then return "donkey" end
    if t == "minecraft:mule" then return "mule" end
    if t == "minecraft:camel" then return "camel" end

    if t == "minecraft:pig" then return "pig" end
    if t == "minecraft:strider" then return "strider" end

    if t == "minecraft:minecart" then return "minecart" end

    return "unknown"
end

return Utility