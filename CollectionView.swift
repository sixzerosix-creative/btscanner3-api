import SwiftUI

struct CollectionView: View {
    @State private var isGalleryView: Bool = true
    @State private var collection: [Card] = [] // Placeholder for collection data

    var body: some View {
        NavigationView {
            VStack {
                // Toggle Buttons for View Modes
                HStack {
                    Button(action: {
                        isGalleryView = true
                    }) {
                        Text("Gallery View")
                            .padding()
                            .background(isGalleryView ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(collection.isEmpty)

                    Button(action: {
                        isGalleryView = false
                    }) {
                        Text("Full-Screen View")
                            .padding()
                            .background(!isGalleryView ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(collection.isEmpty)
                }
                .padding()

                if collection.isEmpty {
                    Text("No cards in collection")
                        .font(.headline)
                        .padding()
                } else {
                    if isGalleryView {
                        GridView(cards: collection)
                    } else {
                        FullScreenCardView(cards: collection)
                    }
                }
            }
            .navigationTitle("My Collection")
        }
    }
}

// ✅ Add GridView inside CollectionView.swift
struct GridView: View {
    var cards: [Card]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
                ForEach(cards) { card in
                    Image(uiImage: card.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 150)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
    }
}

// ✅ Add FullScreenCardView inside CollectionView.swift
struct FullScreenCardView: View {
    var cards: [Card]
    @State private var selectedCardIndex: Int = 0

    var body: some View {
        TabView(selection: $selectedCardIndex) {
            ForEach(cards.indices, id: \.self) { index in
                Image(uiImage: cards[index].image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(12)
                    .padding()
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
    }
}
