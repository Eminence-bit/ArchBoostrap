#!/bin/bash

# Yazi file manager launcher script

# Launch yazi in a floating kitty window
kitty --class="yazi-float" --title="File Manager" yazi "$@"