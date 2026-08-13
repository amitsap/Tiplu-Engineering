# Tiplu — engineering Nepali Marriage card rules

Tiplu is a native iPhone implementation of the 3-deck Nepali Marriage card game. This repository is a **curated, buildable engineering extract** of its rule validation and Maal scoring—not the production game repository.

[View Tiplu on the App Store](https://apps.apple.com/us/app/tiplu-nepali-marriage/id6789902799) · [Product page](https://amitsapkota.me/tiplu/)

![Tiplu game table](docs/images/hero.png)

## What to inspect

- [`Rules.swift`](Sources/TipluEngineering/Rules.swift): sequence, trial, tunnel, dublee, Marriage, wildcard, and seven-dublee rules across three physical decks.
- [`MaalScoringEngine.swift`](Sources/TipluEngineering/MaalScoringEngine.swift): an optimization pass that assigns repeated Jhiplu/Tiplu/Poplu cards to the highest-valued mix of Marriage sets and individual values.
- [`EngineTests.swift`](Tests/TipluEngineeringTests/EngineTests.swift): boundary-heavy examples including Ace wrapping, duplicate physical cards, player-count gates, and scoring allocation.
- [`SOURCE_PROVENANCE.md`](SOURCE_PROVENANCE.md): exact production commit, original paths, and adaptations.

The private production app also includes bots, persistence, Game Center, Multipeer Connectivity, and the full game-state reducer. Hosts validate actions and send each peer a personalized snapshot that omits opponents' cards; production payloads and identifiers are intentionally absent here.

## Run the package

```sh
swift test
```

Requires Swift 6. The package depends only on Foundation and XCTest.

## Product screens

| Maal guidance | Local multiplayer | In-app learning |
|---|---|---|
| ![Maal](docs/images/maal.png) | ![Multiplayer](docs/images/multiplayer.png) | ![Learn](docs/images/learn.png) |

## Use

The source is published for portfolio review. It is not an open-source grant; see [`LICENSE`](LICENSE).
