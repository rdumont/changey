#!/bin/sh
mocha test/*.coffee --compilers coffee:coffee-script/register --reporter spec "$@"