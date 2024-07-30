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

func decodeMessageContent(_ content: String) -> [String: String] {
    do {
        if let jsonData = content.data(using: .utf8),
           let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: String] {
            return dictionary
        } else {
        }
    } catch {
        print("Error: \(error.localizedDescription)")
    }
    return [:]
}

func encodeMessageContent(_ contentDict: [String: String]) -> String {
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

func restoreFileAccess(with bookmarkData: Data, endpoint: Endpoint) -> URL? {
    do {
        var isStale = false
        let url = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
        if isStale {
            // bookmarks could become stale as the OS changes
            print("Bookmark is stale, need to save a new one... ")
            saveBookmarkData(for: url, endpoint: endpoint)
        }
        return url
    } catch {
        print("Error resolving bookmark:", error)
        return nil
    }
}

func saveBookmarkData(for workDir: URL, endpoint: Endpoint) {
    do {
        let bookmarkData = try workDir.bookmarkData(options: [.withSecurityScope, .securityScopeAllowOnlyReadAccess],
                                                    includingResourceValuesForKeys: nil,
                                                    relativeTo: nil)
        endpoint.bookmark = bookmarkData
    } catch {
        print("Failed to save bookmark data for \(workDir)", error)
    }
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

func createDocument(image: CGImage?) -> DataFile? {
    guard let cgImage = image else { return nil }
    let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
    guard let data = nsImage.pngData() else { return nil }
    return DataFile(data: data)
}
