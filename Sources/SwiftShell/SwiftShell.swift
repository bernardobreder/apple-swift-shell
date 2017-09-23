//
//  SwiftShell.swift
//  SwiftShell
//
//  Created by Bernardo Breder on 10/12/16.
//
//

import Foundation

#if SWIFT_PACKAGE
    import Shell
    import Regex
#endif

public enum SwiftShellError: Error {
    case listTests(String, [String])
    case build(String, [String])
    case test
}

open class SwiftShell {
    
    public init() {
    }
    
    open func packageInit(path: String, type: PackageInitType) throws {
        let typeName: String
        switch type {
        case .empty:
            typeName = "empty"
        case .library:
            typeName = "library"
        case .executable:
            typeName = "executable"
        case .systemModule:
            typeName = "system-module"
        }
        _ = try Shell("swift", ["package", "-C", path, "init", "--type", typeName]).start()
    }
    
    open func packageXcodeproj(path: String) -> Bool {
        return Shell("swift", ["package", "-C", path, "generate-xcodeproj"]).startSystem()
    }
    
    open func test(path: String) throws -> (passed: [String], failed: [String]) {
        var passedArray: [String] = []
        var failedArray: [String] = []
        let result = try Shell("swift", ["test", "-C", path]).start()
        guard result.success else { throw SwiftShellError.test }
        let regex = Regex("^Test Case '(.*)' (passed|failed)", groupCount: 2)
        for item in result.output {
            if let entry: [String] = regex.matches(item) {
                let name = entry[1]
                let passed = entry[2]
                if passed == "passed" {
                    passedArray.append(name)
                } else if passed == "failed" {
                    failedArray.append(name)
                }
            }
        }
        return (passedArray, failedArray)
    }
    
    open func testProject(path: String) -> Bool {
        return Shell("swift", ["test", "-C", path]).startSystem()
    }
    
    open func build(path: String) throws {
        let result = try Shell("swift", ["build", "-C", path]).start()
        if result.hasError { throw SwiftShellError.build(path, result.output) }
    }
    
    open func listTests(path: String) throws -> [String: [String]] {
        let result = try Shell("swift", ["test", "-l", "-C", path]).start()
        if result.hasError { throw SwiftShellError.listTests(path, result.output) }
        let regex = Regex("^[a-zA-Z]+\\.([a-zA-Z]+)\\/(.*)$", groupCount: 2)
        var dic: [String: [String]] = [:]
        for item in result.output {
            if let entry: [String] = regex.matches(item) {
                let classname = entry[1]
                let testname = entry[2]
                var array = dic[classname] ?? []
                array.append(testname)
                dic[classname] = array
            }
        }
        return dic
    }
    
}

public enum PackageInitType {
    
    case empty
    case library
    case executable
    case systemModule
    
    public static func value(_ text: String) -> PackageInitType? {
        switch text {
        case "empty":
            return .empty
        case "library":
            return .library
        case "executable":
            return .executable
        case "system-module":
            return .systemModule
        default:
            return nil
        }
    }
}
