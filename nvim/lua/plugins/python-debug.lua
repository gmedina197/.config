return {
  { "rcarriga/nvim-dap-ui", dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" } },
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      local cwd = vim.fn.getcwd()

      dap.configurations = {
        python = {
          {
            type = "debugpy",
            request = "launch",
            name = "Python: serve API vim",
            -- program = "${workspaceFolder}/api/main.py",
            module = "api.main",
            cwd = "${workspaceFolder}",
            pythonPath = function()
              if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
                return cwd .. "/venv/bin/python"
              elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
                return cwd .. "/.venv/bin/python"
              else
                return "/usr/bin/python"
              end
            end,
          },
        },
      }

      dapui.setup()

      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end

      vim.fn.sign_define("DapBreakpoint", {
        text = "",
        texthl = "DiagnosticSignError",
        linehl = "",
        numhl = "",
      })

      vim.fn.sign_define("DapBreakpointRejected", {
        text = "", -- or "❌"
        texthl = "DiagnosticSignError",
        linehl = "",
        numhl = "",
      })

      vim.fn.sign_define("DapStopped", {
        text = "", -- or "→"
        texthl = "DiagnosticSignWarn",
        linehl = "Visual",
        numhl = "DiagnosticSignWarn",
      })

      vim.keymap.set("n", "<Leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
      vim.keymap.set("n", "<Leader>dc", dap.continue, { desc = "Start/Continue debugger" })
      vim.keymap.set("n", "<Leader>do", dap.step_over, { desc = "Step over" })
      vim.keymap.set("n", "<Leader>di", dap.step_into, { desc = "Step into" })
      vim.keymap.set("n", "<Leader>dO", dap.step_out, { desc = "Step out" })
      vim.keymap.set("n", "<Leader>dq", function()
        dap.terminate()
      end, { desc = "Terminate debugger" })

      local api = vim.api
      local keymap_restore = {}
      dap.listeners.after['event_initialized']['me'] = function()
        for _, buf in pairs(api.nvim_list_bufs()) do
          local keymaps = api.nvim_buf_get_keymap(buf, 'n')
          for _, keymap in pairs(keymaps) do
            if keymap.lhs == "K" then
              table.insert(keymap_restore, keymap)
              api.nvim_buf_del_keymap(buf, 'n', 'K')
            end
          end
        end
        api.nvim_set_keymap(
          'n', 'K', '<Cmd>lua require("dap.ui.widgets").hover()<CR>', { silent = true })
      end

      dap.listeners.after['event_terminated']['me'] = function()
        for _, keymap in pairs(keymap_restore) do
          if keymap.rhs then
            api.nvim_buf_set_keymap(
              keymap.buffer,
              keymap.mode,
              keymap.lhs,
              keymap.rhs,
              { silent = keymap.silent == 1 }
            )
          elseif keymap.callback then
            vim.keymap.set(
              keymap.mode,
              keymap.lhs,
              keymap.callback,
              { buffer = keymap.buffer, silent = keymap.silent == 1 }
            )
          end
        end
        keymap_restore = {}
      end
    end,
  },
  {
    "mfussenegger/nvim-dap-python",
    config = function()
      require("dap-python").setup(vim.g.python3_host_prog)
      require("dap-python").test_runner = "pytest"
    end,
  },
}
