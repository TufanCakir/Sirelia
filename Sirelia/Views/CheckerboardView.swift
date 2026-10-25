//
//  CheckerboardView.swift
//  Sirelia
//
//  Created by Tufan Cakir on 25.10.26.
//

import SwiftUI

struct CheckerboardView: View {
    var cellSize: CGFloat = 12

    var body: some View {
        Canvas { context, size in
            let columns = Int(ceil(size.width / cellSize))
            let rows = Int(ceil(size.height / cellSize))

            for row in 0..<rows {
                for column in 0..<columns {
                    let rect = CGRect(
                        x: CGFloat(column) * cellSize,
                        y: CGFloat(row) * cellSize,
                        width: cellSize,
                        height: cellSize
                    )

                    let isLight = (row + column).isMultiple(of: 2)

                    context.fill(
                        Path(rect),
                        with: .color(
                            isLight
                                ? Color(white: 0.92)
                                : Color(white: 0.72)
                        )
                    )
                }
            }
        }
        .accessibilityHidden(true)
    }
}
