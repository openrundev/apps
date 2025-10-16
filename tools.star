# Declarative app config for OpenRun tools, install by running
#   openrun apply --approve github.com/openrundev/apps/tools.star

def create_app(app_path, source_path):
  path_split = app_path.split(":") # split out the domain name
  path = path_split[1] if len(path_split) == 2 else path_split[0]

  branch = config("_branch", "")
  if branch:
     # Add branch name to app path
     path = "/" + branch + path
  if config("_dev", False):
     path = "/dev" + path

  if len(path_split) == 2:
     # Add the domain name back
     path = path_split[0] + ":" + path

  app(path, "github.com/openrundev/apps" + source_path, git_branch=branch)

create_app("/monitor/disk", "/system/disk_usage")
create_app("/monitor/memory", "/system/memory_usage")
create_app("/admin/audit", "/openrun/audit_viewer")
create_app("/admin/list", "/openrun/list_apps")

