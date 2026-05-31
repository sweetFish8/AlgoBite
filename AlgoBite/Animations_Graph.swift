import SwiftUI

// MARK: - BFS / DFS on grid

struct GridSearchAnim: View {
    enum Kind { case bfs, dfs }
    let kind: Kind
    let grid: [[Int]]
    let subtitle: String

    init(kind: Kind,
         grid: [[Int]] = [
            [1, 1, 0, 0, 0],
            [1, 0, 0, 1, 1],
            [0, 0, 1, 1, 0],
            [0, 1, 1, 0, 0],
         ],
         subtitle: String = "") {
        self.kind = kind
        self.grid = grid
        self.subtitle = subtitle
    }

    @State private var visited: Set<String> = []
    @State private var frontier: Set<String> = []
    @State private var caption = ""
    @State private var token = 0

    var body: some View {
        AnimFrame(title: kind == .bfs ? "BFS の広がり" : "DFS の進行", tint: kind == .bfs ? .blue : .green, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
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

// MARK: - Word Search (grid DFS)

struct WordSearchAnim: View {
    let grid: [[Character]] = [
        ["A","B","C","E"],
        ["S","F","C","S"],
        ["A","D","E","E"]
    ]
    let word = "ABCCED"
    @State private var path: [(Int, Int)] = []
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Word Search: \"\(word)\"", tint: .green, onReplay: play) {
            VStack(spacing: 3) {
                ForEach(grid.indices, id: \.self) { r in
                    HStack(spacing: 3) {
                        ForEach(grid[r].indices, id: \.self) { c in
                            let order = path.firstIndex(where: { $0 == (r, c) })
                            tile(width: 32, height: 32,
                                 bg: order != nil ? .green.opacity(0.7) : .white.opacity(0.18),
                                 fg: order != nil ? .white : .white) {
                                VStack(spacing: 0) {
                                    Text(String(grid[r][c]))
                                        .font(.system(size: 13, weight: .black, design: .monospaced))
                                    if let o = order {
                                        Text("\(o + 1)").font(.system(size: 7))
                                    }
                                }
                            }
                        }
                    }
                }
            }
            Text("隣接マスを DFS、word の文字に一致しなければバックトラック")
                .font(.caption2).foregroundStyle(.secondary)
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        path = []
        // "ABCCED" を辿る正解パス
        let solution: [(Int, Int)] = [(0,0),(0,1),(0,2),(1,2),(2,2),(2,1)]
        for (i, p) in solution.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.6) {
                guard t == token else { return }
                withAnimation { path.append(p) }
            }
        }
    }
}

// MARK: - Number of Islands (flood fill counter)

