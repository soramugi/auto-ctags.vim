#!/bin/bash

rm -f /tmp/.X99-lock && \
    /usr/bin/Xvfb :99 & \
    while [ ! -f /tmp/.X99-lock ]; do sleep 1; done

bundle exec rake
