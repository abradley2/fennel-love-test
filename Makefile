build: .local/fennel .local/busted/
	.local/fennel --compile src/systems/cursor.fnl > src/systems/cursor.lua
	.local/fennel --compile src/systems/hire_cursor.fnl > src/systems/hire_cursor.lua
	.local/fennel --compile src/systems/cleanup.fnl > src/systems/cleanup.lua
	.local/fennel --compile src/systems/entity_death.fnl > src/systems/entity_death.lua
	.local/fennel --compile src/systems/movement.fnl > src/systems/movement.lua
	.local/fennel --compile src/systems/touch_damage.fnl > src/systems/touch_damage.lua
	.local/fennel --compile src/systems/action_animation.fnl > src/systems/action_animation.lua
	.local/fennel --compile src/systems/shove.fnl > src/systems/shove.lua
	.local/fennel --compile src/util.fnl > src/util.lua
	.local/fennel --compile src/enemy.fnl > src/enemy.lua
	.local/fennel --compile src/world.fnl > src/world.lua
	.local/fennel --compile src/player.fnl > src/player.lua
	.local/fennel --compile src/main.fnl > src/main.lua
	.local/fennel --compile src/map/map_50_50.fnl > src/map/map_50_50.lua
	.local/fennel --compile src/map/map_50_51.fnl > src/map/map_50_51.lua

lint: .local/fnlfmt
	.local/fnlfmt/bin/fnlfmt --fix src/systems/cursor.fnl
	.local/fnlfmt/bin/fnlfmt --fix src/systems/hire_cursor.fnl
	.local/fnlfmt/bin/fnlfmt --fix src/systems/cleanup.fnl
	.local/fnlfmt/bin/fnlfmt --fix src/systems/entity_death.fnl
	.local/fnlfmt/bin/fnlfmt --fix src/systems/movement.fnl
	.local/fnlfmt/bin/fnlfmt --fix src/systems/touch_damage.fnl
	.local/fnlfmt/bin/fnlfmt --fix src/systems/action_animation.fnl
	.local/fnlfmt/bin/fnlfmt --fix src/systems/shove.fnl
	.local/fnlfmt/bin/fnlfmt --fix src/util.fnl
	.local/fnlfmt/bin/fnlfmt --fix src/enemy.fnl
	.local/fnlfmt/bin/fnlfmt --fix src/world.fnl
	.local/fnlfmt/bin/fnlfmt --fix src/player.fnl
	.local/fnlfmt/bin/fnlfmt --fix src/main.fnl
	.local/fnlfmt/bin/fnlfmt --fix src/map/map_50_50.fnl
	.local/fnlfmt/bin/fnlfmt --fix src/map/map_50_51.fnl

test: .local/ .local/busted/
	.local/busted/bin/busted src

clean:
	rm -rf .local/
	cd fennel && make clean
	cd fnlfmt && make clean

.local/:
	mkdir .local

.local/busted/: .local/ busted/.gitignore
	cd busted && luarocks --tree ../.local/busted/ make

busted/.gitignore:
	git submodule update --init busted 

.local/fennel: .local/ fennel/.gitignore
	cd fennel && make fennel && mv fennel ../.local/fennel

fennel/.gitignore:
	git submodule update --init fennel 

.local/fnlfmt: .local/ fnlfmt/.gitignore
	cd fnlfmt && PREFIX="../.local/fnlfmt" make install

fnlfmt/.gitignore:
	git submodule update --init fnlfmt 