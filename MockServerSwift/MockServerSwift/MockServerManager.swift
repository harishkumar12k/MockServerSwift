//
//  MockServerManager.swift
//  MockServerSwift
//
//  Created by Harish Kumar on 21/04/26.
//

import Foundation
import Swifter

class MockServerManager: ObservableObject {
    private var server = HttpServer()
    @Published var isRunning = false
    @Published var logs: [LogEntry] = []
    
    let baseDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("MockData")
    
    func startServer(port: UInt16) {
        server["/api/:endpoint"] = { request in
            let endpoint = request.params[":endpoint"] ?? ""
            let fileName = "\(endpoint).json"
            let fileURL = self.baseDirectory.appendingPathComponent(fileName)
            let reqBody = String(bytes: request.body, encoding: .utf8) ?? ""
            var statusCode = 404
            var respBody = "File not found: \(fileName)"
            var response: HttpResponse = .raw(404, "Not Found", ["Content-Type": "text/plain"], { writer in
                try? writer.write(Data(respBody.utf8))
            })

            if FileManager.default.fileExists(atPath: fileURL.path) {
                if let data = try? Data(contentsOf: fileURL),
                   let jsonString = String(data: data, encoding: .utf8) {
                    statusCode = 200
                    respBody = jsonString
                    response = .ok(.text(jsonString))
                }
            }
            
            let newLog = LogEntry(
                id: UUID(),
                timestamp: Date(),
                method: request.method,
                path: request.path,
                statusCode: statusCode,
                requestBody: reqBody,
                responseBody: respBody
            )
            DispatchQueue.main.async {
                self.logs.insert(newLog, at: 0)
            }
            
            return response
            
        }
        
        do {
            try server.start(port)
            DispatchQueue.main.async {
                self.isRunning = true
            }
        } catch {
            print("Failed to start: \(error)")
        }
    }
    
    func stopServer() {
        server.stop()
        isRunning = false
    }
    
    func clearLogs() {
        logs.removeAll()
    }
    
    func deleteLog(_ log: LogEntry) {
        logs.removeAll { $0.id == log.id }
    }
    
    func prettyPrintJSON(_ rawString: String) -> String {
        guard let data = rawString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data),
              let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
              let prettyString = String(data: prettyData, encoding: .utf8) else {
            return rawString 
        }
        return prettyString
    }
    
}
