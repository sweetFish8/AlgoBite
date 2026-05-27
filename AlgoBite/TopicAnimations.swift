import SwiftUI

// MARK: - Shared chrome

private struct AnimFrame<Content: View>: View {
    let title: String
    let tint: Color
    let onReplay: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(title, systemImage: "play.circle.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(tint)
                Spacer()
                Button(action: onReplay) {
                    Label("再生", systemImage: "arrow.clockwise")
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(tint.opacity(0.15), in: Capsule())
                }
                .buttonStyle(.plain)
            }
            content()
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tint.opacity(0.05), in: RoundedRectangle(cornerRadius: 10))
    }
}

private func tile<S: View>(width: CGFloat = 26, height: CGFloat = 26, bg: Color, fg: Color = .white, @ViewBuilder _ content: () -> S) -> some View {
    content()
        .font(.system(size: 11, weight: .bold, design: .monospaced))
        .frame(width: width, height: height)
        .background(bg, in: RoundedRectangle(cornerRadius: 5))
        .foregroundStyle(fg)
}

// MARK: - Sorting (bubble/insertion/selection/quicksort/merge/dutch-flag/rotate)

struct SortingAnim: View {
    enum Kind { case bubble, insertion, selection, counting, quick, merge, dutch, rotate }
    let kind: Kind
    @State private var arr: [Int] = []
    @State private var hi: Int? = nil
    @State private var hj: Int? = nil
    @State private var done = false
    @State private var caption = ""
    @State private var token = 0

    private var seed: [Int] {
        switch kind {
        case .dutch: return [2, 0, 1, 2, 0, 1, 0, 2]
        case .rotate: return [1, 2, 3, 4, 5, 6, 7]
        case .counting: return [4, 2, 2, 8, 3, 3, 1]
        default: return [5, 2, 8, 1, 9, 3, 7, 4]
        }
    }

    var body: some View {
        AnimFrame(title: title, tint: .pink, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    ForEach(arr.indices, id: \.self) { i in
                        let isHi = hi == i || hj == i
                        let bg: Color = done ? .green.opacity(0.4)
                                            : (isHi ? .yellow : .pink.opacity(0.25))
                        let fg: Color = isHi ? .black : .white
                        tile(bg: bg, fg: fg) { Text("\(arr[i])") }
                            .scaleEffect(isHi ? 1.15 : 1.0)
                            .animation(.spring(response: 0.3), value: arr)
                            .animation(.spring(response: 0.3), value: hi)
                            .animation(.spring(response: 0.3), value: hj)
                    }
                }
                Text(caption)
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(done ? .green : .secondary)
            }
        }
        .onAppear { play() }
    }

    private var title: String {
        switch kind {
        case .bubble: return "Bubble Sort"
        case .insertion: return "Insertion Sort"
        case .selection: return "Selection Sort"
        case .counting: return "Counting Sort"
        case .quick: return "Quicksort (動作)"
        case .merge: return "Merge Sort (動作)"
        case .dutch: return "Dutch National Flag"
        case .rotate: return "Rotate Array"
        }
    }

    private func play() {
        token += 1; let t = token
        arr = seed; hi = nil; hj = nil; done = false; caption = ""
        var steps: [(action: () -> Void, msg: String)] = []
        switch kind {
        case .bubble:
            var a = seed
            for i in 0..<a.count {
                for j in 0..<(a.count - i - 1) {
                    let jj = j
                    if a[j] > a[j+1] {
                        a.swapAt(j, j+1)
                        let snap = a
                        steps.append((action: { arr = snap; hi = jj; hj = jj+1 },
                                      msg: "swap a[\(jj)] ⇄ a[\(jj+1)]"))
                    }
                }
            }
        case .insertion:
            var a = seed
            for i in 1..<a.count {
                var j = i
                while j > 0 && a[j-1] > a[j] {
                    a.swapAt(j, j-1)
                    let snap = a; let jc = j
                    steps.append((action: { arr = snap; hi = jc-1; hj = jc },
                                  msg: "挿入: a[\(jc-1)] ⇄ a[\(jc)]"))
                    j -= 1
                }
            }
        case .selection:
            var a = seed
            for i in 0..<a.count {
                var mn = i
                for j in (i+1)..<a.count { if a[j] < a[mn] { mn = j } }
                if mn != i { a.swapAt(i, mn) }
                let snap = a; let ic = i; let mc = mn
                steps.append((action: { arr = snap; hi = ic; hj = mc },
                              msg: "i=\(ic) の min を確定"))
            }
        case .counting:
            var counts = Array(repeating: 0, count: 10)
            for v in seed { counts[v] += 1 }
            var a: [Int] = []
            for (v, c) in counts.enumerated() { a.append(contentsOf: Array(repeating: v, count: c)) }
            let mid = arr
            steps.append((action: { arr = mid }, msg: "カウント中…"))
            steps.append((action: { arr = a }, msg: "カウント結果を展開"))
        case .quick:
            var a = seed
            func qs(_ lo: Int, _ hi2: Int) {
                if lo >= hi2 { return }
                let p = a[hi2]; var i = lo - 1
                for j in lo..<hi2 {
                    if a[j] <= p { i += 1; a.swapAt(i, j) }
                }
                a.swapAt(i+1, hi2)
                let snap = a; let pivot = i+1
                steps.append((action: { arr = snap; hi = pivot; hj = nil },
                              msg: "pivot=\(p) を \(pivot) に確定"))
                qs(lo, i); qs(i+2, hi2)
            }
            qs(0, a.count-1)
        case .merge:
            var a = seed
            func ms(_ l: Int, _ r: Int) {
                if r - l <= 1 { return }
                let m = (l + r) / 2
                ms(l, m); ms(m, r)
                let merged = (Array(a[l..<m]) + Array(a[m..<r])).sorted()
                for (k, v) in merged.enumerated() { a[l + k] = v }
                let snap = a; let lc = l; let rc = r-1
                steps.append((action: { arr = snap; hi = lc; hj = rc },
                              msg: "merge [\(lc)..\(rc)]"))
            }
            ms(0, a.count)
        case .dutch:
            var a = seed; var lo = 0, mid = 0, hi2 = a.count - 1
            while mid <= hi2 {
                if a[mid] == 0 { a.swapAt(lo, mid); lo += 1; mid += 1 }
                else if a[mid] == 2 { a.swapAt(mid, hi2); hi2 -= 1 }
                else { mid += 1 }
                let snap = a; let lc = lo; let mc = mid
                steps.append((action: { arr = snap; hi = lc; hj = mc },
                              msg: "lo=\(lc) mid=\(mc) hi=\(hi2)"))
            }
        case .rotate:
            let k = 3; var a = seed
            a = Array(a.suffix(k)) + Array(a.prefix(a.count - k))
            steps.append((action: { arr = a }, msg: "右に \(k) 回転"))
        }
        for (i, st) in steps.enumerated() {
            let delay = 0.4 + Double(i) * 0.7
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                guard t == token else { return }
                withAnimation { st.action(); caption = st.msg }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(steps.count) * 0.7 + 0.3) {
            guard t == token else { return }
            withAnimation { done = true; hi = nil; hj = nil; caption = "ソート完了 ✓" }
        }
    }
}

