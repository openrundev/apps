# OpenRun Applications

OpenRun is a web server which makes self-hosting Hypermedia driven web applications easy. See https://openrun.dev/ for details.

https://github.com/openrundev/openrun is the main OpenRun repository. This `apps` repository contains Hypermedia driven web apps which can be installed on a OpenRun server.

To [install OpenRun](https://openrun.dev/docs/installation/), run:

```
curl -L https://openrun.dev/install.sh | sh
# Note down the generated password
source $HOME/clhome/bin/openrun.env
openrun server start &
```

After OpenRun service is started, an app can be installed by running:

```
openrun app create --approve https://github.com/openrundev/apps/utils/bookmarks/ /bookmarks
openrun app create --approve https://github.com/openrundev/apps/system/disk_usage /system/disk_usage
openrun app create --approve https://github.com/openrundev/apps/system/memory_usage /system/memory_usage
```

The apps will be available at the requested url, like https://localhost:25223/bookmarks. Use `admin` as the username and the password displayed when the OpenRun server was installed. To disable password auth for the ap, add the `--auth none` option to the `app create` command. To change existing app auth, run `openrun app update-settings auth none /bookmarks`.

To reload existing apps with any code changes from GitHub, run

```
openrun app reload --promote /bookmarks # reload one app from latest code in GitHub
openrun app reload --promote all # reload all apps from latest code in GitHub
```

See [lifecycle](https://openrun.dev/docs/applications/lifecycle/) for details on app lifecycle. If application requires new [permissions](https://openrun.dev/docs/applications/appsecurity/), approve by running `openrun app approve /utils/bookmarks` or add `--approve` to the reload command.

# Application Listing

|     App Name     |                  Install Url                  |                        Description                         |             System Requirements             | Demo                                  |
| :--------------: | :-------------------------------------------: | :--------------------------------------------------------: | :-----------------------------------------: | :------------------------------------ |
| Bookmark Manager |   `github.com/openrundev/apps/utils/bookmarks`   | A bookmark manager app, using sqlite for data persistenace |                All platforms                | https://utils.demo.openrun.dev/bookmarks |
|    Disk Usage    |  `github.com/openrundev/apps/system/disk_usage`  |         Disk space usage monitor, with drill down          |                All platforms                | https://du.demo.openrun.dev/             |
|   Memory Usage   | `github.com/openrundev/apps/system/memory_usage` |      Memory usage monitor, grouped by parent process       | Linux, OSX, Windows with WSL. Uses `ps` cli | https://memory.demo.openrun.dev/         |
