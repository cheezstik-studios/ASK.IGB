#!/bin/sh

echo "$1" | grep -Eo '^[[:alnum:]_]*'