// MARK: - Stack (parentheses, min-stack, monotonic, etc.)

struct StackAnim: View {
    let input: [String]
    let kind: Kind
    enum Kind { case parens, minStack, monotonic }
    @State private var stack: [String] = []
    @State private var cursor = -1
    @State private var caption = ""
    @State private var ok: Bool? = nil
    @State private var token = 0

    var body: some View {
        AnimFrame(title: titleText, tint: .indigo, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    ForEach(input.indices, id: \.self) { i in
                        let active = cursor == i
                        tile(bg: active ? .yellow : .white.opacity(0.06),
                             fg: active ? .black : .white) {
                            Text(input[i])
                        }
                        .scaleEffect(active ? 1.15 : 1.0)
                        .animation(.spring(response: 0.3), value: cursor)
                    }
                }
                Text("stack:")
                    .font(.caption2.weight(.bold)).foregroundStyle(.secondary)
                HStack(spacing: 4) {
                    ForEach(stack.indices, id: \.self) { i in
                        tile(bg: .indigo.opacity(0.4)) { Text(stack[i]) }
                            .transition(.scale.combined(with: .opacity))
                    }
                    if stack.isEmpty {
                        Text("(empty)").font(.caption2).foregroundStyle(.tertiary)
                    }
                }
                .animation(.spring(response: 0.3), value: stack)
                Text(caption)
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(ok == true ? .green : (ok == false ? .red : .secondary))
            }
        }
        .onAppear { play() }
    }

    private var titleText: String {
        switch kind { case .parens: return "括弧チェック"; case .minStack: return "Min Stack"; case .monotonic: return "Monotonic Stack" }
    }

    private func play() {
        token += 1; let t = token
        stack = []; cursor = -1; caption = ""; ok = nil
        for (i, ch) in input.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.7) {
                guard t == token else { return }
                withAnimation {
                    cursor = i
                    switch kind {
                    case .parens:
                        if "([{".contains(ch) {
                            stack.append(ch); caption = "push \(ch)"
                        } else {
                            let map = [")":"(", "]":"[", "}":"{"]
                            if let last = stack.last, last == map[ch] { stack.removeLast(); caption = "pop \(last) (\(ch) と対応)" }
                            else { caption = "✗ 対応する括弧が無い"; ok = false }
                        }
                    case .monotonic:
                        let v = Int(ch) ?? 0
                        while let last = stack.last, (Int(last) ?? 0) <= v { stack.removeLast() }
                        stack.append(ch); caption = "push \(ch) (単調維持)"
                    case .minStack:
                        let v = Int(ch) ?? 0
                        let mn = (stack.last.flatMap { Int($0.split(separator: "|").last ?? "") } ?? Int.max)
                        let newMin = min(mn, v)
                        stack.append("\(v)|\(newMin)"); caption = "push v=\(v), min=\(newMin)"
                    }
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(input.count) * 0.7 + 0.2) {
            guard t == token else { return }
            withAnimation {
                cursor = -1
                if kind == .parens, ok != false { ok = stack.isEmpty; caption = stack.isEmpty ? "✓ 有効な括弧列" : "✗ stack 残り" }
            }
        }
    }
}

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

// MARK: - Sliding Window

struct SlidingWindowAnim: View {
    let s: String
    let initialWidth: Int
    @State private var l = 0
    @State private var r = 0
    @State private var best = 0
    @State private var caption = ""
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Sliding Window", tint: .orange, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 3) {
                    ForEach(Array(s).indices, id: \.self) { i in
                        let inWin = i >= l && i <= r
                        tile(bg: inWin ? .orange.opacity(0.55) : .white.opacity(0.06),
                             fg: inWin ? .black : .white) {
                            Text(String(Array(s)[i]))
                        }
                    }
                }
                .animation(.spring(response: 0.3), value: l)
                .animation(.spring(response: 0.3), value: r)
                Text("l=\(l)  r=\(r)  width=\(r-l+1)  best=\(best)")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.secondary)
                Text(caption).font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }

    private func play() {
        token += 1; let t = token
        l = 0; r = max(initialWidth - 1, 0); best = initialWidth; caption = "初期ウィンドウ"
        let arr = Array(s)
        var seen = Set(arr[0...r])
        var i = 0
        func tick(_ delay: Double, _ block: @escaping () -> Void) {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                guard t == token else { return }
                withAnimation { block() }
            })
        }
        var rr = r
        var ll = 0
        while rr < arr.count - 1 {
            rr += 1
            let c = arr[rr]
            if seen.contains(c) {
                while ll <= rr, seen.contains(c) { seen.remove(arr[ll]); ll += 1 }
            }
            seen.insert(c)
            let llc = ll, rrc = rr
            i += 1
            tick(0.5 + Double(i) * 0.65) {
                l = llc; r = rrc; best = max(best, rrc - llc + 1)
                caption = "拡張/縮小: l=\(llc) r=\(rrc)"
            }
        }
        tick(0.5 + Double(i + 1) * 0.65) { caption = "最大幅 = \(best) ✓" }
    }
}

// MARK: - BFS / DFS on grid

struct GridSearchAnim: View {
    enum Kind { case bfs, dfs }
    let kind: Kind
    let grid: [[Int]] = [
        [1, 1, 0, 0, 0],
        [1, 0, 0, 1, 1],
        [0, 0, 1, 1, 0],
        [0, 1, 1, 0, 0],
    ]
    @State private var visited: Set<String> = []
    @State private var frontier: Set<String> = []
    @State private var caption = ""
    @State private var token = 0

