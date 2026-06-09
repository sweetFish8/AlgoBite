import SwiftUI

// MARK: - Linked List

struct LinkedListAnim: View {
    enum Kind { case reverse, merge, middle, cycle, addNumbers, intersection }
    let kind: Kind
    @State private var nodes: [String] = []
    @State private var arrows: [String] = []
    @State private var hi: Int? = nil
    @State private var caption = ""
    @State private var token = 0

    var body: some View {
        AnimFrame(title: title, tint: .teal, onReplay: play) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 2) {
                    ForEach(nodes.indices, id: \.self) { i in
                        let active = hi == i
                        tile(width: 28, bg: active ? .yellow : .teal.opacity(0.35),
                             fg: active ? .black : .white) {
                            Text(nodes[i])
                        }
                        .scaleEffect(active ? 1.15 : 1.0)
                        .animation(.spring(response: 0.3), value: hi)
                        if i < arrows.count {
                            Text(arrows[i])
                                .font(.system(size: 13, weight: .heavy))
                                .foregroundStyle(.teal)
                                .frame(width: 14)
                        }
                    }
                }
                Text(caption)
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }

    private var title: String {
        switch kind {
        case .reverse: return "リスト反転"
        case .merge: return "2つのソート済みリストをマージ"
        case .middle: return "中央ノード (slow/fast)"
        case .cycle: return "Floyd's 循環検出"
        case .addNumbers: return "リストでの加算"
        case .intersection: return "交差ノード検出"
        }
    }

    private func play() {
        token += 1; let t = token
        switch kind {
        case .reverse:
            let init1 = ["1","2","3","4","5"]
            nodes = init1; arrows = Array(repeating: "→", count: 4)
            caption = "初期: head→1→2→3→4→5"
            for i in 0..<4 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6 + Double(i) * 0.8) {
                    guard t == token else { return }
                    withAnimation {
                        arrows[i] = "←"; hi = i+1
                        caption = "step \(i+1): \(init1[i+1])→\(init1[i])"
                    }
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6 + 4*0.8 + 0.3) {
                guard t == token else { return }
                withAnimation { nodes = init1.reversed(); arrows = Array(repeating: "→", count: 4); hi = nil; caption = "完了: 5→4→3→2→1" }
            }
        case .merge:
            nodes = ["1","2","4","|","1","3","4"]; arrows = ["→","→","","","→","→"]
            caption = "L1=1,2,4 / L2=1,3,4"
            let result = ["1","1","2","3","4","4"]
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                guard t == token else { return }
                withAnimation { nodes = result; arrows = Array(repeating: "→", count: 5); caption = "merge: 1→1→2→3→4→4" }
            }
        case .middle:
            let n = ["1","2","3","4","5"]
            nodes = n; arrows = Array(repeating: "→", count: 4); caption = "slow/fast を進める"
            var s = 0, f = 0
            var i = 0
            while f + 2 < n.count {
                s += 1; f += 2
                let sc = s; let fc = f; let ic = i
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(ic) * 0.8) {
                    guard t == token else { return }
                    withAnimation { hi = sc; caption = "slow=\(sc)  fast=\(fc)" }
                }
                i += 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(i) * 0.8 + 0.4) {
                guard t == token else { return }
                withAnimation { caption = "中央 = \(n[s]) ✓" }
            }
        case .cycle:
            nodes = ["3","2","0","-4","↩︎"]; arrows = ["→","→","→","→"]
            caption = "末尾が index 1 に戻る循環リスト"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                guard t == token else { return }
                withAnimation { hi = 1; caption = "slow と fast が出会う = 循環あり ✓" }
            }
        case .addNumbers:
            nodes = ["2","4","3","|","5","6","4"]; arrows = ["→","→","","","→","→"]
            caption = "342 + 465 = 807"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                guard t == token else { return }
                withAnimation { nodes = ["7","0","8"]; arrows = ["→","→"]; caption = "結果: 7→0→8" }
            }
        case .intersection:
            nodes = ["A1","A2","C1","C2","C3"]; arrows = Array(repeating: "→", count: 4)
            caption = "2つのリストが C1 で合流"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                guard t == token else { return }
                withAnimation { hi = 2; caption = "交差ノード = C1 ✓" }
            }
        }
    }
}

// MARK: - LRU Cache (linked list + recency)

