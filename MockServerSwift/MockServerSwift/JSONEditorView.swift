//
//  JSONEditorView.swift
//  MockServerSwift
//
//  Created by Harish Kumar on 21/04/26.
//

import SwiftUI

struct JSONEditorView: View {
    @EnvironmentObject var serverManager: MockServerManager
    @State private var fileName: String = ""
    @State private var jsonContent: String = ""
    @Environment(\.dismiss) private var dismiss
    @State private var showingOverwriteAlert = false
    @State private var pendingFileURL: URL?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Create New Mock Response")
                .font(.headline)
            
            HStack {
                Text("Filename:")
                TextField("e.g., home5", text: $fileName)
                    .textFieldStyle(.roundedBorder)
                Text(".json")
                    .foregroundColor(.secondary)
            }
            
            Text("JSON Content:")
                .font(.caption).bold()
            
            TextEditor(text: $jsonContent)
                .font(.system(.body, design: .monospaced))
                .padding(4)
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(4)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray.opacity(0.2)))

            HStack {
                Button("Format JSON") {
                    jsonContent = serverManager.prettyPrintJSON(jsonContent)
                }
                
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                
                Button("Save to MockData") {
                    saveFile()
                }
                .buttonStyle(.borderedProminent)
                .disabled(fileName.isEmpty || jsonContent.isEmpty)
            }
        }
        .padding()
        .frame(minWidth: 500, minHeight: 400)
        .alert("File Already Exists", isPresented: $showingOverwriteAlert) {
            Button("Overwrite", role: .destructive) {
                if let url = pendingFileURL {
                    performSave(to: url)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("A file named '\(fileName)' already exists. Do you want to replace it?")
        }
    }

    func saveFile() {
        let cleanedName = fileName.lowercased().replacingOccurrences(of: " ", with: "_")
        let fullFileName = cleanedName.hasSuffix(".json") ? cleanedName : "\(cleanedName).json"
        let fileURL = serverManager.baseDirectory.appendingPathComponent(fullFileName)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            self.pendingFileURL = fileURL
            self.showingOverwriteAlert = true
        } else {
            performSave(to: fileURL)
        }
    }

    func performSave(to url: URL) {
        do {
            try jsonContent.write(to: url, atomically: true, encoding: .utf8)
            print("Successfully saved: \(url.path)")
            dismiss()
        } catch {
            print("Failed to save file: \(error.localizedDescription)")
        }
    }
}
