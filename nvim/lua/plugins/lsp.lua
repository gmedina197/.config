return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
      servers = {
        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "off",
              },
            },
          },
        },
      },
    },
  },
}
