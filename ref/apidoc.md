Server
======

Interact with opencode server over HTTP.

The `opencode serve` command runs a headless HTTP server that exposes an OpenAPI endpoint that an opencode client can use.

* * * * *

### [Usage](https://opencode.ai/docs/server/#usage)

Terminal window

```
opencode serve [--port <number>] [--hostname <string>]
```

#### [Options](https://opencode.ai/docs/server/#options)

| Flag | Short | Description | Default |
| --- | --- | --- | --- |
| `--port` | `-p` | Port to listen on | `4096` |
| `--hostname` | `-h` | Hostname to listen on | `127.0.0.1` |

* * * * *

### [How it works](https://opencode.ai/docs/server/#how-it-works)

When you run `opencode` it starts a TUI and a server. Where the TUI is the client that talks to the server. The server exposes an OpenAPI 3.1 spec endpoint. This endpoint is also used to generate an [SDK](https://opencode.ai/docs/sdk).

Tip

Use the opencode server to interact with opencode programmatically.

This architecture lets opencode support multiple clients and allows you to interact with opencode programmatically.

You can run `opencode serve` to start a standalone server. If you have the opencode TUI running, `opencode serve` will start a new server.

* * * * *

#### [Connect to an existing server](https://opencode.ai/docs/server/#connect-to-an-existing-server)

When you start the TUI it randomly assigns a port and hostname. You can instead pass in the `--hostname` and `--port` [flags](https://opencode.ai/docs/cli). Then use this to connect to its server.

The [`/tui`](https://opencode.ai/docs/server/#tui) endpoint can be used to drive the TUI through the server. For example, you can prefill or run a prompt. This setup is used by the opencode [IDE](https://opencode.ai/docs/ide) plugins.

* * * * *

[Spec](https://opencode.ai/docs/server/#spec)
---------------------------------------------

The server publishes an OpenAPI 3.1 spec that can be viewed at:

```
http://<hostname>:<port>/doc
```

For example, `http://localhost:4096/doc`. Use the spec to generate clients or inspect request and response types. Or view it in a Swagger explorer.

* * * * *

[APIs](https://opencode.ai/docs/server/#apis)
---------------------------------------------

The opencode server exposes the following APIs.

* * * * *

### [App](https://opencode.ai/docs/server/#app)

| Method | Path | Description | Response |
| --- | --- | --- | --- |
| `GET` | `/app` | Get app info | [`App`](https://github.com/sst/opencode/blob/dev/packages/sdk/js/src/gen/types.gen.ts) |
| `POST` | `/app/init` | Initialize the app | `boolean` |

* * * * *

### [Config](https://opencode.ai/docs/server/#config)

| Method | Path | Description | Response |
| --- | --- | --- | --- |
| `GET` | `/config` | Get config info | [`Config`](https://github.com/sst/opencode/blob/dev/packages/sdk/js/src/gen/types.gen.ts) |
| `GET` | `/config/providers` | List providers and default models | `{ providers: `[Provider[]](https://github.com/sst/opencode/blob/dev/packages/sdk/js/src/gen/types.gen.ts)`, default: { [key: string]: string } }` |

* * * * *

### [Sessions](https://opencode.ai/docs/server/#sessions)

| Method | Path | Description | Notes |
| --- | --- | --- | --- |
| `GET` | `/session` | List sessions | Returns [`Session[]`](https://github.com/sst/opencode/blob/dev/packages/sdk/js/src/gen/types.gen.ts) |
| `GET` | `/session/:id` | Get session | Returns [`Session`](https://github.com/sst/opencode/blob/dev/packages/sdk/js/src/gen/types.gen.ts) |
| `GET` | `/session/:id/children` | List child sessions | Returns [`Session[]`](https://github.com/sst/opencode/blob/dev/packages/sdk/js/src/gen/types.gen.ts) |
| `POST` | `/session` | Create session | body: `{ parentID?, title? }`, returns [`Session`](https://github.com/sst/opencode/blob/dev/packages/sdk/js/src/gen/types.gen.ts) |
| `DELETE` | `/session/:id` | Delete session |  |
| `PATCH` | `/session/:id` | Update session properties | body: `{ title? }`, returns [`Session`](https://github.com/sst/opencode/blob/dev/packages/sdk/js/src/gen/types.gen.ts) |
| `POST` | `/session/:id/init` | Analyze app and create `AGENTS.md` | body: `{ messageID, providerID, modelID }` |
| `POST` | `/session/:id/abort` | Abort a running session |  |
| `POST` | `/session/:id/share` | Share session | Returns [`Session`](https://github.com/sst/opencode/blob/dev/packages/sdk/js/src/gen/types.gen.ts) |
| `DELETE` | `/session/:id/share` | Unshare session | Returns [`Session`](https://github.com/sst/opencode/blob/dev/packages/sdk/js/src/gen/types.gen.ts) |
| `POST` | `/session/:id/summarize` | Summarize session |  |
| `GET` | `/session/:id/message` | List messages in a session | Returns `{ info: `[Message](https://github.com/sst/opencode/blob/dev/packages/sdk/js/src/gen/types.gen.ts)`, parts: `[Part[]](https://github.com/sst/opencode/blob/dev/packages/sdk/js/src/gen/types.gen.ts)`}[]` |
| `GET` | `/session/:id/message/:messageID` | Get message details | Returns `{ info: `[Message](https://github.com/sst/opencode/blob/dev/packages/sdk/js/src/gen/types.gen.ts)`, parts: `[Part[]](https://github.com/sst/opencode/blob/dev/packages/sdk/js/src/gen/types.gen.ts)`}` |
| `POST` | `/session/:id/message` | Send chat message | body matches [`ChatInput`](https://github.com/sst/opencode/blob/main/packages/opencode/src/session/index.ts#L358), returns [`Message`](https://github.com/sst/opencode/blob/dev/packages/sdk/js/src/gen/types.gen.ts) |
| `POST` | `/session/:id/shell` | Run a shell command | body matches [`CommandInput`](https://github.com/sst/opencode/blob/main/packages/opencode/src/session/index.ts#L1007), returns [`Message`](https://github.com/sst/opencode/blob/dev/packages/sdk/js/src/gen/types.gen.ts) |
| `POST` | `/session/:id/revert` | Revert a message | body: `{ messageID }` |
| `POST` | `/session/:id/unrevert` | Restore reverted messages |  |
| `POST` | `/session/:id/permissions/:permissionID` | Respond to a permission request | body: `{ response }` |

* * * * *

### [Files](https://opencode.ai/docs/server/#files)

| Method | Path | Description | Response |
| --- | --- | --- | --- |
| `GET` | `/find?pattern=<pat>` | Search for text in files | Array of match objects with `path`, `lines`, `line_number`, `absolute_offset`, `submatches` |
| `GET` | `/find/file?query=<q>` | Find files by name | `string[]` (file paths) |
| `GET` | `/find/symbol?query=<q>` | Find workspace symbols | [`Symbol[]`](https://github.com/sst/opencode/blob/dev/packages/sdk/js/src/gen/types.gen.ts) |
| `GET` | `/file?path=<path>` | Read a file | `{ type: "raw" | "patch", content: string }` |
| `GET` | `/file/status` | Get status for tracked files | [`File[]`](https://github.com/sst/opencode/blob/dev/packages/sdk/js/src/gen/types.gen.ts) |

* * * * *

### [Logging](https://opencode.ai/docs/server/#logging)

| Method | Path | Description | Response |
| --- | --- | --- | --- |
| `POST` | `/log` | Write log entry. Body: `{ service, level, message, extra? }` | `boolean` |

* * * * *

### [Agents](https://opencode.ai/docs/server/#agents)

| Method | Path | Description | Response |
| --- | --- | --- | --- |
| `GET` | `/agent` | List all available agents | [`Agent[]`](https://github.com/sst/opencode/blob/dev/packages/sdk/js/src/gen/types.gen.ts) |

* * * * *

### [TUI](https://opencode.ai/docs/server/#tui)

| Method | Path | Description | Response |
| --- | --- | --- | --- |
| `POST` | `/tui/append-prompt` | Append text to the prompt | `boolean` |
| `POST` | `/tui/open-help` | Open the help dialog | `boolean` |
| `POST` | `/tui/open-sessions` | Open the session selector | `boolean` |
| `POST` | `/tui/open-themes` | Open the theme selector | `boolean` |
| `POST` | `/tui/open-models` | Open the model selector | `boolean` |
| `POST` | `/tui/submit-prompt` | Submit the current prompt | `boolean` |
| `POST` | `/tui/clear-prompt` | Clear the prompt | `boolean` |
| `POST` | `/tui/execute-command` | Execute a command (`{ command }`) | `boolean` |
| `POST` | `/tui/show-toast` | Show toast (`{ title?, message, variant }`) | `boolean` |
| `GET` | `/tui/control/next` | Wait for the next control request | Control request object |
| `POST` | `/tui/control/response` | Respond to a control request (`{ body }`) | `boolean` |

* * * * *

### [Auth](https://opencode.ai/docs/server/#auth)

| Method | Path | Description | Response |
| --- | --- | --- | --- |
| `PUT` | `/auth/:id` | Set authentication credentials. Body must match provider schema | `boolean` |

* * * * *

### [Events](https://opencode.ai/docs/server/#events)

| Method | Path | Description | Response |
| --- | --- | --- | --- |
| `GET` | `/event` | Server-sent events stream. First event is `server.connected`, then bus events | Server-sent events stream |

* * * * *

### [Docs](https://opencode.ai/docs/server/#docs)

| Method | Path | Description | Response |
| --- | --- | --- | --- |
| `GET` | `/doc` | OpenAPI 3.1 specification | HTML page with OpenAPI spec |