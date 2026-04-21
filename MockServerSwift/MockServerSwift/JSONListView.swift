//
//  JSONListView.swift
//  MockServerSwift
//
//  Created by Harish Kumar on 21/04/26.
//

import SwiftUI

struct JSONListView: View {
    @State private var files: [URL] = []
    @State private var fileToDelete: URL?
    @State private var showingDeleteAlert = false
    @State private var selection: URL?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(files, id: \.self) { file in
                    NavigationLink(destination: FileDetailView(fileURL: file)) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.orange)
                            VStack(alignment: .leading) {
                                Text(file.lastPathComponent)
                                    .font(.headline)
                                Text(file.creationDateString)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            fileToDelete = file
                            showingDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle("JSON Files")
            .onAppear(perform: loadFiles)
            .toolbar {
                Button(action: loadFiles) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
            }
            .alert("Delete File?", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    if let url = fileToDelete {
                        deleteFile(at: url)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete '\(fileToDelete?.lastPathComponent ?? "this file")'? This action cannot be undone.")
            }
        }
        .navigationTitle("JSON Files")
    }
    
    func deleteFile(at url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
            loadFiles()
        } catch {
            print("Error deleting file: \(error.localizedDescription)")
        }
    }
    
    private func loadFiles() {
        let fileManager = FileManager.default
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("MockData")
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: [.creationDateKey])
            self.files = fileURLs.filter { $0.pathExtension.lowercased() == "json" }
        } catch {
            print("Error loading files: \(error.localizedDescription)")
        }
    }
}

extension URL {
    var creationDateString: String {
        let attributes = try? FileManager.default.attributesOfItem(atPath: self.path)
        let date = attributes?[.creationDate] as? Date ?? Date()
        return date.formatted(date: .abbreviated, time: .omitted)
    }
}