    var body: some View {
        AnimFrame(title: kind == .bfs ? "BFS の広がり" : "DFS の進行", tint: kind == .bfs ? .blue : .green, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                VStack(spacing: 3) {
                    ForEach(grid.indices, id: \.self) { r in
                        HStack(spacing: 3) {
                            ForEach(grid[r].indices, id: \.self) { c in
                                let key = "\(r),\(c)"
                                let v = grid[r][c] == 1
                                let isVisited = visited.contains(key)
                                let isFrontier = frontier.contains(key)
                                tile(width: 22, height: 22,
                                     bg: !v ? Color.white.opacity(0.04)
                                            : (isVisited ? .green.opacity(0.5) : (isFrontier ? .yellow : .blue.opacity(0.2))),
                                     fg: isFrontier ? .black : .white) {
                                    Text(v ? "▓" : " ")
                                }
                                .animation(.easeInOut(duration: 0.2), value: visited)
                                .animation(.easeInOut(duration: 0.2), value: frontier)
                            }
                        }
                    }
                }
                Text(caption).font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }

    private func play() {
        token += 1; let t = token
        visited = []; frontier = []; caption = ""
        let start = (0, 0)
        let R = grid.count, C = grid[0].count
        var queue: [(Int, Int)] = [start]
        var seen: Set<String> = ["0,0"]
        var order: [(Int, Int, [String])] = [(0, 0, ["0,0"])]
        // pre-compute traversal order
        if kind == .bfs {
            var q = queue; var s = seen
            while !q.isEmpty {
                let (r, c) = q.removeFirst()
                for (dr, dc) in [(-1,0),(1,0),(0,-1),(0,1)] {
                    let nr = r + dr, nc = c + dc
                    let key = "\(nr),\(nc)"
                    if nr>=0, nr<R, nc>=0, nc<C, grid[nr][nc]==1, !s.contains(key) {
                        s.insert(key); q.append((nr, nc))
                        order.append((nr, nc, Array(s)))
                    }
                }
            }
        } else {
            var stack = queue; var s = seen
            while !stack.isEmpty {
                let (r, c) = stack.removeLast()
                for (dr, dc) in [(-1,0),(1,0),(0,-1),(0,1)] {
                    let nr = r + dr, nc = c + dc
                    let key = "\(nr),\(nc)"
                    if nr>=0, nr<R, nc>=0, nc<C, grid[nr][nc]==1, !s.contains(key) {
                        s.insert(key); stack.append((nr, nc))
                        order.append((nr, nc, Array(s)))
                    }
                }
            }
        }
        for (i, step) in order.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.5) {
                guard t == token else { return }
                withAnimation {
                    visited.insert("\(step.0),\(step.1)")
                    frontier = []
                    caption = "(\(step.0), \(step.1)) を訪問 (合計 \(visited.count) 個)"
                }
            }
        }
    }
}

// MARK: - Tree traversal

struct TreeTraversalAnim: View {
    enum Order { case inorder, preorder, postorder, level }
    let order: Order
    // Fixed sample tree:    4
    //                      / \
    //                     2   6
    //                    / \ / \
    //                   1  3 5  7
    private let nodes: [Int?] = [4, 2, 6, 1, 3, 5, 7]
    @State private var visited: [Int] = []
    @State private var current: Int? = nil
    @State private var token = 0

    var body: some View {
        AnimFrame(title: title, tint: .green, onReplay: play) {
            VStack(spacing: 8) {
                // Render as 3-level pyramid
                let levels: [[Int]] = [[nodes[0]!], [nodes[1]!, nodes[2]!], [nodes[3]!, nodes[4]!, nodes[5]!, nodes[6]!]]
                ForEach(levels.indices, id: \.self) { lvl in
                    HStack(spacing: 12) {
                        ForEach(levels[lvl], id: \.self) { v in
                            let isVisited = visited.contains(v)
                            let isCur = current == v
                            tile(width: 30, height: 30,
                                 bg: isCur ? .yellow : (isVisited ? .green.opacity(0.5) : .white.opacity(0.08)),
                                 fg: isCur ? .black : .white) { Text("\(v)") }
                                .scaleEffect(isCur ? 1.18 : 1.0)
                                .animation(.spring(response: 0.3), value: current)
                                .animation(.spring(response: 0.3), value: visited)
                        }
                    }
                }
                Text("順番: " + visited.map(String.init).joined(separator: " → "))
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }

    private var title: String {
        switch order {
        case .inorder: return "Inorder (左→根→右)"
        case .preorder: return "Preorder (根→左→右)"
        case .postorder: return "Postorder (左→右→根)"
        case .level: return "Level Order (BFS)"
        }
    }

    private func play() {
        token += 1; let t = token
        visited = []; current = nil
        let seq: [Int]
        switch order {
        case .inorder: seq = [1, 2, 3, 4, 5, 6, 7]
        case .preorder: seq = [4, 2, 1, 3, 6, 5, 7]
        case .postorder: seq = [1, 3, 2, 5, 7, 6, 4]
        case .level: seq = [4, 2, 6, 1, 3, 5, 7]
        }
        for (i, v) in seq.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.6) {
                guard t == token else { return }
                withAnimation { current = v }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.6 + 0.3) {
                guard t == token else { return }
                withAnimation { visited.append(v); current = nil }
            }
        }
    }
}

// MARK: - DP table fill

struct DPTableAnim: View {
    enum Kind {
        case fib, climb, robber, coinChange, lcs, lis, knapsack, uniquePaths, editDist,
             minPath, decode, wordBreak, regex, wildcard, maxSubarray, pascals, countBits, longestValidParens
    }
    let kind: Kind
    @State private var cells: [[String]] = []
    @State private var hi: (Int, Int)? = nil
    @State private var caption = ""
    @State private var token = 0

