return {
  "nvim-neotest/neotest",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-neotest/neotest-jest",
    "nvim-neotest/neotest-python",
  },
  config = function()
    local status_ok, neotest = pcall(require, "neotest")
    if not status_ok then
      return
    end

    local jest = require("neotest-jest")

    local pytest = require("neotest-python")
    local Path = require("plenary.path")

    neotest.setup({
      summary = {
        open = "botright vsplit | vertical resize 80",
      },
      adapters = {
        jest({
          jestCommand = "npm test --",
          cwd = function(path)
            return vim.fn.getcwd()
          end,
        }),
        pytest({
          dap = { justMyCode = false },
          runner = "pytest",
          --args = { "-v", "-s", "-t" },
          --python = ".venv/bin/python",
          is_test_file = function(file_path)
            if not vim.endswith(file_path, ".py") then
              return false
            end
            local elems = vim.split(file_path, Path.path.sep)
            local file_name = elems[#elems]

            local is_singular = vim.startswith(file_name, "test_") or vim.endswith(file_name, "_test.py")
            local is_plural = vim.startswith(file_name, "tests_") or vim.endswith(file_name, "_tests.py")

            return is_plural or is_singular
          end,
        }),
      },
    })
  end,
}
