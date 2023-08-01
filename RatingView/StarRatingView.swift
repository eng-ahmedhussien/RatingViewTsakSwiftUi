//
//  StarRatingView.swift
//  AlDwaaNewApp
//
//  Created by ahmed hussien on 30/05/2023.
//

import SwiftUI

struct StarRatingView: View {

    @State private var rating = 4.0

    var body: some View {
        RatingView($rating, stat: .editable )
            .font(.system(size: 32, weight: .bold))
            .foregroundColor(.yellow)
            .padding()
    }
}
struct RatingView: View {

    let maxRating: Int
    var stat : Ratingstate
    @Binding var rating: Double

    @State private var starSize: CGSize = .zero
    @State private var controlSize: CGSize = .zero
    @GestureState private var dragging: Bool = false

    init(_ rating: Binding<Double>, maxRating: Int = 5, stat :Ratingstate) {
        _rating = rating
        self.maxRating = maxRating
        self.stat = stat
    }

    var body: some View {
        ZStack {
            HStack {
                ForEach(0..<Int(rating), id: \.self) { idx in
                    fullStar
                }

                if (rating != floor(rating)) {
                    halfStar
                }

                ForEach(0..<Int(Double(maxRating) - rating), id: \.self) { idx in
                    emptyStar
                }
            }
            .background(
                GeometryReader { proxy in
                    Color.clear.preference(key: ControlSizeKey.self, value: proxy.size)
                }
            )
            .onPreferenceChange(StarSizeKey.self) { size in
                starSize = size
            }
            .onPreferenceChange(ControlSizeKey.self) { size in
                controlSize = size
            }

            Color.clear
                .frame(width: controlSize.width, height: controlSize.height)
                .contentShape(Rectangle())
                .gesture( DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged { value in
                    if stat == .editable{
                        rating = rating(at: value.location)
                        print("rating = \(rating)")
                    }
                    else {}
                }
                )
        }
    }

    private var fullStar: some View {
        Image(systemName: "star.fill")
            .star(size: starSize)
    }

    private var halfStar: some View {
        Image(systemName: "star.leadinghalf.fill")
            .star(size: starSize)
    }

    private var emptyStar: some View {
        Image(systemName: "star")
            .star(size: starSize)
    }

    private func rating(at position: CGPoint) -> Double {
        let singleStarWidth = starSize.width
        let totalPaddingWidth = controlSize.width - CGFloat(maxRating)*singleStarWidth
        let singlePaddingWidth = totalPaddingWidth / (CGFloat(maxRating) - 1)
        let starWithSpaceWidth = Double(singleStarWidth + singlePaddingWidth)
        let x = Double(position.x)

        let starIdx = Int(x / starWithSpaceWidth)
        let starPercent = x.truncatingRemainder(dividingBy: starWithSpaceWidth) / Double(singleStarWidth) * 100

        let rating: Double
        if starPercent < 25 {
            rating = Double(starIdx)
        } else if starPercent <= 75 {
            rating = Double(starIdx) + 0.5
        } else {
            rating = Double(starIdx) + 1
        }

        return min(Double(maxRating), max(0, rating))
    }
}

struct StarRatingView_Previews: PreviewProvider {
    static var previews: some View {
        StarRatingView()
    }
}

protocol SizeKey: PreferenceKey { }
extension SizeKey {
    static var defaultValue: CGSize { .zero }
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        let next = nextValue()
        value = CGSize(width: max(value.width, next.width), height: max(value.height, next.height))
    }
}
struct StarSizeKey: SizeKey { }
struct ControlSizeKey: SizeKey { }
















