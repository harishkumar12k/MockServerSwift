//
//  FileDetailView.swift
//  MockServerSwift
//
//  Created by Harish Kumar on 21/04/26.
//

import SwiftUI

struct FileDetailView: View {
    let fileURL: URL
    @State private var content: String = "Loading..."

    var body: some View {
        ScrollView {
            Text(content)
                .font(.system(.body, design: .monospaced))
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(fileURL.lastPathComponent)
        .onAppear(perform: readFileContent)
    }

    func readFileContent() {
        do {
            let data = try String(contentsOf: fileURL, encoding: .utf8)
            self.content = data
        } catch {
            self.content = "Error reading file: \(error.localizedDescription)"
        }
    }
}
