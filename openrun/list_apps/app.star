load("openrun.in", "openrun")

# OpenRun brand themes, matching the management console (ui/console
# app.star). Brand greens: light #00C200, dark #007700. #00C200 is primary
# (deep-green content text), #007700 is secondary. Base surfaces are
# green-tinted.
OPENRUN_THEMES = {
    "openrun-light": {
        "color-scheme": "light",
        "--color-base-100": "#ffffff",  # cards
        "--color-base-200": "#f9fcf9",  # page background, faint green tint
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
        "--color-warning": "#946000",  # dark amber, 4.5:1+ on white
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
        "--color-base-100": "#17221a",  # cards, lifted above page bg
        "--color-base-200": "#101a13",  # page background
        "--color-base-300": "#273b2c",  # borders, dividers
        "--color-base-content": "#d9e7db",
        "--color-primary": "#00c200",  # brand light green, actions
        "--color-primary-content": "#012d01",
        "--color-secondary": "#007700",  # brand dark green, fills
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

app = ace.app("List Apps", custom_layout=True,
              routes=[
                ace.html("/", partial="search_results")
              ],
              permissions=[
                  ace.permission("openrun.in", "list_apps"),
              ],
              # The static_root favicons are served under stable names, so
              # give them a bounded cache lifetime; without it the browser
              # refetches them on every hx-push-url history update
              settings={"app_config": {
                  "static_root_cache_control": "public, max-age=3600"}},
              style=ace.style("daisyui",
                              light="openrun-light",
                              dark="openrun-dark",
                              custom_themes=OPENRUN_THEMES)
       )

def glob_ancestors(pf):
    # The set of folder/domain globs on the path filter's ancestor chain,
    # including the filter itself. Tree nodes on this chain render expanded
    chain = {}
    if pf == "" or pf == "all":
        return chain
    domain = ""
    p = pf
    idx = pf.find(":")
    if idx >= 0:
        domain = pf[:idx]
        p = pf[idx + 1:]
    prefix = domain + ":" if domain else ""
    if domain:
        chain[domain + ":**"] = True
    if p.endswith("/**"):
        p = p[:-3]
    elif p.endswith("**"):
        p = ""
    cur = ""
    for seg in p.split("/"):
        if seg:
            cur += "/" + seg
            chain[prefix + cur + "/**"] = True
    return chain


def build_tree(apps, active_path, total):
    # Build the folder tree from each app's path_split/path_split_glob
    # ancestor chain. Only folder ("/x/**") and domain ("dom:**") glob
    # entries become nodes; exact-path entries are the app leaves shown in
    # the grid. Top-level nodes render with their children (one level
    # expanded by default); deeper levels expand along the active filter
    nodes = {}
    for app in apps:
        splits = app["path_split"]
        globs = app["path_split_glob"]
        parent = ""
        depth = 0
        for i in range(len(globs)):
            g = globs[i]
            if not g.endswith("**"):
                continue
            if g not in nodes:
                label = splits[i] if i < len(splits) else g
                nodes[g] = {"label": label, "depth": depth, "parent": parent,
                            "domain": g.endswith(":**"), "count": 0,
                            "children": False}
            nodes[g]["count"] += 1
            if parent:
                nodes[parent]["children"] = True
            parent = g
            depth += 1

    chain = glob_ancestors(active_path)
    rows = [{"label": "All apps", "glob": "", "depth": 0, "domain": False,
             "count": total, "children": False, "expanded": False,
             "indent": 0, "is_all": True,
             "active": active_path == "" or active_path == "all"}]
    # String sort keeps children right after their parent; default-domain
    # folders (no ":" in the glob) sort before the domain groups
    keys = sorted(nodes.keys(), key=lambda g: ("1" + g) if ":" in g else ("0" + g))
    shown = {}
    for g in keys:
        n = nodes[g]
        if n["depth"] == 0:
            show = True
        else:
            pnode = nodes.get(n["parent"])
            show = (pnode != None and shown.get(n["parent"], False) and
                    (pnode["depth"] == 0 or n["parent"] in chain))
        shown[g] = show
        if show:
            rows.append({
                "label": n["label"] + (":" if n["domain"] else ""),
                "glob": g,
                "depth": n["depth"],
                "domain": n["domain"],
                "count": n["count"],
                "children": n["children"],
                "expanded": n["children"] and (n["depth"] == 0 or g in chain),
                "indent": n["depth"] * 18,
                "is_all": False,
                "active": g == active_path,
            })
    return rows


def handler(req):
    query = req.Query.get("q")
    query = query[0].strip() if query else ""
    internal = req.Query.get("internal")
    internal = internal[0] == "true" if internal else False
    path = req.Query.get("path")
    path = path[0] if path else ""

    # Console-style search: a ":" anywhere, a leading "/", or the exact
    # word "all" switches from substring matching to app path GLOB matching
    # (the query goes to list_apps path= instead of query=)
    is_glob = query == "all" or query.startswith("/") or ":" in query
    list_query = "" if is_glob else query
    list_path = query if is_glob else path

    ret = openrun.list_apps(list_query, list_path, internal)
    err = ret.error
    error = ""
    apps = []
    if err:
        error = "Invalid app path glob: %s" % err
    else:
        apps = ret.value

    # The sidebar tree is rebuilt on every request except htmx ones that
    # opt out with the X-Tree-Skip header: sidebar clicks on CHILDLESS
    # folder rows (layout.go.html folder_tree). Those are the only clicks
    # that cannot reveal hidden rows, so they fetch just the app grid and
    # save the extra list_apps call; toggle.js moves the active row
    # highlight for them. Searches, breadcrumb clicks and clicks on rows
    # with children all rebuild the tree as usual
    regen_tree = not (req.IsPartial and req.Headers.get("X-Tree-Skip"))

    tree = []
    if regen_tree:
        # The tree follows the SEARCH (both modes) but not the tree's own
        # folder selection, so folder navigation stays possible. Reuse the
        # results when the filters are identical (no folder selected)
        tree_path = query if is_glob else ""
        if err:
            tree_apps = []
        elif list_path == tree_path:
            tree_apps = apps
        else:
            tree_ret = openrun.list_apps(list_query, tree_path, internal)
            tree_err = tree_ret.error
            tree_apps = [] if tree_err else tree_ret.value

        # Tree nodes and counts cover primary apps only, not stage/preview
        primary = [a for a in tree_apps if a["main_app"] == ""]
        tree = build_tree(primary, list_path, len(primary))

    return {
        "query": query,
        "internal": internal,
        "path": path,
        "apps": apps,
        "error": error,
        # Folder clicks keep a substring search; a glob search is itself a
        # path filter, so the clicked folder replaces it
        "keep_query": "" if is_glob else query,
        "tree": tree,
        "regen_tree": regen_tree,
        "is_partial": req.IsPartial,
        "title": param.title,
        "show_hosted_with": param.show_hosted_with
    }
