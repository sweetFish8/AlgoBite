import SwiftUI

// MARK: - Tree traversal

struct TreeTraversalAnim: View {
    enum Order { case inorder, preorder, postorder, level }
    let order: Order
    /// 7 ノード 3 段の木 (level order の配列表現)。問題ごとに違う数列を渡せる
    let nodes: [Int]
    let hiddenIndices: Set<Int>
    /// 副題 (問題の文脈で表示)
    let subtitle: String

    init(order: Order, nodes: [Int] = [4, 2, 6, 1, 3, 5, 7],
         hiddenIndices: Set<Int> = [], subtitle: String = "") {
        self.order = order
        self.nodes = nodes
        self.hiddenIndices = hiddenIndices
        self.subtitle = subtitle
    }

    @State private var visited: [Int] = []
    @State private var current: Int? = nil
    @State private var token = 0

    var body: some View {
        AnimFrame(title: title, tint: .green, onReplay: play) {
            VStack(spacing: 8) {
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                // Render as 3-level pyramid
                let levels = [[0], [1, 2], [3, 4, 5, 6]]
                ForEach(levels.indices, id: \.self) { lvl in
                    HStack(spacing: 12) {
                        ForEach(levels[lvl], id: \.self) { index in
                            if hiddenIndices.contains(index) {
                                Color.clear.frame(width: 30, height: 30)
                            } else {
                                let value = nodes[index]
                                let isVisited = visited.contains(value)
                                let isCur = current == value
                                tile(width: 30, height: 30,
                                     bg: isCur ? .yellow : (isVisited ? .green.opacity(0.5) : .white.opacity(0.08)),
                                     fg: isCur ? .black : .white) { Text("\(value)") }
                                    .scaleEffect(isCur ? 1.18 : 1.0)
                                    .animation(.spring(response: 0.3), value: current)
                                    .animation(.spring(response: 0.3), value: visited)
                            }
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
        // nodes[0..6] を完全二分木として扱い、走査順を実際に計算する
        // index: 0=root, 1=L, 2=R, 3=LL, 4=LR, 5=RL, 6=RR
        let indices: [Int]
        switch order {
        case .inorder:   indices = [3, 1, 4, 0, 5, 2, 6]
        case .preorder:  indices = [0, 1, 3, 4, 2, 5, 6]
        case .postorder: indices = [3, 4, 1, 5, 6, 2, 0]
        case .level:     indices = Array(nodes.indices)
        }
        let seq = indices.filter { !hiddenIndices.contains($0) }.map { nodes[$0] }
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

// MARK: - Validate BST (inorder ascending check)

struct ValidateBSTAnim: View {
    // 例: [2,1,3] → True。slot 3..6 は null(0)
    let nodes = [2, 1, 3, 0, 0, 0, 0]
    @State private var visited: [Int] = []
    @State private var cur: Int? = nil
    @State private var ok = true
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Validate BST (inorder = 昇順 ?)", tint: .green, onReplay: play) {
            LeveledTree(nodes: nodes, highlightVisited: visited, current: cur,
                        palette: (.green, .yellow, .green.opacity(0.4)))
            HStack(spacing: 4) {
                Text("seen:").font(.caption2.weight(.black)).foregroundStyle(.green)
                ForEach(visited.indices, id: \.self) { i in
                    tile(width: 22, height: 22, bg: .green.opacity(0.55)) { Text("\(visited[i])") }
                }
            }
            Text(ok ? "🟢 BST: 昇順を維持" : "🔴 違反！")
                .font(.caption.weight(.bold))
                .foregroundStyle(ok ? .green : .red)
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        visited = []; cur = nil; ok = true
        // 木 [2,1,3] の inorder (左→根→右) = [1,2,3] → 昇順
        let seq = [1, 2, 3]
        var seen: [Int] = []
        for (i, v) in seq.enumerated() {
            let prevSeen = seen
            seen.append(v)
            let stillOk = prevSeen.last.map { $0 < v } ?? true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(i) * 0.6) {
                guard t == token else { return }
                withAnimation { cur = v; visited = prevSeen + [v]; ok = ok && stillOk }
            }
        }
    }
}

// MARK: - Invert Binary Tree

struct InvertTreeAnim: View {
    @State private var nodes = [4, 2, 7, 1, 3, 6, 9]
    @State private var swapAt: Int? = nil  // swap している親 index
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Invert Binary Tree", tint: .indigo, onReplay: play) {
            LeveledTree(nodes: nodes, highlightVisited: [], current: swapAt.flatMap { nodes.indices.contains($0) ? nodes[$0] : nil },
                        palette: (.indigo, .yellow, .indigo.opacity(0.4)))
            Text("各ノードの左右の子を swap")
                .font(.caption2).foregroundStyle(.secondary)
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        nodes = [4, 2, 7, 1, 3, 6, 9]
        // 反転: 各親の左右の子を swap。サブツリーごと入れ替わるので
        // [4,2,7,1,3,6,9] → [4,7,2,9,6,3,1]
        // (1) root の子を swap: 子サブツリーごと → slot1↔2, slot3↔5, slot4↔6
        // (2) 各サブツリー内で子を swap: slot3↔4, slot5↔6
        // hl は強調する親ノードの index
        let steps: [(hl: Int, swaps: [(Int, Int)])] = [
            (0, [(1, 2), (3, 5), (4, 6)]),  // root の左右サブツリーを入替
            (1, [(3, 4)]),                  // 左 (元 7, 今 index1) の子を swap
            (2, [(5, 6)])                   // 右 (元 2, 今 index2) の子を swap
        ]
        for (k, step) in steps.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(k) * 1.0) {
                guard t == token else { return }
                withAnimation {
                    swapAt = step.hl
                    for (a, b) in step.swaps { nodes.swapAt(a, b) }
                }
            }
        }
    }
}

// MARK: - Symmetric Tree (mirror check)

struct SymmetricTreeAnim: View {
    let nodes = [1, 2, 2, 3, 4, 4, 3]
    @State private var compareLR: (Int, Int)? = nil
    @State private var allOk = true
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Symmetric Tree", tint: .purple, onReplay: play) {
            LeveledTree(nodes: nodes, highlightVisited: [], current: nil,
                        palette: (.purple, .yellow, .purple.opacity(0.4)))
            HStack(spacing: 14) {
                if let pair = compareLR {
                    Text("\(nodes[pair.0])")
                        .font(.system(size: 14, weight: .black))
                        .padding(8)
                        .background(Color.yellow, in: Circle()).foregroundStyle(.black)
                    Image(systemName: "arrow.left.and.right").foregroundStyle(.purple)
                    Text("\(nodes[pair.1])")
                        .font(.system(size: 14, weight: .black))
                        .padding(8)
                        .background(Color.yellow, in: Circle()).foregroundStyle(.black)
                }
            }
            Text(allOk ? "🟢 全 mirror 対応" : "🔴 mirror 違反")
                .font(.caption.weight(.bold))
                .foregroundStyle(allOk ? .green : .red)
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        compareLR = nil; allOk = true
        // (left, right) のミラーペア
        let pairs: [(Int, Int)] = [(1, 2), (3, 6), (4, 5)]
        for (k, p) in pairs.enumerated() {
            let ok = nodes[p.0] == nodes[p.1]
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(k) * 0.9) {
                guard t == token else { return }
                withAnimation { compareLR = p; allOk = allOk && ok }
            }
        }
    }
}

