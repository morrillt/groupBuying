#!/usr/bin/env bash

source $HOME/.rvm/scripts/rvm && source .rvmrc
RAILS_ENV=test rake cruise
