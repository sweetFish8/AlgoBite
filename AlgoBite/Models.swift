import SwiftUI

// MARK: - Models

enum SlotCheckState { case idle, correct, wrong }

// 横揺れアニメーション。`shakes` を整数で増分させると 1 回振動する。
struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 6
    var shakesPerUnit: CGFloat = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = amount * sin(animatableData * .pi * shakesPerUnit)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

enum ResultMood { case neutral, success, fail }

struct PuzzleSlot {
    let id: String
    let label: String
    let answer: String
    let choices: [String]
}

struct PuzzleProblem: Identifiable, Hashable {
    static func == (l: PuzzleProblem, r: PuzzleProblem) -> Bool { l.id == r.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    let id: String
    let title: String
    let difficulty: String
    let topic: String
    let prompt: String
    let example: String
    let template: [String]
    let slots: [String: PuzzleSlot]
    let explanation: String

    init(id: String, title: String, difficulty: String, topic: String,
         prompt: String, example: String, template: [String],
         slots: [String: PuzzleSlot], explanation: String = "") {
        self.id = id
        self.title = title
        self.difficulty = difficulty
        self.topic = topic
        self.prompt = prompt
        self.example = example
        self.template = template
        self.slots = slots
        self.explanation = explanation
    }

    var orderedSlotIDs: [String] {
        var ids: [String] = []
        for line in template {
            for match in line.matches(of: /\{\{(.*?)\}\}/) {
                let id = String(match.1)
                if !ids.contains(id) { ids.append(id) }
            }
        }
        return ids
    }
}

enum CodeSegment: Hashable { case text(String), slot(String) }