// MARK: - Path Sum (root → leaf with running sum)

struct PathSumAnim: View {
    // 例: [5,4,8,11,null,13,4,7,2], target=22 → True (パス 5→4→11→2)
    // 3段までしか描けないので上位3段 [5,4,8,11,null,13,4] を表示。葉の 2 はパス表記のみ
    let nodes = [5, 4, 8, 11, 0, 13, 4]
    let target = 22
    @State private var path: [Int] = []
    @State private var sum = 0
    @State private var done = false
    @State private var found = false
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Path Sum = \(target)", tint: .orange, onReplay: play) {
            LeveledTree(nodes: nodes, highlightVisited: path, current: path.last,
                        palette: (.orange, .yellow, .orange.opacity(0.3)))
            HStack {
                Text("path: " + path.map(String.init).joined(separator: " → "))
                    .font(.system(.caption2, design: .monospaced))
                Spacer()
                Text("sum=\(sum)")
                    .font(.caption.weight(.bold)).foregroundStyle(.orange)
            }
            if done {
                Text(found ? "🎯 target 一致" : "ハズレ (このパスは違う)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(found ? .green : .secondary)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        path = []; sum = 0; done = false; found = false
        // root(5) -> 4 -> 11 -> 2 = 22 ヒット (2 は level4 の葉)
        let seqVals = [5, 4, 11, 2]
        for (k, v) in seqVals.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(k) * 0.8) {
                guard t == token else { return }
                withAnimation { path.append(v); sum += v }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(seqVals.count) * 0.8 + 0.3) {
            guard t == token else { return }
            withAnimation { done = true; found = sum == target }
        }
    }
}

