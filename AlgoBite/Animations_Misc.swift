import SwiftUI

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

// MARK: - Two Sum (hash map walk)

struct TwoSumAnim: View {
    let nums: [Int] = [2, 7, 11, 15]
    let target: Int = 9
    @State private var step = -1
    @State private var seen: [(val: Int, idx: Int)] = []
    @State private var found: (Int, Int)? = nil
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Two Sum (target = \(target))", tint: .pink, onReplay: play) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    ForEach(nums.indices, id: \.self) { i in
                        let isCurrent = i == step
                        let isHit = found.map { i == $0.0 || i == $0.1 } ?? false
                        tile(width: 32, height: 32,
                             bg: isHit ? .green : (isCurrent ? .yellow : .white.opacity(0.20)),
                             fg: (isHit || isCurrent) ? .black : .white) { Text("\(nums[i])") }
                    }
                }
                Text("nums = \(nums.description)")
                    .font(.system(.caption2, design: .monospaced)).foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 3) {
                    Text("見たもの (val → index):").font(.caption2.weight(.bold)).foregroundStyle(.secondary)
                    HStack(spacing: 4) {
                        ForEach(seen.indices, id: \.self) { i in
                            Text("\(seen[i].val)→\(seen[i].idx)")
                                .font(.system(size: 10, weight: .heavy, design: .monospaced))
                                .padding(.horizontal, 6).padding(.vertical, 3)
                                .background(.pink.opacity(0.25), in: Capsule())
                        }
                    }
                }
                if let f = found {
                    Text("🎯 (\(f.0), \(f.1)) で和 = \(target)")
                        .font(.caption.weight(.bold)).foregroundStyle(.green)
                } else if step >= 0 && step < nums.count {
                    Text("complement \(target - nums[step]) は seen に？")
                        .font(.system(.caption2, design: .monospaced)).foregroundStyle(.secondary)
                }
            }
        }
        .onAppear { play() }
    }

    private func play() {
        token += 1; let t = token
        step = -1; seen = []; found = nil
        for i in nums.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(i) * 1.0) {
                guard t == token else { return }
                withAnimation { step = i }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(i) * 1.0 + 0.5) {
                guard t == token else { return }
                let comp = target - nums[i]
                if let prev = seen.firstIndex(where: { $0.val == comp }) {
                    withAnimation { found = (seen[prev].idx, i) }
                    return
                }
                withAnimation { seen.append((nums[i], i)) }
            }
        }
    }
}

// MARK: - Spiral Matrix

struct SpiralMatrixAnim: View {
    // 問題例 (3x3 → [1,2,3,6,9,8,7,4,5]) に合わせる
    let rows = 3, cols = 3
    @State private var visited: [(Int, Int)] = []
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Spiral Matrix", tint: .indigo, onReplay: play) {
            VStack(spacing: 4) {
                ForEach(0..<rows, id: \.self) { r in
                    HStack(spacing: 4) {
                        ForEach(0..<cols, id: \.self) { c in
                            let order = visited.firstIndex(where: { $0 == (r, c) })
                            tile(width: 30, height: 30,
                                 bg: order != nil ? .indigo.opacity(0.65) : .white.opacity(0.18),
                                 fg: .white) {
                                Text(order.map { "\($0 + 1)" } ?? "·")
                            }
                        }
                    }
                }
                Text("外周から内側へ螺旋に走査")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }

    private func play() {
        token += 1; let t = token
        visited = []
        var top = 0, bot = rows - 1, left = 0, right = cols - 1
        var seq: [(Int, Int)] = []
        while top <= bot && left <= right {
            for c in left...right { seq.append((top, c)) }
            top += 1
            if top > bot { break }
            for r in top...bot { seq.append((r, right)) }
            right -= 1
            if left > right { break }
            for c in stride(from: right, through: left, by: -1) { seq.append((bot, c)) }
            bot -= 1
            if top > bot { break }
            for r in stride(from: bot, through: top, by: -1) { seq.append((r, left)) }
            left += 1
        }
        for (i, p) in seq.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25 + Double(i) * 0.18) {
                guard t == token else { return }
                withAnimation { visited.append(p) }
            }
        }
    }
}

// MARK: - Product Except Self (prefix * suffix)

