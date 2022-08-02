require('impatient')
require("options")
require("keymaps")
require("plugins")
require("colorscheme")


-- delete all buffers, except current one
-- %bd - delete all buffers (puts you in empty buffer)
-- e#  - open previous buffer
-- bd# - delete previous buffer (deletes empty buffer)
-- command! Bonly %bd <Bar> e# <Bar> bd#
-- Same as tabonly, but for buffers
vim.cmd("command! Bonly Bdelete other")
