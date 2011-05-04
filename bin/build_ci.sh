#!/usr/bin/env bash

source $HOME/.rvm/scripts/rvm && source .rvmrc
bundle
RAILS_ENV=test rake cruise