    var body: some View {
        AnimFrame(title: title, tint: .yellow, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                VStack(spacing: 3) {
                    ForEach(cells.indices, id: \.self) { r in
                        HStack(spacing: 3) {
                            ForEach(cells[r].indices, id: \.self) { c in
                                let isHi = hi.map { $0 == (r, c) } ?? false
                                tile(width: 24, height: 22,
                                     bg: isHi ? .yellow : (cells[r][c].isEmpty ? .white.opacity(0.04) : .yellow.opacity(0.25)),
                                     fg: isHi ? .black : .white) {
                                    Text(cells[r][c]).font(.system(size: 10, weight: .bold, design: .monospaced))
                                }
                                .animation(.spring(response: 0.3), value: hi?.0)
                                .animation(.spring(response: 0.3), value: hi?.1)
                            }
                        }
                    }
                }
                Text(caption).font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }

    private var title: String {
        switch kind {
        case .fib: return "Fibonacci DP"
        case .climb: return "Climbing Stairs DP"
        case .robber: return "House Robber DP"
        case .coinChange: return "Coin Change DP"
        case .lcs: return "LCS (2D DP)"
        case .lis: return "LIS DP"
        case .knapsack: return "0-1 Knapsack"
        case .uniquePaths: return "Unique Paths (2D)"
        case .editDist: return "Edit Distance (2D)"
        case .minPath: return "Min Path Sum (2D)"
        case .decode: return "Decode Ways DP"
        case .wordBreak: return "Word Break DP"
        case .regex: return "Regex DP"
        case .wildcard: return "Wildcard DP"
        case .maxSubarray: return "Kadane (Max Subarray)"
        case .pascals: return "Pascal's Triangle"
        case .countBits: return "Count Bits DP"
        case .longestValidParens: return "Longest Valid Parens DP"
        }
    }

    private func play() {
        token += 1; let t = token
        cells = []; hi = nil; caption = "DP 表を埋めていきます"
        let steps = computeSteps()
        let rows = steps.last?.cells.count ?? 1
        let cols = steps.last?.cells.first?.count ?? 1
        cells = Array(repeating: Array(repeating: "", count: cols), count: rows)
        for (i, st) in steps.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + Double(i) * 0.5) {
                guard t == token else { return }
                withAnimation { cells = st.cells; hi = st.hi; caption = st.msg }
            }
        }
    }

    private struct Step { let cells: [[String]]; let hi: (Int, Int)?; let msg: String }

    private func computeSteps() -> [Step] {
        switch kind {
        case .fib:
            let n = 8; var dp = Array(repeating: 0, count: n)
            dp[0] = 0; dp[1] = 1
            var s: [Step] = []
            s.append(Step(cells: [dp.map(String.init)], hi: (0,0), msg: "dp[0]=0"))
            s.append(Step(cells: [dp.map(String.init)], hi: (0,1), msg: "dp[1]=1"))
            for i in 2..<n { dp[i] = dp[i-1] + dp[i-2]; s.append(Step(cells: [dp.map(String.init)], hi: (0,i), msg: "dp[\(i)] = dp[\(i-1)]+dp[\(i-2)] = \(dp[i])")) }
            return s
        case .climb:
            return mkLine([1,1,2,3,5,8,13,21], "登り方の総数")
        case .robber:
            let nums = [2,7,9,3,1]; var dp = Array(repeating: 0, count: nums.count); dp[0]=nums[0]; dp[1]=max(nums[0],nums[1])
            var s: [Step] = [Step(cells: [dp.map(String.init)], hi: (0,0), msg: "dp[0]=\(dp[0])"),
                             Step(cells: [dp.map(String.init)], hi: (0,1), msg: "dp[1]=\(dp[1])")]
            for i in 2..<nums.count { dp[i]=max(dp[i-1], dp[i-2]+nums[i]); s.append(Step(cells: [dp.map(String.init)], hi: (0,i), msg: "max(dp[i-1], dp[i-2]+v) = \(dp[i])")) }
            return s
        case .coinChange:
            return mkLine([0,1,2,3,4,2,3,4,5,3,1], "amount=10, coins=[1,5,10]")
        case .lcs:
            return mk2D(rows: 4, cols: 5, init: { _,_ in "0" }, fillMsg: "LCS dp[i][j]")
        case .lis:
            return mkLine([1,2,2,3,3,4,2,4], "LIS dp[i] の進行")
        case .knapsack:
            return mk2D(rows: 4, cols: 6, init: { r,c in r==0||c==0 ? "0" : "" }, fillMsg: "Knapsack dp[i][w]")
        case .uniquePaths:
            return mk2D(rows: 3, cols: 4, init: { r,c in (r==0||c==0) ? "1" : "" }, fillMsg: "dp[i][j] = up + left")
        case .editDist:
            return mk2D(rows: 4, cols: 4, init: { r,c in r==0 ? "\(c)" : (c==0 ? "\(r)" : "") }, fillMsg: "edit dp[i][j]")
        case .minPath:
            return mk2D(rows: 3, cols: 3, init: { _,_ in "" }, fillMsg: "min path 累積")
        case .decode:
            return mkLine([1,1,2,3,5,7], "decode dp")
        case .wordBreak:
            return mkLine([1,0,0,1,0,0,1,1], "wordBreak dp[i]")
        case .regex:
            return mk2D(rows: 4, cols: 5, init: { _,_ in "" }, fillMsg: "regex dp[i][j]")
        case .wildcard:
            return mk2D(rows: 4, cols: 5, init: { _,_ in "" }, fillMsg: "wildcard dp[i][j]")
        case .maxSubarray:
            let nums = [-2,1,-3,4,-1,2,1,-5,4]
            var cur = 0, best = Int.min; var dp: [Int] = []
            for n in nums { cur = max(n, cur + n); best = max(best, cur); dp.append(cur) }
            var s: [Step] = []
            for i in 0..<dp.count { s.append(Step(cells: [dp.prefix(i+1).map(String.init) + Array(repeating: "", count: dp.count-i-1)], hi: (0,i), msg: "cur=\(dp[i]) best=\(dp.prefix(i+1).max()!)")) }
            return s
        case .pascals:
            let rows = 5
            var tri: [[Int]] = []
            for r in 0..<rows {
                var row = Array(repeating: 1, count: r+1)
                for c in 1..<r { row[c] = tri[r-1][c-1] + tri[r-1][c] }
                tri.append(row)
            }
            var s: [Step] = []
            for r in 0..<rows {
                var view: [[String]] = []
                for rr in 0...r { view.append(tri[rr].map(String.init) + Array(repeating: "", count: rows - rr - 1)) }
                while view.count < rows { view.append(Array(repeating: "", count: rows)) }
                s.append(Step(cells: view, hi: (r, 0), msg: "row \(r) = \(tri[r])"))
            }
            return s
        case .countBits:
            var dp = [0]
            for i in 1...10 { dp.append(dp[i >> 1] + (i & 1)) }
            var s: [Step] = []
            for i in 0..<dp.count {
                s.append(Step(cells: [dp.prefix(i+1).map(String.init) + Array(repeating: "", count: dp.count-i-1)],
                              hi: (0,i), msg: "dp[\(i)] = dp[\(i>>1)] + (\(i)&1) = \(dp[i])"))
            }
            return s
        case .longestValidParens:
            return mkLine([0,0,2,0,0,2,4,6,0,2], "longest valid parens dp[i]")
        }
    }

    private func mkLine(_ values: [Int], _ msg: String) -> [Step] {
        var s: [Step] = []
        for i in 0..<values.count {
            let view = values.prefix(i+1).map(String.init) + Array(repeating: "", count: values.count - i - 1)
            s.append(Step(cells: [view], hi: (0, i), msg: "\(msg) → dp[\(i)] = \(values[i])"))
        }
        return s
    }
    private func mk2D(rows: Int, cols: Int, init initFn: (Int, Int) -> String, fillMsg: String) -> [Step] {
        var grid = Array(repeating: Array(repeating: "", count: cols), count: rows)
        for r in 0..<rows { for c in 0..<cols { grid[r][c] = initFn(r, c) } }
        var s: [Step] = []
        for r in 0..<rows {
            for c in 0..<cols {
                if grid[r][c].isEmpty { grid[r][c] = "\(r + c)" }
                s.append(Step(cells: grid, hi: (r, c), msg: "\(fillMsg)  ←  (\(r),\(c))"))
            }
        }
        return s
    }
}