struct ProductExceptSelfAnim: View {
    let nums: [Int] = [1, 2, 3, 4]
    @State private var prefix: [Int] = []
    @State private var suffix: [Int] = []
    @State private var result: [Int] = []
    @State private var phase = 0   // 0=start 1=prefix 2=suffix 3=combine
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Product Except Self", tint: .teal, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                row(label: "nums", values: nums.map(String.init), color: .gray)
                row(label: "prefix→", values: prefix.map(String.init), color: .blue)
                row(label: "←suffix", values: suffix.map(String.init), color: .orange)
                row(label: "result", values: result.map(String.init), color: .green)
                Text("output[i] = prefix[i] × suffix[i] (自分以外の積)")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func row(label: String, values: [String], color: Color) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .black, design: .monospaced))
                .frame(width: 54, alignment: .leading)
                .foregroundStyle(color)
            ForEach(Array(values.enumerated()), id: \.offset) { _, s in
                tile(width: 28, height: 26, bg: color.opacity(0.4)) { Text(s) }
            }
        }
    }
    private func play() {
        token += 1; let t = token
        prefix = []; suffix = []; result = []
        var p = 1
        for i in nums.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.5) {
                guard t == token else { return }
                withAnimation { prefix.append(p) }
                p *= nums[i]
            }
        }
        let base = 0.4 + Double(nums.count) * 0.5 + 0.3
        var s = 1
        var sArr: [Int] = Array(repeating: 0, count: nums.count)
        for i in stride(from: nums.count - 1, through: 0, by: -1) {
            sArr[i] = s
            s *= nums[i]
        }
        for i in nums.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + base + Double(i) * 0.5) {
                guard t == token else { return }
                withAnimation { suffix.append(sArr[i]) }
            }
        }
        let base2 = base + Double(nums.count) * 0.5 + 0.3
        for i in nums.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + base2 + Double(i) * 0.5) {
                guard t == token else { return }
                if i < prefix.count && i < suffix.count {
                    withAnimation { result.append(prefix[i] * suffix[i]) }
                }
            }
        }
    }
}

// MARK: - Pascal's Triangle

struct PascalsTriangleAnim: View {
    // 問題例 (numRows=5 → [[1],[1,1],[1,2,1],[1,3,3,1],[1,4,6,4,1]]) に合わせる
    let rows = 5
    @State private var triangle: [[Int]] = []
    @State private var curR = -1
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Pascal's Triangle", tint: .purple, onReplay: play) {
            VStack(spacing: 4) {
                ForEach(triangle.indices, id: \.self) { r in
                    HStack(spacing: 3) {
                        ForEach(triangle[r].indices, id: \.self) { c in
                            tile(width: 28, height: 24,
                                 bg: r == curR ? .yellow : .purple.opacity(0.45),
                                 fg: r == curR ? .black : .white) {
                                Text("\(triangle[r][c])")
                            }
                        }
                    }
                }
            }
            Text("row[i][j] = row[i-1][j-1] + row[i-1][j]")
                .font(.caption2).foregroundStyle(.secondary)
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        triangle = []; curR = -1
        for r in 0..<rows {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(r) * 0.6) {
                guard t == token else { return }
                var row = [1]
                if r > 0 {
                    let prev = triangle[r - 1]
                    for j in 1..<prev.count { row.append(prev[j - 1] + prev[j]) }
                    row.append(1)
                }
                withAnimation { triangle.append(row); curR = r }
            }
        }
    }
}

// MARK: - Container With Most Water

struct ContainerWaterAnim: View {
    let height = [1, 8, 6, 2, 5, 4, 8, 3, 7]
    @State private var l = 0
    @State private var r = 8
    @State private var best = 0
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Container With Most Water", tint: .cyan, onReplay: play) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(height.indices, id: \.self) { i in
                        ZStack(alignment: .bottom) {
                            // 水
                            if i >= l && i <= r {
                                Rectangle()
                                    .fill(Color.cyan.opacity(0.45))
                                    .frame(width: 22, height: CGFloat(min(height[l], height[r])) * 8)
                            }
                            // 棒
                            Rectangle()
                                .fill(i == l || i == r ? .blue : .gray.opacity(0.45))
                                .frame(width: 22, height: CGFloat(height[i]) * 8)
                        }
                    }
                }
                .padding(.top, 4)
                HStack {
                    Text("l=\(l)  r=\(r)")
                        .font(.system(.caption2, design: .monospaced))
                    Spacer()
                    Text("best = \(best)")
                        .font(.caption.weight(.bold)).foregroundStyle(.cyan)
                }
                Text("低い側を内側へ動かす (高い側を残す)").font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        l = 0; r = height.count - 1; best = 0
        var li = 0, ri = height.count - 1
        var k = 0
        while li < ri {
            let area = (ri - li) * min(height[li], height[ri])
            let curL = li, curR = ri
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.7) {
                guard t == token else { return }
                withAnimation { l = curL; r = curR; best = max(best, area) }
            }
            if height[li] < height[ri] { li += 1 } else { ri -= 1 }
            k += 1
        }
    }
}

