-- End-to-end integration tests using the real Telegram Bot API
-- Requires a .env file with BOT_TOKEN set
-- Run with: busted --run e2e

-- Load .env file
local function load_env()
    local f = io.open('.env', 'r')
    if not f then return nil end
    local env = {}
    for line in f:lines() do
        local key, value = line:match('^([%w_]+)%s*=%s*(.+)$')
        if key and value then
            env[key] = value
        end
    end
    f:close()
    return env
end

local env = load_env()
if not env or not env.BOT_TOKEN then
    print('Skipping e2e tests: no .env file or BOT_TOKEN not set')
    return
end

_G._TEST = true
package.path = './src/?.lua;./src/?/init.lua;' .. package.path

local module_map = {
    ['telegram-bot-lua'] = 'src/init.lua',
    ['telegram-bot-lua.config'] = 'src/config.lua',
    ['telegram-bot-lua.handlers'] = 'src/handlers.lua',
    ['telegram-bot-lua.builders'] = 'src/builders.lua',
    ['telegram-bot-lua.helpers'] = 'src/helpers.lua',
    ['telegram-bot-lua.tools'] = 'src/tools.lua',
    ['telegram-bot-lua.utils'] = 'src/utils.lua',
    ['telegram-bot-lua.async'] = 'src/async.lua',
    ['telegram-bot-lua.compat'] = 'src/compat.lua',
    ['telegram-bot-lua.core'] = 'src/core.lua',
    ['telegram-bot-lua.polyfill'] = 'src/polyfill.lua',
    ['telegram-bot-lua.b64url'] = 'src/b64url.lua',
    ['telegram-bot-lua.methods.updates'] = 'src/methods/updates.lua',
    ['telegram-bot-lua.methods.messages'] = 'src/methods/messages.lua',
    ['telegram-bot-lua.methods.chat'] = 'src/methods/chat.lua',
    ['telegram-bot-lua.methods.members'] = 'src/methods/members.lua',
    ['telegram-bot-lua.methods.forum'] = 'src/methods/forum.lua',
    ['telegram-bot-lua.methods.stickers'] = 'src/methods/stickers.lua',
    ['telegram-bot-lua.methods.inline'] = 'src/methods/inline.lua',
    ['telegram-bot-lua.methods.payments'] = 'src/methods/payments.lua',
    ['telegram-bot-lua.methods.games'] = 'src/methods/games.lua',
    ['telegram-bot-lua.methods.passport'] = 'src/methods/passport.lua',
    ['telegram-bot-lua.methods.bot'] = 'src/methods/bot.lua',
    ['telegram-bot-lua.methods.gifts'] = 'src/methods/gifts.lua',
    ['telegram-bot-lua.methods.checklists'] = 'src/methods/checklists.lua',
    ['telegram-bot-lua.methods.stories'] = 'src/methods/stories.lua',
    ['telegram-bot-lua.methods.suggested_posts'] = 'src/methods/suggested_posts.lua',
    ['telegram-bot-lua.adapters'] = 'src/adapters/init.lua',
    ['telegram-bot-lua.adapters.db'] = 'src/adapters/db.lua',
    ['telegram-bot-lua.adapters.redis'] = 'src/adapters/redis.lua',
    ['telegram-bot-lua.adapters.llm'] = 'src/adapters/llm.lua',
    ['telegram-bot-lua.adapters.email'] = 'src/adapters/email.lua',
}
for mod_name, file_path in pairs(module_map) do
    if not package.preload[mod_name] then
        package.preload[mod_name] = function()
            return dofile(file_path)
        end
    end
end

local api = require('telegram-bot-lua')
api.token = env.BOT_TOKEN

