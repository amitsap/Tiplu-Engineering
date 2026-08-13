import Foundation

public enum MeldType: String, CaseIterable, Codable, Sendable {
    case sequence
    case trial
    case tunnel
    case dirtySet
    case dublee
    case marriage
}

public struct Meld: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID
    public var cards: [Card]
    public var type: MeldType
    public var usesWildcards: Bool

    public init(id: UUID = UUID(), cards: [Card], type: MeldType, usesWildcards: Bool = false) {
        self.id = id
        self.cards = cards
        self.type = type
        self.usesWildcards = usesWildcards
    }
}

public struct RuleSettings: Codable, Hashable, Sendable {
    public var allowDublees: Bool
    public var dubleeRequiresFourOrMorePlayers: Bool
    public var includeAlter: Bool
    public var tipluPoints: Int
    public var popluPoints: Int
    public var jhipluPoints: Int
    public var marriagePoints: Int

    public init(
        allowDublees: Bool = true,
        dubleeRequiresFourOrMorePlayers: Bool = true,
        includeAlter: Bool = true,
        tipluPoints: Int = 3,
        popluPoints: Int = 2,
        jhipluPoints: Int = 2,
        marriagePoints: Int = 10
    ) {
        self.allowDublees = allowDublees
        self.dubleeRequiresFourOrMorePlayers = dubleeRequiresFourOrMorePlayers
        self.includeAlter = includeAlter
        self.tipluPoints = tipluPoints
        self.popluPoints = popluPoints
        self.jhipluPoints = jhipluPoints
        self.marriagePoints = marriagePoints
    }

    public static let nepalStandard = Self()
}

/// Pure validation for the distinctive three-deck Marriage meld rules.
public struct RulesEngine: Sendable {
    public var settings: RuleSettings

    public init(settings: RuleSettings = .nepalStandard) { self.settings = settings }

    public func classifyPureMeld(_ cards: [Card]) -> MeldType? {
        let sorted = cards.sortedForRules()
        if isDublee(sorted) { return .dublee }
        if isTunnel(sorted) { return .tunnel }
        if isTrial(sorted) { return .trial }
        if isSequence(sorted) { return .sequence }
        return nil
    }

    public func isPureMeld(_ meld: Meld) -> Bool {
        guard !meld.usesWildcards, let type = classifyPureMeld(meld.cards) else { return false }
        return type == meld.type
    }

    public func isSevenDubleeShow(_ melds: [Meld], playerCount: Int) -> Bool {
        settings.allowDublees
            && (!settings.dubleeRequiresFourOrMorePlayers || playerCount >= 4)
            && melds.count == 7
            && melds.allSatisfy { classifyPureMeld($0.cards) == .dublee }
    }

    public func isMaal(_ card: Card, tiplu: Card?) -> Bool {
        guard let tiplu else { return false }
        if card.rank == tiplu.rank { return true }
        guard card.suit == tiplu.suit else { return false }
        return card.rank == tiplu.rank.wrappedAdvanced(by: 1)
            || card.rank == tiplu.rank.wrappedAdvanced(by: -1)
    }

    public func isMarriage(_ cards: [Card], tiplu: Card?) -> Bool {
        guard let tiplu, cards.count == 3, cards.allSatisfy({ $0.suit == tiplu.suit }) else { return false }
        return Set(cards.map(\.rank)) == Set([
            tiplu.rank.wrappedAdvanced(by: -1), tiplu.rank, tiplu.rank.wrappedAdvanced(by: 1),
        ])
    }

    public func isValidMeld(_ meld: Meld, tiplu: Card?) -> Bool {
        if meld.type == .marriage { return isMarriage(meld.cards, tiplu: tiplu) }
        if isPureMeld(meld) { return true }
        guard meld.cards.count >= 3 else { return false }
        let wildcards = meld.cards.filter { isMaal($0, tiplu: tiplu) }
        let naturals = meld.cards.filter { !isMaal($0, tiplu: tiplu) }
        guard !wildcards.isEmpty, !naturals.isEmpty else { return false }
        return isDirtyTrial(naturals: naturals, wildcards: wildcards)
            || isDirtySequence(naturals: naturals, wildcards: wildcards)
    }

    private func isTrial(_ cards: [Card]) -> Bool {
        cards.count == 3 && Set(cards.map(\.rank)).count == 1 && Set(cards.map(\.suit)).count == 3
    }

    private func isTunnel(_ cards: [Card]) -> Bool {
        cards.count == 3 && Set(cards.map(\.rank)).count == 1 && Set(cards.map(\.suit)).count == 1
            && Set(cards.map(\.deckIndex)).count == cards.count
    }

    private func isSequence(_ cards: [Card]) -> Bool {
        guard (3...13).contains(cards.count), Set(cards.map(\.suit)).count == 1 else { return false }
        let ranks = cards.map(\.rank.rawValue).sorted()
        guard Set(ranks).count == ranks.count else { return false }
        if zip(ranks, ranks.dropFirst()).allSatisfy({ $1 == $0 + 1 }) { return true }
        guard ranks.contains(1) else { return false }
        let wrapped = ranks.map { $0 == 1 ? 14 : $0 }.sorted()
        return zip(wrapped, wrapped.dropFirst()).allSatisfy { $1 == $0 + 1 }
    }

    private func isDublee(_ cards: [Card]) -> Bool {
        cards.count == 2 && Set(cards.map(\.rank)).count == 1 && Set(cards.map(\.suit)).count == 1
            && cards[0].deckIndex != cards[1].deckIndex
    }

    private func isDirtyTrial(naturals: [Card], wildcards: [Card]) -> Bool {
        naturals.count + wildcards.count == 3 && !wildcards.isEmpty
            && Set(naturals.map(\.rank)).count == 1 && Set(naturals.map(\.suit)).count == naturals.count
    }

    private func isDirtySequence(naturals: [Card], wildcards: [Card]) -> Bool {
        let count = naturals.count + wildcards.count
        guard (3...13).contains(count), !wildcards.isEmpty, !naturals.isEmpty,
              Set(naturals.map(\.suit)).count == 1,
              Set(naturals.map(\.rank)).count == naturals.count else { return false }
        let ranks = Set(naturals.map(\.rank.rawValue))
        return sequenceRankWindows(length: count).contains { ranks.isSubset(of: Set($0)) }
    }

    private func sequenceRankWindows(length: Int) -> [[Int]] {
        guard (3...13).contains(length) else { return [] }
        var windows = (1...(14 - length)).map { Array($0..<($0 + length)) }
        windows.append(((15 - length)...14).map { $0 == 14 ? Rank.ace.rawValue : $0 })
        return windows
    }
}

private extension Array where Element == Card {
    func sortedForRules() -> [Card] {
        sorted {
            if $0.suit != $1.suit { return $0.suit.rawValue < $1.suit.rawValue }
            if $0.rank != $1.rank { return $0.rank < $1.rank }
            return $0.deckIndex < $1.deckIndex
        }
    }
}
