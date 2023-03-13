local wk = require('whichkey_setup')

local keymap = {

    c        = { name = '+Comment' },
    d        = { name = '+Date' },
    f        = { name = '+Find' },
    g        = { name = '+Git' },
    h        = { name = '+Haskell' },
    i        = { name = '+Gist' },
    l        = { name = '+Language' },
    m        = { name = '+Markdown' },
    s        = { name = '+Surround' },
    t        = { name = '+Tag' },
    u        = { name = '+Undo' },
    z        = { name = '+Zen' },
    }

wk.register_keymap('leader', keymap)