// MARK: - Max Depth (postorder, returning depth)

struct MaxDepthBTAnim: View {
    // 例: [3,9,20,null,null,15,7] → 3。slot 3,4 は null(0)
    let nodes = [3, 9, 20, 0, 0, 15, 7]
    @State private var depths: [Int: Int] = [:]   // node value → depth
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Max Depth of Binary Tree", tint: .green, onReplay: play) {
            LeveledTree(nodes: nodes, highlightVisited: Array(depths.keys), current: nil,
                        palette: (.green, .yellow, .green.opacity(0.4)))
            HStack(spacing: 4) {
                Text("depth:").font(.caption2.weight(.black)).foregroundStyle(.green)
                ForEach(depths.sorted(by: { $0.key < $1.key }), id: \.key) { kv in
                    tile(width: 32, height: 24, bg: .green.opacity(0.5)) {
                        VStack(spacing: 0) {
                            Text("\(kv.key)").font(.system(size: 9))
                            Text("→\(kv.value)").font(.system(size: 9, weight: .heavy))
                        }
                    }
                }
            }
            if let m = depths.values.max() {
                Text("max depth = \(m)").font(.caption.weight(.bold)).foregroundStyle(.green)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        depths = [:]
        // 葉から順に depth を確定 (9 は葉=1, 15/7=1, 20=2, root 3=3)
        let order: [(Int, Int)] = [(9, 1), (15, 1), (7, 1), (20, 2), (3, 3)]
        for (k, (v, d)) in order.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(k) * 0.6) {
                guard t == token else { return }
                withAnimation { depths[v] = d }
            }
        }
    }
}

// MARK: - LCA of BST (using BST property)

struct LCAofBSTAnim: View {
    let nodes = [6, 2, 8, 0, 4, 7, 9]
    // 問題例 (p=2, q=8 → node(6)) に合わせる
    let p = 2, q = 8
    @State private var path: [Int] = []
    @State private var lca: Int? = nil
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "LCA of BST (p=\(p), q=\(q))", tint: .teal, onReplay: play) {
            LeveledTree(nodes: nodes, highlightVisited: path,
                        current: lca, palette: (.teal, .yellow, .teal.opacity(0.4)))
            HStack {
                Text("walking:")
                    .font(.caption2.weight(.black)).foregroundStyle(.teal)
                Text(path.map(String.init).joined(separator: " → "))
                    .font(.system(.caption2, design: .monospaced))
            }
            if let l = lca {
                Text("🎯 LCA = \(l)").font(.caption.weight(.bold)).foregroundStyle(.teal)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        path = []; lca = nil
        // p=2 < 6 < q=8 で左右に分岐 → 6 が LCA
        let walk = [6]
        for (k, v) in walk.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(k) * 0.8) {
                guard t == token else { return }
                withAnimation { path.append(v) }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(walk.count) * 0.8 + 0.2) {
            guard t == token else { return }
            withAnimation { lca = 6 }
        }
    }
}

// MARK: - Diameter of Binary Tree

