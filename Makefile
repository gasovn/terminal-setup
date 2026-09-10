.PHONY: test test-integration

test:
	@luajit tests/wezterm-session/run.lua

test-integration:
	@bash tests/wezterm-session/integration/run.sh
