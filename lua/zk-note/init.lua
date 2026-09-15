-- zk-note: capture a note now, decide where it belongs afterwards.
--
-- :ZkNote opens an empty scratch buffer. Write in it, close it with ZZ (or tc,
-- or :bd), and only then are you asked which notebook directory it goes in and
-- what it is called -- zk then creates the real note with that directory's own
-- template and filename rule. The order is the whole point: naming a note is
-- the part that stops you from writing one, so it happens after the thought is
-- already safely on disk.
--
-- Drafts are real files under the cache directory, so nothing lives only in a
-- buffer: nvim dying, or being killed with drafts still open, leaves the text
-- on disk rather than nowhere.
--
-- Nothing typed is ever thrown away. Cancel either prompt, give no title, or
-- quit nvim outright while drafts are open, and the text is appended to
-- q/q.md, which is where loose thoughts already live. Only a draft that is
-- blank to begin with is dropped without a word.
--
-- Paired with ~/.local/bin/zk-note and $mod+n in sway: that opens one
-- persistent nvim in the scratchpad and asks it for a new draft, so capture is
-- one keypress from anywhere. The plugin does not need any of that -- :ZkNote
-- in the nvim you are already in works the same way.

local M = {}

M.config = {
  -- Notebook root. ZK_NOTEBOOK_DIR wins when it is set, since that is what zk
  -- itself honours.
  notebook = vim.env.ZK_NOTEBOOK_DIR or vim.fn.expand("~/memo"),
  -- Where unfiled drafts wait. Real files on purpose, see above.
  -- Inside the notebook, and hidden. Both halves matter:
  --
  --   * zk's LSP is attached by zk-nvim only to buffers that have a .zk
  --     directory somewhere above them, so a draft in ~/.cache would get no
  --     tag completion, no [[link]] completion and no dead-link diagnostics --
  --     exactly the things you want while writing the note rather than after;
  --   * zk's indexer skips dot-directories, so drafts are invisible to
  --     `zk list`, the graph and the index until they become real notes.
  --
  -- Not stdpath("cache") either way: the sway capture window and the nvim you
  -- already have open must agree on one directory, or an unfiled draft from
  -- one is invisible to the other.
  drafts = vim.env.ZK_NOTE_DRAFTS,
  -- Ask for tags after the title. false skips that prompt entirely.
  tags = true,
  -- Path, relative to the notebook, that catches anything not filed.
  quick = "q/q.md",
  -- sway's exec environment has no ~/.local/bin on PATH, so the fallback
  -- matters when nvim was started from a keybind rather than a shell.
  zk = vim.fn.executable("zk") == 1 and "zk" or vim.fn.expand("~/.local/bin/zk"),
  -- How :ZkNote puts the draft on screen. A split keeps whatever you were
  -- doing visible; the capture window passes "edit", having nothing to keep.
  open = "split",
  -- Global keymap for a new draft. false to set up none.
  keymap = "<Leader>zn",
  -- How many recently modified notes to read directory order out of.
  recent = 300,
}

local function cfg()
  return M.config
end

local function drafts_dir()
  return vim.fn.resolve(vim.fn.expand(cfg().drafts or (cfg().notebook .. "/.drafts")))
end

local function is_draft(buf)
  if not (buf and vim.api.nvim_buf_is_valid(buf)) then
    return false
  end
  local name = vim.api.nvim_buf_get_name(buf)
  local dir = drafts_dir()
  return name ~= "" and name:sub(1, #dir + 1) == dir .. "/"
end

local function draft_bufs()
  return vim.tbl_filter(function(b)
    return vim.fn.buflisted(b) == 1 and is_draft(b)
  end, vim.api.nvim_list_bufs())
end

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "zk-note" })
end

-- What has happened to each draft, keyed by path rather than by buffer number:
-- nvim hands out the numbers of deleted buffers again, and a recycled one
-- would look like a draft already filed and never get filed at all. Every
-- draft has its own name, so the path is the honest key.
--
--   "pending" -- a prompt chain is in flight for it
--   true      -- dealt with for good; never touch it again
local handed = {}

-- Drafts this nvim opened. The drafts directory is shared with every other
-- nvim (that is the point -- the capture window and the editor you already
-- have open see the same unfiled notes), so "everything in the directory" is
-- never the right set to act on at exit.
local mine = {}

