param("path", description="The app declaration file path", required=False)

param("id", description="The sync job id", required=False)

param("approve", description="Whether to approve the app plugin permissions", type=BOOLEAN, default=True)

param("promote", description="Whether to promote the app to the production environment", type=BOOLEAN, default=True)

param("minutes", description="The frequency in minutes", type=INT, default=5)

param("dry_run", description="Whether to dry run the operation", type=BOOLEAN, default=False)

param("git_branch", description="The git branch to use", required=False)

param("git_auth", description="The git auth to use", required=False)

param("detail", description="Whether to show detailed response", type=BOOLEAN, default=False)
