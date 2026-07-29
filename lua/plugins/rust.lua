-- rust-analyzer for Brazil / CargoBrazil packages.
--
-- Why this is needed: CargoBrazil regenerates `rust-toolchain.toml` to point
-- at a custom toolchain (build/private/cargo-brazil-toolchain) that ships no
-- rust-analyzer and no rust-src. The `rust-analyzer` on PATH is a rustup proxy
-- that then errors out. So we:
--   * run the Amazon-built rust-analyzer from toolbox (matches Brazil's rustc
--     ABI for proc-macros),
--   * put the Brazil toolchain's bin/ first on rust-analyzer's cargo PATH so
--     `cargo metadata` and `cargo clippy` run through Brazil's cargo wrapper
--     (which knows about the offline registry and internal dependencies —
--     the plain rustup cargo cannot resolve `amzn-*` crates from crates.io),
--   * point stdlib sources at a user rustup toolchain matching Brazil's rustc
--     version (1.96.0), since the Brazil toolchain has no rust-src, and
--   * give rust-analyzer its own cargo target dir so its `cargo check`
--     artifacts don't collide with `brazil-build` output (different rustc
--     -> incompatible proc-macro ABI).
--
-- Version bump: if `build/private/cargo-brazil-toolchain/bin/rustc --version`
-- changes, run `rustup toolchain install <ver> --profile minimal --component
-- rust-src` and update `brazil_rustc_version` below.
local brazil_rustc_version = "1.96.0"
local rustup_toolchain = vim.fn.expand("~/.rustup/toolchains/" .. brazil_rustc_version .. "-x86_64-unknown-linux-gnu")

-- Find the Brazil toolchain bin/ dir relative to the current file. Walks up
-- from the buffer until it hits a directory containing
-- `build/private/cargo-brazil-toolchain/bin`, so this works in any brazil
-- workspace, not just the current one.
local function brazil_toolchain_bin()
  local start = vim.fn.expand("%:p:h")
  if start == "" then start = vim.fn.getcwd() end
  local pkg_root = vim.fs.find({ "Cargo.toml", "Config" }, { upward = true, path = start })[1]
  if not pkg_root then return nil end
  local root = vim.fs.dirname(pkg_root)
  local candidate = root .. "/build/private/cargo-brazil-toolchain/bin"
  if vim.uv.fs_stat(candidate) then return candidate end
  return nil
end

return {
  "mrcjkb/rustaceanvim",
  -- To avoid being surprised by breaking changes,
  -- I recommend you set a version range
  version = "^9",
  -- This plugin implements proper lazy-loading (see :h lua-plugin-lazy).
  -- No need for lazy.nvim to lazy-load it.
  lazy = false,
  init = function()
    vim.g.rustaceanvim = {
      server = {
        -- Amazon-built rust-analyzer (bt-rust), installed via toolbox. Point
        -- at the absolute path so the rustup proxy on PATH can't intercept.
        cmd = { vim.fn.expand("~/.toolbox/bin/rust-analyzer") },
        default_settings = {
          ["rust-analyzer"] = {
            cargo = {
              sysroot = rustup_toolchain,
              sysrootSrc = rustup_toolchain .. "/lib/rustlib/src/rust/library",
              targetDir = true,
              -- Force rust-analyzer to invoke the Brazil-provided `cargo`
              -- rather than the rustup proxy at ~/.cargo/bin/cargo. The
              -- rustup proxy uses public crates.io and fails to resolve
              -- internal `amzn-*` crates.
              cargoPath = (function()
                local bin = brazil_toolchain_bin()
                if bin then return bin .. "/cargo" end
                return nil
              end)(),
              -- Also prepend the toolchain bin/ to PATH so any subprocess
              -- (proc-macro server, cargo-clippy, etc.) uses Brazil binaries.
              extraEnv = (function()
                local bin = brazil_toolchain_bin()
                if bin then return { PATH = bin .. ":" .. (vim.env.PATH or "") } end
                return nil
              end)(),
            },
            check = {
              -- Same story for `cargo check` / clippy driving the diagnostics.
              -- Point at Brazil's cargo binary explicitly and let it call
              -- Brazil's clippy driver via the PATH we set above.
              command = "clippy",
              extraEnv = (function()
                local bin = brazil_toolchain_bin()
                if bin then return { PATH = bin .. ":" .. (vim.env.PATH or "") } end
                return nil
              end)(),
              overrideCommand = (function()
                local bin = brazil_toolchain_bin()
                if not bin then return nil end
                return {
                  bin .. "/cargo",
                  "clippy",
                  "--workspace",
                  "--message-format=json-diagnostic-rendered-ansi",
                  "--all-targets",
                  "--keep-going",
                }
              end)(),
            },
          },
        },
      },
    }
  end,
}