-- Put the buffer's text on disk without filing anything. A draft is typically
-- never saved -- you write it and close it -- so its words live only in memory
-- until something like this writes them out, and by the time BufDelete runs
-- the buffer has already been unloaded and there is nothing left to read. So
-- the text is stashed on the way out while the buffer is still loaded, and
-- everything downstream works from the file.
--
-- Not for a draft that has already been filed or discarded, though: closing
-- its buffer unloads it, and writing the text back out at that point would
-- recreate on disk the very file that was just cleaned up, leaving a copy of
-- every note ever captured sitting in the drafts directory.
local function stash(buf)
  if not is_draft(buf) or not vim.api.nvim_buf_is_loaded(buf) then
    return
  end
  if handed[vim.api.nvim_buf_get_name(buf)] then
    return
  end
  -- :write rather than writefile. Putting the lines on disk behind nvim's back
  -- leaves the buffer's idea of the file stale, and returning to the draft then
  -- gets you "W12: file has changed and the buffer was changed in Vim as well"
  -- about your own autosave. Writing through the buffer keeps the two in step.
  -- noautocmd, so no formatter or save hook runs over a half-written thought;
  -- keepalt so stashing does not clobber the alternate file.
  vim.api.nvim_buf_call(buf, function()
    vim.cmd("silent noautocmd keepalt write")
  end)
end

-- Closing the draft buffer is the last step of filing, not a separate thing
-- the keymap does: the prompts are asynchronous, and deleting the buffer while
-- the picker was still opening its window silently failed and left the draft
-- sitting there after its note had already been written.
local function close(buf)
  if buf and vim.api.nvim_buf_is_valid(buf) then
    pcall(vim.api.nvim_buf_delete, buf, { force = true })
  end
end

local function read(path)
  if vim.fn.filereadable(path) ~= 1 then
    return {}
  end
  return vim.fn.readfile(path)
end

local function blank(lines)
  for _, l in ipairs(lines) do
    if l:match("%S") then
      return false
    end
  end
  return true
end

-- The first line with anything on it, minus the markdown that decorates it --
-- a heading typed as "# Cyprus permit" should not suggest "# Cyprus permit".
local function suggest_title(lines)
  for _, l in ipairs(lines) do
    if l:match("%S") then
      local t = l:gsub("^%s*#+%s*", ""):gsub("^%s*[-*+]%s+", ""):gsub("%s+$", "")
      return t:sub(1, 72)
    end
  end
  return ""
end

-- The template already writes "# {{title}}" above the body, so a draft that
-- opens with the very heading the title came from would say it twice. Dropped
-- only when it was a markdown heading and it still matches the accepted title
-- -- a plain first line is prose and stays where it was written.
local function body_lines(lines, title)
  local out, started, skip_blank = {}, false, false
  for _, l in ipairs(lines) do
    if not started then
      if l:match("%S") then
        started = true
        local heading = l:match("^%s*#+%s*(.-)%s*$")
        if heading and heading == title then
          skip_blank = true
          goto continue
        end
      else
        goto continue
      end
    end
    if skip_blank and not l:match("%S") then
      goto continue
    end
    skip_blank = false
    table.insert(out, l)
    ::continue::
  end
  return out
end

local function run(args, stdin)
  local res = vim.system(args, { cwd = cfg().notebook, stdin = stdin, text = true }):wait()
  return res.code, (res.stdout or ""), (res.stderr or "")
end

local function reindex()
  vim.system({ cfg().zk, "index", "--quiet" }, { cwd = cfg().notebook })
end

-- Candidate directories: the ones holding recently modified notes first, then
-- every other directory in the notebook, then the root. zk's index already
-- knows the modification order, which is what makes the top of the list the
-- answer most of the time.
local function candidates()
  local seen, out = {}, {}
  local function add(d)
    if d ~= "" and not seen[d] then
      seen[d] = true
      table.insert(out, d)
    end
  end

  local code, stdout = run({
    cfg().zk, "list", "--quiet", "--format", "{{path}}",
    "--sort", "modified-", "--limit", tostring(cfg().recent),
  })
  if code == 0 then
    for _, p in ipairs(vim.split(stdout, "\n", { trimempty = true })) do
      local dir = p:match("^(.*)/[^/]*$")
      add(dir or ".")
    end
  end

  local _, found = run({ "find", ".", "-type", "d", "-name", ".*", "-prune", "-o", "-type", "d", "-printf", "%P\n" })
  local rest = vim.split(found, "\n", { trimempty = true })
  table.sort(rest)
  for _, d in ipairs(rest) do
    add(d)
  end

  add(".")
  return out
