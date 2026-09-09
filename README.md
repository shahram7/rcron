# rcron

`rcron` combines the official [rclone image](https://hub.docker.com/r/rclone/rclone) with [crontab-ui](https://github.com/alseambusher/crontab-ui). It exposes crontab-ui on port 8000 and makes `rclone` available to every scheduled job.

## Run locally

```sh
docker compose up --build -d
```

Open `http://localhost:8000`, then create jobs such as:

```sh
rclone sync /data remote:backup --config /config/rclone/rclone.conf
```

The named volumes preserve both rclone configuration (`/config`) and crontab-ui data (`/rcron-data`). For credentials, use a `.env` file or your deployment platform's secret mechanism; do not commit it. Set `BASIC_AUTH_USER` and `BASIC_AUTH_PWD` before exposing the web UI beyond a trusted network.

## Publish with GitHub Actions

Create a GitHub repository named `rcron` and upload these wrapper files, excluding the `rclone` and `crontab-ui` clone directories. Make `main` its default branch. In repository settings, enable GitHub Actions **Read and write permissions**.

The publish workflow sends images to:

```text
ghcr.io/YOUR-GITHUB-USER/rcron:latest
```

Every six hours, the update workflow records the latest commits from rclone and crontab-ui in `upstream.lock`. A changed lock file triggers a fresh image build and publish. The rclone runtime base is also pulled fresh for every published build.

```sh
docker run -d --name rcron -p 8000:8000 \
  -e BASIC_AUTH_USER=admin -e BASIC_AUTH_PWD=change-me \
  -v rclone-config:/config -v rcron-data:/rcron-data \
  ghcr.io/YOUR-GITHUB-USER/rcron:latest
```
