# gentoo-x32-docker

Container images for Gentoo **x32 (ILP32, `x86_64` ELF32)** systems. Previously
each image lived on its own git branch; everything now lives on `main`, one
directory per image under `images/`.

## Images

| Directory | Docker Hub tag | Based on |
| --- | --- | --- |
| `images/stage3-openrc` | `kennycheng/gentoo-stage3:x32-openrc` (alias `:x32`) | upstream stage3 tarball |
| `images/stage3-systemd` | `kennycheng/gentoo-stage3:x32-systemd` | upstream stage3 tarball |
| `images/stage4-openrc` | `kennycheng/gentoo-stage4:x32-openrc` | `stage3-openrc` |
| `images/stage4-systemd` | `kennycheng/gentoo-stage4:x32-systemd` | `stage3-systemd` |
| `images/stage4-systemd-xfce4` | `kennycheng/gentoo-stage4:x32-systemd-xfce4` | `stage4-systemd` |
| `images/stage4-systemd-xfce4-overlay` | `kennycheng/gentoo-stage4:x32-systemd-xfce4-overlay` (alias `:x32-systemd-xfce4`) | `stage4-systemd` |
| `images/stage4-systemd-binhost` | `kennycheng/gentoo-stage4:x32-systemd-binhost` (alias `:x32-binhost`) | `stage4-systemd` |

Each directory holds a `Containerfile` and an `image.env` with `IMAGE`, `TAG`
and optional `ALIASES` / `STAGE3_FLAVOR`. The env file is the single source of
truth for both local builds and CI.

### Shared build-host configuration (`images/stage4-common`)

The stage4 images are the daily-use desktop systems whose packages are served
to x32 machines through the binhost. Their build-host portage configuration is
shared in `images/stage4-common/portage/` and copied into every stage4 image:

- `package.use/stage4` — per-package USE flags (desktop, fcitx, pipewire, …)
- `package.accept_keywords/stage4`, `package.mask/stage4`, `package.unmask/`
- `profile/use.mask` — `-efistub` (no EFI stub/UKI on x32)
- `sets/stage4` — world additions built with `emerge @world $(cat …)`

The stage4 Containerfiles bootstrap `dev-vcs/git` with `USE=-rust` (Rust git
cannot link for x32), sync `x32-overlay`, and wire its patch tree into
`/etc/portage/patches` before building `@world`.

Branch → image mapping for the old branches:

- `stage3-openrc` → `images/stage3-openrc` (also `.devcontainer/`)
- `stage3-systemd` → `images/stage3-systemd`
- `stage4` → `images/stage4-openrc`
- `stage4-systemd` → `images/stage4-systemd`
- `stage4-systemd-xfce4` → `images/stage4-systemd-xfce4`
- `x32-systemd-xfce4` → `images/stage4-systemd-xfce4-overlay`
- `stage4-binhost` → `images/stage4-systemd-binhost`

## Local builds

```sh
# stage3 images: fetch the latest upstream tarball first
scripts/fetch-stage3.sh systemd images/stage3-systemd
scripts/build.sh stage3-systemd

# stage4 images build on top of the locally present stage3 tag
scripts/build.sh stage4-systemd            # add --push to upload
```

`scripts/build.sh` honours `CONTAINER_ENGINE` (default `podman`), `MAKEOPTS`,
`EMERGE_DEFAULT_OPTS` and `GENTOO_MIRROR`. It builds with `--pull=newer`; the
layer cache is the engine's own image store (do not pass `--no-cache`).

## CI

`.github/workflows/build-images.yml` runs on a self-hosted Linux runner with
the `podman` label:

- `push` to `main` (changes under `images/`, `scripts/`, `.github/`)
- weekly `schedule`
- manual `workflow_dispatch` with an optional `only` list, e.g.
  `stage4-systemd,stage4-systemd-binhost`

The `stage3` matrix builds and pushes stage3 first; the `stage4` matrix then
builds/pushes the five derived images. Full `@world` builds take hours — the
job timeout is 12 h.

**Persistent runner store, don't clean it.** Build caching relies on the
podman image store on the runner's disk. If you prune images on the runner,
every build starts from zero, and a full stage4 `@world` build takes many
hours.

Required repository secrets (Settings → Secrets and variables → Actions):

- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN` — Docker Hub access token with read/write (not the password)

### Runner notes

- The runner runs as the `kenny` user with rootless podman; no root required.
- Run it from a terminal multiplexer (`tmux new -s runner 'cd ~/actions-runner && ./run.sh'`)
  or via an OpenRC service (`./svc.sh` only supports systemd/launchd).
- **Security:** the repository is public. Never trigger builds from
  `pull_request` events on a self-hosted runner — fork PRs would execute
  arbitrary code with your Docker Hub credentials.
