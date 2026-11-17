-- Java: nvim-jdtls (Eclipse JDT Language Server), Lombok, debug és teszt futtatás.
-- A jdtls-hez Java 21+ kell a PATH-ban (mise: java = temurin-25).
-- Projektenként más JDK: mise use java@temurin-17 a projektben — a jdtls ezt használja buildre.
local ok, jdtls = pcall(require, "jdtls")
if not ok then return end

local mason = vim.fn.stdpath("data") .. "/mason"
local jdtls_pkg = mason .. "/packages/jdtls"
if vim.fn.executable(mason .. "/bin/jdtls") == 0 then
  vim.notify("jdtls nincs telepítve (:Mason)", vim.log.levels.WARN)
  return
end

local root_dir = vim.fs.root(0, { "mvnw", "gradlew", "settings.gradle", "settings.gradle.kts", "pom.xml", "build.gradle", "build.gradle.kts", ".git" })
if not root_dir then return end

-- Projektenként külön jdtls workspace
local workspace = vim.fn.stdpath("cache") .. "/jdtls/" .. root_dir:gsub("[/\\:]", "%%")

-- Debug és teszt bundle-ök (mason: java-debug-adapter, java-test)
local bundles = vim.fn.glob(mason .. "/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar", true, true)
for _, jar in ipairs(vim.fn.glob(mason .. "/packages/java-test/extension/server/*.jar", true, true)) do
  local name = vim.fn.fnamemodify(jar, ":t")
  if name ~= "com.microsoft.java.test.runner-jar-with-dependencies.jar" and name ~= "jacocoagent.jar" then
    table.insert(bundles, jar)
  end
end

local cmd = { mason .. "/bin/jdtls", "-data", workspace }
local lombok = jdtls_pkg .. "/lombok.jar"
if vim.uv.fs_stat(lombok) then
  table.insert(cmd, "--jvm-arg=-javaagent:" .. lombok)
end

local extendedClientCapabilities = jdtls.extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

jdtls.start_or_attach({
  cmd = cmd,
  root_dir = root_dir,
  capabilities = require("blink.cmp").get_lsp_capabilities(),
  init_options = { bundles = bundles, extendedClientCapabilities = extendedClientCapabilities },
  settings = {
    java = {
      eclipse = { downloadSources = true },
      maven = { downloadSources = true },
      configuration = { updateBuildConfiguration = "interactive" },
      implementationsCodeLens = { enabled = true },
      referencesCodeLens = { enabled = true },
      inlayHints = { parameterNames = { enabled = "literals" } },
      signatureHelp = { enabled = true },
      format = { enabled = true },
      saveActions = { organizeImports = false },
      completion = {
        favoriteStaticMembers = {
          "org.junit.jupiter.api.Assertions.*",
          "org.assertj.core.api.Assertions.*",
          "org.mockito.Mockito.*",
          "org.mockito.ArgumentMatchers.*",
          "java.util.Objects.requireNonNull",
        },
        importOrder = { "java", "javax", "jakarta", "org", "com", "" },
      },
      sources = { organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 } },
    },
  },
  on_attach = function(_, bufnr)
    -- debug: a main osztályok automatikusan bekerülnek a DAP konfigurációk közé
    jdtls.setup_dap({ hotcodereplace = "auto" })
    pcall(function() require("jdtls.dap").setup_dap_main_class_configs() end)

    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end
    map("n", "<leader>jo", jdtls.organize_imports, "Java: importok rendezése")
    map("n", "<leader>jt", jdtls.test_nearest_method, "Java: legközelebbi teszt")
    map("n", "<leader>jT", jdtls.test_class, "Java: teszt osztály")
    map({ "n", "v" }, "<leader>jv", jdtls.extract_variable, "Java: változó kiemelése")
    map({ "n", "v" }, "<leader>jc", jdtls.extract_constant, "Java: konstans kiemelése")
    map("v", "<leader>jm", function() jdtls.extract_method(true) end, "Java: metódus kiemelése")
    map("n", "<leader>ju", "<cmd>JdtUpdateConfig<CR>", "Java: build config frissítése")
  end,
})
