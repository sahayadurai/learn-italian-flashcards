//
//  FlashcardGameView.swift
//  learn-ita
//
//  Created by Sahaya Muthukani Gnanadurai on 08/04/26.
//

import SwiftUI

struct FlashcardGameView: View {
    @ObservedObject var gameManager: GameManager
    @State private var rotation: Double = 0
    @State private var showAnswer = false
    
    var currentGame: GameCard? {
        guard gameManager.currentCardIndex < gameManager.gameCards.count else { return nil }
        return gameManager.gameCards[gameManager.currentCardIndex]
    }
    
    var isFlipped: Bool {
        return rotation > 90
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                // Header with score
                HStack {
                    Text("Card \(gameManager.currentCardIndex + 1)/\(gameManager.totalCards)")
                        .font(.headline)
                    Spacer()
                    Text("Score: \(gameManager.score)/\(gameManager.totalCards)")
                        .font(.headline)
                        .foregroundColor(.green)
                }
                .padding()
                
                Spacer()
                
                if let currentGame = currentGame {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [.blue.opacity(0.8), .purple.opacity(0.8)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(height: 250)
                            .shadow(radius: 10)
                        
                        VStack(spacing: 20) {
                            if !isFlipped {
                                // Front Side - Italian Word
                                Text("Italian Word")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                
                                Text(currentGame.flashcard.italian)
                                    .font(.system(size: 48, weight: .bold, design: .default))
                                    .foregroundColor(.white)
                                    .minimumScaleFactor(0.5)
                                    .lineLimit(2)
                                
                                Divider()
                                    .background(.white.opacity(0.3))
                                
                                Text("Tap to reveal answer")
                                    .font(.system(.body, design: .rounded))
                                    .foregroundColor(.white.opacity(0.6))
                            } else {
                                // Back Side - Answer
                                Text("Answer")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                
                                Text(currentGame.flashcard.english)
                                    .font(.system(size: 36, weight: .semibold))
                                    .foregroundColor(.yellow)
                                    .lineLimit(3)
                                    .minimumScaleFactor(0.8)
                            }
                        }
                        .padding(30)
                    }
                    .rotation3DEffect(
                        .degrees(rotation),
                        axis: (x: 0, y: 1, z: 0)
                    )
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.6)) {
                            if rotation == 0 {
                                rotation = 180
                            } else {
                                rotation = 0
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Multiple Choice Options
                    VStack(spacing: 12) {
                        Text("Select the correct answer:")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        ForEach(currentGame.options, id: \.self) { option in
                            OptionButton(
                                text: option,
                                isSelected: gameManager.selectedAnswer == option,
                                isCorrect: gameManager.showResult && option == currentGame.correctAnswer,
                                isWrong: gameManager.showResult && gameManager.selectedAnswer == option && !gameManager.isCorrect,
                                action: {
                                    if !gameManager.showResult {
                                        gameManager.selectedAnswer = option
                                        gameManager.submitAnswer(option)
                                    }
                                }
                            )
                        }
                    }
                    .padding()
                    
                    // Result and Continue Button
                    if gameManager.showResult {
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: gameManager.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(gameManager.isCorrect ? .green : .red)
                                
                                Text(gameManager.isCorrect ? "Correct!" : "Incorrect!")
                                    .font(.headline)
                            }
                            
                            Button(action: {
                                withAnimation {
                                    rotation = 0
                                    gameManager.nextCard()
                                }
                            }) {
                                Text(gameManager.currentCardIndex + 1 >= gameManager.totalCards ? "See Results" : "Next Card")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .padding()
                        .background(.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding()
                    }
                    
                    Spacer()
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundColor(.orange)
                        
                        Text("Loading cards...")
                            .font(.headline)
                    }
                    Spacer()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Ensure game cards are generated when view appears
            if gameManager.gameCards.isEmpty {
                gameManager.generateGameCards()
            }
        }
    }
}

struct OptionButton: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool
    let isWrong: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.body)
                    .foregroundColor(.black)
                    .lineLimit(2)
                
                Spacer()
                
                if isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else if isWrong {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(backgroundColor)
            )
        }
        .disabled(isCorrect || isWrong)
    }
    
    var backgroundColor: Color {
        if isCorrect {
            return .green.opacity(0.2)
        } else if isWrong {
            return .red.opacity(0.2)
        } else if isSelected {
            return .blue.opacity(0.3)
        } else {
            return .gray.opacity(0.1)
        }
    }
}

#Preview {
    let store = FlashcardStore()
    let manager = GameManager(cardStore: store)
    
    return FlashcardGameView(gameManager: manager)
        .environmentObject(manager)
}
