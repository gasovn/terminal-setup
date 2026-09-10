package.path = 'configs/wezterm/?.lua;tests/wezterm-session/?.lua;' .. package.path

local harness = require 'harness'

require 'test_layout'
require 'test_snapshot'
require 'test_store'
require 'test_restore'

harness.report()
