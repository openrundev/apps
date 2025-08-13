load("openrun.in", "openrun")

app = ace.app("OpenRun Audit Events", custom_layout=True,
              routes=[
                ace.html("/", partial="audit_body")
              ],
              permissions=[
                  ace.permission("openrun.in", "list_all_apps"),
                  ace.permission("openrun.in", "list_operations"),
                  ace.permission("openrun.in", "list_audit_events"),
              ],
              style=ace.style("daisyui", themes=["emerald", "night"])
       )

def query(req, key):
    return req.Query.get(key)[0] if req.Query.get(key) else ""

def handler(req):
    all_apps = openrun.list_all_apps()
    if all_apps.error:
        ace.response(all_apps.error, code=500)

    operations = openrun.list_operations()
    if operations.error:
        ace.response(operations.error, code=500)

    ret = openrun.list_audit_events(app_glob=query(req, "appGlob"),
                                     user_id=query(req, "userId"),
                                     event_type=query(req, "eventType"),
                                     operation=query(req, "operation"),
                                     target=query(req, "target"),
                                     status=query(req, "status"),
                                     start_date=query(req, "startDate"),
                                     end_date=query(req, "endDate"),
                                     rid=query(req, "rid"),
                                     before_timestamp=query(req, "beforeTimestamp"),
                                     )
    if ret.error:
        ace.response(ret.error, code=500)

    queryTimestamp = ret.value[-1]["create_time_epoch"] if len(ret.value) > 0 else ""
    nextPage = req.AppPath + "/?appGlob=" + query(req, "appGlob") + "&userId=" + query(req, "userId") + "&eventType=" + query(req, "eventType") + \
        "&operation=" + query(req, "operation") + "&target=" + query(req, "target") + "&status=" + query(req, "status") + "&startDate=" +  \
        query(req, "startDate") + "&endDate=" + query(req, "endDate") + "&rid=" + query(req, "rid") + "&beforeTimestamp=" + queryTimestamp
    
    return {
        "Apps": all_apps.value,
        "Operations": operations.value,
        "NextPage": nextPage,
        "Events": ret.value,
    }
