## Bookmark Manager App

This is a OpenRun app to manage bookmarks. To install, run

```shell
openrun app create --approve github.com/openrundev/apps/utils/bookmarks /book
```

The app should be installed to `https://localhost:25223/book`. To disable authentication for the app, run

```shell
openrun app update auth none /book
```

or add `--auth none` in the `app create` command.

The data is persisted to a sqlite database, at `$CL_HOME/openrun_app.db` by default. The database tables are automatically created on first access.

The app uses [DaisyUI](https://daisyui.com/) (component library for TailwindCSS). If running in `--dev` mode, see [config](https://openrun.dev/docs/app/styling/#tailwindcss) for tailwind config required.

The app uses [automatic error handling](https://openrun.dev/docs/plugins/overview/#automatic-error-handling), all errors are automatically displayed on the UI.

## Code Layout

- app.star : The starlark config for the app
- schema.star : The database schema config
- \*.go.html : The go HTML template files