struct NumIslandsAnim: View {
    let grid: [[Int]] = [
        [1, 1, 0, 0, 1],
        [1, 1, 0, 1, 1],
        [0, 0, 1, 0, 0],
        [1, 1, 0, 1, 1]
    ]
    @State private var filled: [[Int]] = []   // 0 if water, n=island id, or -1 unvisited land
    @State private var count = 0
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Number of Islands", tint: .teal, onReplay: play) {
            VStack(spacing: 3) {
                ForEach(filled.indices, id: \.self) { r in
                    HStack(spacing: 3) {
                        ForEach(filled[r].indices, id: \.self) { c in
                            let v = filled[r][c]
                            let bg: Color = v == 0 ? .gray.opacity(0.3) : islandColor(v)
                            tile(width: 26, height: 26, bg: bg) {
                                Text(v == 0 ? "~" : "#")
                                    .font(.system(size: 11, weight: .black))
                            }
                        }
                    }
                }
            }
            Text("島の数 = \(count)").font(.caption.weight(.bold)).foregroundStyle(.teal)
        }
        .onAppear { play() }
    }
    private func islandColor(_ id: Int) -> Color {
        let palette: [Color] = [.teal, .orange, .pink, .green, .indigo, .red]
        return palette[(abs(id) - 1) % palette.count]
    }
    private func play() {
        token += 1; let t = token
        // 初期: 1 → -1 (未訪問), 0 → 0
        filled = grid.map { row in row.map { $0 == 0 ? 0 : -1 } }
        count = 0
        let rs = grid.count, cs = grid[0].count
        var visited = Array(repeating: Array(repeating: false, count: cs), count: rs)
        var id = 0
        var orderedFills: [(Int, Int, Int)] = []
        for r in 0..<rs {
            for c in 0..<cs where grid[r][c] == 1 && !visited[r][c] {
                id += 1
                var stack = [(r, c)]
                while let p = stack.popLast() {
                    if p.0 < 0 || p.0 >= rs || p.1 < 0 || p.1 >= cs { continue }
                    if visited[p.0][p.1] || grid[p.0][p.1] == 0 { continue }
                    visited[p.0][p.1] = true
                    orderedFills.append((p.0, p.1, id))
                    stack.append((p.0 + 1, p.1))
                    stack.append((p.0 - 1, p.1))
                    stack.append((p.0, p.1 + 1))
                    stack.append((p.0, p.1 - 1))
                }
            }
        }
        for (k, f) in orderedFills.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.18) {
                guard t == token else { return }
                withAnimation {
                    filled[f.0][f.1] = f.2
                    count = max(count, f.2)
                }
            }
        }
    }
}

// MARK: - Topological Sort (Kahn)

struct TopologicalSortAnim: View {
    let edges: [(String, String)] = [("A","B"),("A","C"),("B","D"),("C","D"),("D","E")]
    let nodes = ["A", "B", "C", "D", "E"]
    @State private var indeg: [String: Int] = [:]
    @State private var queue: [String] = []
    @State private var order: [String] = []
    @State private var current: String? = nil
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Topological Sort (Kahn)", tint: .blue, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                Text("edges: " + edges.map { "\($0.0)→\($0.1)" }.joined(separator: ", "))
                    .font(.system(size: 10, design: .monospaced)).foregroundStyle(.secondary)
                HStack(spacing: 4) {
                    ForEach(nodes, id: \.self) { n in
                        VStack(spacing: 2) {
                            ZStack {
                                Circle().fill(order.contains(n) ? .green.opacity(0.7) :
                                              current == n ? .yellow :
                                              queue.contains(n) ? .blue : .gray.opacity(0.4))
                                    .frame(width: 28, height: 28)
                                Text(n).font(.system(size: 11, weight: .black))
                                    .foregroundStyle(current == n ? .black : .white)
                            }
                            Text("in=\(indeg[n] ?? 0)").font(.system(size: 9, weight: .heavy))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                HStack(spacing: 4) {
                    Text("queue:").font(.caption2.weight(.black)).foregroundStyle(.blue)
                    ForEach(queue.indices, id: \.self) { i in
                        tile(width: 22, height: 22, bg: .blue.opacity(0.6)) { Text(queue[i]) }
                    }
                }
                HStack(spacing: 4) {
                    Text("order:").font(.caption2.weight(.black)).foregroundStyle(.green)
                    ForEach(order.indices, id: \.self) { i in
                        tile(width: 22, height: 22, bg: .green.opacity(0.65)) { Text(order[i]) }
                    }
                }
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        var ind: [String: Int] = [:]
        for n in nodes { ind[n] = 0 }
        var adj: [String: [String]] = [:]
        for e in edges { adj[e.0, default: []].append(e.1); ind[e.1, default: 0] += 1 }
        indeg = ind; queue = []; order = []; current = nil
        var q = nodes.filter { ind[$0] == 0 }
        var o: [String] = []
        var delay = 0.4
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            guard t == token else { return }
            withAnimation { queue = q }
        }
        delay += 0.8
        while !q.isEmpty {
            let n = q.removeFirst()
            o.append(n)
            for next in adj[n] ?? [] {
                ind[next, default: 0] -= 1
                if ind[next] == 0 { q.append(next) }
            }
            let curN = n, snapQ = q, snapO = o, snapInd = ind
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                guard t == token else { return }
                withAnimation {
                    current = curN; queue = snapQ; order = snapO; indeg = snapInd
                }
            }
            delay += 0.8
        }
    }
}