end

-- Existing directories are fuzzy-picked; ctrl-x takes whatever is typed as a
-- new one, prefilled with the query so the path does not have to be retyped.
-- fzf-lua is what the rest of this config picks with, but it is asked for
-- lazily and vim.ui.select covers its absence.
--
-- Aborting a picker (esc) cannot be observed here: fzf exits 130 with no
-- selection and fzf-lua calls nothing back -- not an action, not fn_selected.
-- So the callback below simply never runs, and the draft is released again
-- from the other side, when its buffer is re-entered (see the BufEnter hook).
local function pick_dir(cb)
  local list = candidates()
  local ok, fzf = pcall(require, "fzf-lua")
  if not ok then
    vim.ui.select(list, { prompt = "File note in:" }, function(choice)
      cb(choice)
    end)
    return
  end

  local function ask_new(seed)
    vim.ui.input({ prompt = "New directory: ", default = seed or "", completion = "dir" }, function(input)
      cb(input and vim.trim(input) or nil)
    end)
  end

  fzf.fzf_exec(list, {
    prompt = "File in> ",
    fzf_opts = { ["--header"] = "ctrl-x: new directory" },
    actions = {
      ["default"] = function(selected)
        cb(selected and selected[1])
      end,
      -- last_query is set from fzf's --print-query before actions run, so the
      -- path half-typed into the filter carries over instead of being lost.
      ["ctrl-x"] = function(_, opts)
        ask_new(opts and opts.last_query)
      end,
    },
  })
end

-- Tags the notebook already uses, most used first -- the tag you want is
-- nearly always one that exists, and note-count order puts it on screen
-- without typing. Tab marks several, ctrl-x adds one that does not exist yet,
-- esc takes none.
local function pick_tags(cb)
  if not cfg().tags then
    return cb({})
  end

  local code, stdout = run({
    cfg().zk, "tag", "list", "--quiet", "--no-pager",
    "--sort", "note-count-", "--format", "{{name}}",
  })
  local list = code == 0 and vim.split(stdout, "\n", { trimempty = true }) or {}

  local ok, fzf = pcall(require, "fzf-lua")
  if not ok then
    vim.ui.input({ prompt = "Tags (comma separated): " }, function(input)
      local tags = {}
      for _, t in ipairs(vim.split(type(input) == "string" and input or "", ",", { trimempty = true })) do
        table.insert(tags, vim.trim(t))
      end
      cb(tags)
    end)
    return
  end

  fzf.fzf_exec(list, {
    prompt = "Tags> ",
    fzf_opts = {
      ["--multi"] = true,
      ["--header"] = "tab: mark several / ctrl-x: new tag / esc: none",
    },
    actions = {
      ["default"] = function(selected)
        cb(selected or {})
      end,
      -- Whatever was marked, plus the tag being typed when there was nothing
      -- to match it against.
      ["ctrl-x"] = function(selected, opts)
        local tags = selected or {}
        local new = opts and opts.last_query and vim.trim(opts.last_query) or ""
        if new ~= "" then
          table.insert(tags, new)
        end
        cb(tags)
      end,
    },
  })
end

local function append_quick(lines, why)
  local path = cfg().notebook .. "/" .. cfg().quick
  vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
  local out = vim.list_extend({ "", "", os.date("%Y-%m-%d") }, lines)
  vim.fn.writefile(out, path, "a")
  notify((why and why .. " -- " or "") .. "kept in " .. cfg().quick, vim.log.levels.WARN)
end

