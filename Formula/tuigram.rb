class Tuigram < Formula
  include Language::Node::Shebang

  desc "Terminal UI client for Telegram"
  homepage "https://github.com/leonid-shutov/tuigram"
  url "https://registry.npmjs.org/tuigram/-/tuigram-1.0.0.tgz"
  sha256 "4dd0b3306690cf9d0075888cd09c1fb93106874878f0e149d510cd290cee74c9"
  license "MIT"

  # opentui's prebuilt libopentui.dylib has no header padding, so Homebrew cannot rewrite its
  # `@rpath/libopentui.dylib` ID into an absolute one -- and does not need to: node:ffi dlopens
  # the file by absolute path, and nothing links against it.
  preserve_rpath

  depends_on "node"

  def install
    # better-sqlite3 (@mtcute/node's session storage) unpacks a native addon from its install
    # script, so scripts have to run and npm's allow-list has to name it: with --ignore-scripts,
    # or a user whose npm config is strict, there is no better_sqlite3.node and the client dies on
    # first login. --min-release-age=1 refuses a version published less than a day ago, which is
    # exactly what CI bumps this formula to. Dropping --build-from-source lets prebuild-install
    # fetch the prebuilt addon (2s rather than 80s of compiling); it falls back to node-gyp on its
    # own if a prebuilt is ever missing.
    args = std_npm_args(ignore_scripts: false).reject do |arg|
      arg.include?("min-release-age") || arg.include?("build-from-source")
    end
    system "npm", "install", "--allow-scripts=better-sqlite3", *args

    # npm leaves `#!/usr/bin/env node`, so tuigram would run under whichever node is first on
    # PATH -- a version manager's node 22 crashes it. It needs >= 26.4 for node:ffi, and
    # better_sqlite3.node is ABI-bound to the node it was fetched for.
    rewrite_shebang detected_node_shebang, libexec/"lib/node_modules/tuigram/bin/tuigram.js"

    bin.install_symlink libexec.glob("bin/*")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/tuigram --version")

    modules = libexec/"lib/node_modules/tuigram/node_modules"
    # the Zig terminal backend arrives as a platform-specific optional dependency
    refute_empty modules.glob("@opentui/core-*/libopentui.*")
    # the sqlite addon -- this is the assertion that fails after a node major bump
    system Formula["node"].opt_bin/"node", "-e", "require('#{modules}/better-sqlite3')"
  end
end
