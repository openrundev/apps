load ("openrun.in", "openrun")
load ("openrun_admin.in", "openrun_admin")

def list_sync(dry_run, args):
    syncs = openrun.list_sync().value
    if args.detail:
        return ace.result("Sync jobs", syncs, ace.JSON)
    ret = [{" Path": s["path"], "Id": s["id"], "Branch": s["metadata"]["git_branch"],
      "Minutes": s["metadata"]["schedule_frequency"],
      "approve": s["metadata"]["approve"], "promote": s["metadata"]["promote"],
      " State": s["status"]["state"], "Last Run": s["status"]["last_execution_time"], "Error": s["status"]["error"]}
      for s in syncs]
    return ace.result("Sync jobs", ret, ace.TABLE)

def suggest_sync(args):
    syncs = openrun.list_sync().value
    return {"id": [s["id"] + ":" + s["path"] for s in syncs]}

def create_sync(dry_run, args):
    return ace.result("Sync created", [openrun_admin.create_sync(args.path, args.git_branch, args.git_auth, args.minutes, args.dry_run, args.promote, args.approve).value])

def run_sync(dry_run, args):
    if not args.id:
        return ace.result("Validation failed", param_errors={"id": "Sync id has to be specified"})
    id = args.id.split(":")[0]
    return ace.result("Sync run status", [openrun_admin.run_sync(id).value])

def delete_sync(dry_run, args):
    if not args.id:
        return ace.result("Validation failed", param_errors={"id": "Sync id has to be specified"})
    id = args.id.split(":")[0]
    return ace.result("Sync deleted", [openrun_admin.delete_sync(id).value])

hidden = ["git_branch", "git_auth", "approve", "promote", "minutes"]
app = ace.app("Manage Sync Jobs",
    actions=[
        ace.action("List Sync Jobs", "/", list_sync, description="List sync jobs", hidden=["dry_run", "id", "path"] + hidden),
        ace.action("Create Sync", "/create", create_sync, description="Create a new sync job", hidden=["detail", "id"], permit=["manage", "sync_create"]),
        ace.action("Run Sync", "/run", run_sync, suggest_sync, description="Run a sync job",
            hidden=["path", "detail"] + hidden, permit=["manage", "sync_execute"]),
        ace.action("Delete Sync", "/delete", delete_sync, suggest_sync, description="Delete sync job",
            hidden=["path", "detail"] + hidden, permit=["manage", "sync_delete"]),
    ],
    permissions=[
        ace.permission("openrun.in", "list_sync"),
        ace.permission("openrun_admin.in", "create_sync"),
        ace.permission("openrun_admin.in", "run_sync"),
        ace.permission("openrun_admin.in", "delete_sync"),
    ],
)
