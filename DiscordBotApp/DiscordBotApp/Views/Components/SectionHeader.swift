//
//  File.swift
//  DiscordBotApp
//
//  Created by speedy on 2024/12/24.
//

import SwiftUI

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(Theme.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SectionHeader_Previews: PreviewProvider {
    static var previews: some View {
        SectionHeader(title: "SECTION TITLE")
            .padding()
            .background(Theme.primaryBackground)
    }
}
