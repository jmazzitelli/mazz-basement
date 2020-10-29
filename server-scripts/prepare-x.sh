#!/bin/bash

# This just tells you how to be able to run X apps as another user.

x_cookie="$(xauth list ${DISPLAY} | head -n 1)"

cat <<EOM

X COOKIES FOR DISPLAY [${DISPLAY}]:
$(xauth list ${DISPLAY})

When switching users via su, run this command as the new user to be able to run X apps:

   xauth add ${x_cookie}

EOM
