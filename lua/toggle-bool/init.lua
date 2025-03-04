local M = {}
M.conf = {
  mapping = '<leader>tt',
  toggles = {
    ['false'] = 'true',
    ['False'] = 'True',
  },
}

-- Finds the first ocurrence of a toggle word in a line
local function find_toggle_word(line, start)
  local found_word, substitute_word = '', ''
  local min_index = #line + 1
  local ocurrences = {}

  -- Finds first ocurrences of all toggle words
  for key, value in pairs(M.conf.toggles) do
    local key_index = line:find(key, start)
    local value_index = line:find(value, start)

    if key_index then
      table.insert(ocurrences, { index = key_index, found_word = key, substitute_word = value })
    end

    if value_index then
      table.insert(ocurrences, { index = value_index, found_word = value, substitute_word = key })
    end
  end

  -- Finds the first ocurrence of all ocurrences
  for _, ocurrence in ipairs(ocurrences) do
    if ocurrence.index < min_index or (ocurrence.index == min_index and #ocurrence.found_word > #found_word) then
      min_index = ocurrence.index
      found_word = ocurrence.found_word
      substitute_word = ocurrence.substitute_word
    end
  end

  return found_word, substitute_word, min_index - 1
end

M.toggle_bool = function()
  if vim.o.modifiable == false then
    vim.print 'toggl-bool.nvim: Cannot toggle. Buffer is not modifiable.'
    return
  end

  local line = vim.api.nvim_get_current_line()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))

  local found_word, substitute_word, pos = find_toggle_word(line, col + 1)

  -- ::continue::
  if found_word ~= '' then
    -- Check if found_word is part of a bigger word
    -- local before, after = pos - 1 , pos + found_word:len()
    -- if (pos > 1 and line:sub(before, before + 1):match("%w"))
    -- 	or (after < line:len() and line:sub(after, after + 1):match("%w"))
    -- then
    --
    -- 	pos = pos + 2
    -- 	found_word, substitute_word, pos = find_toggle_word(line, pos)
    -- 	goto continue
    -- end

    local sub_line = line:sub(pos + 1)
    local new_line = line:sub(1, pos) .. sub_line:gsub(found_word, substitute_word, 1)

    vim.api.nvim_set_current_line(new_line)
    vim.api.nvim_win_set_cursor(0, { row, pos })
  end
end

M.setup = function(opts)
  opts = opts or {}
  if opts.additional_toggles then
    M.conf.toggles = vim.tbl_extend('force', M.conf.toggles, opts.additional_toggles)
  end
  if opts.mapping then
    M.conf.mapping = opts.mapping
  end
  vim.keymap.set('n', M.conf.mapping, M.toggle_bool, { desc = opts.map_description or 'Toggle bool/option' })
end

return M
-- vim: ts=2