-- Make sure the note actually carries what was written, because there are two
-- quiet ways for zk to drop it:
--
--   * a template with no {{content}} placeholder -- log.md, daily.md and the
--     brief templates are all like that, so filing into log/ or a brief
--     directory would produce a pristine template and nothing else;
--   * a note that already exists, which zk leaves untouched while still
--     printing its path and exiting 0 -- the second note of the day into a
--     group whose filename is a date.
--
-- Both end with the draft gone and the words nowhere, which is the one outcome
-- this whole thing exists to prevent. Appending is safe either way: it never
-- overwrites what the template or the earlier note put there.
local function ensure_body(path, body)
  local first
  for _, l in ipairs(body) do
    if l:match("%S") then
      first = l
      break
    end
  end
  if not first then
    return false
  end
  for _, l in ipairs(read(path)) do
    if l == first then
      return false
    end
  end
  vim.fn.writefile(vim.list_extend({ "" }, body), path, "a")
  return true
end

local function yaml_tags(tags)
  local quoted = {}
  for _, t in ipairs(tags) do
    table.insert(quoted, '"' .. t:gsub("\\", "\\\\"):gsub('"', '\\"') .. '"')
  end
  return "tags: [" .. table.concat(quoted, ", ") .. "]"
end

-- Where the tags actually go depends on what the directory's template built.
-- Most of them open with YAML frontmatter carrying an empty tags list, which
-- is the right place. The log and brief templates have no frontmatter at all,
-- and an existing note we appended to is not ours to restructure, so there the
-- tags go in as hashtags -- which this notebook indexes (format.markdown
-- hashtags = true), but only for single words, since multiword-tags is off.
local function apply_tags(path, tags)
  if #tags == 0 then
    return false
  end
  local lines = read(path)

  if lines[1] == "---" then
    local close
    for i = 2, #lines do
      if lines[i] == "---" then
        close = i
        break
      end
    end
    if close then
      for i = 2, close - 1 do
        if lines[i]:match("^tags:") then
          lines[i] = yaml_tags(tags)
          vim.fn.writefile(lines, path)
          return true
        end
      end
      table.insert(lines, close, yaml_tags(tags))
      vim.fn.writefile(lines, path)
      return true
    end
  end

  local hashed, skipped = {}, {}
  for _, t in ipairs(tags) do
    if t:match("^[%w_/%-]+$") then
      table.insert(hashed, "#" .. t)
    else
      table.insert(skipped, t)
    end
  end
  if #hashed > 0 then
    vim.fn.writefile({ "", table.concat(hashed, " ") }, path, "a")
  end
  if #skipped > 0 then
    notify("no frontmatter here and a hashtag cannot hold a space, so these were not applied: "
      .. table.concat(skipped, ", "), vim.log.levels.WARN)
  end
  return #hashed > 0
end

local function create(dir, title, tags, lines, done)
  -- A name ending in .md is a filename, so zk gets the stem as the title and
  -- the note is moved onto the exact name afterwards.
  local fname
  if title:sub(-3) == ".md" then
    fname = title
    title = vim.fn.fnamemodify(title, ":t:r")
  end

  local body = body_lines(lines, title)
  vim.fn.mkdir(cfg().notebook .. "/" .. dir, "p")

  local code, stdout = run(
    { cfg().zk, "new", dir, "--title", title, "-i", "--no-input", "-p" },
    table.concat(body, "\n") .. "\n"
  )
  local path = vim.trim(stdout)
  if code ~= 0 or path == "" or vim.fn.filereadable(path) ~= 1 then
    return done(nil)
  end

  local touched = false
  if fname then
    local dest = cfg().notebook .. "/" .. dir .. "/" .. fname
    if vim.fn.filereadable(dest) == 1 and dest ~= path then
      notify("name already taken, kept as " .. path, vim.log.levels.WARN)
    elseif dest ~= path then
      -- zk indexed the note under the name it generated; the rename happens
      -- behind its back, so the index has to be told.
      if vim.fn.rename(path, dest) == 0 then
        path, touched = dest, true
      end
    end
  end

  local appended = ensure_body(path, body)
  local tagged = apply_tags(path, tags)
  if touched or appended or tagged then
    reindex()
  end
  done(path, appended)
end

local function finish(buf, draft, lines, dir, title, tags)
  create(dir, title, tags, lines, function(path, appended)
    handed[draft] = true
    vim.fn.delete(draft)
    close(buf)
    if not path then
      append_quick(lines, "zk could not create the note in " .. dir)
    else
      local rel = path:gsub("^" .. vim.pesc(cfg().notebook) .. "/", "")
      pcall(vim.fn.setreg, "+", path)
      notify((appended and "appended to " or "filed ") .. rel)
    end
    M.on_idle()
  end)