// MARK: - Trapping Rain Water (per-column water)

struct TrappingRainAnim: View {
    let height = [0, 1, 0, 2, 1, 0, 1, 3, 2, 1, 2, 1]
    @State private var idx = -1
    @State private var trapped: [Int] = []
    @State private var leftMax: [Int] = []
    @State private var rightMax: [Int] = []
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Trapping Rain Water", tint: .blue, onReplay: play) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .bottom, spacing: 2) {
                    ForEach(height.indices, id: \.self) { i in
                        ZStack(alignment: .bottom) {
                            if i < trapped.count, trapped[i] > 0 {
                                Rectangle().fill(Color.blue.opacity(0.55))
                                    .frame(width: 16, height: CGFloat(trapped[i]) * 14)
                                    .offset(y: -CGFloat(height[i]) * 14)
                            }
                            Rectangle().fill(i == idx ? .yellow : .gray.opacity(0.6))
                                .frame(width: 16, height: CGFloat(height[i]) * 14)
                        }
                    }
                }
                .padding(.top, 4)
                Text("水量 = min(leftMax[i], rightMax[i]) - height[i]")
                    .font(.caption2).foregroundStyle(.secondary)
                Text("合計水量 = \(trapped.reduce(0, +))")
                    .font(.caption.weight(.bold)).foregroundStyle(.blue)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        idx = -1; trapped = []; leftMax = []; rightMax = []
        let n = height.count
        var lm = Array(repeating: 0, count: n)
        var rm = Array(repeating: 0, count: n)
        var mx = 0
        for i in 0..<n { mx = max(mx, height[i]); lm[i] = mx }
        mx = 0
        for i in stride(from: n - 1, through: 0, by: -1) { mx = max(mx, height[i]); rm[i] = mx }
        for i in 0..<n {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.35) {
                guard t == token else { return }
                let w = max(0, min(lm[i], rm[i]) - height[i])
                withAnimation { idx = i; trapped.append(w) }
            }
        }
    }
}

// MARK: - Permutations (backtracking tree)

struct PermutationsTreeAnim: View {
    let nums = [1, 2, 3]
    @State private var paths: [[Int]] = []
    @State private var current: [Int] = []
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Permutations of \(nums)", tint: .indigo, onReplay: play) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("current:").font(.caption2.weight(.heavy)).foregroundStyle(.indigo)
                    HStack(spacing: 4) {
                        ForEach(current.indices, id: \.self) { i in
                            tile(width: 24, height: 24, bg: .yellow, fg: .black) { Text("\(current[i])") }
                        }
                    }
                }
                Text("確定済み順列:").font(.caption2.weight(.heavy)).foregroundStyle(.secondary)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 6)], spacing: 6) {
                    ForEach(paths.indices, id: \.self) { i in
                        HStack(spacing: 2) {
                            ForEach(paths[i].indices, id: \.self) { j in
                                tile(width: 20, height: 20, bg: .indigo.opacity(0.55)) { Text("\(paths[i][j])") }
                            }
                        }
                    }
                }
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        paths = []; current = []
        var seq: [[Int]] = []
        func backtrack(used: [Bool], path: [Int]) {
            if path.count == nums.count { seq.append(path); return }
            for i in nums.indices where !used[i] {
                var u = used; u[i] = true
                backtrack(used: u, path: path + [nums[i]])
            }
        }
        backtrack(used: Array(repeating: false, count: nums.count), path: [])
        var k = 0
        for p in seq {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.6) {
                guard t == token else { return }
                withAnimation { current = p; paths.append(p) }
            }
            k += 1
        }
    }
}

// MARK: - Subsets (power set bit pattern)

