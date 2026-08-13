# Source provenance

This snapshot was adapted from the private Tiplu production repository at commit `0762bdb2927ddfa9af65701e5db92cd96a90206b`.

Original production paths:

- `MarriageCardGame/Models/Card.swift`
- `MarriageCardGame/Models/RuleSettings.swift`
- `MarriageCardGame/Models/GameModels.swift`
- `MarriageCardGame/Engines/RulesEngine.swift`
- `MarriageCardGame/Engines/ScoringEngine.swift`

Adaptations for this public package:

- Removed SwiftUI-only card symbols, colors, and hand-sorting presentation.
- Reduced `RuleSettings` to values used by the extracted validators and Maal scorer.
- Removed declaration validation and hand suggestions because those depend on the private game-state reducer and solver.
- Extracted `maalBreakdown` from full zero-sum round settlement and named the boundary `MaalScoringEngine`.
- Added dependency-free XCTest coverage focused on the published boundary.

Card identity, rank wrapping, pure/dirty meld rules, player-count gating, Maal recognition, Marriage detection, repeated-card values, Alter values, and Marriage-allocation optimization are unchanged.
