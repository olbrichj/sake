import SakefileDescription
import SakefileUtils

// MARK: - Tasks

enum Task: String, CustomStringConvertible {
  case documentation = "docs"
  var description: String {
    switch self {
    case .documentation:
        return "Generates the project documentation"
    }
  }
}

// MARK: - Functions

func anyGitChanges() -> Bool {
    return false
}

Sake<Task> {
    $0.task(.documentation) { (utils) in
        try utils.git.commitAll(message: "Fix git util")
    }
}.run()

