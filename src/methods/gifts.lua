--- gifts API methods.
-- @module telegram-bot-lua.methods.gifts
return function(api)
    local config = require('telegram-bot-lua.config')

    --- get the list of gifts received by a user.
    -- @param user_id number unique identifier of the target user
    -- @return table|false the user gifts object, or false on failure
    -- @return string|table the HTTP status or error details
    function api.get_user_gifts(user_id)
        local success, res = api.request(config.endpoint .. api.token .. '/getUserGifts', {
            ['user_id'] = user_id
        })
        return success, res
    end

    --- get the list of gifts that can be sent by the bot.
    -- @return table|false the available gifts object, or false on failure
    -- @return string|table the HTTP status or error details
    function api.get_available_gifts()
        local success, res = api.request(config.endpoint .. api.token .. '/getAvailableGifts')
        return success, res
    end

    --- send a gift to a user.
    -- @param user_id number unique identifier of the target user
    -- @param gift_id string identifier of the gift to send
    -- @param opts table optional parameters (text, text_parse_mode, pay_for_upgrade)
    -- @return table|false true on success, or false on failure
    -- @return string|table the HTTP status or error details
    function api.send_gift(user_id, gift_id, opts)
        opts = opts or {}
        local success, res = api.request(config.endpoint .. api.token .. '/sendGift', {
            ['user_id'] = user_id,
            ['gift_id'] = gift_id,
            ['text'] = opts.text,
            ['text_parse_mode'] = opts.text_parse_mode,
            ['pay_for_upgrade'] = opts.pay_for_upgrade
        })
        return success, res
    end
end
