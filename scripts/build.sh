#!/bin/sh
echo 'Removing old compiled .js files...'
rm -f lib/*.js
rm -f bin/*.js
echo 'Compiling coffee files...'
node_modules/.bin/coffee -b -c lib/ bin/
echo 'Prepending shebang to bin file...'
sed -i '1s;^;#!/usr/bin/env node\n;' bin/cli.js