// MARK: - Heap

struct HeapAnim: View {
    enum Kind { case kthLargest, topK, slidingMax, meetingRooms }
    let kind: Kind
    @State private var heap: [Int] = []
    @State private var ingest: Int? = nil
    @State private var caption = ""
    @State private var token = 0

    var body: some View {
        AnimFrame(title: title, tint: .red, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Text("min-heap").font(.caption2.weight(.bold)).foregroundStyle(.secondary)
                    ForEach(heap.indices, id: \.self) { i in
                        tile(bg: .red.opacity(0.3)) { Text("\(heap[i])") }
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.3), value: heap)
                if let v = ingest {
                    Text("追加: \(v)").font(.system(.caption2, design: .monospaced)).foregroundStyle(.yellow)
                }
                Text(caption).font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }

    private var title: String {
        switch kind {
        case .kthLargest: return "Kth Largest (size-k Heap)"
        case .topK: return "Top K Frequent"
        case .slidingMax: return "Sliding Window Max"
        case .meetingRooms: return "Meeting Rooms (終了時刻)"
        }
    }

    private func play() {
        token += 1; let t = token
        heap = []; ingest = nil; caption = ""
        let stream: [Int]
        let k = 3
        switch kind {
        case .kthLargest: stream = [3,2,1,5,6,4]
        case .topK: stream = [1,1,1,2,2,3,3,3,3]
        case .slidingMax: stream = [1,3,-1,-3,5,3,6,7]
        case .meetingRooms: stream = [1,3,5,8,9,11]
        }
        for (i, v) in stream.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.6) {
                guard t == token else { return }
                withAnimation {
                    ingest = v
                    heap.append(v); heap.sort()
                    if heap.count > k { heap.removeFirst() }
                    caption = "v=\(v) を投入, heap=\(heap)"
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(stream.count) * 0.6 + 0.2) {
            guard t == token else { return }
            withAnimation { ingest = nil; caption = "結果 = \(heap)" }
        }
    }
}

// MARK: - Bit operations

struct BitAnim: View {
    enum Kind { case singleNumber, powerOfTwo, reverseBits }
    let kind: Kind
    @State private var bits: [Int] = []
    @State private var caption = ""
    @State private var hi: Int? = nil
    @State private var token = 0

    var body: some View {
        AnimFrame(title: title, tint: .mint, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 3) {
                    ForEach(bits.indices, id: \.self) { i in
                        let active = hi == i
                        tile(width: 22, height: 22,
                             bg: active ? .yellow : (bits[i] == 1 ? .mint.opacity(0.6) : .white.opacity(0.06)),
                             fg: active ? .black : .white) { Text("\(bits[i])") }
                            .scaleEffect(active ? 1.15 : 1.0)
                            .animation(.spring(response: 0.3), value: hi)
                            .animation(.easeInOut(duration: 0.25), value: bits)
                    }
                }
                Text(caption).font(.system(.caption2, design: .monospaced)).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }

    private var title: String {
        switch kind {
        case .singleNumber: return "XOR で消す"
        case .powerOfTwo: return "2の冪 (n & (n-1))"
        case .reverseBits: return "ビット反転"
        }
    }

    private func bitsOf(_ x: Int, width: Int = 8) -> [Int] {
        (0..<width).map { (x >> ($0)) & 1 }.reversed()
    }

    private func play() {
        token += 1; let t = token
        switch kind {
        case .singleNumber:
            let nums = [4, 1, 2, 1, 2]
            var acc = 0
            bits = bitsOf(0); caption = "acc = 0"
            for (i, v) in nums.enumerated() {
                acc ^= v
                let snap = acc
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(i) * 0.7) {
                    guard t == token else { return }
                    withAnimation { bits = bitsOf(snap); caption = "acc ^= \(v) → \(snap)" }
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(nums.count) * 0.7 + 0.2) {
                guard t == token else { return }
                withAnimation { caption = "唯一の単独要素 = \(acc) ✓" }
            }
        case .powerOfTwo:
            let n = 16
            bits = bitsOf(n); caption = "n = \(n) = \(String(n, radix: 2))"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                guard t == token else { return }
                withAnimation { bits = bitsOf(n - 1); caption = "n-1 = \(n-1) = \(String(n-1, radix: 2))" }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                guard t == token else { return }
                withAnimation { bits = bitsOf(n & (n-1)); caption = "n & (n-1) = \(n & (n-1)) → 0 なら2の冪 ✓" }
            }
        case .reverseBits:
            let n = 0b10110100
            bits = bitsOf(n); caption = "元: \(String(n, radix: 2))"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                guard t == token else { return }
                withAnimation { bits = bits.reversed(); caption = "反転: \(bits.map(String.init).joined())" }
            }
        }
    }
}

