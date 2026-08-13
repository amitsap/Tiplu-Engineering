import XCTest
@testable import TipluEngineering

final class RulesEngineTests: XCTestCase {
    private let engine = RulesEngine()

    private func card(_ rank: Rank, _ suit: Suit = .hearts, _ deck: Int = 0) -> Card {
        Card(rank: rank, suit: suit, deckIndex: deck)
    }

    func testMarriageDeckHas156UniqueCards() {
        let deck = Card.marriageDeck()
        XCTAssertEqual(deck.count, 156)
        XCTAssertEqual(Set(deck.map(\.id)).count, 156)
    }

    func testSequenceSupportsAceLowAndAceHigh() {
        XCTAssertEqual(engine.classifyPureMeld([card(.ace), card(.two), card(.three)]), .sequence)
        XCTAssertEqual(engine.classifyPureMeld([card(.queen), card(.king), card(.ace)]), .sequence)
    }

    func testTrialTunnelAndDubleeRequireExactShapes() {
        XCTAssertEqual(engine.classifyPureMeld([card(.five, .hearts), card(.five, .clubs), card(.five, .spades)]), .trial)
        XCTAssertEqual(engine.classifyPureMeld([card(.five, .hearts, 0), card(.five, .hearts, 1), card(.five, .hearts, 2)]), .tunnel)
        XCTAssertEqual(engine.classifyPureMeld([card(.five, .hearts, 0), card(.five, .hearts, 1)]), .dublee)
        XCTAssertNil(engine.classifyPureMeld([card(.five, .hearts, 0), card(.five, .hearts, 1), card(.five, .hearts, 2), card(.five, .hearts, 0)]))
    }

    func testSevenDubleesRequireFourPlayersByDefault() {
        let melds = (0..<7).map { index in
            Meld(cards: [card(Rank.allCases[index], .clubs, 0), card(Rank.allCases[index], .clubs, 1)], type: .dublee)
        }
        XCTAssertFalse(engine.isSevenDubleeShow(melds, playerCount: 3))
        XCTAssertTrue(engine.isSevenDubleeShow(melds, playerCount: 4))
    }

    func testMaalAndMarriageWrapAcrossKingAndAce() {
        let tiplu = card(.ace, .spades)
        XCTAssertTrue(engine.isMaal(card(.king, .spades), tiplu: tiplu))
        XCTAssertTrue(engine.isMaal(card(.two, .spades), tiplu: tiplu))
        XCTAssertTrue(engine.isMarriage([card(.king, .spades), tiplu, card(.two, .spades)], tiplu: tiplu))
    }

    func testWildcardCompletesDirtySequence() {
        let tiplu = card(.seven, .hearts)
        let meld = Meld(
            cards: [card(.three, .clubs), card(.five, .clubs), card(.seven, .spades)],
            type: .dirtySet,
            usesWildcards: true
        )
        XCTAssertTrue(engine.isValidMeld(meld, tiplu: tiplu))
    }
}

final class MaalScoringEngineTests: XCTestCase {
    private func card(_ rank: Rank, _ suit: Suit = .hearts, _ deck: Int = 0) -> Card {
        Card(rank: rank, suit: suit, deckIndex: deck)
    }

    func testSingleMarriageBeatsIndividualValues() {
        let tiplu = card(.seven)
        let cards = [card(.six), tiplu, card(.eight)]
        let result = MaalScoringEngine().breakdown(cards: cards, tiplu: tiplu)
        XCTAssertEqual(result.total, 10)
        XCTAssertEqual(result.marriageCount, 1)
    }

    func testOptimizerKeepsOneOfThreeSetsAsIndividualCards() {
        let tiplu = card(.seven)
        let cards = (0..<3).flatMap { deck in [card(.six, .hearts, deck), card(.seven, .hearts, deck), card(.eight, .hearts, deck)] }
        let result = MaalScoringEngine().breakdown(cards: cards, tiplu: tiplu)
        XCTAssertEqual(result.total, 37)
        XCTAssertEqual(result.marriageCount, 2)
    }

    func testAlterScoringCanBeDisabled() {
        let tiplu = card(.seven)
        let alter = card(.seven, .diamonds)
        XCTAssertEqual(MaalScoringEngine().breakdown(cards: [alter], tiplu: tiplu).total, 5)
        var settings = RuleSettings.nepalStandard
        settings.includeAlter = false
        XCTAssertEqual(MaalScoringEngine(settings: settings).breakdown(cards: [alter], tiplu: tiplu).total, 0)
    }
}