describe('e2e', function()
    describe('bot identity', function()
        it('get_me returns bot info', function()
            local result = api.get_me()
            assert.is_table(result)
            assert.is_true(result.ok)
            assert.is_table(result.result)
            assert.is_true(result.result.is_bot)
            assert.is_string(result.result.first_name)
            assert.is_number(result.result.id)
            assert.is_string(result.result.username)
        end)
    end)

    describe('bot commands', function()
        it('set_my_commands succeeds', function()
            local commands = {
                api.bot_command('start', 'Start the bot'),
                api.bot_command('help', 'Show help')
            }
            local result = api.set_my_commands(commands)
            assert.is_table(result)
            assert.is_true(result.ok)
        end)

        it('get_my_commands returns the commands', function()
            local result = api.get_my_commands()
            assert.is_table(result)
            assert.is_true(result.ok)
            assert.is_table(result.result)
            assert.equals(2, #result.result)
            assert.equals('start', result.result[1].command)
            assert.equals('help', result.result[2].command)
        end)

        it('delete_my_commands succeeds', function()
            local result = api.delete_my_commands()
            assert.is_table(result)
            assert.is_true(result.ok)
        end)

        it('get_my_commands returns empty after delete', function()
            local result = api.get_my_commands()
            assert.is_table(result)
            assert.is_true(result.ok)
            assert.equals(0, #result.result)
        end)
    end)

    describe('bot profile', function()
        local original_description
        local original_short_description

        it('get_my_name returns name', function()
            local result = api.get_my_name()
            assert.is_table(result)
            assert.is_true(result.ok)
            assert.is_table(result.result)
        end)

        it('get_my_description returns description', function()
            local result = api.get_my_description()
            assert.is_table(result)
            assert.is_true(result.ok)
            assert.is_table(result.result)
            original_description = result.result.description or ''
        end)

        it('get_my_short_description returns short description', function()
            local result = api.get_my_short_description()
            assert.is_table(result)
            assert.is_true(result.ok)
            assert.is_table(result.result)
            original_short_description = result.result.short_description or ''
        end)

        it('set_my_description succeeds', function()
            local result = api.set_my_description('E2E test bot description')
            assert.is_table(result)
            assert.is_true(result.ok)
        end)

        it('get_my_description confirms change', function()
            local result = api.get_my_description()
            assert.is_table(result)
            assert.is_true(result.ok)
            assert.equals('E2E test bot description', result.result.description)
        end)

        it('restores original description', function()
            local result = api.set_my_description(original_description)
            assert.is_table(result)
            assert.is_true(result.ok)
        end)

        it('set_my_short_description succeeds', function()
            local result = api.set_my_short_description('E2E short desc')
            assert.is_table(result)
            assert.is_true(result.ok)
        end)

        it('restores original short description', function()
            local result = api.set_my_short_description(original_short_description)
            assert.is_table(result)
            assert.is_true(result.ok)
        end)
    end)

    describe('webhook management', function()
        it('delete_webhook succeeds', function()
            local result = api.delete_webhook()
            assert.is_table(result)
            assert.is_true(result.ok)
        end)

        it('get_webhook_info shows no webhook', function()
            local result = api.get_webhook_info()
            assert.is_table(result)
            assert.is_true(result.ok)
            assert.is_table(result.result)
            assert.equals('', result.result.url)
        end)

        it('set_webhook succeeds', function()
            local result = api.set_webhook('https://example.com/e2e-test-webhook')
            assert.is_table(result)
            assert.is_true(result.ok)
        end)

        it('get_webhook_info confirms webhook', function()
            local result = api.get_webhook_info()
            assert.is_table(result)
            assert.is_true(result.ok)
            assert.is_table(result.result)
            assert.equals('https://example.com/e2e-test-webhook', result.result.url)
        end)

        it('cleans up webhook', function()
            local result = api.delete_webhook()
            assert.is_table(result)
            assert.is_true(result.ok)
        end)
    end)

    describe('error handling', function()
        it('returns error for invalid chat_id', function()
            local result, err = api.send_message(0, 'test')
            assert.is_false(result)
            assert.is_table(err)
            assert.is_number(err.error_code)
        end)

        it('returns error for invalid file_id', function()
            local result, err = api.get_file('invalid_file_id_that_does_not_exist')
            assert.is_false(result)
            assert.is_table(err)
            assert.is_number(err.error_code)
        end)
    end)

    describe('get_updates', function()
        it('returns updates array', function()
            local result = api.get_updates({ timeout = 0, limit = 1 })
            assert.is_table(result)
            assert.is_true(result.ok)
            assert.is_table(result.result)
        end)
    end)

    describe('menu button', function()
        it('get_chat_menu_button returns default', function()
            local result = api.get_chat_menu_button()
            assert.is_table(result)
            assert.is_true(result.ok)
            assert.is_table(result.result)
        end)
    end)

    describe('default administrator rights', function()
        it('get_my_default_administrator_rights returns rights', function()
            local result = api.get_my_default_administrator_rights()
            assert.is_table(result)
            assert.is_true(result.ok)
            assert.is_table(result.result)
        end)
    end)

    describe('star transactions', function()
        it('get_star_transactions returns transactions', function()
            local result = api.get_star_transactions()
            assert.is_table(result)
            assert.is_true(result.ok)
            assert.is_table(result.result)
        end)
    end)
end)