struct LRUCacheAnim: View {
    let capacity = 2
    let ops: [(String, Int, Int?)] = [
        ("put", 1, 1), ("put", 2, 2), ("get", 1, nil),
        ("put", 3, 3), ("get", 2, nil)
    ]
    @State private var cache: [(key: Int, val: Int)] = []
    @State private var step = -1
    @State private var note = ""
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "LRU Cache (cap=\(capacity))", tint: .pink, onReplay: play) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text("MRU →")
                        .font(.caption2.weight(.heavy)).foregroundStyle(.pink)
                    ForEach(cache.indices, id: \.self) { i in
                        tile(width: 44, height: 40, bg: .pink.opacity(0.6)) {
                            VStack(spacing: 0) {
                                Text("k=\(cache[i].key)").font(.system(size: 10, weight: .heavy))
                                Text("v=\(cache[i].val)").font(.system(size: 9))
                            }
                        }
                    }
                    Text("← LRU")
                        .font(.caption2.weight(.heavy)).foregroundStyle(.pink.opacity(0.6))
                }
                if step >= 0 && step < ops.count {
                    let o = ops[step]
                    Text("op: \(o.0)(\(o.1)\(o.2.map { ", \($0)" } ?? ""))")
                        .font(.system(.caption, design: .monospaced).weight(.bold))
                        .foregroundStyle(.pink)
                }
                if !note.isEmpty {
                    Text(note).font(.caption2).foregroundStyle(.secondary)
                }
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        cache = []; step = -1; note = ""
        for (k, o) in ops.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(k) * 1.1) {
                guard t == token else { return }
                withAnimation {
                    step = k
                    if o.0 == "put" {
                        if let idx = cache.firstIndex(where: { $0.key == o.1 }) { cache.remove(at: idx) }
                        cache.insert((o.1, o.2!), at: 0)
                        if cache.count > capacity { let removed = cache.removeLast(); note = "容量超過 → k=\(removed.key) を evict" }
                        else { note = "k=\(o.1) を MRU へ" }
                    } else {
                        if let idx = cache.firstIndex(where: { $0.key == o.1 }) {
                            let entry = cache.remove(at: idx)
                            cache.insert(entry, at: 0)
                            note = "ヒット v=\(entry.val) → MRU へ"
                        } else { note = "miss" }
                    }
                }
            }
        }
    }
}

// MARK: - Queue: Implement with Two Stacks

struct TwoStacksQueueAnim: View {
    @State private var inStack: [Int] = []
    @State private var outStack: [Int] = []
    @State private var op = ""
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Queue with Two Stacks", tint: .blue, onReplay: play) {
            HStack(spacing: 18) {
                stackView(label: "in", arr: inStack, color: .blue)
                Image(systemName: "arrow.right").foregroundStyle(.blue)
                stackView(label: "out", arr: outStack, color: .green)
            }
            VStack(spacing: 4) {
                Text(op).font(.caption2.weight(.heavy)).foregroundStyle(.blue)
                Text("push は in、pop は out → 空なら in を反転して移送")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func stackView(label: String, arr: [Int], color: Color) -> some View {
        VStack(spacing: 2) {
            ForEach(arr.indices.reversed(), id: \.self) { i in
                tile(width: 38, height: 24, bg: color.opacity(0.55)) { Text("\(arr[i])") }
            }
            ForEach(0..<max(0, 3 - arr.count), id: \.self) { _ in
                tile(width: 38, height: 24, bg: color.opacity(0.10), fg: .white.opacity(0.5)) { Text("·") }
            }
            Text(label).font(.caption2.weight(.heavy)).foregroundStyle(color)
        }
    }
    private func play() {
        token += 1; let t = token
        inStack = []; outStack = []; op = ""
        let actions: [(String, Int?)] = [("push", 1), ("push", 2), ("pop", nil)]
        for (k, (a, v)) in actions.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(k) * 1.1) {
                guard t == token else { return }
                withAnimation {
                    if a == "push", let x = v {
                        inStack.append(x); op = "push(\(x)) → in"
                    } else {
                        if outStack.isEmpty {
                            outStack = inStack.reversed(); inStack = []
                            op = "out が空 → in を反転して移送"
                        }
                        if let popped = outStack.popLast() { op = "pop() = \(popped)" }
                    }
                }
            }
        }
    }
}

// MARK: - Circular Queue