struct DiameterBTAnim: View {
    // 例: [1,2,3,4,5] → 直径 3 (4-2-1-3)。slot 5,6 は null(0)
    let nodes = [1, 2, 3, 4, 5, 0, 0]
    @State private var leftD: Int? = nil
    @State private var rightD: Int? = nil
    @State private var rootHL: Int? = nil
    @State private var dia = 0
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Diameter of Binary Tree", tint: .red, onReplay: play) {
            LeveledTree(nodes: nodes,
                        highlightVisited: [leftD, rightD].compactMap { $0 != nil ? nodes[$0!] : nil },
                        current: rootHL,
                        palette: (.red.opacity(0.55), .yellow, .red.opacity(0.3)))
            HStack(spacing: 8) {
                if let l = leftD {
                    Text("left depth=\(l)").font(.caption2.weight(.heavy)).foregroundStyle(.red)
                }
                if let r = rightD {
                    Text("right depth=\(r)").font(.caption2.weight(.heavy)).foregroundStyle(.red)
                }
            }
            Text("diameter = max(左深さ + 右深さ) = \(dia)")
                .font(.caption.weight(.bold)).foregroundStyle(.red)
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        leftD = nil; rightD = nil; rootHL = nil; dia = 0
        // root(1) の左サブツリー深さ=2 (2→4/5), 右=1 (3), 通る経路長=2+1=3
        let steps = [
            (0.5, { self.rootHL = 1 }),
            (1.2, { self.leftD = 2 }),
            (1.8, { self.rightD = 1 }),
            (2.4, { self.rootHL = nodes[0]; self.dia = 3 })
        ]
        for (delay, action) in steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                guard t == token else { return }
                withAnimation { action() }
            }
        }
    }
}

// MARK: - Balanced Binary Tree

struct BalancedBTAnim: View {
    // 例: [3,9,20,null,null,15,7] → True。slot 3,4 は null(0)
    let nodes = [3, 9, 20, 0, 0, 15, 7]
    @State private var depths: [Int: Int] = [:]
    @State private var bad: Int? = nil
    @State private var done = false
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Balanced Binary Tree", tint: .green, onReplay: play) {
            LeveledTree(nodes: nodes,
                        highlightVisited: Array(depths.keys),
                        current: bad,
                        palette: (.green, .red, .green.opacity(0.4)))
            HStack(spacing: 4) {
                ForEach(depths.sorted(by: { $0.key < $1.key }), id: \.key) { kv in
                    tile(width: 32, height: 22, bg: .green.opacity(0.55)) {
                        VStack(spacing: 0) {
                            Text("\(kv.key)").font(.system(size: 9))
                            Text("h=\(kv.value)").font(.system(size: 9, weight: .heavy))
                        }
                    }
                }
            }
            if done {
                Text(bad == nil ? "🟢 バランス済 (|hL-hR| ≤ 1)" : "🔴 unbalanced at \(bad!)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(bad == nil ? .green : .red)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        depths = [:]; bad = nil; done = false
        // postorder で高さ計算 (葉=1)。9 は葉=1, 15/7=1, 20=2, root 3=3
        let post: [(Int, Int)] = [(9, 1), (15, 1), (7, 1), (20, 2), (3, 3)]
        for (k, (v, h)) in post.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(k) * 0.6) {
                guard t == token else { return }
                withAnimation { depths[v] = h }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(post.count) * 0.6 + 0.3) {
            guard t == token else { return }
            withAnimation { done = true }   // この木はバランス
        }
    }
}

// MARK: - Build Tree from Inorder + Postorder

