--- stories API methods.
-- @module telegram-bot-lua.methods.stories
return function(api)
    local config = require('telegram-bot-lua.config')

    --- repost a story to a chat.
    -- @param chat_id string|number unique identifier for the target chat
    -- @param story_id number unique identifier of the story to repost
    -- @return table|false true on success, or false on failure
    -- @return string|table the HTTP status or error details
    function api.repost_story(chat_id, story_id)
        local success, res = api.request(config.endpoint .. api.token .. '/repostStory', {
            ['chat_id'] = chat_id,
            ['story_id'] = story_id
        })
        return success, res
    end
end
