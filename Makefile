build: .local/fennel
	fennel --compile main.fnl > main.lua

test: .local/ .local/busted/
	.local/busted/bin/busted

clean:
	rm -rf .local/
	cd fennel && make clean

run:
	fennel --compile main.fnl > main.lua && ~/lib/love.app/Contents/MacOS/love .

lint:
	fnlfmt --fix main.fnl

.local/:
	mkdir .local

.local/busted/: .local/ busted/
	cd busted && luarocks --tree ../.local/busted/ make

busted/:
	git submodule update --init busted

.local/fennel: .local/ fennel/
	cd fennel && make fennel && mv fennel ../.local/fennel

fennel/:
	git submodule update --init fennel