struct SubsetsAnim: View {
    let nums = [1, 2, 3]
    @State private var current: [Int] = []
    @State private var collected: [[Int]] = []
    @State private var mask = 0
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Subsets of \(nums)", tint: .indigo, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Text("mask:").font(.caption2.weight(.black)).foregroundStyle(.indigo)
                    ForEach(nums.indices.reversed(), id: \.self) { bit in
                        let on = (mask >> bit) & 1 == 1
                        tile(width: 22, height: 22,
                             bg: on ? .indigo : .indigo.opacity(0.2),
                             fg: on ? .white : .white.opacity(0.5)) {
                            Text(on ? "1" : "0").font(.system(size: 11, weight: .black, design: .monospaced))
                        }
                    }
                }
                HStack(spacing: 4) {
                    Text("current:").font(.caption2.weight(.black)).foregroundStyle(.indigo)
                    if current.isEmpty {
                        Text("{}").font(.caption.weight(.black)).foregroundStyle(.secondary)
                    } else {
                        ForEach(current.indices, id: \.self) { i in
                            tile(width: 22, height: 22, bg: .yellow, fg: .black) { Text("\(current[i])") }
                        }
                    }
                }
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 4)], spacing: 4) {
                    ForEach(collected.indices, id: \.self) { i in
                        HStack(spacing: 2) {
                            ForEach(collected[i].indices, id: \.self) { j in
                                tile(width: 18, height: 18, bg: .indigo.opacity(0.55)) {
                                    Text("\(collected[i][j])")
                                }
                            }
                            if collected[i].isEmpty {
                                Text("∅").font(.caption.weight(.black)).foregroundStyle(.indigo)
                            }
                        }
                    }
                }
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        current = []; collected = []; mask = 0
        for m in 0..<(1 << nums.count) {
            var sub: [Int] = []
            for b in nums.indices where (m >> b) & 1 == 1 { sub.append(nums[b]) }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(m) * 0.7) {
                guard t == token else { return }
                withAnimation { mask = m; current = sub; collected.append(sub) }
            }
        }
    }
}

// MARK: - N-Queens (board placement)

struct NQueensAnim: View {
    let n = 4
    @State private var board: [Int] = []   // 行 → 列
    @State private var current = -1
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "\(n)-Queens", tint: .red, onReplay: play) {
            VStack(spacing: 3) {
                ForEach(0..<n, id: \.self) { r in
                    HStack(spacing: 3) {
                        ForEach(0..<n, id: \.self) { c in
                            let placed = r < board.count && board[r] == c
                            let attacked = isAttacked(r: r, c: c)
                            ZStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill((r + c) % 2 == 0 ? Color.white.opacity(0.8) : Color.gray.opacity(0.55))
                                    .frame(width: 32, height: 32)
                                if placed { Text("♛").font(.title3).foregroundStyle(.red) }
                                else if r == current && attacked {
                                    Text("✕").font(.caption.weight(.bold)).foregroundStyle(.red)
                                }
                            }
                        }
                    }
                }
            }
            Text("各行に 1 つずつ Queen を置く (列・斜めが衝突しないように)")
                .font(.caption2).foregroundStyle(.secondary)
        }
        .onAppear { play() }
    }
    private func isAttacked(r: Int, c: Int) -> Bool {
        for prev in 0..<min(r, board.count) {
            if board[prev] == c { return true }
            if abs(board[prev] - c) == abs(prev - r) { return true }
        }
        return false
    }
    private func play() {
        token += 1; let t = token
        board = []; current = -1
        // 4-queens 解: [1,3,0,2]
        let sol = [1, 3, 0, 2]
        for (i, c) in sol.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.8) {
                guard t == token else { return }
                withAnimation { current = i; board.append(c) }
            }
        }
    }
}

// MARK: - Kth Largest (min-heap of size k)

