#!/usr/bin/env bash

mkcd() {
	mkdir "$1" && cd "$1" || return
}
