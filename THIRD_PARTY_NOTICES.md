# Third-party notices

The deployment files in this repository are licensed under GPL-3.0-or-later.
Packages and game assets distributed in the container retain their upstream
licenses and copyright notices.

| Component | License | Source and notices |
| --- | --- | --- |
| Alpine Linux base image and dependencies | Varies by package | [Alpine base image](https://github.com/alpinelinux/docker-alpine) · [Alpine 3.24 package recipes and patches](https://gitlab.alpinelinux.org/alpine/aports/-/tree/3.24-stable) |
| `supertuxkart-server` | GPL-3.0-or-later | [SuperTuxKart license](https://github.com/supertuxkart/stk-code/blob/1.5/COPYING) · [Alpine build recipe and source URLs](https://gitlab.alpinelinux.org/alpine/aports/-/tree/3.24-stable/community/supertuxkart) |
| `supertuxkart-data` | See the individual asset licenses and credits | [SuperTuxKart 1.5 source and assets](https://github.com/supertuxkart/stk-code/releases/tag/1.5) |
| `bash` | GPL-3.0-or-later | [Alpine package](https://pkgs.alpinelinux.org/package/v3.24/main/x86/bash) · [Alpine build recipe and source URLs](https://gitlab.alpinelinux.org/alpine/aports/-/tree/3.24-stable/main/bash) |
| `ca-certificates` | MPL-2.0 AND MIT | [Alpine package](https://pkgs.alpinelinux.org/package/v3.24/main/x86/ca-certificates) · [Alpine build recipe and source URLs](https://gitlab.alpinelinux.org/alpine/aports/-/tree/3.24-stable/main/ca-certificates) |
| `libxml2-utils` | MIT | [Alpine package](https://pkgs.alpinelinux.org/packages?arch=x86_64&branch=v3.24&name=libxml2-utils) · [Alpine build recipe and source URLs](https://gitlab.alpinelinux.org/alpine/aports/-/tree/3.24-stable/main/libxml2) |

Run `apk info -vv` inside the container to list the installed package versions.
The Alpine package recipes identify the upstream sources and packaging
patches. SuperTuxKart's source archive includes the license and credit files
for the individual game assets.