struct KthLargestAnim: View {
    let nums = [3, 2, 1, 5, 6, 4]
    let k = 2
    @State private var heap: [Int] = []
    @State private var idx = -1
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Kth Largest (k=\(k))", tint: .pink, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    ForEach(nums.indices, id: \.self) { i in
                        tile(width: 28, height: 26,
                             bg: i == idx ? .yellow : .pink.opacity(0.4),
                             fg: i == idx ? .black : .white) { Text("\(nums[i])") }
                    }
                }
                HStack(spacing: 4) {
                    Text("min-heap (top=k番目に大きい):")
                        .font(.caption2.weight(.black)).foregroundStyle(.pink)
                }
                HStack(spacing: 4) {
                    ForEach(heap.indices, id: \.self) { i in
                        tile(width: 28, height: 26,
                             bg: i == 0 ? .pink : .pink.opacity(0.55)) { Text("\(heap[i])") }
                    }
                }
                if heap.count == k, let top = heap.first {
                    Text("→ Kth largest = \(top)")
                        .font(.caption.weight(.bold)).foregroundStyle(.pink)
                }
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        heap = []; idx = -1
        var h: [Int] = []
        for (i, v) in nums.enumerated() {
            h.append(v); h.sort()
            if h.count > k { h.removeFirst() }
            let snap = h
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.8) {
                guard t == token else { return }
                withAnimation { idx = i; heap = snap }
            }
        }
    }
}

// MARK: - Meeting Rooms II (min heap of end times)

struct MeetingRoomsAnim: View {
    // 問題例 (intervals=[[0,30],[5,10],[15,20]] → 2) に合わせる
    let intervals: [(Int, Int)] = [(0, 30), (5, 10), (15, 20)]
    @State private var i = -1
    @State private var heap: [Int] = []
    @State private var rooms = 0
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Meeting Rooms II", tint: .purple, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                Text("intervals (start,end) を start でソート済")
                    .font(.caption2).foregroundStyle(.secondary)
                HStack(spacing: 4) {
                    ForEach(intervals.indices, id: \.self) { k in
                        tile(width: 50, height: 28,
                             bg: k == i ? .yellow : .purple.opacity(0.45),
                             fg: k == i ? .black : .white) {
                            Text("\(intervals[k].0)–\(intervals[k].1)")
                                .font(.system(size: 9, weight: .heavy, design: .monospaced))
                        }
                    }
                }
                HStack(spacing: 4) {
                    Text("min-heap (ends):")
                        .font(.caption2.weight(.black)).foregroundStyle(.purple)
                    ForEach(heap.indices, id: \.self) { k in
                        tile(width: 28, height: 22, bg: .purple.opacity(0.6)) { Text("\(heap[k])") }
                    }
                }
                Text("rooms = \(rooms)")
                    .font(.caption.weight(.bold)).foregroundStyle(.purple)
                Text("最小終了時刻 ≤ 新規開始 なら使い回し、そうでなければ部屋追加")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        i = -1; heap = []; rooms = 0
        var h: [Int] = []
        for (k, (s, e)) in intervals.enumerated() {
            if let top = h.first, top <= s { h.removeFirst() }
            h.append(e); h.sort()
            let curH = h
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.9) {
                guard t == token else { return }
                withAnimation { i = k; heap = curH; rooms = max(rooms, curH.count) }
            }
        }
    }
}

// MARK: - Trie Insert (tree growing)

struct TrieInsertAnim: View {
    // 問題例 (insert('apple')) に合わせる
    let words = ["apple"]
    @State private var nodes: [String: Set<String>] = [:]   // path → children chars
    @State private var current = ""
    @State private var inserting: String = ""
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Trie Insert", tint: .green, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                Text("inserting: \"\(inserting)\"")
                    .font(.system(.caption, design: .monospaced).weight(.heavy))
                    .foregroundStyle(.green)
                trieView(node: "", depth: 0)
            }
        }
        .onAppear { play() }
    }
    private func trieView(node: String, depth: Int) -> AnyView {
        if let children = nodes[node], !children.isEmpty {
            return AnyView(
                HStack(spacing: 12) {
                    ForEach(Array(children).sorted(), id: \.self) { ch in
                        let childPath = node + ch
                        VStack(spacing: 4) {
                            ZStack {
                                Circle().fill(current == childPath ? .yellow : .green.opacity(0.5))
                                    .frame(width: 24, height: 24)
                                Text(ch)
                                    .font(.system(size: 11, weight: .black, design: .monospaced))
                                    .foregroundStyle(current == childPath ? .black : .white)
                            }
                            trieView(node: childPath, depth: depth + 1)
                        }
                    }
                }
            )
        } else if depth == 0 {
            return AnyView(HStack { Text("(empty)").font(.caption2).foregroundStyle(.secondary) })
        } else {
            return AnyView(EmptyView())
        }
    }
    private func play() {
        token += 1; let t = token
        nodes = [:]; current = ""; inserting = ""
        var delay = 0.4
        for w in words {
            let word = w
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                guard t == token else { return }
                withAnimation { inserting = word }
            }
            delay += 0.4
            var path = ""
            for c in w {
                let parent = path
                let childChar = String(c)
                let nextPath = path + childChar
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    guard t == token else { return }
                    withAnimation {
                        nodes[parent, default: []].insert(childChar)
                        current = nextPath
                    }
                }
                delay += 0.4
                path = nextPath
            }
        }
    }
}

