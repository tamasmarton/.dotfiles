-- Debugger (DAP): Go (delve) és Java (java-debug-adapter, az nvim-jdtls köti be).
-- Billentyűk VS Code-szerűen (F5, F9, F10, F11) és <leader>b… alatt.
return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" }, opts = {} },
      { "theHamsta/nvim-dap-virtual-text", opts = { virt_text_pos = "eol" } },
      { "leoluz/nvim-dap-go", opts = {} },
    },
    keys = {
      { "<F5>", function() require("dap").continue() end, desc = "Debug: indítás / folytatás" },
      { "<F9>", function() require("dap").toggle_breakpoint() end, desc = "Debug: breakpoint" },
      { "<F10>", function() require("dap").step_over() end, desc = "Debug: step over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Debug: step into" },
      { "<S-F11>", function() require("dap").step_out() end, desc = "Debug: step out" },
      { "<leader>bb", function() require("dap").toggle_breakpoint() end, desc = "Breakpoint ki/be" },
      {
        "<leader>bc",
        function() require("dap").set_breakpoint(vim.fn.input("Feltétel: ")) end,
        desc = "Feltételes breakpoint",
      },
      { "<leader>br", function() require("dap").continue() end, desc = "Debug indítása / folytatása" },
      { "<leader>bl", function() require("dap").run_last() end, desc = "Utolsó debug újra" },
      { "<leader>bo", function() require("dap").step_over() end, desc = "Step over" },
      { "<leader>bi", function() require("dap").step_into() end, desc = "Step into" },
      { "<leader>bO", function() require("dap").step_out() end, desc = "Step out" },
      { "<leader>bx", function() require("dap").terminate() end, desc = "Debug leállítása" },
      { "<leader>bu", function() require("dapui").toggle() end, desc = "Debug UI ki/be" },
      { "<leader>be", function() require("dapui").eval() end, mode = { "n", "v" }, desc = "Kifejezés kiértékelése" },
      { "<leader>bt", function() require("dap-go").debug_test() end, desc = "Go: teszt debugolása" },
    },
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      -- A UI automatikusan nyílik / záródik
      dap.listeners.after.event_initialized.dapui = function() dapui.open() end
      dap.listeners.before.event_terminated.dapui = function() dapui.close() end
      dap.listeners.before.event_exited.dapui = function() dapui.close() end

      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn" })
      vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticOk", linehl = "Visual" })
    end,
  },
  -- Java: a konfigurációt az ftplugin/java.lua indítja, itt csak a plugin betöltése
  { "mfussenegger/nvim-jdtls", ft = "java" },
}