// MARK: - Dijkstra (priority queue)

struct DijkstraAnim: View {
    let nodes = ["A", "B", "C", "D"]
    let edges: [(String, String, Int)] = [
        ("A", "B", 2), ("A", "C", 5),
        ("B", "C", 1), ("B", "D", 4),
        ("C", "D", 2)
    ]
    @State private var dist: [String: Int] = [:]
    @State private var finalized: Set<String> = []
    @State private var current: String? = nil
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Dijkstra (from A)", tint: .orange, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 14) {
                    ForEach(nodes, id: \.self) { n in
                        VStack(spacing: 2) {
                            ZStack {
                                Circle().fill(finalized.contains(n) ? .green.opacity(0.75) :
                                              current == n ? .yellow : .orange.opacity(0.5))
                                    .frame(width: 32, height: 32)
                                Text(n).font(.system(size: 12, weight: .black))
                                    .foregroundStyle(current == n ? .black : .white)
                            }
                            Text(dist[n].map { $0 == .max ? "∞" : "\($0)" } ?? "∞")
                                .font(.system(size: 10, weight: .heavy))
                                .foregroundStyle(.orange)
                        }
                    }
                }
                Text("edges: " + edges.map { "\($0.0)-\($0.1)(\($0.2))" }.joined(separator: " "))
                    .font(.system(size: 9, design: .monospaced)).foregroundStyle(.secondary)
                Text("各ステップで最短距離が確定したノードを緑、現在処理中を黄に")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        var d: [String: Int] = [:]
        for n in nodes { d[n] = n == "A" ? 0 : .max }
        dist = d; finalized = []; current = nil
        var adj: [String: [(String, Int)]] = [:]
        for e in edges {
            adj[e.0, default: []].append((e.1, e.2))
            adj[e.1, default: []].append((e.0, e.2))
        }
        var fin: Set<String> = []
        var delay = 0.4
        while fin.count < nodes.count {
            // 最小未確定 d を選ぶ
            var pick: String? = nil
            var minV = Int.max
            for n in nodes where !fin.contains(n) {
                if let v = d[n], v < minV { minV = v; pick = n }
            }
            guard let p = pick else { break }
            fin.insert(p)
            for (nb, w) in adj[p] ?? [] {
                if !fin.contains(nb), d[p]! + w < d[nb, default: .max] {
                    d[nb] = d[p]! + w
                }
            }
            let snapD = d, snapF = fin, curP = p
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                guard t == token else { return }
                withAnimation { dist = snapD; finalized = snapF; current = curP }
            }
            delay += 1.0
        }
    }
}

// MARK: - Union Find Merge

struct UnionFindMergeAnim: View {
    let n = 6
    let unions: [(Int, Int)] = [(0,1),(2,3),(0,2),(4,5)]
    @State private var parent: [Int] = []
    @State private var op = ""
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Union-Find", tint: .pink, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    ForEach(0..<n, id: \.self) { i in
                        VStack(spacing: 2) {
                            ZStack {
                                Circle().fill(rootColor(i))
                                    .frame(width: 26, height: 26)
                                Text("\(i)").font(.system(size: 11, weight: .black))
                                    .foregroundStyle(.white)
                            }
                            if i < parent.count {
                                Text("→\(find(i))")
                                    .font(.system(size: 8, weight: .heavy, design: .monospaced))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                Text(op).font(.caption.weight(.heavy)).foregroundStyle(.pink)
                Text("union(a,b): root(b) を root(a) の子に")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func find(_ x: Int) -> Int {
        guard parent.indices.contains(x) else { return x }
        var i = x
        while parent[i] != i { i = parent[i] }
        return i
    }
    private func rootColor(_ i: Int) -> Color {
        let r = find(i)
        let palette: [Color] = [.pink, .blue, .green, .orange, .purple, .teal]
        return palette[r % palette.count].opacity(0.75)
    }
    private func play() {
        token += 1; let t = token
        parent = Array(0..<n)
        op = ""
        for (k, (a, b)) in unions.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(k) * 1.0) {
                guard t == token else { return }
                withAnimation {
                    let ra = self.find(a), rb = self.find(b)
                    if ra != rb { parent[rb] = ra }
                    op = "union(\(a), \(b)) → root(\(b))=\(rb) を root(\(a))=\(ra) の子に"
                }
            }
        }
    }
}

