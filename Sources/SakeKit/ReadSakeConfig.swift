//
//  ReadSakeConfig.swift
//  sakePackageDescription
//
//  Created by Jan Olbrich on 17.02.18.
//

import Foundation
import PathKit

public class Library: Codable {
    var name: String
    var path: String
}

public class SakeConfig {
    public var libraries: [Library]
    
    public init?(configPath: Path) {
        do {
            let data = try configPath.read()
            libraries = try JSONDecoder().decode([Library].self, from: data)
        } catch {
            return nil
        }
    }
}
