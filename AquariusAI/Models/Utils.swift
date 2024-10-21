//
//  Utils.swift
//  AquariusAI
//
//  Created by Lei Cao on 2024/5/10.
//

import SwiftUI
import UniformTypeIdentifiers

func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}

func decodeContent(_ content: String) -> [String: Any] {
    do {
        if let jsonData = content.data(using: .utf8),
           let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
            return dictionary
        } else {
        }
    } catch {
        print("Error: \(error.localizedDescription)")
    }
    return [:]
}

func encodeContent(_ contentDict: [String: Any]) -> String {
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: contentDict, options: [])
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
    } catch {
        print("Error: \(error.localizedDescription)")
    }
    return ""
}

func isDirectoryReadable(path: String) -> Bool {
    var isReadable = false
    var isDirectory: ObjCBool = false

    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: path, isDirectory: &isDirectory) {
        if isDirectory.boolValue {
            isReadable = fileManager.isReadableFile(atPath: path)
        }
    }
    return isReadable
}

func isFileReadable(path: String) -> Bool {
    let fileManager = FileManager.default
    return fileManager.isReadableFile(atPath: path)
}

func restoreFileAccess(with bookmarkData: Data, onStale: (_ data: Data) -> Void) -> URL? {
    do {
        var isStale = false
        let url = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
        if isStale {
            // bookmarks could become stale as the OS changes
            print("Bookmark is stale, need to save a new one... ")
            let bookmarkData = try createBookmarkData(for: url)
            onStale(bookmarkData)
        }
        return url
    } catch {
        print("Error resolving bookmark:", error)
        return nil
    }
}

// createBookmarkData
func createBookmarkData(for workDir: URL) throws -> Data {
    let bookmarkData = try workDir.bookmarkData(options: [.withSecurityScope, .securityScopeAllowOnlyReadAccess],
                                                includingResourceValuesForKeys: nil,
                                                relativeTo: nil)
    return bookmarkData
}

struct DataFile: FileDocument {
    static var readableContentTypes: [UTType] { [.png] }
    var data: Data
    
    init(data: Data) {
        self.data = data
    }
    
    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: data)
    }
}

func createPngFileDocument(image: CGImage?) -> DataFile? {
    guard let cgImage = image else { return nil }
    let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
    guard let data = nsImage.pngData() else { return nil }
    return DataFile(data: data)
}

// getDocumentsDirectory
private func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

// saveFileToDocumentsDirectory
func saveFileToDocumentsDirectory<T: Codable>(_ object: T, to filename: String) throws {
    let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
    let directoryURL = fileURL.deletingLastPathComponent()
    let fileManager = FileManager.default
    if !fileManager.fileExists(atPath: directoryURL.path) {
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
    }
    let data = try PropertyListEncoder().encode(object)
    try data.write(to: fileURL)
}

// loadFileFromDocumentsDirectory
func loadFileFromDocumentsDirectory<T: Codable>(_ filename: String, as type: T.Type) throws -> T {
    let url = getDocumentsDirectory().appendingPathComponent(filename)
    let data = try Data(contentsOf: url)
    let object = try PropertyListDecoder().decode(type, from: data)
    return object
}

func cosineSimilarity(_ vectorA: [Double], _ vectorB: [Double]) throws -> Double {
    guard vectorA.count == vectorB.count else {
        throw AppError.bizError(description: "Vectors must be of same length")
    }
    let dotProduct = zip(vectorA, vectorB).map(*).reduce(0, +)
    let magnitudeA = sqrt(vectorA.map { $0 * $0 }.reduce(0, +))
    let magnitudeB = sqrt(vectorB.map { $0 * $0 }.reduce(0, +))
    return dotProduct / (magnitudeA * magnitudeB)
}

func mostSimilarVector(queryVector: [Double], vectors: [[Double]], topK: Int) throws -> [(index: Int, similarity: Double)] {
    var result: [(index: Int, similarity: Double)] = []
    for (index, vector) in vectors.enumerated() {
        let similarity = try cosineSimilarity(queryVector, vector)
        result.append((index, similarity))
    }
    result.sort(by: { $0.similarity > $1.similarity })
    return Array(result.prefix(topK))
}

func splitTextIntoChunks(_ text: String, chunkSize: Int) -> [String] {
    var chunks: [String] = []
    let lines = text.split(separator: "\n", omittingEmptySubsequences: true)
    var length = 0
    var start = 0
    for (i, line) in zip(lines.indices, lines) {
        if length + line.count > chunkSize {
            let array = lines[start...i-1]
            chunks.append(array.joined(separator: "\n"))
            start = i
            length = 0
        }
        if i == lines.count - 1 {
            let array = lines[start...i]
            chunks.append(array.joined(separator: "\n"))
        }
        length += line.count
    }
    return chunks
}
