#!/bin/sh

LUAROCKS_SYSCONFDIR='/etc/luarocks' exec '/usr/bin/lua5.3' -e \
  'package.path="/home/timb/workbench/cryptopals/lua_modules/share/lua/5.3/?.lua;/home/timb/.luarocks/share/lua/5.3/?.lua;/home/timb/.luarocks/share/lua/5.3/?/init.lua;/usr/local/share/lua/5.3/?.lua;/usr/local/share/lua/5.3/?/init.lua;"..package.path;package.cpath="/home/timb/workbench/cryptopals/lua_modules/lib/lua/5.3/?.so;/home/timb/.luarocks/lib/lua/5.3/?.so;/usr/local/lib/lua/5.3/?.so;"..package.cpath' $([ "$*" ] || echo -i) "$@"
