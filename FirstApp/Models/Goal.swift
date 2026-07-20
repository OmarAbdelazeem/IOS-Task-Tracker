import SwiftData

@Model
final class Goal {
    var title: String
    var count: Int
    var target: Int

    init(
        title: String,
        count: Int = 0,
        target: Int
    ) {
        self.title = title
        self.count = count
        self.target = target
    }

    var progress: Double {
        guard target > 0 else {
            return 0
        }

        return min(
            Double(count) / Double(target),
            1.0
        )
    }

    var isCompleted: Bool {
        guard target > 0 else {
            return false
        }

        return count >= target
    }
}