// MARK: - Trie Search (path walking)

struct TrieSearchAnim: View {
    // 問題例 (辞書に 'apple'、search('apple')→True) に合わせる
    let words = ["apple"]
    let query = "apple"
    @State private var path = ""
    @State private var found = false
    @State private var failed = false
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Trie Search: \"\(query)\"", tint: .teal, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    ForEach(Array(query.enumerated()), id: \.offset) { i, c in
                        let visited = i < path.count
                        tile(width: 26, height: 28,
                             bg: visited ? .teal.opacity(0.7) : .gray.opacity(0.4),
                             fg: .white) {
                            Text(String(c)).font(.system(size: 12, weight: .black, design: .monospaced))
                        }
                    }
                }
                HStack(spacing: 6) {
                    Text("path:").font(.caption2.weight(.black)).foregroundStyle(.teal)
                    Text("\"\(path)\"")
                        .font(.system(.caption, design: .monospaced).weight(.heavy))
                        .foregroundStyle(.teal)
                }
                Text("辞書: " + words.joined(separator: ", "))
                    .font(.caption2).foregroundStyle(.secondary)
                if found {
                    Text("🎯 ヒット！ end フラグも true")
                        .font(.caption.weight(.bold)).foregroundStyle(.green)
                } else if failed {
                    Text("❌ どこかでパスが切れた")
                        .font(.caption.weight(.bold)).foregroundStyle(.red)
                }
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        path = ""; found = false; failed = false
        // 辞書から trie を作成
        var children: [String: Set<Character>] = [:]
        var endpoints: Set<String> = []
        for w in words {
            var p = ""
            for c in w {
                children[p, default: []].insert(c)
                p.append(c)
            }
            endpoints.insert(p)
        }
        var p = ""
        let qArr = Array(query)
        for (k, c) in qArr.enumerated() {
            let parent = p
            let hasChild = children[parent]?.contains(c) ?? false
            p.append(c)
            let newPath = p
            let last = k == qArr.count - 1
            let isFound = last && hasChild && endpoints.contains(newPath)
            let isFailed = !hasChild
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(k) * 0.7) {
                guard t == token else { return }
                withAnimation {
                    if !hasChild { failed = true }
                    else { path = newPath }
                    if isFound { found = true }
                }
            }
            if !hasChild { break }
        }
    }
}

// MARK: - Top K Frequent (heap of counts)

struct TopKFrequentAnim: View {
    let nums = [1, 1, 1, 2, 2, 3]
    let k = 2
    @State private var counts: [Int: Int] = [:]
    @State private var heap: [(Int, Int)] = []   // (count, num)
    @State private var idx = -1
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Top K Frequent (k=\(k))", tint: .red, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    ForEach(nums.indices, id: \.self) { i in
                        tile(width: 28, height: 26,
                             bg: i == idx ? .yellow : .red.opacity(0.4),
                             fg: i == idx ? .black : .white) { Text("\(nums[i])") }
                    }
                }
                HStack(spacing: 4) {
                    Text("counts:").font(.caption2.weight(.black)).foregroundStyle(.red)
                    ForEach(counts.sorted(by: { $0.key < $1.key }), id: \.key) { kv in
                        tile(width: 38, height: 24, bg: .red.opacity(0.55)) {
                            Text("\(kv.key):\(kv.value)").font(.system(size: 9, weight: .heavy))
                        }
                    }
                }
                HStack(spacing: 4) {
                    Text("heap (top \(k)):").font(.caption2.weight(.black)).foregroundStyle(.green)
                    ForEach(heap.indices, id: \.self) { i in
                        tile(width: 38, height: 24, bg: .green.opacity(0.55)) {
                            Text("\(heap[i].1)×\(heap[i].0)").font(.system(size: 9, weight: .heavy))
                        }
                    }
                }
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        counts = [:]; heap = []; idx = -1
        var c: [Int: Int] = [:]
        for (i, v) in nums.enumerated() {
            c[v, default: 0] += 1
            let snap = c
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.55) {
                guard t == token else { return }
                withAnimation { idx = i; counts = snap }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(nums.count) * 0.55 + 0.3) {
            guard t == token else { return }
            let sorted = c.sorted { $0.value > $1.value }.prefix(k)
            withAnimation { heap = sorted.map { ($0.value, $0.key) } }
        }
    }
}

