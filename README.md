# Docker + Vim = DrVim

A dockerized image of my typical development environment.

## Language Support
-[x] Python
-[x] Javascript/Typescript
-[] Ruby

## Build for you!

The default container user is `drvim`.
You'll want to make a build for your development user so the container user/group id matches the you
local user/group id.

```bash
make me
```

See the `Makefile` for how your user is passed through to docker build.
