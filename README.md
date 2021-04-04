## Descriptions

Batch scripts to upscales ppsspp textures dumps using: https://github.com/JoeyBallentine/ESRGAN (required).

Require ImageMagick: https://imagemagick.org

To be usable you need to edit and configure "UPSCALE PPSSPP Games.bat".

## Features

* The model and settings used should minimize artifacts due to AI upcaling (meaning it is meant to work 'universally' but isn't meant to be the best model/settings for a specific game)

* Automatically creates a backup of both the dump and the upscaled textures
* Check for duplicates and auto-add them to the [hashes] sections

## What it does not

* Organize the texture pack: all upscaled textures will still have the default name and be in the default folder.
* Give the best upscaled texture possible
