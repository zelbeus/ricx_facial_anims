----------------------------MENU----------------------------
MenuData = {}
if Config.framework == "rsg" then
    TriggerEvent("rsg-menubase:getData",function(call)
        MenuData = call
end)
elseif Config.framework == "redemrp" then
    TriggerEvent("redemrp_menu_base:getData",function(call)
        MenuData = call
end)
end
----------------------------END MENU----------------------------
local fa = {}
local function CreateFacialAnims()
    for i,v in pairs(Config.facial_anims) do 
        if not fa[v[2]] then 
            fa[v[2]] = {
                id = v[2],
                items = {}
            }
        end
        fa[v[2]].items[#fa[v[2]].items+1] = v[1]
    end
end
--------------------------------------------------------------------------------------------------------------------------------------------
local function GetFacialAnimDictLabel(dict)
    return Config.animDicts[dict] or dict
end
--------------------------------------------------------------------------------------------------------------------------------------------
local function StartFacialAnim(anim)
    RequestAnimDict(anim[1])
    while not HasAnimDictLoaded(anim[1]) do 
        Wait(1)
    end
    SetFacialIdleAnimOverride(PlayerPedId(), anim[2], anim[1])
end
--------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    CreateFacialAnims()
end)

RegisterCommand("face_anims",function(src,args,raw)
    TriggerEvent("ricx_facial_anims:menu")
end)
--------------------------------------------------------------------------------------------------------------------------------------------
local created = nil
RegisterNetEvent("ricx_facial_anims:menu", function()
    MenuData.CloseAll()
    menuOpen = true
    local elements = {}

    if not created then 
        elements[1] = {label = "Clear Animation", value = "clear", desc = "Reset Facial Animation"}

        for i,v in pairs(fa) do 
            elements[#elements+1] = {label = GetFacialAnimDictLabel(v.id), value = v.id, desc = "Open Category"}
        end
        created = elements
    else
        elements = created
    end

    MenuData.Open('default', GetCurrentResourceName(), 'ricx_facial_anims',{
         title    = "Facial Anims",
         subtext    = "Categories",
         align    = "top-right",
         elements = elements,
     },
     function(data, menu)
        if data.current.value then
            if data.current.value ~= "clear" then  
                TriggerEvent("ricx_facial_anims:menu_category", data.current.value)
            else
                ClearFacialIdleAnimOverride(PlayerPedId())
            end
        end
     end,
     function(data, menu)
        menuOpen = false
        menu.close()
     end)
end)
--------------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("ricx_facial_anims:menu_category", function(id)
    MenuData.CloseAll()
    menuOpen = true
    local elements = {}

    for i,v in pairs(fa[id].items) do 
        elements[#elements+1] = {label = Config.VariationLabels[v] or v, value = {id, v}, desc = "Play Facial Anim"}
    end

    MenuData.Open('default', GetCurrentResourceName(), 'ricx_facial_anims2',{
         title    = "Facial Anims",
         subtext    = GetFacialAnimDictLabel(id),
         align    = "top-right",
         elements = elements,
     },
     function(data, menu)
        if data.current.value then 
            StartFacialAnim(data.current.value)
        end
     end,
     function(data, menu)
        TriggerEvent("ricx_facial_anims:menu")
     end)
end)
--------------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("ricx_facial_anims:", function()

end)
--------------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
	  return
	end
    if menuOpen then 
        MenuData.CloseAll()
    end
end)
--------------------------------------------------------------------------------------------------------------------------------------------