struct CircularQueueAnim: View {
    let cap = 3
    @State private var buf: [Int?] = Array(repeating: nil, count: 3)
    @State private var head = 0
    @State private var size = 0
    @State private var op = ""
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Circular Queue (cap=\(cap))", tint: .orange, onReplay: play) {
            VStack(spacing: 8) {
                ZStack {
                    Circle().stroke(Color.orange.opacity(0.45), lineWidth: 1.4)
                        .frame(width: 160, height: 160)
                    ForEach(0..<cap, id: \.self) { i in
                        let angle = Double(i) / Double(cap) * 2 * .pi - .pi / 2
                        let x = cos(angle) * 70
                        let y = sin(angle) * 70
                        let isHead = i == head && size > 0
                        let tail = (head + size - 1 + cap) % cap
                        let isTail = i == tail && size > 0
                        ZStack {
                            Circle()
                                .fill(buf[i] != nil ? .orange : .gray.opacity(0.18))
                                .frame(width: 36, height: 36)
                            Text(buf[i].map { "\($0)" } ?? "")
                                .font(.system(size: 12, weight: .black))
                                .foregroundStyle(.white)
                            if isHead {
                                Text("H").font(.system(size: 9, weight: .black))
                                    .foregroundStyle(.green).offset(y: -28)
                            }
                            if isTail {
                                Text("T").font(.system(size: 9, weight: .black))
                                    .foregroundStyle(.blue).offset(y: 28)
                            }
                        }
                        .offset(x: x, y: y)
                    }
                }
                .frame(height: 180)
                Text(op).font(.caption.weight(.heavy)).foregroundStyle(.orange)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        buf = Array(repeating: nil, count: cap); head = 0; size = 0; op = ""
        let actions: [(String, Int?)] = [
            ("enQ", 1), ("enQ", 2), ("enQ", 3), ("deQ", nil), ("enQ", 4)
        ]
        for (k, (a, v)) in actions.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(k) * 1.0) {
                guard t == token else { return }
                withAnimation {
                    if a == "enQ", let x = v {
                        if size == cap { op = "Full → enQ(\(x)) 拒否" }
                        else {
                            let tail = (head + size) % cap
                            buf[tail] = x; size += 1
                            op = "enQ(\(x)) → index \(tail)"
                        }
                    } else {
                        if size == 0 { op = "Empty → deQ 拒否" }
                        else { buf[head] = nil; let h = head; head = (head + 1) % cap; size -= 1
                               op = "deQ → index \(h)" }
                    }
                }
            }
        }
    }
}

// MARK: - Reverse Linked List (arrows flip)

struct ReverseLinkedListAnim: View {
    let vals = [1, 2, 3, 4, 5]
    @State private var prevIdx = -1  // 既に反転済みの末端
    @State private var curIdx = 0
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Reverse Linked List", tint: .blue, onReplay: play) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 0) {
                    ForEach(vals.indices, id: \.self) { i in
                        let done = i <= prevIdx
                        let isCur = i == curIdx
                        tile(width: 30, height: 30,
                             bg: done ? .green : (isCur ? .yellow : .blue.opacity(0.4)),
                             fg: isCur ? .black : .white) { Text("\(vals[i])") }
                        if i < vals.count - 1 {
                            Image(systemName: i <= prevIdx ? "arrow.left" : "arrow.right")
                                .font(.caption.weight(.heavy))
                                .foregroundStyle(i <= prevIdx ? .green : .secondary)
                                .frame(width: 14)
                        }
                    }
                }
                Text("prev=\(prevIdx < 0 ? "nil" : "\(vals[prevIdx])")  cur=\(curIdx < vals.count ? "\(vals[curIdx])" : "nil")")
                    .font(.system(.caption2, design: .monospaced)).foregroundStyle(.secondary)
                Text("cur.next を prev に向け、prev/cur を 1 つ進める")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        prevIdx = -1; curIdx = 0
        for k in 0...vals.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(k) * 0.8) {
                guard t == token else { return }
                withAnimation { prevIdx = k - 1; curIdx = k }
            }
        }
    }
}

// MARK: - Merge Two Sorted Lists

