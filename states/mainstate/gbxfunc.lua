local gbxfunc = {}

function gbxfunc.isAChallenge(cid)
    if (cid.engine == '03' and cid.class == '043' and cid.chunk == '000') or (cid.engine == '24' and cid.class == '003' and cid.chunk == '000') then return true else return false end
end

function gbxfunc.saveCampaign(button)
    for i=1, 3 do
        if string.len(button.parent.children[i].value) < 1 then return end
    end
    local challenges = button.parent.challenges
    local collection = ""
    for k,flag in ipairs(challenges) do
        for l,chall in ipairs(flag) do
            collection = chall.userdata[2].trackmeta.collection
        end
    end
    local params = {}
    params.name = button.parent.children[1].value
    params.ident = button.parent.children[2].value
    params.collection = collection
    params.index = tonumber(button.parent.children[3].value)
    params.icon = button.parent.children[2].value
    params.unlockorder = button.parent.children[4].selected - 1
    _GLibs.gbx.saveCampaign(challenges, params)
    if button.parent.children[5].value then
        love.system.openURL(love.filesystem.getSaveDirectory())
    end
    button.parent.shown = false
end

return gbxfunc
