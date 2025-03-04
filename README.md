# Statuscolumn README

My own take on a [statuscolumn](https://neovim.io/doc/user/options.html#'statuscolumn')
for Neovim.

![image](https://github.com/user-attachments/assets/fccfda68-9838-4954-806b-994d8f267b0d)

Nothing special really, I just wanted to try my hand at makeing one, and
implement some cool features I couldn't find in other statuscolumn plugins.

The features:
- Diagnostic signs are alone in their own column. They cannot be overwritten by
  gitsigns for example.
- Strong border with the "buffer" space.
- Gitsigns are displayed as a different color on the border.
- Wrapped lines now better display their span in the number column.
- Marks are shown if there are any in the current buffer.


## Installation

With [lazy.nvim](https://github.com/folke/lazy.nvim):
```lua
return {
  "louis-neovim-plugins/statuscolumn",
  dependencies = { "runiq/neovim-throttle-debounce" },
  opts = {},
}
```


## Configuration

No configuration options yet. I consider it to be a work in progress until I
have ironed out some refreshing issues.


## FAQ

Q: Any mouse support?  
A: No. I use Neovim explicitly to avoid using the mouse.

Q: Any fold indicators?  
A: No. I rarely fold, do not feel like I need additional indicators to "find"
   the folds, and that would take yet another column of screen space.


## Similar plugins

- [snacks.nvim/statuscolumn](https://github.com/folke/snacks.nvim/blob/main/docs/statuscolumn.md)
- [luukvbaal/statuscol.nvim](https://github.com/luukvbaal/statuscol.nvim)