struct MergeTwoListsAnim: View {
    let a = [1, 2, 4]
    let b = [1, 3, 4]
    @State private var i = 0
    @State private var j = 0
    @State private var merged: [Int] = []
    @State private var lastFrom: Character? = nil   // 'a' or 'b'
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Merge Two Sorted Lists", tint: .teal, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                row("a", arr: a, ptr: i, color: .blue, taken: lastFrom == "a")
                row("b", arr: b, ptr: j, color: .orange, taken: lastFrom == "b")
                HStack(spacing: 4) {
                    Text("merged →")
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .foregroundStyle(.teal)
                    ForEach(merged.indices, id: \.self) { k in
                        tile(width: 26, height: 24, bg: .teal.opacity(0.5)) { Text("\(merged[k])") }
                    }
                }
                Text("先頭同士を比較 → 小さい方を取って前進").font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func row(_ label: String, arr: [Int], ptr: Int, color: Color, taken: Bool) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .black, design: .monospaced))
                .frame(width: 16).foregroundStyle(color)
            ForEach(arr.indices, id: \.self) { i in
                tile(width: 26, height: 24,
                     bg: i < ptr ? color.opacity(0.20)
                          : (i == ptr ? (taken ? .yellow : color) : color.opacity(0.35)),
                     fg: i == ptr ? .black : .white) { Text("\(arr[i])") }
            }
        }
    }
    private func play() {
        token += 1; let t = token
        i = 0; j = 0; merged = []; lastFrom = nil
        var k = 0
        while i + j < a.count + b.count {
            let pickA = j == b.count || (i < a.count && a[i] <= b[j])
            let val = pickA ? a[i] : b[j]
            let from: Character = pickA ? "a" : "b"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.7) {
                guard t == token else { return }
                withAnimation {
                    merged.append(val); lastFrom = from
                    if pickA { i += 1 } else { j += 1 }
                }
            }
            if pickA { i += 1 } else { j += 1 }
            k += 1
        }
    }
}

// MARK: - Detect Cycle (Floyd's tortoise & hare)

struct DetectCycleFloydAnim: View {
    // 1→2→3→4→(2) value 2 のノードに戻る循環
    let nodes = [1, 2, 3, 4]
    let cycleStart = 1   // index 1 = value 2 のノード
    @State private var slow = 0
    @State private var fast = 0
    @State private var found = false
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Detect Cycle (Floyd)", tint: .red, onReplay: play) {
            ZStack {
                // 円周上にノードを配置
                let cnt = nodes.count
                ForEach(0..<cnt, id: \.self) { i in
                    let angle = Double(i) / Double(cnt) * 2 * .pi - .pi / 2
                    let x = cos(angle) * 70
                    let y = sin(angle) * 70
                    ZStack {
                        Circle().fill(Color.red.opacity(0.35))
                            .frame(width: 32, height: 32)
                        Text("\(nodes[i])").font(.system(size: 11, weight: .black))
                            .foregroundStyle(.white)
                        if slow == i && fast == i && found {
                            Text("🎯").font(.title3).offset(y: -28)
                        } else {
                            if slow == i { Text("🐢").font(.caption).offset(y: -22) }
                            if fast == i { Text("🐇").font(.caption).offset(y: 22) }
                        }
                    }
                    .offset(x: x, y: y)
                }
            }
            .frame(height: 180)
            VStack(spacing: 2) {
                Text("slow=\(slow)  fast=\(fast)")
                    .font(.system(.caption2, design: .monospaced)).foregroundStyle(.secondary)
                if found {
                    Text("🎯 兎と亀が出会った → サイクルあり")
                        .font(.caption.weight(.bold)).foregroundStyle(.red)
                }
            }
        }
        .onAppear { play() }
    }
    private func next(_ i: Int) -> Int { i == nodes.count - 1 ? cycleStart : i + 1 }
    private func play() {
        token += 1; let t = token
        slow = 0; fast = 0; found = false
        var s = 0, f = 0
        for k in 1...12 {
            s = next(s); f = next(next(f))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.65) {
                guard t == token else { return }
                let curS = s, curF = f
                withAnimation { slow = curS; fast = curF }
                if curS == curF {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        guard t == token else { return }
                        withAnimation { found = true }
                    }
                }
            }
            if s == f { break }
        }
    }
}

// MARK: - Add Two Numbers (digit column + carry)

