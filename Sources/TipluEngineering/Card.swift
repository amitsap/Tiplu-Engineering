import Foundation

public enum Suit: String, CaseIterable, Codable, Hashable, Sendable {
    case hearts
    case diamonds
    case clubs
    case spades

    public var shortName: String {
        switch self {
        case .hearts: "H"
        case .diamonds: "D"
        case .clubs: "C"
        case .spades: "S"
        }
    }

    public var alterCounterpart: Self {
        switch self {
        case .hearts: .diamonds
        case .diamonds: .hearts
        case .clubs: .spades
        case .spades: .clubs
        }
    }
}

public enum Rank: Int, CaseIterable, Codable, Comparable, Hashable, Sendable {
    case ace = 1, two, three, four, five, six, seven, eight, nine, ten, jack, queen, king

    public static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }

    public var label: String {
        switch self {
        case .ace: "A"
        case .jack: "J"
        case .queen: "Q"
        case .king: "K"
        default: "\(rawValue)"
        }
    }

    public func advanced(by offset: Int) -> Self? { Self(rawValue: rawValue + offset) }

    public func wrappedAdvanced(by offset: Int) -> Self {
        let wrapped = (((rawValue - 1 + offset) % 13) + 13) % 13
        return Self(rawValue: wrapped + 1) ?? .ace
    }
}

public struct Card: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let rank: Rank
    public let suit: Suit
    public let deckIndex: Int

    public init(rank: Rank, suit: Suit, deckIndex: Int) {
        self.rank = rank
        self.suit = suit
        self.deckIndex = deckIndex
        id = "\(deckIndex)-\(suit.rawValue)-\(rank.rawValue)"
    }

    public var displayName: String { "\(rank.label)\(suit.shortName)" }

    public static func marriageDeck() -> [Self] {
        (0..<3).flatMap { deckIndex in
            Suit.allCases.flatMap { suit in
                Rank.allCases.map { rank in Self(rank: rank, suit: suit, deckIndex: deckIndex) }
            }
        }
    }
}