struct BuildTreePostAnim: View {
    let inorder = [9, 3, 15, 20, 7]
    let postorder = [9, 15, 7, 20, 3]
    @State private var built: Set<Int> = []
    @State private var current: Int? = nil
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Build Tree (in+post)", tint: .green, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Text("inorder:").font(.caption2.weight(.black)).foregroundStyle(.green)
                    ForEach(inorder, id: \.self) { v in
                        tile(width: 28, height: 24,
                             bg: built.contains(v) ? .green.opacity(0.6) : .green.opacity(0.25)) {
                            Text("\(v)")
                        }
                    }
                }
                HStack(spacing: 4) {
                    Text("postorder:").font(.caption2.weight(.black)).foregroundStyle(.green)
                    ForEach(postorder, id: \.self) { v in
                        tile(width: 28, height: 24,
                             bg: current == v ? .yellow :
                                 built.contains(v) ? .green.opacity(0.6) : .green.opacity(0.25),
                             fg: current == v ? .black : .white) {
                            Text("\(v)")
                        }
                    }
                }
                Text("postorder の末尾 = root。inorder でその位置を見つけて左右に分割")
                    .font(.caption2).foregroundStyle(.secondary)
                LeveledTree(nodes: [3, 9, 20, 0, 0, 15, 7],
                            highlightVisited: Array(built),
                            current: current,
                            palette: (.green.opacity(0.7), .yellow, .green.opacity(0.3)))
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        built = []; current = nil
        // 確定する順: 3 (root) → 20 (right) → 7 → 15 → 9 (postorder 逆順で各 root)
        let order = [3, 20, 7, 15, 9]
        for (k, v) in order.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.8) {
                guard t == token else { return }
                withAnimation { current = v; built.insert(v) }
            }
        }
    }
}

// MARK: - Serialize Binary Tree

struct SerializeBTAnim: View {
    // 例: [1,2,3,null,null,4,5] → '1,2,3,N,N,4,5'
    let nodes = [1, 2, 3, 0, 0, 4, 5]
    @State private var serialized: [String] = []
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Serialize BT (BFS)", tint: .orange, onReplay: play) {
            LeveledTree(nodes: nodes,
                        highlightVisited: serialized.compactMap { Int($0) },
                        current: nil,
                        palette: (.orange.opacity(0.65), .yellow, .orange.opacity(0.3)))
            HStack(spacing: 3) {
                Text("→")
                ForEach(serialized.indices, id: \.self) { i in
                    tile(width: 22, height: 22, bg: .orange.opacity(0.55)) {
                        Text(serialized[i])
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                    }
                }
            }
            Text("level order + null を文字列化")
                .font(.caption2).foregroundStyle(.secondary)
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        serialized = []
        // BFS: 1,2,3,N,N,4,5 (例の出力と一致)
        let seq = ["1", "2", "3", "N", "N", "4", "5"]
        for (k, s) in seq.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.4) {
                guard t == token else { return }
                withAnimation { serialized.append(s) }
            }
        }
    }
}

// MARK: - Kth Smallest in BST

struct KthSmallestBSTAnim: View {
    // 例: BST=[3,1,4,null,2], k=1 → 1。slot 3,5,6 は null(0)
    let nodes = [3, 1, 4, 0, 2, 0, 0]
    let k = 1
    @State private var visited: [Int] = []
    @State private var current: Int? = nil
    @State private var answer: Int? = nil
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Kth Smallest in BST (k=\(k))", tint: .pink, onReplay: play) {
            LeveledTree(nodes: nodes,
                        highlightVisited: visited,
                        current: current,
                        palette: (.pink.opacity(0.65), .yellow, .pink.opacity(0.3)))
            HStack(spacing: 4) {
                Text("inorder:").font(.caption2.weight(.black)).foregroundStyle(.pink)
                ForEach(visited.indices, id: \.self) { i in
                    let isAns = i + 1 == k
                    tile(width: 26, height: 22,
                         bg: isAns ? .green.opacity(0.75) : .pink.opacity(0.55)) {
                        Text("\(visited[i])")
                    }
                }
            }
            if let a = answer {
                Text("🎯 \(k) 番目に小さい = \(a)")
                    .font(.caption.weight(.bold)).foregroundStyle(.green)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        visited = []; current = nil; answer = nil
        // BST [3,1,4,null,2] の inorder = 昇順 [1,2,3,4]
        let seq = [1, 2, 3, 4]
        for (idx, v) in seq.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(idx) * 0.6) {
                guard t == token else { return }
                withAnimation { current = v; visited.append(v) }
                if idx + 1 == k {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        guard t == token else { return }
                        withAnimation { answer = v }
                    }
                }
            }
            if idx + 1 == k { break }
        }
    }
}

// MARK: - Inorder Iterative (stack)