// MARK: - Backtracking (recursion tree)

struct BacktrackingAnim: View {
    enum Kind { case combinations, subsets, permutations, nQueens, wordSearch }
    let kind: Kind
    @State private var lines: [String] = []
    @State private var token = 0

    var body: some View {
        AnimFrame(title: title, tint: .purple, onReplay: play) {
            VStack(alignment: .leading, spacing: 3) {
                ForEach(lines.indices, id: \.self) { i in
                    Text(lines[i])
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(lines[i].contains("✓") ? .green : .secondary)
                        .transition(.opacity.combined(with: .move(edge: .leading)))
                }
            }
            .animation(.easeOut, value: lines)
        }
        .onAppear { play() }
    }

    private var title: String {
        switch kind {
        case .combinations: return "Combinations 再帰木"
        case .subsets: return "Subsets 再帰木"
        case .permutations: return "Permutations 再帰木"
        case .nQueens: return "N-Queens (4x4)"
        case .wordSearch: return "Word Search DFS"
        }
    }

    private func play() {
        token += 1; let t = token
        lines = []
        let seq: [String]
        switch kind {
        case .combinations: seq = ["start=1","  pick 1, [1]","    pick 2, [1,2] ✓","    pick 3, [1,3] ✓","  pick 2, [2]","    pick 3, [2,3] ✓","  pick 3, [3]"]
        case .subsets: seq = ["[]", "  [1]", "    [1,2]", "      [1,2,3] ✓", "    [1,3] ✓", "  [2]", "    [2,3] ✓", "  [3] ✓"]
        case .permutations: seq = ["[]", "  [1]", "    [1,2]", "      [1,2,3] ✓", "    [1,3]", "      [1,3,2] ✓", "  [2]", "    [2,1,3] ✓", "  ..."]
        case .nQueens: seq = ["row 0: Q at col 0", "  row 1: Q at col 2", "    row 2: 全部攻撃される ✗", "  row 1: Q at col 3", "    row 2: Q at col 1", "      row 3: ✓ 解 (0,2,3,1)"]
        case .wordSearch: seq = ["start (0,0)='A'", "  右 (0,1)='B' ✓", "    下 (1,1)='C' ✓", "      右 (1,2)='C' ✗ 戻る", "      下 (2,1)='D' ✓ 完成"]
        }
        for (i, line) in seq.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.5) {
                guard t == token else { return }
                withAnimation { lines.append(line) }
            }
        }
    }
}

// MARK: - Trie

struct TrieAnim: View {
    enum Kind { case insert, search }
    let kind: Kind
    let words: [String] = ["cat", "car", "card", "cab"]
    @State private var inserted: [String] = []
    @State private var caption = ""
    @State private var token = 0

    var body: some View {
        AnimFrame(title: kind == .insert ? "Trie Insert" : "Trie Search", tint: .indigo, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                Text("root").font(.caption.weight(.bold))
                ForEach(words.indices, id: \.self) { i in
                    let w = words[i]
                    HStack(spacing: 3) {
                        Text("├")
                        ForEach(Array(w).indices, id: \.self) { j in
                            let active = inserted.contains(String(w.prefix(j+1)))
                            tile(width: 18, height: 18,
                                 bg: active ? .indigo.opacity(0.5) : .white.opacity(0.06),
                                 fg: .white) { Text(String(Array(w)[j])) }
                        }
                    }
                    .font(.system(.caption2, design: .monospaced))
                    .animation(.easeInOut, value: inserted)
                }
                Text(caption).font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }

    private func play() {
        token += 1; let t = token
        inserted = []; caption = ""
        var allPrefixes: [String] = []
        for w in words {
            for j in 1...w.count { allPrefixes.append(String(w.prefix(j))) }
        }
        for (i, p) in allPrefixes.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + Double(i) * 0.3) {
                guard t == token else { return }
                withAnimation {
                    if !inserted.contains(p) { inserted.append(p) }
                    caption = "ノード追加: \(p)"
                }
            }
        }
    }
}

// MARK: - Union Find

struct UnionFindAnim: View {
    let kind: Kind
    enum Kind { case basic, kruskal }
    @State private var parent: [Int] = Array(0..<6)
    @State private var caption = ""
    @State private var token = 0

    var body: some View {
        AnimFrame(title: kind == .basic ? "Union-Find" : "Kruskal (辺を貪欲に追加)", tint: .orange, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 3) {
                    ForEach(parent.indices, id: \.self) { i in
                        tile(bg: rootColor(of: i)) {
                            VStack(spacing: 0) {
                                Text("\(i)").font(.system(size: 9, weight: .bold))
                                Text("→\(find(i))").font(.system(size: 7))
                            }
                        }
                    }
                }
                .animation(.spring(response: 0.3), value: parent)
                Text(caption).font(.system(.caption2, design: .monospaced)).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }

    private func find(_ x: Int) -> Int {
        var v = x
        while parent[v] != v { v = parent[v] }
        return v
    }

    private func rootColor(of i: Int) -> Color {
        let palette: [Color] = [.orange, .blue, .green, .pink, .purple, .cyan]
        return palette[find(i) % palette.count].opacity(0.4)
    }

    private func play() {
        token += 1; let t = token
        parent = Array(0..<6); caption = "各要素は単独"
        let unions: [(Int, Int)]
        switch kind {
        case .basic: unions = [(0,1),(2,3),(1,3),(4,5)]
        case .kruskal: unions = [(0,1),(2,3),(4,5),(1,2),(3,4)]
        }
        for (i, (a, b)) in unions.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(i) * 0.8) {
                guard t == token else { return }
                withAnimation {
                    let ra = find(a), rb = find(b)
                    if ra != rb { parent[ra] = rb; caption = "union(\(a), \(b))" }
                    else { caption = "union(\(a), \(b)) → 同じ集合" }
                }
            }
        }
    }
}

// MARK: - Math: GCD, FastPow, Sieve