// MARK: - Kruskal MST

struct KruskalAnim: View {
    let nodes = ["A", "B", "C", "D", "E"]
    let edges: [(String, String, Int)] = [
        ("A", "B", 1), ("C", "D", 2), ("A", "C", 3),
        ("B", "D", 4), ("D", "E", 5), ("B", "C", 6)
    ]
    @State private var processed: [(String, String, Int, Bool)] = []   // bool = used
    @State private var mstSum = 0
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Kruskal MST", tint: .green, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                Text("edges を重み昇順、Union-Find でサイクル回避")
                    .font(.caption2).foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 3) {
                    ForEach(processed.indices, id: \.self) { i in
                        let e = processed[i]
                        HStack(spacing: 6) {
                            Text(e.3 ? "✓" : "×")
                                .font(.caption.weight(.heavy))
                                .foregroundStyle(e.3 ? .green : .red)
                            Text("\(e.0)-\(e.1)")
                                .font(.system(size: 12, weight: .black, design: .monospaced))
                                .foregroundStyle(e.3 ? .green : .secondary)
                            Text("w=\(e.2)")
                                .font(.system(size: 10, weight: .heavy, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                Text("MST 合計 = \(mstSum)").font(.caption.weight(.bold)).foregroundStyle(.green)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        processed = []; mstSum = 0
        let sorted = edges.sorted { $0.2 < $1.2 }
        var parent: [String: String] = [:]
        for n in nodes { parent[n] = n }
        func find(_ x: String) -> String {
            var i = x
            while parent[i] != i { i = parent[i]! }
            return i
        }
        var sum = 0
        for (k, e) in sorted.enumerated() {
            let ra = find(e.0), rb = find(e.1)
            let use = ra != rb
            if use { parent[rb] = ra; sum += e.2 }
            let entry = (e.0, e.1, e.2, use)
            let snapSum = sum
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(k) * 0.9) {
                guard t == token else { return }
                withAnimation { processed.append(entry); mstSum = snapSum }
            }
        }
    }
}

// MARK: - BFS (queue + grid visit order)

struct BFSGridCustomAnim: View {
    let grid: [[Int]] = [
        [1, 1, 1, 0, 1],
        [0, 1, 0, 0, 1],
        [0, 1, 1, 1, 1],
        [0, 0, 0, 0, 1]
    ]
    @State private var visited: [[Int]] = []   // order numbers, 0 = unvisited
    @State private var queue: [String] = []
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "BFS (start=(0,0))", tint: .blue, onReplay: play) {
            VStack(spacing: 3) {
                ForEach(visited.indices, id: \.self) { r in
                    HStack(spacing: 3) {
                        ForEach(visited[r].indices, id: \.self) { c in
                            let order = visited[r][c]
                            let isWall = grid[r][c] == 0
                            tile(width: 28, height: 28,
                                 bg: isWall ? .gray.opacity(0.45)
                                       : (order > 0 ? .blue.opacity(0.70) : .blue.opacity(0.20))) {
                                Text(order > 0 ? "\(order)" : (isWall ? "#" : "·"))
                                    .font(.system(size: 11, weight: .black, design: .monospaced))
                            }
                        }
                    }
                }
            }
            HStack(spacing: 4) {
                Text("queue:").font(.caption2.weight(.black)).foregroundStyle(.blue)
                ForEach(queue.indices, id: \.self) { i in
                    tile(width: 36, height: 22, bg: .blue.opacity(0.55)) {
                        Text(queue[i]).font(.system(size: 9, weight: .heavy, design: .monospaced))
                    }
                }
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        let R = grid.count, C = grid[0].count
        visited = Array(repeating: Array(repeating: 0, count: C), count: R)
        queue = []
        var q: [(Int, Int)] = [(0, 0)]
        var v = visited
        v[0][0] = 1
        var order = 2
        var seq: [(v: [[Int]], q: [String])] = []
        seq.append((v, ["(0,0)"]))
        while let p = q.first {
            q.removeFirst()
            for (dr, dc) in [(-1, 0), (1, 0), (0, -1), (0, 1)] {
                let nr = p.0 + dr, nc = p.1 + dc
                guard nr >= 0, nr < R, nc >= 0, nc < C else { continue }
                guard grid[nr][nc] == 1, v[nr][nc] == 0 else { continue }
                v[nr][nc] = order
                order += 1
                q.append((nr, nc))
            }
            seq.append((v, q.map { "(\($0.0),\($0.1))" }))
        }
        for (k, s) in seq.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.55) {
                guard t == token else { return }
                withAnimation { visited = s.v; queue = s.q }
            }
        }
    }
}

