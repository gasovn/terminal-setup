-- Workaround: Kitty keyboard protocol + non-Latin layouts in WezTerm.
--
-- WezTerm bug: for non-Latin keys, Shift stays in modifiers even though
-- the character is already resolved. Example:
--   Latin Shift+f  → key='F', mods=NONE (Shift consumed)
--   Cyrillic Shift+ф → key='А', mods=SHIFT (Shift NOT consumed)
--
-- This causes Kitty protocol to encode Shift as a modifier, and apps
-- (Claude Code, Fish) either can't parse it or apply wrong shift rules.
--
-- Fix: intercept these keys before Kitty encoding, send character as UTF-8.
--
-- See: WezTerm #1746, #2546; Claude Code #3015, #17040
-- Remove this file when WezTerm fixes Shift consumption for non-Latin layouts.

local wezterm = require 'wezterm'
local act = wezterm.action
local M = {}

function M.apply(config)
    -- Cyrillic uppercase letters (Shift + letter)
    -- WezTerm reports key=Char('А'), mods=SHIFT for Shift+а
    local upper = {
        'А', 'Б', 'В', 'Г', 'Д', 'Е', 'Ё',
        'Ж', 'З', 'И', 'Й', 'К', 'Л', 'М',
        'Н', 'О', 'П', 'Р', 'С', 'Т', 'У',
        'Ф', 'Х', 'Ц', 'Ч', 'Ш', 'Щ', 'Ъ',
        'Ы', 'Ь', 'Э', 'Ю', 'Я',
    }

    for _, ch in ipairs(upper) do
        table.insert(config.keys, {
            key = 'mapped:' .. ch,
            mods = 'SHIFT',
            action = act.SendString(ch),
        })
    end

    -- Russian number row: Shift+digit produces different symbols than English.
    -- Same bug: key=Char(';'), mods=SHIFT for Shift+4 — Shift not consumed.
    -- phys: prefix can't be used here — it matches BOTH layouts because
    -- WezTerm checks raw modifiers (Shift always present when physically held).
    -- Use mapped: which only matches the resolved character from the layout.
    -- Note: mapped: may not work for ASCII punctuation (;, :) — known limitation.
    local ru_numrow = {
        '№',  -- Shift+3 (EN: #, RU: №)
        '"',  -- Shift+2 (EN: @, RU: ")
        '?',  -- Shift+7 (EN: &, RU: ?)
    }

    for _, ch in ipairs(ru_numrow) do
        table.insert(config.keys, {
            key = 'mapped:' .. ch,
            mods = 'SHIFT',
            action = act.SendString(ch),
        })
    end

    -- Ctrl + Cyrillic: remap to Ctrl + Latin equivalent (by QWERTY position).
    -- In Kitty protocol, Ctrl+с (Cyrillic) encodes as Ctrl+U+0441, which apps
    -- (Claude Code, Fish) can't interpret. Send raw control code (0x01-0x1A)
    -- corresponding to the Latin letter at the same physical key position.
    local cyrillic_to_latin = {
        ['й'] = 'q', ['ц'] = 'w', ['у'] = 'e', ['к'] = 'r', ['е'] = 't',
        ['н'] = 'y', ['г'] = 'u', ['ш'] = 'i', ['щ'] = 'o', ['з'] = 'p',
        ['ф'] = 'a', ['ы'] = 's', ['в'] = 'd', ['а'] = 'f', ['п'] = 'g',
        ['р'] = 'h', ['о'] = 'j', ['л'] = 'k', ['д'] = 'l',
        ['я'] = 'z', ['ч'] = 'x', ['с'] = 'c', ['м'] = 'v', ['и'] = 'b',
        ['т'] = 'n', ['ь'] = 'm',
    }

    for cyr, lat in pairs(cyrillic_to_latin) do
        local ctrl_code = string.byte(lat) - string.byte('a') + 1
        table.insert(config.keys, {
            key = 'mapped:' .. cyr,
            mods = 'CTRL',
            action = act.SendString(string.char(ctrl_code)),
        })
    end
end

return M
