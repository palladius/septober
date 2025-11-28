This is my oldest and more production-ready app which is basically a TODO list.

Be very conservative on changing things like database and such. Small changes, and confirm before committing.

# Tasks for Gemini

I want you ensure these 3 actions are done. Skip them if they're already there!

1. Ensure the documentation in README.md is up to date. For instance, a mermaid graph of
2. Let's have a CLI tool to add a todo, like `septober-cli`. I have a feeling that might be broken as of now.
3. Let's add some MCP (ModelContextProtocol) using the official ruby gem for MCP (I think its `mcp`) tools to add add these 2 tools under app/tools/ :
   1. list_todos
   2. add_todo
   3. list_projects
   Ideally these functionalities should be authenticated and return per authenticated user. We can start without this.
