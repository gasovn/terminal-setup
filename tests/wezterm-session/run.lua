package.path = 'configs/wezterm/?.lua;tests/wezterm-session/?.lua;' .. package.path

local harness = require 'harness'

require 'test_layout'

harness.report()
