import Foundation

public enum MaalCardRole: Int, Equatable, Sendable {
    case jhiplu
    case tiplu
    case poplu
    case alter
}

public struct MaalCardContribution: Identifiable, Equatable, Sendable {
    public var id: String { card.id }
    public let card: Card
    public let role: MaalCardRole
}

public struct MaalScoringBreakdown: Equatable, Sendable {
    public let total: Int
    public let contributions: [MaalCardContribution]
    public let marriageCount: Int
}

/// Optimizes how repeated Maal cards are allocated between Marriage sets and individual values.
public struct MaalScoringEngine: Sendable {
    public var settings: RuleSettings

    public init(settings: RuleSettings = .nepalStandard) { self.settings = settings }

    public func breakdown(cards: [Card], tiplu: Card?) -> MaalScoringBreakdown {
        guard let tiplu else { return MaalScoringBreakdown(total: 0, contributions: [], marriageCount: 0) }
        let exactTiplu = cards.filter { $0.rank == tiplu.rank && $0.suit == tiplu.suit }.count
        let poplu = cards.filter { $0.suit == tiplu.suit && $0.rank == tiplu.rank.wrappedAdvanced(by: 1) }.count
        let jhiplu = cards.filter { $0.suit == tiplu.suit && $0.rank == tiplu.rank.wrappedAdvanced(by: -1) }.count

        var best = 0
        var bestMarriageCount = 0
        for marriages in 0...min(exactTiplu, poplu, jhiplu) {
            let marriageValue = marriages == 0 ? 0 : (marriages == 1 ? settings.marriagePoints : 30)
            let score = marriageValue
                + repeatedValue(count: exactTiplu - marriages, single: settings.tipluPoints, double: 7)
                + repeatedValue(count: poplu - marriages, single: settings.popluPoints, double: 5)
                + repeatedValue(count: jhiplu - marriages, single: settings.jhipluPoints, double: 5)
            if score > best {
                best = score
                bestMarriageCount = marriages
            }
        }

        if settings.includeAlter {
            let alters = cards.filter { $0.rank == tiplu.rank && $0.suit == tiplu.suit.alterCounterpart }
            best += repeatedValue(count: alters.count, single: 5, double: 15, triple: 25)
        }

        let contributions = cards.compactMap { card -> MaalCardContribution? in
            let role: MaalCardRole
            if settings.includeAlter, card.rank == tiplu.rank, card.suit == tiplu.suit.alterCounterpart {
                role = .alter
            } else if card.suit == tiplu.suit, card.rank == tiplu.rank.wrappedAdvanced(by: -1) {
                role = .jhiplu
            } else if card.suit == tiplu.suit, card.rank == tiplu.rank {
                role = .tiplu
            } else if card.suit == tiplu.suit, card.rank == tiplu.rank.wrappedAdvanced(by: 1) {
                role = .poplu
            } else {
                return nil
            }
            return MaalCardContribution(card: card, role: role)
        }.sorted {
            $0.role.rawValue == $1.role.rawValue
                ? $0.card.deckIndex < $1.card.deckIndex
                : $0.role.rawValue < $1.role.rawValue
        }
        return MaalScoringBreakdown(total: best, contributions: contributions, marriageCount: bestMarriageCount)
    }

    private func repeatedValue(count: Int, single: Int, double: Int, triple: Int = 10) -> Int {
        switch count {
        case ...0: 0
        case 1: single
        case 2: double
        default: triple
        }
    }
}
