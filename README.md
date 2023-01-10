# Tig Suite

## Stash support

### Keys: exe
Execute one of past ":!…" or ":exec …" commands after choosing one from a TUI like `tig` itself or `fzf`, etc.

![past commands](https://raw.githubusercontent.com/psprint/tigsuite/main/img/past-commands.png)

### Keys: Zpa
Apply selected stash with the `patch` utility. It might get better results
than the standard `git stash apply …`

### Keys: ZRpa
The same, but reversed patch will be used.

### Keys: Za
Apply the stash normally with `git stash apply`.

### Keys: Zz
Save a new stash keeping the staged changes.

### Keys: Zf
Save a new stash keeping the staged changes for currently highlighted file
**only**.

### Keys: Zif
Save a new stash keeping the staged changes for currently highlighted file
**only**and do this **interactively**.

### Keys: Ziz
Save a new stash keeping the staged changes and do this **interactively**.

### Keys: ZZZ
Uncodintionally stash all changes.

### Keys: Zmz
Save a new stash keeping the staged changes, with a custom message (will
get prompted).

### Keys: Zimz
Save a new stash keeping the staged changes, with a custom message (will
get prompted), **interactively**.

### Keys: Z1P
Apply the stash changes for a single file (currently highlighted), with
a different method.

### Keys: ZP
Apply the stash changes with the `patch` utility, with a different method
of generating the changes (`git diff stash^1 stash`).

### Keys: ZR1P
The same as `Z1P`, but the patch is reversed.

### Keys: ZRP
The same as `ZP`, but the patch is reversed.

## Ctags support

### Keys: x!b
Browse all the tags from `TAGS` index file with a TUI helper app, and open
`$EDITOR` on it.

![tags](https://raw.githubusercontent.com/psprint/tigsuite/main/img/tags.png)

### Keys: x!mt
Run `make tags` in the repo (should generate `TAGS` index file).

### Keys: x!mc
Run `make ctags` in the repo (should generate `TAGS` index file).

### Keys: x!tc
Run a curated `ctags --languages=C …` command that creates `TAGS` file
with symbols from any C source file (`.c`, `.h`).
@universal-ctags/ctags is required.

### Keys: x!tz
Run a curated `ctags --languages=Zsh,Sh …` command that creates `TAGS` file
with symbols from any shell source file (`.sh`, `.zsh`, `.bash`).
@universal-ctags/ctags is required.

### Keys: v!tc
The same as `x!tc`, but with Vim-style `tags` index file.

### Keys: v!tz
The same as `x!tz`, but with Vim-style `tags` index file.

### Keys: ed
Runs the `$EDITOR` on current file and line. The same as original `e` key.

## Support for °features°
Features are named groups of files, which can be opened in editor, by picking
up in tig:

![features](https://raw.githubusercontent.com/psprint/tigsuite/main/img/features.png)

or by any other tool like `fzf`. Set `$TICHOOSE_APP` to change from the default (`tig`). It's possible to create one from:
- commit – all files changed by commit become a °feature°,
- accumulator/queue – all files added to a side-buffer become a °feature°;
  you can add single files to it, or files of commit, or files from the
  current tree of files, etc.

### Keys: equ

Edit the current accumulator/queue (in $EDITOR).

### Keys: efe
Edit the file where all °features° are saved (in $EDITOR).

### Keys: esq
View files in queue, in `tig`.

### Keys: esc
View files in commit, in `tig`.

### Keys: enq
Create a new °feature° from accumulator/queue.

### Keys: enc
Create a new °feature° from commit.

### Keys: esvt
Create a new °feature° from tree (HEAD).

### Keys: esvT
Create a new °feature° from tree (current commit).

### Keys: eqe
Empty the queue.

### Keys: esvf
Save file in queue.

### Keys: esvF
Save all files in given °feature° to the queue.

### Keys: esvc
Save files in commit to the queue.

### Keys: eopm
Open °feature° in `$EDITOR`, after picking (from `tig`, `fzf`, etc.).

### Keys: eope
Open °feature° in `$EDITOR`, after entering its name in prompt.

### Keys: erem
Rename °feature° – menu (`tig`, `fzf`, etc.).

### Keys: eree
Rename °feature° – prompt.