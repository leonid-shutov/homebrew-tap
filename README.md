# homebrew-tap

Homebrew formulae for my software.

```sh
brew install leonid-shutov/tap/tuigram
```

Installing the fully qualified name is enough — it taps on demand and trusts just that formula, so
no separate `brew tap` or `brew trust` is needed.

| Formula   | What it is                       |
| --------- | -------------------------------- |
| [tuigram] | Telegram client for the terminal |

[tuigram]: https://github.com/leonid-shutov/tuigram

## After a Homebrew node major upgrade

tuigram's session storage uses a compiled sqlite addon, and compiled addons are tied to the Node ABI
they were built for. When Homebrew moves `node` across a major version, reinstall:

```sh
brew reinstall tuigram
```

The formulae are bumped automatically by each app's release workflow.
