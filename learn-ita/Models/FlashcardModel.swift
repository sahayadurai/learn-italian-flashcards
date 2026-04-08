//
//  FlashcardModel.swift
//  learn-ita
//
//  Created by Sahaya Muthukani Gnanadurai on 08/04/26.
//

import Foundation
import Combine

struct Flashcard: Identifiable {
    let id = UUID()
    let italian: String
    let english: String
}

class FlashcardStore: ObservableObject {
    @Published var cards: [Flashcard] = []
    
    init() {
        loadCards()
    }
    
    func loadCards() {
        guard let url = Bundle.main.url(forResource: "italian-words", withExtension: "psv") else {
            print("Could not find italian-words.psv")
            return
        }
        
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            let lines = content.components(separatedBy: .newlines)
            
            var loadedCards: [Flashcard] = []
            for line in lines.dropFirst() { // Skip header
                let parts = line.components(separatedBy: "|")
                if parts.count >= 2 && !line.isEmpty {
                    let flashcard = Flashcard(italian: parts[0].trimmingCharacters(in: .whitespaces),
                                             english: parts[1].trimmingCharacters(in: .whitespaces))
                    loadedCards.append(flashcard)
                }
            }
            
            DispatchQueue.main.async {
                self.cards = loadedCards
            }
        } catch {
            print("Error loading cards: \(error)")
        }
    }
    
    func getRandomCards(count: Int) -> [Flashcard] {
        return Array(cards.shuffled().prefix(count))
    }
    
    func getRandomWrongAnswers(excludingCorrect: String, count: Int) -> [String] {
        let wrongAnswers = cards
            .filter { $0.english != excludingCorrect }
            .map { $0.english }
            .shuffled()
            .prefix(count)
        return Array(wrongAnswers)
    }
}

struct GameCard {
    let flashcard: Flashcard
    let options: [String] // All three options shuffled
    let correctAnswer: String
}

class GameManager: ObservableObject {
    @Published var currentCardIndex = 0
    @Published var score = 0
    @Published var gameCards: [GameCard] = []
    @Published var selectedAnswer: String?
    @Published var showResult = false
    @Published var isCorrect = false
    @Published var gameOver = false
    
    let cardStore: FlashcardStore
    let totalCards = 10
    private var cardsLoaded = false
    
    init(cardStore: FlashcardStore) {
        self.cardStore = cardStore
        // Wait a moment for cards to load before generating game cards
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if !self.cardsLoaded && !self.cardStore.cards.isEmpty {
                self.cardsLoaded = true
                self.generateGameCards()
            }
        }
    }
    
    func generateGameCards() {
        let selectedCards = cardStore.getRandomCards(count: totalCards)
        
        if selectedCards.isEmpty {
            // If still no cards, try again in a moment
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if self.cardStore.cards.isEmpty {
                    return
                }
                let retryCards = self.cardStore.getRandomCards(count: self.totalCards)
                self.gameCards = retryCards.map { card in
                    return GameCard(flashcard: card, options: self.createRandomizedOptions(correctAnswer: card.english), correctAnswer: card.english)
                }
            }
        } else {
            gameCards = selectedCards.map { card in
                return GameCard(flashcard: card, options: self.createRandomizedOptions(correctAnswer: card.english), correctAnswer: card.english)
            }
        }
    }
    
    private func createRandomizedOptions(correctAnswer: String) -> [String] {
        let wrongAnswers = cardStore.getRandomWrongAnswers(excludingCorrect: correctAnswer, count: 2)
        var allAnswers = wrongAnswers + [correctAnswer]
        
        // Shuffle multiple times for better randomization
        for _ in 0..<3 {
            allAnswers.shuffle()
        }
        
        return allAnswers
    }
    
    func submitAnswer(_ answer: String) {
        guard currentCardIndex < gameCards.count else { return }
        
        let correct = answer == gameCards[currentCardIndex].correctAnswer
        isCorrect = correct
        
        if correct {
            score += 1
        }
        
        showResult = true
    }
    
    func nextCard() {
        currentCardIndex += 1
        selectedAnswer = nil
        showResult = false
        
        if currentCardIndex >= totalCards {
            gameOver = true
        }
    }
    
    func resetGame() {
        currentCardIndex = 0
        score = 0
        selectedAnswer = nil
        showResult = false
        isCorrect = false
        gameOver = false
        generateGameCards()
    }
}