struct GCDAnim: View {
    @State private var steps: [(a: Int, b: Int)] = []
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "ユークリッドの互除法", tint: .blue, onReplay: play) {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(steps.indices, id: \.self) { i in
                    Text("a=\(steps[i].a)  b=\(steps[i].b)  →  a%b=\(steps[i].b == 0 ? 0 : steps[i].a % steps[i].b)")
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(steps[i].b == 0 ? .green : .secondary)
                }
            }
        }
        .onAppear { play() }
    }

    private func play() {
        token += 1; let t = token
        steps = []
        var a = 48, b = 18
        var local: [(Int, Int)] = []
        while b != 0 { local.append((a, b)); let r = a % b; a = b; b = r }
        local.append((a, 0))
        for (i, s) in local.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.6) {
                guard t == token else { return }
                withAnimation { steps.append(s) }
            }
        }
    }
}

struct FastPowAnim: View {
    @State private var lines: [String] = []
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Fast Exponentiation (2^13)", tint: .cyan, onReplay: play) {
            VStack(alignment: .leading, spacing: 3) {
                ForEach(lines.indices, id: \.self) { i in
                    Text(lines[i]).font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .onAppear { play() }
    }

    private func play() {
        token += 1; let t = token
        lines = []
        var b = 2, e = 13, r = 1
        var seq: [String] = []
        while e > 0 {
            if e & 1 == 1 { r *= b; seq.append("e&1 → r *= \(b) → r=\(r)") }
            b *= b; e >>= 1
            seq.append("b=\(b)  e=\(e)")
        }
        seq.append("結果 = \(r) ✓")
        for (i, line) in seq.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.5) {
                guard t == token else { return }
                withAnimation { lines.append(line) }
            }
        }
    }
}

struct SieveAnim: View {
    let n = 30
    @State private var marked: Set<Int> = []
    @State private var current: Int? = nil
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "エラトステネスのふるい", tint: .pink, onReplay: play) {
            let cols = 10
            VStack(spacing: 3) {
                ForEach(0..<(n / cols), id: \.self) { r in
                    HStack(spacing: 3) {
                        ForEach(0..<cols, id: \.self) { c in
                            let v = r * cols + c + 1
                            let isMarked = marked.contains(v)
                            let isCur = current == v
                            tile(width: 22, height: 22,
                                 bg: isCur ? .yellow : (isMarked ? .gray.opacity(0.3) : .pink.opacity(0.4)),
                                 fg: (isCur ? .black : (isMarked ? .white.opacity(0.4) : .white))) {
                                Text("\(v)")
                            }
                            .animation(.easeInOut(duration: 0.25), value: marked)
                            .animation(.easeInOut(duration: 0.25), value: current)
                        }
                    }
                }
            }
        }
        .onAppear { play() }
    }

    private func play() {
        token += 1; let t = token
        marked = [1]; current = nil
        var step = 0
        for p in 2...n {
            if marked.contains(p) { continue }
            let pc = p
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(step) * 0.5) {
                guard t == token else { return }
                withAnimation { current = pc }
            }
            step += 1
            var m = p * 2
            while m <= n {
                let mc = m
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(step) * 0.25) {
                    guard t == token else { return }
                    withAnimation { _ = marked.insert(mc) }
                }
                step += 1
                m += p
            }
        }
    }
}

// MARK: - Container with Most Water / Trapping Rain Water

struct WaterAnim: View {
    enum Kind { case container, trapping }
    let kind: Kind
    let heights: [Int] = [1, 8, 6, 2, 5, 4, 8, 3, 7]
    @State private var l = 0
    @State private var r = 8
    @State private var best = 0
    @State private var caption = ""
    @State private var token = 0

    var body: some View {
        AnimFrame(title: kind == .container ? "Container With Most Water" : "Trapping Rain Water",
                  tint: .blue, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .bottom, spacing: 3) {
                    ForEach(heights.indices, id: \.self) { i in
                        let active = i == l || i == r
                        Rectangle()
                            .fill(active ? Color.yellow : Color.blue.opacity(0.5))
                            .frame(width: 18, height: CGFloat(heights[i]) * 6)
                            .overlay(Text("\(heights[i])").font(.system(size: 9)).foregroundStyle(.white).padding(.top, 2), alignment: .top)
                            .scaleEffect(active ? 1.05 : 1.0)
                            .animation(.spring(response: 0.3), value: l)
                            .animation(.spring(response: 0.3), value: r)
                    }
                }
                Text(caption).font(.system(.caption2, design: .monospaced)).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }

    private func play() {
        token += 1; let t = token
        l = 0; r = heights.count - 1; best = 0; caption = ""
        var ll = 0, rr = heights.count - 1, b = 0
        var snaps: [(Int, Int, Int, String)] = []
        while ll < rr {
            let area = min(heights[ll], heights[rr]) * (rr - ll); b = max(b, area)
            snaps.append((ll, rr, b, "min(\(heights[ll]),\(heights[rr]))×(\(rr)-\(ll))=\(area), best=\(b)"))
            if heights[ll] < heights[rr] { ll += 1 } else { rr -= 1 }
        }
        for (i, s) in snaps.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.7) {
                guard t == token else { return }
                withAnimation { l = s.0; r = s.1; best = s.2; caption = s.3 }
            }
        }
    }
}

// MARK: - Floyd's cycle detection (visualized linearly)

struct FloydAnim: View {
    @State private var slow = 0
    @State private var fast = 0
    @State private var caption = ""
    @State private var token = 0
    let arr = [1, 3, 4, 2, 5, 2, 6]

    var body: some View {
        AnimFrame(title: "Floyd's Tortoise & Hare", tint: .green, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 3) {
                    ForEach(arr.indices, id: \.self) { i in
                        let isSlow = i == slow
                        let isFast = i == fast
                        VStack(spacing: 2) {
                            Text(isSlow && isFast ? "S=F" : (isSlow ? "S" : (isFast ? "F" : " ")))
                                .font(.system(size: 9, weight: .heavy))
                                .foregroundStyle(isSlow || isFast ? Color.yellow : .clear)
                            tile(width: 22, height: 22,
                                 bg: (isSlow && isFast) ? .yellow : (isSlow || isFast ? .green.opacity(0.5) : .white.opacity(0.08))) {
                                Text("\(arr[i])")
                            }
                        }
                    }
                }
                .animation(.spring(response: 0.3), value: slow)
                .animation(.spring(response: 0.3), value: fast)
                Text(caption).font(.system(.caption2, design: .monospaced)).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }

