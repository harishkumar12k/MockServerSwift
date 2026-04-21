//
//  ContentView.swift
//  MockServerSwift
//
//  Created by Harish Kumar on 21/04/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject var serverManager = MockServerManager()
    @State private var selectedLog: LogEntry?
    @State private var portString: String = "8080"
    @State private var logToDelete: LogEntry?
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationSplitView {
            VStack {
                VStack(spacing: 20) {
                    NavigationLink(destination: JSONListView()) {
                        Label("Shows List of JSONs", systemImage: "list.dash")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.gray)
                    NavigationLink(destination: JSONEditorView()) {
                        Label("Add new JSON", systemImage: "plus.circle")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.gray)
                    Divider()
                    Text("Server Controls")
                        .font(.headline)
                    
                    TextField("Port", text: $portString)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 100)
                    
                    Button(serverManager.isRunning ? "Stop Server" : "Start Server") {
                        let port = UInt16(portString) ?? 8080
                        serverManager.isRunning ? serverManager.stopServer() : serverManager.startServer(port: port)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(serverManager.isRunning ? .red : .blue)
                    
                    Button("Clear Logs") {
                        serverManager.clearLogs()
                        selectedLog = nil
                    }
                    .buttonStyle(.link)
                }
                .padding()
                .frame(minWidth: 150, maxWidth: 200)
                
                List(serverManager.logs, selection: $selectedLog) { log in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(log.path).font(.headline)
                            Text("\(log.timeString) • \(log.method)").font(.caption)
                        }
                        Spacer()
                        Text("\(log.statusCode)")
                            .foregroundColor(log.statusCode == 200 ? .green : .red)
                        Menu {
                            Button {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(log.responseBody, forType: .string)
                            } label: {
                                Label("Copy Response", systemImage: "doc.on.doc")
                            }
                            
                            Button {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(log.requestBody, forType: .string)
                            } label: {
                                Label("Copy Request", systemImage: "arrow.clockwise")
                            }
                            
                            Divider()
                            
                            Button(role: .destructive) {
                                logToDelete = log
                                showingDeleteAlert = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.title3)
                                .foregroundColor(.secondary)
                                .contentShape(Rectangle())
                        }
                        .menuStyle(.borderlessButton)
                        .fixedSize()
                    }
                    .tag(log)
                }
            }
            .frame(minWidth: 250)
            .alert("Delete Log?", isPresented: $showingDeleteAlert, presenting: logToDelete) { log in
                Button("Delete", role: .destructive) {
                    deleteLogAndReset(log)
                }
                Button("Cancel", role: .cancel) {
                    logToDelete = nil
                }
            } message: { log in
                Text("Are you sure you want to delete the log for \(log.path)? This action cannot be undone.")
            }
        } detail: {
            if let log = selectedLog {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        SectionView(title: "Request Body", content: log.requestBody, manager: serverManager)
                        Divider()
                        SectionView(title: "Response Body", content: log.responseBody, manager: serverManager)
                    }
                    .padding()
                }
            } else {
                Text("Select a log to see details").foregroundColor(.secondary)
            }
        }
    }
    
    func deleteLogAndReset(_ log: LogEntry) {
        if selectedLog?.id == log.id {
            selectedLog = nil
        }
        serverManager.deleteLog(log)
        logToDelete = nil
    }
    
}

struct SectionView: View {
    let title: String
    let content: String
    let manager: MockServerManager
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.caption).bold().foregroundColor(.secondary)
            Text(manager.prettyPrintJSON(content))
                .font(.system(.body, design: .monospaced))
                .padding(8)
                .background(Color.black.opacity(0.05))
                .cornerRadius(4)
        }
    }
}


#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
