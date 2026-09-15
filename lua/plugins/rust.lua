-- rust-analyzer for Brazil / CargoBrazil packages.
--
-- Why this is needed: CargoBrazil regenerates `rust-toolchain.toml` to point at
-- a custom toolchain (build/private/cargo-brazil-toolchain) that ships no
-- rust-analyzer and no rust-src, and vendors deps into an offline local-registry
-- a plain cargo doesn't know about. The approach that actually works:
--
--   * Run the Amazon-built rust-analyzer from toolbox (its rustc matches
--     Brazil's, so proc-macro .so ABI checks pass).
--   * Put Brazil's toolchain bin/ FIRST on rust-analyzer's PATH. Brazil's
--     `cargo`/`rustc` are self-configuring shims: they locate their own
--     CARGO_HOME (with the crates.io -> offline local-registry source
--     replacement that resolves internal `amzn-*` crates) and their own
--     sysroot. This is how the team's VSCode setup works too.
--   * Do NOT set cargo.sysroot. Doing so makes rust-analyzer inject
--     RUSTUP_TOOLCHAIN / RUSTUP_HOME pointing at ~/.rustup into every cargo
--     call, and Brazil's rustc shim then panics ("Brazil Rustup called with
--     RUSTUP_HOME set to non-Brazil Rustup directory"). We only set
--     sysrootSrc -- the stdlib *source* path for std/core hover & goto -- which
--     does not trigger that injection. rust-src comes from a user rustup
--     toolchain matching Brazil's rustc version (Brazil's has none).
--   * Pin cargo.target to the host triple. Brazil only vendors crates its real
--     build needs, so platform-gated deps (e.g. android_system_properties via
--     chrono -> iana-time-zone) are absent from the registry. Without a target
--     filter, `cargo metadata` resolves the all-platforms graph and fails
--     fetching those. Filtering to the host prunes them.
--   * Give rust-analyzer its own target dir so its check artifacts don't
--     collide with brazil-build output (different rustc -> proc-macro ABI).
--
-- Requires (one-time):
--   toolbox registry add s3://buildertoolbox-registry-bt-rust-registry-us-west-2/tools.json
--   toolbox install --channel head rust-analyzer
--   rustup toolchain install 1.96.0 --profile minimal --component rust-src
-- and a completed `brazil-build` in the package (populates the offline registry
-- and toolchain). If rust-analyzer later errors about a missing crate, re-run
-- `brazil-build sync`.
--
-- Version bump: if `build/private/cargo-brazil-toolchain/bin/rustc --version`
-- changes, run `rustup toolchain install <ver> --profile minimal --component
-- rust-src` and update `brazil_rustc_version` below.
local brazil_rustc_version = "1.96.0"
local host_target = "x86_64-unknown-linux-gnu"
local rust_src = vim.fn.expand("~/.rustup/toolchains/" .. brazil_rustc_version .. "-" .. host_target)
  .. "/lib/rustlib/src/rust/library"

-- Brazil's toolchain bin/ for the package owning `path`, or nil outside a built
-- Brazil package (config then degrades to a plain rust-analyzer). Walk up to the
-- package root and check for the generated toolchain.
local function brazil_toolchain_bin(path)
  local pkg_root = vim.fs.find({ "Config", "Cargo.toml" }, { upward = true, path = path })[1]
  if not pkg_root then return nil end
  local bin = vim.fs.dirname(pkg_root) .. "/build/private/cargo-brazil-toolchain/bin"
  if vim.uv.fs_stat(bin) then return bin end
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
        -- settings is evaluated per-project with the resolved project root, so
        -- the Brazil toolchain PATH tracks whichever brazil package a file
        -- belongs to when editing across several in one session.
        settings = function(project_root)
          local cargo = {
            sysrootSrc = rust_src,
            target = host_target,
            targetDir = true,
          }
          local bin = brazil_toolchain_bin(project_root)
          if bin then
            cargo.extraEnv = { PATH = bin .. ":" .. (vim.env.PATH or "") }
          end
          return { ["rust-analyzer"] = { cargo = cargo } }
        end,
      },
    }
  end,
}