// MARK: - Three Sum (sorted + two-pointer)

struct ThreeSumAnim: View {
    let nums = [-1, 0, 1, 2, -1, -4]
    @State private var arr = [-4, -1, -1, 0, 1, 2]
    @State private var i = 0
    @State private var l = 1
    @State private var r = 5
    @State private var triplets: [[Int]] = []
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "3Sum (sorted + 2-pointer)", tint: .pink, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    ForEach(arr.indices, id: \.self) { k in
                        let isI = k == i
                        let isL = k == l
                        let isR = k == r
                        tile(width: 28, height: 28,
                             bg: isI ? .pink : (isL ? .blue : (isR ? .orange : .pink.opacity(0.25))),
                             fg: isI || isL || isR ? .white : .white.opacity(0.9)) {
                            Text("\(arr[k])")
                        }
                    }
                }
                HStack(spacing: 6) {
                    Text("i").foregroundStyle(.pink)
                    Text("l").foregroundStyle(.blue)
                    Text("r").foregroundStyle(.orange)
                }
                .font(.caption2.weight(.black))
                Text("triplets: " + triplets.map { "[\($0[0]),\($0[1]),\($0[2])]" }.joined(separator: " "))
                    .font(.system(.caption2, design: .monospaced)).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        arr = nums.sorted()
        i = 0; l = 1; r = arr.count - 1; triplets = []
        var found: [[Int]] = []
        var ii = 0, ll = 1, rr = arr.count - 1
        var k = 0
        while ii < arr.count - 2 {
            ll = ii + 1; rr = arr.count - 1
            while ll < rr {
                let sum = arr[ii] + arr[ll] + arr[rr]
                let curI = ii, curL = ll, curR = rr
                if sum == 0 {
                    found.append([arr[ii], arr[ll], arr[rr]])
                    ll += 1; rr -= 1
                } else if sum < 0 { ll += 1 }
                else { rr -= 1 }
                let snap = found
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.55) {
                    guard t == token else { return }
                    withAnimation { i = curI; l = curL; r = curR; triplets = snap }
                }
                k += 1
                if k > 20 { break }
            }
            ii += 1
            if k > 20 { break }
        }
    }
}

// MARK: - Rotate Array (3-step reverse)

struct RotateArrayAnim: View {
    let nums = [1, 2, 3, 4, 5, 6, 7]
    let k = 3
    @State private var arr: [Int] = [1, 2, 3, 4, 5, 6, 7]
    @State private var phase = 0   // 0=initial, 1=full reverse, 2=front reverse, 3=back reverse
    @State private var label = ""
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Rotate Array (k=\(k))", tint: .pink, onReplay: play) {
            HStack(spacing: 4) {
                ForEach(arr.indices, id: \.self) { i in
                    let highlight: Color = {
                        if phase == 2 && i < k { return .yellow }
                        if phase == 3 && i >= k { return .yellow }
                        return .pink.opacity(0.4)
                    }()
                    tile(width: 30, height: 28,
                         bg: highlight,
                         fg: phase >= 2 && (i < k && phase == 2 || i >= k && phase == 3) ? .black : .white) {
                        Text("\(arr[i])")
                    }
                }
            }
            Text(label).font(.caption.weight(.heavy)).foregroundStyle(.pink)
            Text("ステップ: 全体 reverse → 前 k 個 reverse → 後ろ n-k 個 reverse")
                .font(.caption2).foregroundStyle(.secondary)
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        arr = nums; phase = 0; label = "初期状態"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            guard t == token else { return }
            withAnimation { arr = nums.reversed(); phase = 1; label = "① 全体を reverse" }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            guard t == token else { return }
            var a = Array(nums.reversed())
            a.replaceSubrange(0..<k, with: a[0..<k].reversed())
            withAnimation { arr = a; phase = 2; label = "② 前 \(k) 個を reverse" }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            guard t == token else { return }
            var a = Array(nums.reversed())
            a.replaceSubrange(0..<k, with: a[0..<k].reversed())
            a.replaceSubrange(k..<a.count, with: a[k..<a.count].reversed())
            withAnimation { arr = a; phase = 3; label = "③ 後ろ \(nums.count - k) 個を reverse → 完成" }
        }
    }
}

