#!/bin/sh
rm -f lib/*.js && rm -f bin/*.js && node_modules/.bin/coffee -b -c lib/ bin/