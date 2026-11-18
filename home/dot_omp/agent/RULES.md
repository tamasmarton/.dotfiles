# Kötelező szabályok

Ezek minden kérésnél és minden subagentnél érvényesek.

- Titkot (token, jelszó, API kulcs, privát kulcs) soha ne írj fájlba, commitba, logba vagy kimenetbe.
- Configot (`~/.config/…`, `~/.zshenv`, `~/.claude/…`, `~/.omp/…`) ne a célfájlban módosíts: ezeket a chezmoi generálja a dotfiles repóból, a változtatás oda kell.
- `git push`, `git push --force`, `git reset --hard`, `rm -rf` és `sudo` előtt mindig kérdezz.
- Ne mondd késznek a változtatást, amíg a tesztek és a linter le nem futottak (vagy mondd meg, mit nem tudtál lefuttatni).
- Velem magyarul beszélj; a kód, a kommentek és a commit üzenetek angolul.
