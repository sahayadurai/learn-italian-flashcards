//
//  GameResultsView.swift
//  learn-ita
//
//  Created by Sahaya Muthukani Gnanadurai on 08/04/26.
//

import SwiftUI

struct GameResultsView: View {
    @ObservedObject var gameManager: GameManager
    @Environment(\.presentationMode) var presentationMode
    
    var scorePercentage: Double {
        Double(gameManager.score) / Double(gameManager.totalCards) * 100
    }
    
    var resultMessage: String {
        if gameManager.score == gameManager.totalCards {
            return "Perfect! 🎉"
        } else if gameManager.score >= 8 {
            return "Great! 👏"
        } else if gameManager.score >= 6 {
            return "Good job! 💪"
        } else {
            return "Keep practicing! 📚"
        }
    }
    
    var resultColor: Color {
        if gameManager.score == gameManager.totalCards {
            return .green
        } else if gameManager.score >= 8 {
            return .blue
        } else if gameManager.score >= 6 {
            return .orange
        } else {
            return .red
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.blue.opacity(0.1), .purple.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Result Message
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(resultColor.opacity(0.2))
                            .frame(width: 120, height: 120)
                        
                        VStack(spacing: 10) {
                            Text("\(gameManager.score)")
                                .font(.system(size: 56, weight: .bold))
                                .foregroundColor(resultColor)
                            
                            Text("/ \(gameManager.totalCards)")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Text(resultMessage)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(resultColor)
                    
                    Text("\(Int(scorePercentage))% Correct")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                
                // Score Breakdown
                VStack(spacing: 16) {
                    ScoreRow(label: "Correct Answers", value: gameManager.score, color: .green)
                    ScoreRow(label: "Incorrect Answers", value: gameManager.totalCards - gameManager.score, color: .red)
                }
                .padding()
                .background(.white)
                .cornerRadius(15)
                .padding()
                
                Spacer()
                
                // Action Button
                VStack(spacing: 12) {
                    Button(action: {
                        gameManager.resetGame()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Try Again")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .font(.headline)
                    }
                }
                .padding()
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct ScoreRow: View {
    let label: String
    let value: Int
    let color: Color
    
    var body: some View {
        HStack {
            HStack(spacing: 10) {
                Circle()
                    .fill(color)
                    .frame(width: 12, height: 12)
                
                Text(label)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Text("\(value)")
                .font(.headline)
                .foregroundColor(color)
        }
    }
}

#Preview {
    let store = FlashcardStore()
    let manager = GameManager(cardStore: store)
    manager.score = 9
    
    return GameResultsView(gameManager: manager)
        .environmentObject(manager)
}
