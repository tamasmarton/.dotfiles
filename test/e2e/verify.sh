#!/bin/bash
# Telepítés utáni ellenőrzés (a teszt felhasználóként fut). Hibánál nem nulla kóddal lép ki.
fail=0
src="$(sed -n 's/^sourceDir = "\(.*\)"/\1/p' ~/.config/chezmoi/chezmoi.toml)"
echo "forrás: $src"
echo "################ ELLENŐRZÉS"
export TERM=xterm-256color
out="$(zsh -i -c 'for c in starship nvim fzf eza bat delta zoxide sesh lazygit tree-sitter mise claude tmux; do printf "  %-12s %s\n" $c "$(command -v $c >/dev/null && echo ok || echo HIÁNYZIK)"; done; echo "  pluginok: fzftab=$+widgets[fzf-tab-complete] hss=$+widgets[history-substring-search-up] autosuggest=$+widgets[autosuggest-accept]"; echo "  LANG=$LANG"' 2>&1 | grep -vE '^\s*$|can.t change option')"
echo "$out"
grep -q HIÁNYZIK <<<"$out" && fail=1
grep -q "pluginok: fzftab=1 hss=1 autosuggest=1" <<<"$out" || fail=1
echo "--- prompt:"; zsh -i -c 'cd "$src" && STARSHIP_SHELL= starship prompt' 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g; s/%[{}]//g' | head -3
echo "--- tmux:"; tmux -L t -f /dev/null new-session -d && tmux -L t source-file ~/.config/tmux/tmux.conf && echo "  prefix=$(tmux -L t show -gv prefix)"; [ "$(tmux -L t show -gv prefix)" = "C-a" ] || fail=1; tmux -L t kill-server
echo "--- git:"; git -C "$src" --paginate log -1 --oneline | cat
echo "--- claude:"; ~/.local/bin/claude --version 2>&1 | head -1 || fail=1
echo "--- neovim (pluginok + 3 treesitter parser):"
cat > /tmp/nvcheck.lua <<'LUA'
local ok = require("nvim-treesitter").install({ "lua", "go", "typescript" }):wait(300000)
local errs = {}
for l in vim.api.nvim_exec2("messages", { output = true }).output:gmatch("[^\n]+") do
  if l:match("[Ee]rror") then table.insert(errs, l) end
end
vim.cmd("edit /tmp/x.lua"); vim.wait(500)
print(string.format("  treesitter install=%s highlighter=%s colors=%s hibák=%d",
  tostring(ok), tostring(vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] ~= nil), vim.g.colors_name, #errs))
for _, e in ipairs(errs) do print("  " .. e) end
vim.cmd("qa!")
LUA
echo 'local x = 1' > /tmp/x.lua
nv="$(zsh -i -c 'CI=1 nvim --headless "+Lazy! restore" +qa >/dev/null 2>&1; nvim --headless -c "luafile /tmp/nvcheck.lua" 2>&1' 2>&1 | grep -v "can.t change option" | tail -5)"
echo "$nv"
grep -q "treesitter install=true highlighter=true colors=tokyonight-night hibák=0" <<<"$nv" || fail=1
echo "--- chezmoi data:"; grep -E 'isLinux|isDebian|isContainer|gui|linuxHost' ~/.config/chezmoi/chezmoi.toml
echo
if [ "$fail" = 0 ]; then
  echo "################ OK"
else
  echo "################ HIBA"
  exit 1
fi
