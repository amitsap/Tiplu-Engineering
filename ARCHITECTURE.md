# Architecture

The public package isolates two pure boundaries from Tiplu's production architecture.

- `Card.swift` models the 156 distinct physical cards in three standard decks.
- `RulesEngine` validates the culturally specific meld vocabulary and wildcard behavior without UI or network state.
- `MaalScoringEngine` searches valid Marriage allocations before scoring any remaining Maal cards and optional Alter cards.

The production app uses a host-authoritative game-state reducer. Game Center or nearby connectivity transports commands to the host; the host validates them and returns redacted, player-specific snapshots. Bots, networking payloads, saved games, analytics, and presentation code remain private.
