# miniterm.nvim

Minimalist approach to display a terminal on your screen.
Inspired by [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim).

## How to Use

Import the `Terminal` module and create an object like so:
```lua
local term = require("minterm.terminal").new({ 
    -- Setting `floating` to true will work (it's false by default), but 
    -- floating persistent windows can lead to scenarios where your cursor is 
    -- on a different buffer under the window, unable to see the text of that 
    -- buffer.
    floating = false, 
    height_percentage = 0.33,
})
```
Each terminal object created will have it's own buffer, and therefore it's own state.

Then use the object to open, close, and toggle the terminal:
```lua
term:open()
-- OR
term:close()
-- OR
term:toggle() 
```
> A `Terminal` object -- even floating ones -- will always open from the 
bottom to the top, regardless of the current window layout.

### Toggle
Open and Close are self-explanatory. Toggle will:
1. Open the terminal window if it's closed.
2. Close the terminal window if it's opened and focused.
3. Focus the terminal window if it's open but the cursor is not active in it.