struct AddTwoNumbersAnim: View {
    let a = [2, 4, 3]   // 342 (頭から1の位)
    let b = [5, 6, 4]   // 465 (頭から1の位)
    @State private var idx = -1
    @State private var carry = 0
    @State private var result: [Int] = []
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Add Two Numbers", tint: .purple, onReplay: play) {
            VStack(alignment: .leading, spacing: 4) {
                row("a", arr: a)
                row("b", arr: b)
                HStack(spacing: 6) {
                    Text("=").font(.system(size: 14, weight: .black))
                    ForEach(result.indices, id: \.self) { i in
                        tile(width: 28, height: 28, bg: .purple) { Text("\(result[i])") }
                    }
                }
                Text("carry = \(carry)")
                    .font(.system(.caption, design: .monospaced).weight(.heavy))
                    .foregroundStyle(.purple)
                Text("各桁を a[i] + b[i] + carry、carry = sum / 10")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func row(_ label: String, arr: [Int]) -> some View {
        HStack(spacing: 6) {
            Text(label).font(.system(size: 12, weight: .black, design: .monospaced))
                .frame(width: 16, alignment: .leading).foregroundStyle(.purple)
            ForEach(arr.indices, id: \.self) { i in
                tile(width: 28, height: 28,
                     bg: i == idx ? .yellow : .purple.opacity(0.4),
                     fg: i == idx ? .black : .white) { Text("\(arr[i])") }
            }
        }
    }
    private func play() {
        token += 1; let t = token
        idx = -1; carry = 0; result = []
        var c = 0
        for i in 0..<max(a.count, b.count) {
            let av = i < a.count ? a[i] : 0
            let bv = i < b.count ? b[i] : 0
            let sum = av + bv + c
            let d = sum % 10
            c = sum / 10
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 1.0) {
                guard t == token else { return }
                withAnimation { idx = i; result.append(d); carry = c }
            }
        }
    }
}

// MARK: - Middle of Linked List (slow / fast)

struct MiddleOfLLAnim: View {
    let vals = [1, 2, 3, 4, 5]
    @State private var slow = 0
    @State private var fast = 0
    @State private var done = false
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Middle of Linked List", tint: .green, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    ForEach(vals.indices, id: \.self) { i in
                        ZStack {
                            tile(width: 30, height: 32,
                                 bg: done && i == slow ? .green : .green.opacity(0.35)) {
                                Text("\(vals[i])")
                            }
                            if slow == i { Text("🐢").font(.system(size: 11)).offset(y: -22) }
                            if fast == i { Text("🐇").font(.system(size: 11)).offset(y: 22) }
                        }
                    }
                }
                Text("slow=\(slow)  fast=\(fast)")
                    .font(.system(.caption2, design: .monospaced)).foregroundStyle(.secondary)
                if done {
                    Text("🎯 fast が末尾に到達 → slow が中央")
                        .font(.caption.weight(.bold)).foregroundStyle(.green)
                }
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        slow = 0; fast = 0; done = false
        var s = 0, f = 0, k = 1
        while f + 2 < vals.count {
            s += 1; f += 2
            let curS = s, curF = f
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.75) {
                guard t == token else { return }
                withAnimation { slow = curS; fast = curF }
            }
            k += 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.75 + 0.3) {
            guard t == token else { return }
            withAnimation { done = true }
        }
    }
}

// MARK: - Flatten Binary Tree to Linked List

struct FlattenBTAnim: View {
    @State private var nodes = [1, 2, 5, 3, 4, 0, 6]
    @State private var phase = 0   // 0=tree, 1=flatten
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Flatten BT → Linked List", tint: .indigo, onReplay: play) {
            VStack(alignment: .leading, spacing: 8) {
                if phase == 0 {
                    LeveledTree(nodes: nodes,
                                highlightVisited: [],
                                current: nil,
                                palette: (.indigo, .yellow, .indigo.opacity(0.4)))
                    Text("preorder = [1, 2, 3, 4, 5, 6] になるように右リンクに展開")
                        .font(.caption2).foregroundStyle(.secondary)
                } else {
                    HStack(spacing: 0) {
                        ForEach([1, 2, 3, 4, 5, 6], id: \.self) { v in
                            ZStack {
                                Circle().fill(.indigo).frame(width: 28, height: 28)
                                Text("\(v)").font(.system(size: 11, weight: .black))
                                    .foregroundStyle(.white)
                            }
                            if v != 6 {
                                Image(systemName: "arrow.right")
                                    .font(.caption.weight(.heavy))
                                    .foregroundStyle(.indigo)
                                    .frame(width: 14)
                            }
                        }
                    }
                    Text("右リンクのみの単方向リスト")
                        .font(.caption2).foregroundStyle(.secondary)
                }
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        phase = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            guard t == token else { return }
            withAnimation { phase = 1 }
        }
    }
}

