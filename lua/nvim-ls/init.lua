local telescope = require('telescope')
local builtin = require('telescope.builtin')
local ls = require('telescope.extensions.luasnip').luasnip

local make_ls_picker = function()
  local ls_output = io.popen('ls -l'):read('*a')
  local ls_lines = vim.split(ls_output, '\n')

  local ls_items = {}
  for _, line in ipairs(ls_lines) do
    local file_name = string.match(line, '(%S+)$')
    local file_path = '.' .. '/' .. file_name
    local file_info = vim.fn.stat(file_path)

    local file_type = ''
    if file_info.type == 'directory' then
      file_type = 'dir'
    elseif file_info.type == 'file' then
      file_type = 'file'
    end

    local file_size = file_info.size
    local file_permissions = file_info.permissions

    local file_icon = ''
    if file_type == 'dir' then
      file_icon = ''
    elseif file_type == 'file' then
      file_icon = ''
    end

    local file_item = {
      value = file_name,
      display = file_icon .. ' ' .. file_name,
      ordinal = file_name,
      filename = file_name,
      filetype = file_type,
      filesize = file_size,
      filepermissions = file_permissions,
    }

    table.insert(ls_items, file_item)
  end

  telescope.pickers.new(
    {
      prompt_title = 'ls',
      finder = ls,
      sorter = require('telescope.sorters').get_generic_fuzzy_sorter(),
      attach_mappings = function(prompt_bufnr)
        local actions = require('telescope.actions')

        actions.select_default:replace(function()
          local selection = require('telescope.actions.state').get_selected_entry()
          local file_name = selection.filename
          local file_path = '.' .. '/' .. file_name

          if vim.fn.isdirectory(file_path) == 1 then
            vim.cmd('edit ' .. file_path)
          else
            vim.cmd('edit ' .. file_path)
          end

          return require('telescope.actions').close(prompt_bufnr)
        end)

        return true
      end,
    },
    {
      results = ls_items,
    }
  ):find()
end

return {
  make_ls_picker = make_ls_picker,
}
