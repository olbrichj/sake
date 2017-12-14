import Foundation
import PathKit
import SwiftShell

/// Runs the Sakefile.
public class RunSakefile {
    
    // MARK: - Attributes

    /// Path where the Sakefile.swift file is.
    let path: String
    
    /// Arguments to be passed.
    let arguments: [String]
    
    /// Verbose
    let verbose: Bool
    
    // MARK: - Init
    
    /// Default constructor.
    ///
    /// - Parameters:
    ///   - path: path where the Sakefile.swift file is.
    ///   - arguments: arguments to be passed.
    ///   - verbose: if it should print logs verbosely.
    public init(path: String,
                arguments: [String],
                verbose: Bool) {
        self.path = path
        self.arguments = arguments
        self.verbose = verbose
    }
    
    // MARK: - Public
    
    /// Executes the Sakefile.swift
    ///
    /// - Throws: an error if the execution fails for any reason.
    public func execute() throws {
        guard let sakefilePath = sakefilePath() else {
            throw "Couldn't find Sakefile.swift in directory \(path)"
        }
        guard let filedescriptionLibraryPath = Runtime.filedescriptionLibraryPath() else {
            throw "Couldn't find libSakefileDescription.dylib to link against to"
        }
        
        var arguments: [String] = []
        arguments += ["--driver-mode=swift"]
        arguments += ["-L", filedescriptionLibraryPath.parent().normalize().string]
        arguments += ["-I", filedescriptionLibraryPath.parent().normalize().string]
        if let utilsLibraryPath = Runtime.utilsLibraryPath() {
            arguments += ["-L", utilsLibraryPath.parent().normalize().string]
            arguments += ["-I", utilsLibraryPath.parent().normalize().string]
            arguments += ["-lSakefileUtils"]
        } else {
            arguments += ["-lSakefileDescription"]
        }
        arguments += [sakefilePath.string]
        arguments += self.arguments
        do {
            var bashCommand = "swiftc \(arguments.joined(separator: " "))"
            if !verbose {
                bashCommand = "exec 2>/dev/null; \(bashCommand)"
            }
            try runAndPrint(bash: bashCommand)
        } catch {
            throw "Error processing your Sakefile.swift. Use --verbose to get more details about the problem."
        }
    }
    
    // MARK: - Fileprivate
    
    fileprivate func sakefilePath() -> Path? {
        let sakefilePath = (Path(path) + "Sakefile.swift").normalize()
        if sakefilePath.exists {
            return sakefilePath
        }
        return nil
    }
    
}