end

--- Ask where a draft goes and file it. Safe to call on an unloaded buffer.
function M.file(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  if not is_draft(buf) then
    return
  end
  local draft = vim.api.nvim_buf_get_name(buf)
  if handed[draft] then
    return
  end
  -- Stash before claiming it: stash deliberately refuses to write a draft that
  -- has already been handed over, so claiming first would leave nothing to read.
  stash(buf)
  handed[draft] = "pending"
  local lines = read(draft)

  -- A draft with nothing but whitespace in it is a keypress you changed your
  -- mind about, not a note.
  if blank(lines) then
    handed[draft] = true
    vim.fn.delete(draft)
    close(buf)
    M.on_idle()
    return
  end

  -- Backing out of a prompt is not the same as losing the note. While the
  -- buffer is still there, the draft simply stays what it was -- open, on
  -- disk, unfiled -- and ZZ tries again; `handed` has to be given back or the
  -- second attempt would be ignored as already dealt with. Only when the
  -- buffer is gone (:bd started this, so there is nothing to return to) does
  -- the text go to the quick-note buffer instead.
  -- "Is there still a buffer to go back to" is a question about the buffer
  -- being listed, not about it being valid: :bdelete unlists and unloads a
  -- buffer but does not wipe it, so the handle stays valid afterwards and a
  -- validity check would claim a draft you just closed is still on screen.
  local function cancelled(why)
    if vim.api.nvim_buf_is_valid(buf) and vim.fn.buflisted(buf) == 1 then
      handed[draft] = nil
      notify(why .. " -- still unfiled", vim.log.levels.WARN)
    else
      handed[draft] = true
      vim.fn.delete(draft)
      append_quick(lines, why)
    end
    M.on_idle()
  end

  pick_dir(function(dir)
    -- type-checked, not just nil-checked: a cancelled prompt is nil, but a
    -- picker handing back something that is not a string must not be pasted
    -- into a path either.
    if type(dir) ~= "string" or dir == "" then
      return cancelled("no directory chosen")
    end
    dir = dir:gsub("^%./", ""):gsub("/$", "")
    if dir == "" then
      dir = "."
    end

    vim.ui.input({ prompt = "Title (" .. dir .. "): ", default = suggest_title(lines) }, function(title)
      title = type(title) == "string" and vim.trim(title) or ""
      if title == "" then
        return cancelled("no title given")
      end

      pick_tags(function(tags)
        finish(buf, draft, lines, dir, title, tags or {})
      end)
    end)
  end)
end

--- Throw a draft away, buffer and file both.
function M.discard(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  if not is_draft(buf) then
    return
  end
  local draft = vim.api.nvim_buf_get_name(buf)
  handed[draft] = true
  vim.api.nvim_buf_delete(buf, { force = true })
  vim.fn.delete(draft)
  M.on_idle()
end

-- Two drafts must never land on the same path -- they are what `handed` is
-- keyed by. The timestamp alone is not enough (two presses inside one second),
-- and math.random is not either: LuaJIT never seeds it, so every nvim in the
-- session would pick the same "random" name. Pid plus a counter is simply true.
local seq = 0

--- Where unfiled drafts live, config default resolved.
function M.drafts_dir()
  return drafts_dir()
end

--- Open a new draft. opts.open overrides config.open ("edit", "split", ...).
function M.new(opts)
  opts = opts or {}
  local dir = drafts_dir()
  vim.fn.mkdir(dir, "p")
  seq = seq + 1
  local path = string.format("%s/%s-%d-%d.md", dir, os.date("%Y%m%d-%H%M%S"), vim.fn.getpid(), seq)
  mine[path] = true
  -- Created empty before it is opened, not left for the first stash. A buffer
  -- on a file that did not exist yet gets "W13: file has been created after
  -- editing started" thrown at it the moment stash writes the text out and you
  -- come back to it -- and the draft only becomes crash-proof once it is real.
  vim.fn.writefile({}, path)
  vim.cmd(string.format("%s %s", opts.open or cfg().open, vim.fn.fnameescape(path)))
  return path
end

-- Called whenever a draft stops existing. Overridden by the capture window's
-- launcher, which parks its sway scratchpad window once nothing is left to
-- file; a plain nvim has nothing to do here.
function M.on_idle()
  if vim.env.ZK_NOTE_WINDOW ~= "1" then
    return
  end
  vim.schedule(function()
    if #draft_bufs() > 0 then
      return
    end
    vim.system({ "swaymsg", '[con_mark="zknote_win"] move to scratchpad' })
  end)
end

function M.setup(opts)
  M.config = vim.tbl_extend("force", M.config, opts or {})
  local group = vim.api.nvim_create_augroup("ZkNote", { clear = true })
  local pattern = drafts_dir() .. "/*.md"

  vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
    group = group,
    pattern = pattern,
    callback = function(ev)
      local buf = ev.buf
      vim.b[buf].zk_draft = true
      vim.bo[buf].bufhidden = "hide"
      mine[vim.api.nvim_buf_get_name(buf)] = true
      -- Scheduled so the buffer-local maps land after the markdown ftplugin
      -- has had its turn rather than racing it.
      vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(buf) then
          return
        end
        vim.keymap.set("n", "ZZ", function()
          M.file(buf)
        end, { buffer = buf, desc = "zk-note: file this draft" })
        vim.keymap.set("n", "ZQ", function()
          M.discard(buf)
        end, { buffer = buf, desc = "zk-note: throw this draft away" })
      end)
    end,
  })

  -- Leaving the buffer at all, for any reason, gets the words onto disk.
  -- Cheap, and it is what leaves something recoverable if nvim dies outright.
  vim.api.nvim_create_autocmd({ "BufUnload", "BufLeave" }, {
    group = group,
    pattern = pattern,
    callback = function(ev)
      stash(ev.buf)
    end,
  })

  -- Coming back to a draft means the picker in front of it went away. fzf
  -- reports nothing when you abort it, so this is the only moment we learn
  -- that a prompt chain ended without an answer -- release the draft so ZZ
  -- starts a fresh one instead of being ignored as already dealt with.
  -- Silent: on the way through a successful filing this fires too, the instant
  -- the picker closes and before the title is asked for, and there is nothing
  -- to report then. (Nothing can start a second chain in between, since every
  -- prompt holds the keyboard until it is answered.)
  vim.api.nvim_create_autocmd("BufEnter", {
    group = group,
    pattern = pattern,
    callback = function(ev)
      local name = vim.api.nvim_buf_get_name(ev.buf)
      if handed[name] == "pending" then
        handed[name] = nil
      end
    end,
  })

  -- :bd and tc get you the same thing ZZ does, so muscle memory works.
  vim.api.nvim_create_autocmd("BufDelete", {
    group = group,
    pattern = pattern,
    callback = function(ev)
      M.file(ev.buf)
    end,
  })

  -- Quitting nvim outright is the one moment there is no UI left to ask in, so
  -- anything this nvim still holds goes to the quick-note buffer rather than
  -- nowhere. Driven off `mine` rather than off the open buffers: a draft whose
  -- buffer was closed with :bd and whose picker was then aborted has no buffer
  -- left to find it by, and it would otherwise be left in the drafts directory
  -- without a word. Drafts belonging to another nvim are none of our business.
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = function()
      for draft in pairs(mine) do
        if handed[draft] ~= true then
          local buf = vim.fn.bufnr(draft)
          if buf ~= -1 then
            stash(buf)
          end
          handed[draft] = true
          if vim.fn.filereadable(draft) == 1 then
            local lines = read(draft)
            vim.fn.delete(draft)
            if not blank(lines) then
              append_quick(lines, "nvim exited")
            end
          end
        end
      end
    end,
  })

  vim.api.nvim_create_user_command("ZkNote", function(a)
    M.new({ open = a.args ~= "" and a.args or nil })
  end, { nargs = "?", desc = "zk-note: new draft" })
  vim.api.nvim_create_user_command("ZkNoteFile", function()
    M.file()
  end, { desc = "zk-note: file the current draft" })
  vim.api.nvim_create_user_command("ZkNoteDiscard", function()
    M.discard()
  end, { desc = "zk-note: discard the current draft" })

  if cfg().keymap then
    vim.keymap.set("n", cfg().keymap, function()
      M.new()
    end, { desc = "zk-note: new draft" })
  end
end

return M