// MARK: - DFS Iterative

struct DFSIterativeAnim: View {
    let grid: [[Int]] = [
        [1, 1, 0, 0, 0],
        [1, 0, 0, 1, 1],
        [0, 0, 1, 1, 0],
        [0, 1, 1, 0, 0]
    ]
    @State private var visited: [[Int]] = []
    @State private var stack: [String] = []
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "DFS Iterative", tint: .green, onReplay: play) {
            VStack(spacing: 3) {
                ForEach(visited.indices, id: \.self) { r in
                    HStack(spacing: 3) {
                        ForEach(visited[r].indices, id: \.self) { c in
                            let order = visited[r][c]
                            let isWall = grid[r][c] == 0
                            tile(width: 28, height: 28,
                                 bg: isWall ? .gray.opacity(0.45)
                                       : (order > 0 ? .green.opacity(0.70) : .green.opacity(0.20))) {
                                Text(order > 0 ? "\(order)" : (isWall ? "#" : "·"))
                                    .font(.system(size: 11, weight: .black, design: .monospaced))
                            }
                        }
                    }
                }
            }
            HStack(spacing: 4) {
                Text("stack:").font(.caption2.weight(.black)).foregroundStyle(.green)
                ForEach(stack.indices, id: \.self) { i in
                    tile(width: 36, height: 22, bg: .green.opacity(0.55)) {
                        Text(stack[i]).font(.system(size: 9, weight: .heavy, design: .monospaced))
                    }
                }
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        let R = grid.count, C = grid[0].count
        visited = Array(repeating: Array(repeating: 0, count: C), count: R)
        stack = []
        var st: [(Int, Int)] = [(0, 0)]
        var v = visited
        var order = 1
        var seq: [(v: [[Int]], s: [String])] = []
        seq.append((v, ["(0,0)"]))
        while let p = st.popLast() {
            if grid[p.0][p.1] == 0 || v[p.0][p.1] > 0 { continue }
            v[p.0][p.1] = order
            order += 1
            for (dr, dc) in [(0, 1), (1, 0), (0, -1), (-1, 0)] {
                let nr = p.0 + dr, nc = p.1 + dc
                if nr >= 0 && nr < R && nc >= 0 && nc < C && grid[nr][nc] == 1 && v[nr][nc] == 0 {
                    st.append((nr, nc))
                }
            }
            seq.append((v, st.map { "(\($0.0),\($0.1))" }))
        }
        for (k, s) in seq.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.5) {
                guard t == token else { return }
                withAnimation { visited = s.v; stack = s.s }
            }
        }
    }
}
