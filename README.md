# Xdebug-mode

This major mode is targeted to analyze a given
machine readable xdebug file and supports the
following features:

* show/hide all lines belonging to the current callstack level


## Show/Hiding functionality

* Hide (C-h/xdebug-hide-call-level-at-cursor): This will hide all lines that belong to the same call
stack level or above as defined by the number at the beginning of the line until the first tab
WARNING: Depending how far down the callstack the current line is finding the whole area to hide might
take some time

* Show (C-s/xdebug-show-overlay-again): This will display all the lines hidden by the overlay at the cursor
point again. This will include sub-overlays that were swallowed by the bigger one referenced by the 
current cursor position