struct InorderIterativeAnim: View {
    // 例: BST [4,2,6,1,3] → inorder [1,2,3,4,6]。slot 5,6 は null(0)
    let nodes = [4, 2, 6, 1, 3, 0, 0]
    @State private var stack: [Int] = []
    @State private var current: Int? = nil
    @State private var visited: [Int] = []
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Inorder (Iterative)", tint: .teal, onReplay: play) {
            LeveledTree(nodes: nodes,
                        highlightVisited: visited,
                        current: current,
                        palette: (.teal.opacity(0.65), .yellow, .teal.opacity(0.3)))
            HStack(spacing: 4) {
                Text("stack:").font(.caption2.weight(.black)).foregroundStyle(.teal)
                ForEach(stack.indices, id: \.self) { i in
                    tile(width: 22, height: 22, bg: .teal.opacity(0.55)) { Text("\(stack[i])") }
                }
            }
            HStack(spacing: 4) {
                Text("out:").font(.caption2.weight(.black)).foregroundStyle(.green)
                ForEach(visited.indices, id: \.self) { i in
                    tile(width: 22, height: 22, bg: .green.opacity(0.65)) { Text("\(visited[i])") }
                }
            }
            Text("ループ: 左の子をスタックに積み続け、ない時 pop → visit → 右へ")
                .font(.caption2).foregroundStyle(.secondary)
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        stack = []; current = nil; visited = []
        // インデックス: 0=root, 1/2=L/R, 3..6
        var st: [Int] = []
        var v: [Int] = []
        // シンプルにスタックの push/pop を演出
        // 木 [4,2,6,1,3] の反復中順 → out: 1,2,3,4,6
        let steps: [(stack: [Int], visit: Int?, cur: Int?)] = [
            ([4], nil, 4), ([4, 2], nil, 2), ([4, 2, 1], nil, 1),
            ([4, 2], 1, 1),
            ([4], 2, 2),
            ([4, 3], nil, 3),
            ([4], 3, 3),
            ([], 4, 4),
            ([6], nil, 6),
            ([], 6, 6)
        ]
        for (k, step) in steps.enumerated() {
            let s = step.stack
            let curV = step.cur
            let visit = step.visit
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.55) {
                guard t == token else { return }
                withAnimation {
                    st = s; stack = s; current = curV
                    if let val = visit, !v.contains(val) { v.append(val); visited = v }
                }
            }
        }
    }
}

// MARK: - LCA of Binary Tree

struct LCAofBTAnim: View {
    let nodes = [3, 5, 1, 6, 2, 0, 8]
    let p = 5, q = 1
    @State private var subResult: [Int: String] = [:]
    @State private var lca: Int? = nil
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "LCA of BT (p=\(p), q=\(q))", tint: .red, onReplay: play) {
            LeveledTree(nodes: nodes,
                        highlightVisited: Array(subResult.keys),
                        current: lca,
                        palette: (.red.opacity(0.55), .yellow, .red.opacity(0.3)))
            HStack(spacing: 4) {
                ForEach(subResult.sorted(by: { $0.key < $1.key }), id: \.key) { kv in
                    tile(width: 38, height: 24, bg: .red.opacity(0.55)) {
                        VStack(spacing: 0) {
                            Text("\(kv.key)").font(.system(size: 9))
                            Text(kv.value).font(.system(size: 9, weight: .heavy))
                        }
                    }
                }
            }
            if let l = lca {
                Text("🎯 LCA = \(l)")
                    .font(.caption.weight(.bold)).foregroundStyle(.red)
            }
            Text("葉から上へ「p or q を含んでる？」を伝搬。左右両方 true なら LCA")
                .font(.caption2).foregroundStyle(.secondary)
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        subResult = [:]; lca = nil
        // ノード 5 と 1 を含む部分木を見つけ、LCA は 3
        let post: [(Int, String)] = [
            (6, "−"), (2, "−"), (5, "p"),
            (0, "−"), (8, "−"), (1, "q"),
            (3, "LCA")
        ]
        for (k, (v, label)) in post.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(k) * 0.7) {
                guard t == token else { return }
                withAnimation {
                    subResult[v] = label
                    if label == "LCA" { lca = v }
                }
            }
        }
    }
}