// MARK: - Intersection of Two Linked Lists

struct IntersectionLLAnim: View {
    let a = [4, 1]
    let b = [5, 6, 1]
    let shared = [8, 4, 5]
    // ポインタの現在位置: row 0=A, 1=B / そのrow内のindex
    @State private var aRow = 0
    @State private var aIdx = 0
    @State private var bRow = 1
    @State private var bIdx = 0
    @State private var token = 0
    @State private var hit: Int? = nil

    var body: some View {
        AnimFrame(title: "Intersection of Two LLs", tint: .blue, onReplay: play) {
            VStack(alignment: .leading, spacing: 8) {
                listRow("A", rowId: 0, arr: a + shared, color: .blue, intersect: a.count)
                listRow("B", rowId: 1, arr: b + shared, color: .orange, intersect: b.count)
                Text("片方が末尾に着いたらもう片方の先頭にジャンプ。長さ差を吸収して同じノードで出会う")
                    .font(.caption2).foregroundStyle(.secondary)
                if let h = hit {
                    Text("🎯 交点 = \(h)").font(.caption.weight(.bold)).foregroundStyle(.green)
                }
            }
        }
        .onAppear { play() }
    }

    private func listRow(_ label: String, rowId: Int, arr: [Int], color: Color, intersect: Int) -> some View {
        HStack(spacing: 4) {
            Text(label).font(.system(size: 12, weight: .black, design: .monospaced))
                .frame(width: 14).foregroundStyle(color)
            ForEach(arr.indices, id: \.self) { i in
                let isPtr = (aRow == rowId && aIdx == i) || (bRow == rowId && bIdx == i)
                tile(width: 28, height: 28,
                     bg: isPtr ? .yellow : (i >= intersect ? .green.opacity(0.55) : color.opacity(0.45)),
                     fg: isPtr ? .black : .white) { Text("\(arr[i])") }
            }
        }
    }

    /// 表示位置 (row, idx) と、ノード同一判定用ID をまとめた1ステップ
    private struct Step { let row: Int; let idx: Int; let id: String }

    /// A行の各ノードID (前半=A固有, 後半=共有S)
    private var aRowIDs: [String] {
        (0..<a.count).map { "A\($0)" } + (0..<shared.count).map { "S\($0)" }
    }
    private var bRowIDs: [String] {
        (0..<b.count).map { "B\($0)" } + (0..<shared.count).map { "S\($0)" }
    }
    /// ポインタAの旅: A行を最後まで → B行の先頭へジャンプ
    private var journeyA: [Step] {
        aRowIDs.enumerated().map { Step(row: 0, idx: $0.offset, id: $0.element) }
        + bRowIDs.enumerated().map { Step(row: 1, idx: $0.offset, id: $0.element) }
    }
    /// ポインタBの旅: B行を最後まで → A行の先頭へジャンプ
    private var journeyB: [Step] {
        bRowIDs.enumerated().map { Step(row: 1, idx: $0.offset, id: $0.element) }
        + aRowIDs.enumerated().map { Step(row: 0, idx: $0.offset, id: $0.element) }
    }

    private func play() {
        token += 1; let t = token
        hit = nil
        let jA = journeyA, jB = journeyB
        let n = min(jA.count, jB.count)
        aRow = 0; aIdx = 0; bRow = 1; bIdx = 0

        // 同一ノード (同じID) に同時に到達したステップ = 交点
        var meetK: Int? = nil
        for k in 0..<n where jA[k].id == jB[k].id { meetK = k; break }
        let last = meetK ?? (n - 1)

        for k in 0...last {
            let sA = jA[k], sB = jB[k]
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.7) {
                guard t == token else { return }
                withAnimation { aRow = sA.row; aIdx = sA.idx; bRow = sB.row; bIdx = sB.idx }
                if k == last, let mk = meetK {
                    // 交点ノードのID "S<offset>" から共有配列の値を引く → 8
                    let off = Int(jA[mk].id.dropFirst()) ?? 0
                    if shared.indices.contains(off) {
                        withAnimation { hit = shared[off] }
                    }
                }
            }
        }
    }
}
