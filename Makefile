build: .local/fennel
	./local/fennel --compile main.fnl > main.lua

test: .local/ .local/busted/
	.local/busted/bin/busted

clean:
	rm -rf .local/
	cd fennel && make clean
	cd fnlfmt && make clean

lint: .local/fnlfmt
	.local/fnlfmt/bin/fnlfmt --fix main.fnl

.local/:
	mkdir .local

.local/busted/: .local/ busted/
	cd busted && luarocks --tree ../.local/busted/ make

busted/:
	git submodule update busted

.local/fennel: .local/ fennel/
	cd fennel && make fennel && mv fennel ../.local/fennel

fennel/:
	git submodule update  fennel

.local/fnlfmt: .local/ fnlfmt/
	cd fnlfmt && PREFIX="../.local/fnlfmt" make install

fnlfmt/:
	git submodule update fnlfmt