# CONTRIBUTING to Statuscolumn

Notes about working on this code base.


## General context

The statuscolumn is a flexible structure for displaying "things" in a column to
the left of a buffer.

The "things" in question could be virtually anything, but usually are:
- Line numbers.
- Diagnostic symbols.
- Git symbols.
- Fold symbols.

The statuscolumn can reuse the `signcolumn` and line numbers "as is", but some
features can only be implemented with custom `statuscolumn` code.

Features of this particular implementation:
- When wrapping lines, the line number column will display nice "scope" symbols
  to represent the full span of the wrapping line where, by default, there
  would be empty space.
- Git signs have been split to their own "column" (which doubles as a border
  before the buffer space). The default `signcolumn` is a shared space that both
  diagnostic and gitsigns write to, usually resulting in gitsigns being
  overwritten by diagnostic signs.


## Development tips

Signs are (also) contained in extmarks since Neovim 0.10.0

Be mindful of the following:
- The line the statuscolumn function wants to draw, which isn't necessarily in
  your "current buffer".
- "Current buffer" probably means the buffer where your cursor is.
- The function will be called once for each line for each buffer on screen. You
  should consider caching expensive function calls whenever possible. e.g. If the
  buffer hasn't changed then there is probably no reason for the git and LSP
  signs to have changed.
- There are a lot of vim options related to line numbers. Some are globally
  scoped, others window scoped, and others buffer scoped. Make sure to get the
  `vim.wo[win_id].number` option for example. Or by default `vim.wo` will be
  `vim.wo[0]`. And as explained earlier, the "current buffer" is not always what
  you want (it rarely is for statuscolumn).


## Design

A few notes about design choices.

### Caching

As explained above, when you run a function for every single line of you
buffer, it better be efficient.

`changedtick` allows us to cache some results: e.g. we get all signs for the
buffer and cache the signs based on the changedtick. This way we don't need to
fetch those again for the next lines in the same buffer.

However `changedtick` is **NOT** a good way to detect when the cache should be
invalidated. When you change the  buffer, the `changedtick` will increment, and
your signs will likely change. Because gitsigns and diagnostics take some time
to update, Neovim will redraw the cursorline before the signs are updated.

The better way is to wait for the respective "changed" events for each sign
"source" to come in, and switch a flag allowing the statuscolumn function to
fetch the signs.

Unfortunately this is not fool proof and there are quite a few scenarios where
the signs are changed but no event is emitted / received.

One workaround, which I dislike, would be to just update everything on a set
interval. e.g. snacks.nvim/statuscolumn has a 50ms timer I believe. So your nvim
client does a ton of work in the background all the time.

For now I just try to identify when certain things happen / don't happend and
add their corresponding events to the cache invalidation system.


#### Benchmark

The following results were taken by comparing `vim.uv.hrtime()` before and after
function calls. No idea how accurate that is. And I am eyeballing the values.

Note to self: `print(vim.inspect())` has a massive impact on performance.
So values are best interpreted by comparing with other values. Do not take them
as "absolutes".

Gitsigns:
- No cache whatsoever:      0.06000 ms avg, 0.1500 ms peak.
- Cached signs:             0.00050 ms avg, 0.0200 ms peak.
- Cached symbols:           0.00030 ms avg, 0.0015 ms peak.
- Cached signs and symbols: 0.00015 ms avg, 0.0015 ms peak.

Diagnostic sings:
- No cache whatsoever: 0.07 ms avg, 0.27 ms peak.
- Cached signs: 0.0003 ms avg, 0.0024 ms peak.
- Cached symbols: 0.0007 ms avg, 0.0026 ms peak.
- Cached signs and symbols: 0.0003 ms avg, 0.0040 ms peak.

Line number:
- No cache whatsoever: 0.005 ms avg, 0.03 ms peak.


### Extmarks and namespaces

`extmarks` are namespaced, making "filtering" them easier, provided you have the
correct namespace. For gitsigns it's easy enough to find the namespace `id`
from the namespace name, because the name is stable. For LSPs however, they all
have a different name. So I chose to get all marks and filter them based on the
highlight group used, not an ideal solution, but it works for now.


## TODOs

- [ ] There are a few cases where git (maybe diagnostic as well) signs do not
      update, but I have not pinpointed when it happens, or what the cause is.
- [ ] I have not found a way to detect when marks have changed. There are no
      events, and I do not think it's possible to properly "wrap" the default
      bindings to call custom functions.

