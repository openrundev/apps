load("openrun.in", "openrun")

app = ace.app("List Apps", custom_layout=True,
              routes=[
                ace.html("/", partial="search_results")
              ],
              permissions=[
                  ace.permission("openrun.in", "list_apps"),
              ],
              style=ace.style("daisyui", themes=["emerald", "night"])
       )

def handler(req):
    query = req.Query.get("q")
    query = query[0] if query else ""
    internal = req.Query.get("internal")
    internal = internal[0] == "true" if internal else False
    path = req.Query.get("path")
    path = path[0] if path else ""

    return {
        "query": query,
        "internal": internal,
        "path": path,
        "apps": openrun.list_apps(query, path, internal).value
    }
