# OpenRun login page app.
#
# This app is a DEV HARNESS, not a deployed app: it exists so the tailwind
# watcher (dev mode install) generates static/gen/css/style.css for the login
# page markup in index.go.html. The generated CSS and index.go.html are copied
# into the openrun repo (internal/server/login_html/) and embedded into the
# openrun binary, which renders the page itself for apps using system/builtin
# auth. Keep index.go.html renderable by plain html/template: only use
# {{ .Data.* }} values (no app-framework template funcs like static/secret).
#
# Preview routes (install with --dev to get live reload + the tailwind watcher):
#   /        - builtin auth variant
#   /system  - system (admin) auth variant
#   /error   - builtin variant with a failed-login error
#   /expired - expired variant with the "sign in again" link back to the app
#   /expired_nolink - expired variant when no app URL is known

# OpenRun brand themes, copied verbatim from the console app (ui/console
# app.star). Brand greens: light #00C200 (primary), dark #007700 (secondary).
# Base surfaces are green-tinted. Keep in sync with the console.
OPENRUN_THEMES = {
    "openrun-light": {
        "color-scheme": "light",
        "--color-base-100": "#ffffff",  # cards, sidebar
        "--color-base-200": "#f1f6f1",  # page background, green-tinted
        "--color-base-300": "#dce8dc",  # borders, dividers
        "--color-base-content": "#142319",
        "--color-primary": "#00c200",  # brand light green, actions
        "--color-primary-content": "#012d01",
        "--color-secondary": "#007700",  # brand dark green, highlights
        "--color-secondary-content": "#d9ffd6",
        "--color-accent": "#009a66",
        "--color-accent-content": "#f0fff8",
        "--color-neutral": "#1e2b22",
        "--color-neutral-content": "#eef5ee",
        "--color-info": "#0b6bcb",
        "--color-info-content": "#f2f8ff",
        "--color-success": "#0f7d0f",
        "--color-success-content": "#f2fff2",
        "--color-warning": "#946000",
        "--color-warning-content": "#fffaf0",
        "--color-error": "#d3302f",
        "--color-error-content": "#fff5f4",
        "--radius-selector": "0.5rem",
        "--radius-field": "0.5rem",
        "--radius-box": "0.75rem",
        "--size-selector": "0.25rem",
        "--size-field": "0.25rem",
        "--border": "1px",
        "--depth": "1",
        "--noise": "0",
    },
    "openrun-dark": {
        "color-scheme": "dark",
        "--color-base-100": "#17221a",  # cards, sidebar, lifted above page bg
        "--color-base-200": "#101a13",  # page background
        "--color-base-300": "#273b2c",  # borders, dividers
        "--color-base-content": "#d9e7db",
        "--color-primary": "#00c200",
        "--color-primary-content": "#012d01",
        "--color-secondary": "#007700",
        "--color-secondary-content": "#d9ffd6",
        "--color-accent": "#00d98b",
        "--color-accent-content": "#00311d",
        "--color-neutral": "#22312a",
        "--color-neutral-content": "#d3e3d6",
        "--color-info": "#55a9ff",
        "--color-info-content": "#00203f",
        "--color-success": "#37d24c",
        "--color-success-content": "#003a0c",
        "--color-warning": "#ffbe3d",
        "--color-warning-content": "#402d00",
        "--color-error": "#ff6f65",
        "--color-error-content": "#400300",
        "--radius-selector": "0.5rem",
        "--radius-field": "0.5rem",
        "--radius-box": "0.75rem",
        "--size-selector": "0.25rem",
        "--size-field": "0.25rem",
        "--border": "1px",
        "--depth": "1",
        "--noise": "0",
    },
}

# The preview data mirrors the fields the openrun server passes when it
# renders the embedded copy (internal/server login page handler).
def preview_data(auth_type, error):
    return {
        "AuthType": auth_type,
        "Error": error,
        "State": "preview-state",
        "StyleHref": "static/gen/css/style.css",
        "ExtraHref": "static/css/login_extra.css",
        "FontsHref": "static/css/login_fonts.css",
        "LoginPath": "#",
        "BackURL": "",
    }

def builtin_preview(req):
    return preview_data("builtin", "")

def system_preview(req):
    return preview_data("system", "")

def error_preview(req):
    return preview_data("builtin", "Invalid username or password")

def expired_preview(req):
    data = preview_data("builtin", "")
    data["State"] = ""
    data["BackURL"] = "#"  # link back to the app the login was started from
    return data

def expired_nolink_preview(req):
    data = preview_data("builtin", "")
    data["State"] = ""
    data["BackURL"] = ""
    return data

# Logout page previews (served on the app domain by the openrun server)
def logout_data(mode, user):
    return {
        "Mode": mode,
        "User": user,
        "LogoutPath": "#",
        "StyleHref": "static/gen/css/style.css",
        "ExtraHref": "static/css/login_extra.css",
        "FontsHref": "static/css/login_fonts.css",
        "Redirect": "#",
    }

def logout_confirm_preview(req):
    return logout_data("confirm", "builtin:testuser")

def logout_done_preview(req):
    return logout_data("done", "")

def logout_none_preview(req):
    return logout_data("none", "")

app = ace.app("OpenRun Login",
              custom_layout=True,
              routes=[
                  ace.html("/", full="index.go.html", handler=builtin_preview),
                  ace.html("/system", full="index.go.html", handler=system_preview),
                  ace.html("/error", full="index.go.html", handler=error_preview),
                  ace.html("/expired", full="index.go.html", handler=expired_preview),
                  ace.html("/expired_nolink", full="index.go.html", handler=expired_nolink_preview),
                  ace.html("/logout", full="logout.go.html", handler=logout_confirm_preview),
                  ace.html("/logout_done", full="logout.go.html", handler=logout_done_preview),
                  ace.html("/logout_none", full="logout.go.html", handler=logout_none_preview),
              ],
              style=ace.style("daisyui",
                              light="openrun-light",
                              dark="openrun-dark",
                              custom_themes=OPENRUN_THEMES))
