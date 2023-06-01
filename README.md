# Fennel LÖVE Test

Just trying out [fennel-lang](https://fennel-lang.org/)
by making a game with [LÖVE](https://love2d.org/)

# Dependencies

* [Lua 5.4.6](https://www.lua.org/ftp/)
* [LuaRocks](https://github.com/luarocks/luarocks/wiki/Download#installing)
* [LÖVE 11.4](https://github.com/love2d/love/releases)
* [Tiled](https://www.mapeditor.org/)

# Building

```
make build
```

# Running 

Where `<LoveBin>` is the path to your LÖVE binary, e.g. `/Applications/love.app/Contents/MacOS/love`

```
<LoveBin> src
```

To do a build and run in one step you may do something like:
```
make build && love src
```





