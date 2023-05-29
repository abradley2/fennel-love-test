build: .local/fennel .local/busted/
	.local/fennel --compile src/world.fnl > src/world.lua
	.local/fennel --compile src/player.fnl > src/player.lua
	.local/fennel --compile src/player_spec.fnl > src/player_spec.lua
	.local/fennel --compile src/main.fnl > src/main.lua
	.local/busted/bin/busted src

lint: .local/fnlfmt
	.local/fnlfmt/bin/fnlfmt --fix src/world.fnl
	.local/fnlfmt/bin/fnlfmt --fix src/player.fnl
	.local/fnlfmt/bin/fnlfmt --fix src/player_spec.fnl
	.local/fnlfmt/bin/fnlfmt --fix src/main.fnl

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