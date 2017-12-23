import Foundation
import XCTest

@testable import SakefileDescription

final class SakeTests: XCTestCase {
    
    enum Task: String, CustomStringConvertible {
        case a = "a"
        case b = "b_name"
        var description: String {
            switch self {
            case .a: return "a description"
            case .b: return "b description"
            }
        }
    }
    
    func test_runTask_runsEverythingInTheRightOrder() {
        var executionOutputs: [String] = []
        let subject = Sake<Task> {
            try $0.task(.a, dependencies: [.b]) {
                executionOutputs.append("a")
            }
            try $0.task(.b) {
                executionOutputs.append("b")
            }
            $0.beforeEach {
                executionOutputs.append("before_each")
            }
            $0.beforeAll {
                executionOutputs.append("before_all")
            }
            $0.afterEach {
                executionOutputs.append("after_each")
            }
            $0.afterAll {
                executionOutputs.append("after_all")
            }
        }
        subject.run(arguments: ["task", "a"])
        XCTAssertEqual(executionOutputs, [
            "before_all",
            "before_each",
            "b",
            "after_each",
            "before_each",
            "a",
            "after_each",
            "after_all"
        ])
    }

    func test_runTasks_printsTheCorrectString() {
        var printed: String!
        let subject = Sake<Task>(printer: { printed = $0 }) {
            try $0.task(.a, dependencies: [.b]) { }
            try $0.task(.b) { }
        }
        subject.run(arguments: ["tasks"])
        let expected = """
b_name:     b description
a:          a description
"""
        XCTAssertEqual(printed, expected)
    }
    
    func test_runWrongTask_printSuggestedTaskName() {
        var printed: String!
        let subject = Sake<Task>(printer: { printed = $0 }) {
            try $0.task(.a, dependencies: [.b]) { }
            try $0.task(.b) {  }
        }
        subject.run(arguments: ["task", "_"])
        let expected = "> [!] Could not find task '_'. Maybe did you mean 'b_name'?"
        XCTAssertEqual(printed, expected)
    }
}