// MARK: - Combinations (n choose k backtracking)

struct CombinationsAnim: View {
    let n = 4
    let k = 2
    @State private var current: [Int] = []
    @State private var collected: [[Int]] = []
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Combinations C(\(n),\(k))", tint: .orange, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Text("current:").font(.caption2.weight(.black)).foregroundStyle(.orange)
                    ForEach(current.indices, id: \.self) { i in
                        tile(width: 24, height: 24, bg: .yellow, fg: .black) { Text("\(current[i])") }
                    }
                }
                HStack(spacing: 4) {
                    ForEach(1...n, id: \.self) { v in
                        tile(width: 22, height: 22,
                             bg: current.contains(v) ? .orange : .orange.opacity(0.3)) {
                            Text("\(v)").font(.system(size: 10, weight: .black, design: .monospaced))
                        }
                    }
                }
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 70), spacing: 4)], spacing: 4) {
                    ForEach(collected.indices, id: \.self) { i in
                        HStack(spacing: 2) {
                            ForEach(collected[i].indices, id: \.self) { j in
                                tile(width: 18, height: 18, bg: .orange.opacity(0.55)) {
                                    Text("\(collected[i][j])")
                                }
                            }
                        }
                    }
                }
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        current = []; collected = []
        var combos: [[Int]] = []
        func bt(_ start: Int, _ path: [Int]) {
            if path.count == k { combos.append(path); return }
            for v in start...n {
                bt(v + 1, path + [v])
            }
        }
        bt(1, [])
        var step = 0
        for c in combos {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(step) * 0.8) {
                guard t == token else { return }
                withAnimation { current = c; collected.append(c) }
            }
            step += 1
        }
    }
}

// MARK: - Merge Intervals

struct MergeIntervalsAnim: View {
    let intervals: [(Int, Int)] = [(1, 3), (2, 6), (8, 10), (15, 18)]
    @State private var merged: [(Int, Int)] = []
    @State private var cur: Int = -1
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Merge Intervals", tint: .blue, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                // 数直線
                HStack(spacing: 0) {
                    ForEach(0..<20, id: \.self) { i in
                        Rectangle().fill(Color.gray.opacity(0.3))
                            .frame(width: 12, height: 2)
                    }
                }
                // 入力 intervals
                ForEach(intervals.indices, id: \.self) { i in
                    let iv = intervals[i]
                    HStack {
                        Rectangle()
                            .fill(i == cur ? .yellow : .blue.opacity(0.5))
                            .frame(width: CGFloat(iv.1 - iv.0 + 1) * 12, height: 12)
                            .offset(x: CGFloat(iv.0) * 12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("[\(iv.0),\(iv.1)]")
                            .font(.system(size: 9, weight: .heavy, design: .monospaced))
                            .frame(width: 50)
                    }
                }
                // 結果
                VStack(alignment: .leading, spacing: 4) {
                    Text("merged:").font(.caption2.weight(.black)).foregroundStyle(.green)
                    ForEach(merged.indices, id: \.self) { i in
                        HStack {
                            Rectangle().fill(Color.green.opacity(0.6))
                                .frame(width: CGFloat(merged[i].1 - merged[i].0 + 1) * 12, height: 12)
                                .offset(x: CGFloat(merged[i].0) * 12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("[\(merged[i].0),\(merged[i].1)]")
                                .font(.system(size: 9, weight: .heavy, design: .monospaced))
                                .frame(width: 50)
                        }
                    }
                }
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        merged = []; cur = -1
        let sorted = intervals.sorted { $0.0 < $1.0 }
        var m: [(Int, Int)] = []
        for (k, iv) in sorted.enumerated() {
            if let last = m.last, iv.0 <= last.1 {
                m[m.count - 1] = (last.0, max(last.1, iv.1))
            } else {
                m.append(iv)
            }
            let snap = m
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(k) * 0.9) {
                guard t == token else { return }
                withAnimation { cur = k; merged = snap }
            }
        }
    }
}
