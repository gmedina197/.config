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
            program = "${workspaceFolder}/api/main.py",
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