    private func play() {
        token += 1; let t = token
        slow = 0; fast = 0; caption = "slow=fast=start"
        let steps = 6
        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(i) * 0.6) {
                guard t == token else { return }
                withAnimation {
                    slow = (slow + 1) % arr.count
                    fast = (fast + 2) % arr.count
                    caption = "step \(i): slow=\(slow) fast=\(fast)"
                    if slow == fast { caption += "  → 合流！循環あり ✓" }
                }
            }
        }
    }
}

// MARK: - Topic dispatcher

@ViewBuilder
func topicAnimation(for problem: PuzzleProblem) -> some View {
    switch problem.id {
    // Binary search variants
    case "binary-search", "search-rotated", "first-last-pos", "median-two-arrays":
        BinarySearchAnim()
    // Two pointers / strings
    case "palindrome-check": TwoPointerAnim(word: "racecar")
    case "reverse-string": TwoPointerAnim(word: "hello")
    case "container-water": WaterAnim(kind: .container)
    case "trapping-rain": WaterAnim(kind: .trapping)
    // Anagram
    case "anagram-check": AnagramAnim(a: "anagram", b: "nagaram")
    case "group-anagrams": AnagramAnim(a: "eat", b: "tea")
    // Sorting
    case "bubble-sort": SortingAnim(kind: .bubble)
    case "insertion-sort": SortingAnim(kind: .insertion)
    case "selection-sort": SortingAnim(kind: .selection)
    case "counting-sort": SortingAnim(kind: .counting)
    case "quicksort": SortingAnim(kind: .quick)
    case "merge-sort": SortingAnim(kind: .merge)
    case "dutch-flag": SortingAnim(kind: .dutch)
    case "rotate-array": SortingAnim(kind: .rotate)
    case "merge-intervals": SortingAnim(kind: .merge)
    // Stack
    case "valid-parentheses": StackAnim(input: ["(","(",")",")","[","]"], kind: .parens)
    case "min-stack": StackAnim(input: ["3","5","2","1"], kind: .minStack)
    case "next-greater": StackAnim(input: ["2","1","3","2","4"], kind: .monotonic)
    case "largest-rectangle": StackAnim(input: ["2","1","5","6","2","3"], kind: .monotonic)
    case "longest-valid-parens": DPTableAnim(kind: .longestValidParens)
    // Linked list
    case "reverse-linked-list": LinkedListAnim(kind: .reverse)
    case "merge-two-lists": LinkedListAnim(kind: .merge)
    case "middle-ll": LinkedListAnim(kind: .middle)
    case "detect-cycle": LinkedListAnim(kind: .cycle)
    case "add-two-numbers": LinkedListAnim(kind: .addNumbers)
    case "intersection-ll": LinkedListAnim(kind: .intersection)
    // Sliding window
    case "longest-substring": SlidingWindowAnim(s: "abcabcbb", initialWidth: 1)
    case "min-window-substring": SlidingWindowAnim(s: "ADOBECODEBANC", initialWidth: 1)
    case "sliding-window-max": HeapAnim(kind: .slidingMax)
    // BFS / DFS / Graph
    case "bfs": GridSearchAnim(kind: .bfs)
    case "dfs-iterative": GridSearchAnim(kind: .dfs)
    case "num-islands": GridSearchAnim(kind: .bfs)
    case "level-order": TreeTraversalAnim(order: .level)
    case "topo-sort", "course-schedule": GridSearchAnim(kind: .dfs)
    case "dijkstra": GridSearchAnim(kind: .bfs)
    case "union-find": UnionFindAnim(kind: .basic)
    case "kruskal": UnionFindAnim(kind: .kruskal)
    // Tree
    case "inorder-iter", "validate-bst", "kth-smallest-bst": TreeTraversalAnim(order: .inorder)
    case "lca-bt", "lca-bst", "flatten-bt", "build-tree-post": TreeTraversalAnim(order: .preorder)
    case "max-depth-bt", "balanced-bt", "diameter-bt", "path-sum",
         "invert-bt", "symmetric-tree": TreeTraversalAnim(order: .postorder)
    case "serialize-bt": TreeTraversalAnim(order: .level)
    // DP
    case "fibonacci-memo": DPTableAnim(kind: .fib)
    case "climbing-stairs": DPTableAnim(kind: .climb)
    case "house-robber": DPTableAnim(kind: .robber)
    case "coin-change": DPTableAnim(kind: .coinChange)
    case "lcs": DPTableAnim(kind: .lcs)
    case "lis": DPTableAnim(kind: .lis)
    case "knapsack": DPTableAnim(kind: .knapsack)
    case "unique-paths": DPTableAnim(kind: .uniquePaths)
    case "edit-distance": DPTableAnim(kind: .editDist)
    case "min-path-sum": DPTableAnim(kind: .minPath)
    case "decode-ways": DPTableAnim(kind: .decode)
    case "word-break": DPTableAnim(kind: .wordBreak)
    case "regex-matching": DPTableAnim(kind: .regex)
    case "wildcard-matching": DPTableAnim(kind: .wildcard)
    case "max-subarray": DPTableAnim(kind: .maxSubarray)
    case "pascals-triangle": DPTableAnim(kind: .pascals)
    case "count-bits": DPTableAnim(kind: .countBits)
    // Heap
    case "kth-largest": HeapAnim(kind: .kthLargest)
    case "top-k-freq": HeapAnim(kind: .topK)
    case "meeting-rooms": HeapAnim(kind: .meetingRooms)
    // Bit
    case "single-number": BitAnim(kind: .singleNumber)
    case "power-of-two": BitAnim(kind: .powerOfTwo)
    case "reverse-bits": BitAnim(kind: .reverseBits)
    // Backtracking
    case "combinations": BacktrackingAnim(kind: .combinations)
    case "subsets": BacktrackingAnim(kind: .subsets)
    case "permutations": BacktrackingAnim(kind: .permutations)
    case "n-queens": BacktrackingAnim(kind: .nQueens)
    case "word-search": BacktrackingAnim(kind: .wordSearch)
    // Trie
    case "trie-insert": TrieAnim(kind: .insert)
    case "trie-search": TrieAnim(kind: .search)
    // Math
    case "gcd": GCDAnim()
    case "fast-pow": FastPowAnim()
    case "sieve": SieveAnim()
    // Floyd's cycle (Array variant)
    case "find-duplicate": FloydAnim()
    default:
        EmptyView()
    }
}
