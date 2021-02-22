//
//  ColorEntry.swift
//  Laputa
//
//  Created by Cynthia Jia on 2/21/21.
//

import SwiftUI

struct ColorEntry: View {
    let colorInfo: ColorInfo
    
    var body: some View {
        HStack {
            Circle()
                .fill(colorInfo.color)
                .frame(width: 40, height: 40)
                .padding(.all)
            Text(colorInfo.displayName)
        }
    }
}
