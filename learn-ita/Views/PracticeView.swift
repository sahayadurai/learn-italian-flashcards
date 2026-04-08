//
//  PracticeView.swift
//  learn-ita
//
//  Created by Sahaya Muthukani Gnanadurai on 08/04/26.
//

import SwiftUI

struct PracticeView: View {
    @ObservedObject var cardStore: FlashcardStore
    @State private var shuffledCards: [Flashcard] = []
    @State private var currentIndex = 0
    @State private var rotation: Double = 0
    
    var isFlipped: Bool {
        return rotation > 90
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                // Header
                HStack {
                    Text("Practice Mode")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                    Text("\(currentIndex + 1)/\(shuffledCards.count)")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                .padding()
                
                Spacer()
                
                if shuffledCards.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundColor(.orange)
                        
                        Text("No cards available")
                            .font(.headline)
                    }
                } else if currentIndex < shuffledCards.count {
                    let currentCard = shuffledCards[currentIndex]
                    
                    // Spinning Flashcard
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [.orange.opacity(0.8), .red.opacity(0.8)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(height: 300)
                            .shadow(radius: 10)
                        
                        VStack(spacing: 20) {
                            if !isFlipped {
                                // Front Side - Italian Word
                                Text("Italian Word")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                
                                Text(currentCard.italian)
                                    .font(.system(size: 56, weight: .bold, design: .default))
                                    .foregroundColor(.white)
                                    .minimumScaleFactor(0.5)
                                    .lineLimit(2)
                                
                                Divider()
                                    .background(.white.opacity(0.3))
                                
                                VStack(spacing: 15) {
                                    Image(systemName: "hand.tap")
                                        .font(.system(size: 32))
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    Text("Tap to reveal")
                                        .font(.system(.body, design: .rounded))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            } else {
                                // Back Side - Meaning
                                Text("Meaning")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                
                                Text(currentCard.english)
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
                    .padding()
                    
                    // Navigation Buttons
                    HStack(spacing: 20) {
                        Button(action: previousCard) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Previous")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.gray.opacity(0.2))
                            .cornerRadius(10)
                        }
                        .disabled(currentIndex == 0)
                        .opacity(currentIndex == 0 ? 0.5 : 1.0)
                        
                        Button(action: shuffleCards) {
                            HStack {
                                Image(systemName: "shuffle")
                                Text("Shuffle")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.orange.opacity(0.2))
                            .cornerRadius(10)
                        }
                        
                        Button(action: nextCard) {
                            HStack {
                                Text("Next")
                                Image(systemName: "chevron.right")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue.opacity(0.2))
                            .cornerRadius(10)
                        }
                        .disabled(currentIndex == shuffledCards.count - 1)
                        .opacity(currentIndex == shuffledCards.count - 1 ? 0.5 : 1.0)
                    }
                    .padding()
                }
                
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            shuffledCards = cardStore.cards.shuffled()
        }
    }
    
    func nextCard() {
        if currentIndex < shuffledCards.count - 1 {
            withAnimation {
                rotation = 0
                currentIndex += 1
            }
        }
    }
    
    func previousCard() {
        if currentIndex > 0 {
            withAnimation {
                rotation = 0
                currentIndex -= 1
            }
        }
    }
    
    func shuffleCards() {
        withAnimation {
            shuffledCards.shuffle()
            currentIndex = 0
            rotation = 0
        }
    }
}

#Preview {
    let store = FlashcardStore()
    PracticeView(cardStore: store)
        .environmentObject(store)
}
