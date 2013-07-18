#!/usr/bin/env bash

tar czvf – . | (cd ${DESTDIR:=/}; tar zxvf -)
