-- rust-analyzer for Brazil / CargoBrazil packages.
--
-- Why this is needed: CargoBrazil regenerates `rust-toolchain.toml` to point
-- at a custom toolchain (build/private/cargo-brazil-toolchain) that ships no
-- rust-analyzer and no rust-src. The `rust-analyzer` on PATH is a rustup proxy
-- that then errors out. So we:
--   * run the Amazon-built rust-analyzer from toolbox (matches Brazil's rustc
--     ABI for proc-macros), and
--   * point stdlib sources at a user rustup toolchain matching Brazil's rustc
--     version (1.96.0), since the Brazil toolchain has no rust-src, and
--   * give rust-analyzer its own cargo target dir so its `cargo check`
--     artifacts don't collide with `brazil-build` output.
--
-- Version bump: if `build/private/cargo-brazil-toolchain/bin/rustc --version`
-- changes, run `rustup toolchain install <ver> --profile minimal --component
-- rust-src` and update the two paths below.
local brazil_rustc_version = "1.96.0"
local rustup_toolchain = vim.fn.expand("~/.rustup/toolchains/" .. brazil_rustc_version .. "-x86_64-unknown-linux-gnu")

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
            },
          },
        },
      },
    }
  end,
}
