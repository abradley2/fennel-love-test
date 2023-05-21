build:
	fennel --compile main.fnl > main.lua

run:
	fennel --compile main.fnl > main.lua && ~/lib/love.app/Contents/MacOS/love .

lint:
	fnlfmt --fix main.fnl