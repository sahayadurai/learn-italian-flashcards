//
//  ContentView.swift
//  learn-ita
//
//  Created by Sahaya Muthukani Gnanadurai on 08/04/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var cardStore = FlashcardStore()
    @StateObject private var gameManager: GameManager
    @State private var showGameView = false
    @State private var showPracticeView = false
    
    init() {
        let store = FlashcardStore()
        _cardStore = StateObject(wrappedValue: store)
        _gameManager = StateObject(wrappedValue: GameManager(cardStore: store))
    }

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [.blue.opacity(0.1), .purple.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 10) {
                        Text("Italian Flashcards")
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Master vocabulary with flashcards")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(30)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    
                    Spacer()
                    
                    // Main Menu
                    VStack(spacing: 16) {
                        // Game Mode Card
                        NavigationLink(destination: NavigationView {
                            ZStack {
                                if gameManager.gameOver {
                                    GameResultsView(gameManager: gameManager)
                                } else {
                                    FlashcardGameView(gameManager: gameManager)
                                }
                            }
                        }) {
                            MenuCard(
                                title: "Play Game",
                                subtitle: "Answer 10 questions with multiple choice",
                                icon: "gamecontroller.fill",
                                color: Color.blue
                            )
                        }
                        
                        // Practice Mode Card
                        NavigationLink(destination: PracticeView(cardStore: cardStore)) {
                            MenuCard(
                                title: "Practice Mode",
                                subtitle: "Browse and flip through flashcards",
                                icon: "books.vertical.fill",
                                color: Color.orange
                            )
                        }
                    }
                    .padding(24)
                    
                    Spacer()
                    
                    // Footer
                    VStack(spacing: 8) {
                        Text("Tip: Tap the flashcard to flip and reveal the answer!")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
    }
}

struct MenuCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(color)
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
        .padding(16)
        .background(.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    ContentView()
}
