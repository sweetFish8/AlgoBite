import SwiftUI

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

// MARK: - Climbing Stairs (DP with stair visual)

struct ClimbingStairsAnim: View {
    let n: Int = 5
    @State private var dp: [Int] = []
    @State private var curIdx = -1
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Climbing Stairs (n=\(n))", tint: .orange, onReplay: play) {
            VStack(alignment: .leading, spacing: 8) {
                // 階段グラフィック
                HStack(alignment: .bottom, spacing: 2) {
                    ForEach(0...n, id: \.self) { i in
                        VStack(spacing: 2) {
                            if i == curIdx {
                                Text("🚶").font(.title2)
                            } else {
                                Text(" ").font(.title2)
                            }
                            ForEach(0..<(i+1), id: \.self) { _ in
                                Rectangle()
                                    .fill(.orange.opacity(0.45))
                                    .frame(width: 28, height: 12)
                            }
                        }
                    }
                }
                Text("dp[i] = dp[i-1] + dp[i-2]")
                    .font(.system(.caption2, design: .monospaced)).foregroundStyle(.secondary)
                HStack(spacing: 6) {
                    ForEach(dp.indices, id: \.self) { i in
                        tile(width: 36, height: 28,
                             bg: i == curIdx ? .yellow : .orange.opacity(0.30),
                             fg: i == curIdx ? .black : .white) {
                            VStack(spacing: 0) {
                                Text("\(dp[i])").font(.system(size: 12, weight: .black))
                                Text("dp[\(i)]").font(.system(size: 8))
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
        dp = []; curIdx = -1
        for i in 0...n {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.7) {
                guard t == token else { return }
                let v: Int
                if i <= 1 { v = 1 } else { v = dp[i-1] + dp[i-2] }
                withAnimation { dp.append(v); curIdx = i }
            }
        }
    }
}

// MARK: - Buy/Sell Stock (price chart + min tracker)

struct BuySellStockAnim: View {
    let prices: [Int] = [7, 1, 5, 3, 6, 4]
    @State private var idx = -1
    @State private var minSoFar: Int = .max
    @State private var maxProfit = 0
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Best Time to Buy/Sell", tint: .green, onReplay: play) {
            VStack(alignment: .leading, spacing: 8) {
                // バーグラフ
                HStack(alignment: .bottom, spacing: 5) {
                    ForEach(prices.indices, id: \.self) { i in
                        let isCur = i == idx
                        let isMin = prices[i] == minSoFar && minSoFar != .max && i <= idx
                        VStack(spacing: 2) {
                            Text("\(prices[i])")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.secondary)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(isMin ? .blue : (isCur ? .yellow : .gray.opacity(0.5)))
                                .frame(width: 26, height: CGFloat(prices[i]) * 10)
                        }
                    }
                }
                .padding(.top, 4)
                HStack(spacing: 12) {
                    Label("min: \(minSoFar == .max ? 0 : minSoFar)", systemImage: "arrow.down")
                        .font(.caption2.weight(.heavy))
                        .foregroundStyle(.blue)
                    Label("max profit: \(maxProfit)", systemImage: "dollarsign.circle.fill")
                        .font(.caption2.weight(.heavy))
                        .foregroundStyle(.green)
                }
            }
        }
        .onAppear { play() }
    }

    private func play() {
        token += 1; let t = token
        idx = -1; minSoFar = .max; maxProfit = 0
        for i in prices.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.7) {
                guard t == token else { return }
                withAnimation {
                    idx = i
                    minSoFar = min(minSoFar, prices[i])
                    maxProfit = max(maxProfit, prices[i] - minSoFar)
                }
            }
        }
    }
}

// MARK: - Jump Game (reachability)

struct JumpGameAnim: View {
    let nums: [Int]
    let countMode: Bool   // true = JumpGameII (回数), false = JumpGame (届く/届かない)

    init(nums: [Int] = [2, 3, 1, 1, 4], countMode: Bool = false) {
        self.nums = nums; self.countMode = countMode
    }

    @State private var idx = -1
    @State private var maxReach = 0
    @State private var jumps = 0
    @State private var token = 0

    var body: some View {
        AnimFrame(title: countMode ? "Jump Game II (回数最小)" : "Jump Game (到達?)",
                  tint: .purple, onReplay: play) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 5) {
                    ForEach(nums.indices, id: \.self) { i in
                        let reached = i <= maxReach
                        tile(width: 30, height: 30,
                             bg: i == idx ? .yellow : (reached ? .purple.opacity(0.5) : .white.opacity(0.15)),
                             fg: i == idx ? .black : .white) { Text("\(nums[i])") }
                    }
                }
                Text("nums[i] = ジャンプできる最大距離")
                    .font(.caption2).foregroundStyle(.secondary)
                HStack(spacing: 10) {
                    Text("maxReach = \(maxReach)")
                        .font(.system(.caption, design: .monospaced).weight(.bold))
                        .foregroundStyle(.purple)
                    if countMode {
                        Text("jumps = \(jumps)")
                            .font(.system(.caption, design: .monospaced).weight(.bold))
                            .foregroundStyle(.orange)
                    }
                }
                if idx == nums.count - 1 {
                    Text(countMode ? "🎯 最小 \(jumps) 回で到達" : "✅ 到達できた！")
                        .font(.caption.weight(.bold)).foregroundStyle(.green)
                }
            }
        }
        .onAppear { play() }
    }

    private func play() {
        token += 1; let t = token
        idx = -1; maxReach = 0; jumps = 0
        var curEnd = 0, far = 0
        for i in nums.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.8) {
                guard t == token else { return }
                withAnimation {
                    idx = i
                    far = max(far, i + nums[i])
                    maxReach = far
                    if countMode && i == curEnd && i < nums.count - 1 {
                        jumps += 1
                        curEnd = far
                    }
                }
            }
        }
    }
}

// MARK: - Coin Change (DP min coins)

struct CoinChangeAnim: View {
    let coins: [Int] = [1, 2, 5]
    let amount: Int = 7
    @State private var dp: [Int] = []
    @State private var curI = -1
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Coin Change (amount=\(amount))", tint: .yellow, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                Text("coins = \(coins)").font(.caption2).foregroundStyle(.secondary)
                HStack(spacing: 4) {
                    ForEach(dp.indices, id: \.self) { i in
                        tile(width: 28, height: 30,
                             bg: i == curI ? .yellow : (dp[i] == Int.max ? .red.opacity(0.35) : .green.opacity(0.4)),
                             fg: i == curI ? .black : .white) {
                            VStack(spacing: 0) {
                                Text(dp[i] == Int.max ? "∞" : "\(dp[i])")
                                    .font(.system(size: 11, weight: .black))
                                Text("\(i)").font(.system(size: 8))
                            }
                        }
                    }
                }
                Text("dp[a] = min(dp[a-c]+1) for c in coins")
                    .font(.system(.caption2, design: .monospaced)).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        dp = Array(repeating: Int.max, count: amount + 1)
        dp[0] = 0
        curI = -1
        for i in 1...amount {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.6) {
                guard t == token else { return }
                var v = Int.max
                for c in coins where i - c >= 0 && dp[i - c] != Int.max {
                    v = min(v, dp[i - c] + 1)
                }
                withAnimation { dp[i] = v; curI = i }
            }
        }
    }
}

// MARK: - Edit Distance (DP grid)

struct EditDistanceAnim: View {
    let a = "kitten"
    let b = "sitting"
    @State private var dp: [[Int]] = []
    @State private var cur: (Int, Int)? = nil
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Edit Distance", tint: .indigo, onReplay: play) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\"\(a)\" → \"\(b)\"")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.secondary)
                grid
                Text("dp[i][j] = 編集距離。挿入 / 削除 / 置換 の最小 +1")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    @ViewBuilder private var grid: some View {
        // ヘッダ行
        HStack(spacing: 2) {
            tile(width: 20, height: 20, bg: .indigo.opacity(0.15)) { Text(" ") }
            tile(width: 20, height: 20, bg: .indigo.opacity(0.25)) { Text("ε") }
            ForEach(Array(b.enumerated()), id: \.offset) { _, c in
                tile(width: 20, height: 20, bg: .indigo.opacity(0.25)) { Text(String(c)) }
            }
        }
        ForEach(dp.indices, id: \.self) { i in
            HStack(spacing: 2) {
                let lbl = i == 0 ? "ε" : String(Array(a)[i - 1])
                tile(width: 20, height: 20, bg: .indigo.opacity(0.25)) { Text(lbl) }
                ForEach(dp[i].indices, id: \.self) { j in
                    let isCur = cur.map { $0 == (i, j) } ?? false
                    tile(width: 20, height: 20,
                         bg: isCur ? .yellow : .indigo.opacity(0.45),
                         fg: isCur ? .black : .white) {
                        Text("\(dp[i][j])")
                    }
                }
            }
        }
    }
    private func play() {
        token += 1; let t = token
        let n = a.count, m = b.count
        dp = Array(repeating: Array(repeating: 0, count: m + 1), count: n + 1)
        cur = nil
        let aArr = Array(a), bArr = Array(b)
        var k = 0
        for i in 0...n {
            for j in 0...m {
                let v: Int
                if i == 0 { v = j }
                else if j == 0 { v = i }
                else if aArr[i - 1] == bArr[j - 1] { v = dp[i - 1][j - 1] }
                else { v = 1 + min(dp[i - 1][j - 1], min(dp[i][j - 1], dp[i - 1][j])) }
                let ii = i, jj = j
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + Double(k) * 0.10) {
                    guard t == token else { return }
                    withAnimation { dp[ii][jj] = v; cur = (ii, jj) }
                }
                k += 1
            }
        }
    }
}

// MARK: - Fibonacci Memo (tree with cache)

struct FibMemoAnim: View {
    let n = 6
    @State private var memo: [Int: Int] = [0: 0, 1: 1]
    @State private var current: Int? = nil
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "fib(\(n)) with memoization", tint: .cyan, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    ForEach(0...n, id: \.self) { i in
                        let cached = memo[i] != nil
                        tile(width: 32, height: 36,
                             bg: current == i ? .yellow : (cached ? .cyan : .gray.opacity(0.25)),
                             fg: current == i ? .black : .white) {
                            VStack(spacing: 0) {
                                Text("\(i)").font(.system(size: 9))
                                Text(cached ? "\(memo[i]!)" : "?")
                                    .font(.system(size: 11, weight: .black))
                            }
                        }
                    }
                }
                Text("base case: fib(0)=0, fib(1)=1")
                    .font(.caption2).foregroundStyle(.secondary)
                Text("memo[n] が確定済なら再計算しない")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        memo = [0: 0, 1: 1]; current = nil
        // bottom-up でメモ化を可視化
        for i in 2...n {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i - 2) * 0.8) {
                guard t == token else { return }
                let v = (memo[i - 1] ?? 0) + (memo[i - 2] ?? 0)
                withAnimation { current = i; memo[i] = v }
            }
        }
    }
}

// MARK: - House Robber (DP)

struct HouseRobberAnim: View {
    let nums: [Int] = [2, 7, 9, 3, 1]
    @State private var dp: [Int] = []
    @State private var picks: Set<Int> = []
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "House Robber", tint: .orange, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(nums.indices, id: \.self) { i in
                        VStack(spacing: 2) {
                            Text("\(nums[i])")
                                .font(.system(size: 10, weight: .bold)).foregroundStyle(.secondary)
                            Rectangle()
                                .fill(picks.contains(i) ? Color.orange : Color.gray.opacity(0.5))
                                .frame(width: 28, height: CGFloat(nums[i]) * 8)
                            Text("🏠").font(.system(size: 18))
                                .opacity(picks.contains(i) ? 1 : 0.4)
                        }
                    }
                }
                HStack(spacing: 4) {
                    Text("dp:").font(.caption2.weight(.black)).foregroundStyle(.orange)
                    ForEach(dp.indices, id: \.self) { i in
                        tile(width: 28, height: 22,
                             bg: i == dp.count - 1 ? .yellow : .orange.opacity(0.45),
                             fg: i == dp.count - 1 ? .black : .white) { Text("\(dp[i])") }
                    }
                }
                Text("dp[i] = max(dp[i-1], dp[i-2] + nums[i])")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        dp = []; picks = []
        let n = nums.count
        var d = Array(repeating: 0, count: n)
        for i in 0..<n {
            if i == 0 { d[i] = nums[0] }
            else if i == 1 { d[i] = max(nums[0], nums[1]) }
            else { d[i] = max(d[i - 1], d[i - 2] + nums[i]) }
        }
        for i in 0..<n {
            let v = d[i]
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.7) {
                guard t == token else { return }
                withAnimation { dp.append(v) }
            }
        }
        // 最終的にどこを robbed したか backtrack
        var p: Set<Int> = []
        var i = n - 1
        while i >= 0 {
            if i == 0 { if d[0] > 0 { p.insert(0) }; break }
            if i == 1 { if nums[1] > nums[0] { p.insert(1) } else { p.insert(0) }; break }
            if d[i] == d[i - 1] { i -= 1 } else { p.insert(i); i -= 2 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(n) * 0.7) {
            guard t == token else { return }
            withAnimation { picks = p }
        }
    }
}

// MARK: - LIS (Patience-style DP)

struct LISAnim: View {
    let nums: [Int] = [10, 9, 2, 5, 3, 7, 101, 18]
    @State private var dp: [Int] = []
    @State private var idx = -1
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Longest Increasing Subsequence", tint: .pink, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    ForEach(nums.indices, id: \.self) { i in
                        tile(width: 32, height: 26,
                             bg: i == idx ? .yellow : .pink.opacity(0.4),
                             fg: i == idx ? .black : .white) { Text("\(nums[i])") }
                    }
                }
                HStack(spacing: 4) {
                    Text("dp:").font(.caption2.weight(.black)).foregroundStyle(.pink)
                    ForEach(dp.indices, id: \.self) { i in
                        tile(width: 32, height: 22, bg: .pink.opacity(0.55)) { Text("\(dp[i])") }
                    }
                }
                Text("dp[i] = 1 + max(dp[j]) for j<i where nums[j]<nums[i]")
                    .font(.caption2).foregroundStyle(.secondary)
                if let m = dp.max() {
                    Text("LIS = \(m)")
                        .font(.caption.weight(.bold)).foregroundStyle(.pink)
                }
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        dp = []; idx = -1
        let n = nums.count
        var d = Array(repeating: 1, count: n)
        for i in 0..<n {
            for j in 0..<i where nums[j] < nums[i] { d[i] = max(d[i], d[j] + 1) }
            let v = d[i]
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.7) {
                guard t == token else { return }
                withAnimation { idx = i; dp.append(v) }
            }
        }
    }
}

// MARK: - LCS (2D DP grid for two strings)

struct LCSAnim: View {
    let a = "abcde"
    let b = "ace"
    @State private var grid: [[Int]] = []
    @State private var cur: (Int, Int)? = nil
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Longest Common Subsequence", tint: .teal, onReplay: play) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\"\(a)\" ∩ \"\(b)\"")
                    .font(.caption2).foregroundStyle(.secondary)
                HStack(spacing: 2) {
                    tile(width: 22, height: 22, bg: .teal.opacity(0.15)) { Text(" ") }
                    tile(width: 22, height: 22, bg: .teal.opacity(0.3)) { Text("ε") }
                    ForEach(Array(b.enumerated()), id: \.offset) { _, c in
                        tile(width: 22, height: 22, bg: .teal.opacity(0.3)) { Text(String(c)) }
                    }
                }
                ForEach(grid.indices, id: \.self) { i in
                    HStack(spacing: 2) {
                        let lbl = i == 0 ? "ε" : String(Array(a)[i - 1])
                        tile(width: 22, height: 22, bg: .teal.opacity(0.3)) { Text(lbl) }
                        ForEach(grid[i].indices, id: \.self) { j in
                            let isCur = cur.map { $0 == (i, j) } ?? false
                            tile(width: 22, height: 22,
                                 bg: isCur ? .yellow : .teal.opacity(0.5),
                                 fg: isCur ? .black : .white) { Text("\(grid[i][j])") }
                        }
                    }
                }
                if let last = grid.last?.last {
                    Text("LCS 長 = \(last)").font(.caption.weight(.bold)).foregroundStyle(.teal)
                }
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        let n = a.count, m = b.count
        grid = Array(repeating: Array(repeating: 0, count: m + 1), count: n + 1)
        cur = nil
        let aArr = Array(a), bArr = Array(b)
        var k = 0
        for i in 0...n {
            for j in 0...m {
                let v: Int
                if i == 0 || j == 0 { v = 0 }
                else if aArr[i - 1] == bArr[j - 1] { v = grid[i - 1][j - 1] + 1 }
                else { v = max(grid[i - 1][j], grid[i][j - 1]) }
                let ii = i, jj = j
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + Double(k) * 0.15) {
                    guard t == token else { return }
                    withAnimation { grid[ii][jj] = v; cur = (ii, jj) }
                }
                k += 1
            }
        }
    }
}

// MARK: - 0/1 Knapsack

struct KnapsackAnim: View {
    // 問題例 (W=4, wt=[1,3,4], val=[1,4,5] → 5) に合わせる
    let weights = [1, 3, 4]
    let values  = [1, 4, 5]
    let cap = 4
    @State private var grid: [[Int]] = []
    @State private var cur: (Int, Int)? = nil
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "0/1 Knapsack (cap=\(cap))", tint: .orange, onReplay: play) {
            VStack(alignment: .leading, spacing: 4) {
                Text("items: " + weights.indices.map { "(w=\(weights[$0]),v=\(values[$0]))" }.joined(separator: " "))
                    .font(.system(size: 9, design: .monospaced)).foregroundStyle(.secondary)
                HStack(spacing: 2) {
                    tile(width: 22, height: 22, bg: .orange.opacity(0.2)) { Text("") }
                    ForEach(0...cap, id: \.self) { c in
                        tile(width: 22, height: 22, bg: .orange.opacity(0.3)) { Text("\(c)") }
                    }
                }
                ForEach(grid.indices, id: \.self) { i in
                    HStack(spacing: 2) {
                        tile(width: 22, height: 22, bg: .orange.opacity(0.3)) {
                            Text(i == 0 ? "∅" : "#\(i)")
                        }
                        ForEach(grid[i].indices, id: \.self) { c in
                            let isCur = cur.map { $0 == (i, c) } ?? false
                            tile(width: 22, height: 22,
                                 bg: isCur ? .yellow : .orange.opacity(0.55),
                                 fg: isCur ? .black : .white) { Text("\(grid[i][c])") }
                        }
                    }
                }
            }
            Text("dp[i][c] = max(取らない: dp[i-1][c], 取る: dp[i-1][c-w]+v)")
                .font(.caption2).foregroundStyle(.secondary)
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        let n = weights.count
        grid = Array(repeating: Array(repeating: 0, count: cap + 1), count: n + 1)
        cur = nil
        var k = 0
        for i in 0...n {
            for c in 0...cap {
                let v: Int
                if i == 0 { v = 0 }
                else if c < weights[i - 1] { v = grid[i - 1][c] }
                else { v = max(grid[i - 1][c], grid[i - 1][c - weights[i - 1]] + values[i - 1]) }
                let ii = i, cc = c
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + Double(k) * 0.18) {
                    guard t == token else { return }
                    withAnimation { grid[ii][cc] = v; cur = (ii, cc) }
                }
                k += 1
            }
        }
    }
}

// MARK: - Unique Paths (path count grid)

struct UniquePathsAnim: View {
    // 問題例 (m=3, n=7 → 28) に合わせる
    let rows = 3, cols = 7
    @State private var grid: [[Int]] = []
    @State private var cur: (Int, Int)? = nil
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Unique Paths (\(rows)×\(cols))", tint: .blue, onReplay: play) {
            VStack(spacing: 3) {
                ForEach(grid.indices, id: \.self) { r in
                    HStack(spacing: 3) {
                        ForEach(grid[r].indices, id: \.self) { c in
                            let isCur = cur.map { $0 == (r, c) } ?? false
                            tile(width: 30, height: 26,
                                 bg: isCur ? .yellow : .blue.opacity(0.5),
                                 fg: isCur ? .black : .white) { Text("\(grid[r][c])") }
                        }
                    }
                }
            }
            Text("dp[r][c] = dp[r-1][c] + dp[r][c-1]")
                .font(.caption2).foregroundStyle(.secondary)
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        grid = Array(repeating: Array(repeating: 0, count: cols), count: rows)
        cur = nil
        var k = 0
        for r in 0..<rows {
            for c in 0..<cols {
                let v: Int
                if r == 0 || c == 0 { v = 1 }
                else { v = grid[r - 1][c] + grid[r][c - 1] }
                let rr = r, cc = c
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + Double(k) * 0.15) {
                    guard t == token else { return }
                    withAnimation { grid[rr][cc] = v; cur = (rr, cc) }
                }
                k += 1
            }
        }
    }
}

// MARK: - Maximum Subarray (Kadane)

struct MaxSubarrayKadaneAnim: View {
    let nums = [-2, 1, -3, 4, -1, 2, 1, -5, 4]
    @State private var i = -1
    @State private var cur = 0
    @State private var best = 0
    @State private var bestRange: (Int, Int) = (0, 0)
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Maximum Subarray (Kadane)", tint: .blue, onReplay: play) {
            HStack(spacing: 4) {
                ForEach(nums.indices, id: \.self) { k in
                    let inBest = k >= bestRange.0 && k <= bestRange.1
                    tile(width: 32, height: 28,
                         bg: k == i ? .yellow : (inBest ? .blue.opacity(0.65) : .blue.opacity(0.25)),
                         fg: k == i ? .black : .white) { Text("\(nums[k])") }
                }
            }
            HStack(spacing: 14) {
                Text("cur=\(cur)").font(.system(.caption2, design: .monospaced)).foregroundStyle(.yellow)
                Text("best=\(best)").font(.caption.weight(.bold)).foregroundStyle(.blue)
            }
            Text("cur = max(nums[i], cur + nums[i]); best = max(best, cur)")
                .font(.caption2).foregroundStyle(.secondary)
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        i = -1; cur = 0; best = nums[0]; bestRange = (0, 0)
        var c = 0; var b = nums[0]
        var startCur = 0
        var br: (Int, Int) = (0, 0)
        for (k, v) in nums.enumerated() {
            if c + v < v { c = v; startCur = k } else { c += v }
            if c > b { b = c; br = (startCur, k) }
            let curC = c, curB = b, curR = br
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.65) {
                guard t == token else { return }
                withAnimation { i = k; cur = curC; best = curB; bestRange = curR }
            }
        }
    }
}

// MARK: - Min Path Sum (grid DP)

struct MinPathSumAnim: View {
    let grid: [[Int]] = [[1, 3, 1],
                         [1, 5, 1],
                         [4, 2, 1]]
    @State private var dp: [[Int]] = []
    @State private var cur: (Int, Int)? = nil
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Min Path Sum", tint: .indigo, onReplay: play) {
            HStack(alignment: .top, spacing: 12) {
                VStack(spacing: 3) {
                    Text("grid").font(.caption2.weight(.heavy)).foregroundStyle(.secondary)
                    ForEach(grid.indices, id: \.self) { r in
                        HStack(spacing: 3) {
                            ForEach(grid[r].indices, id: \.self) { c in
                                tile(width: 26, height: 26, bg: .gray.opacity(0.45)) {
                                    Text("\(grid[r][c])")
                                }
                            }
                        }
                    }
                }
                VStack(spacing: 3) {
                    Text("dp").font(.caption2.weight(.heavy)).foregroundStyle(.indigo)
                    ForEach(dp.indices, id: \.self) { r in
                        HStack(spacing: 3) {
                            ForEach(dp[r].indices, id: \.self) { c in
                                let isCur = cur.map { $0 == (r, c) } ?? false
                                tile(width: 26, height: 26,
                                     bg: isCur ? .yellow : .indigo.opacity(0.55),
                                     fg: isCur ? .black : .white) { Text("\(dp[r][c])") }
                            }
                        }
                    }
                }
            }
            Text("dp[r][c] = grid[r][c] + min(dp[r-1][c], dp[r][c-1])")
                .font(.caption2).foregroundStyle(.secondary)
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        let R = grid.count, C = grid[0].count
        dp = Array(repeating: Array(repeating: 0, count: C), count: R)
        cur = nil
        var k = 0
        for r in 0..<R {
            for c in 0..<C {
                let v: Int
                if r == 0 && c == 0 { v = grid[0][0] }
                else if r == 0 { v = dp[0][c - 1] + grid[r][c] }
                else if c == 0 { v = dp[r - 1][0] + grid[r][c] }
                else { v = min(dp[r - 1][c], dp[r][c - 1]) + grid[r][c] }
                let rr = r, cc = c
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.5) {
                    guard t == token else { return }
                    withAnimation { dp[rr][cc] = v; cur = (rr, cc) }
                }
                k += 1
            }
        }
    }
}

// MARK: - Word Break (DP boolean array with split highlight)

struct WordBreakAnim: View {
    let s = "leetcode"
    let dict: Set<String> = ["leet", "code"]
    @State private var i = -1
    @State private var dp: [Bool] = []
    @State private var splitAt: Int? = nil
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Word Break (\"\(s)\")", tint: .teal, onReplay: play) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 2) {
                    ForEach(Array(s.enumerated()), id: \.offset) { idx, c in
                        tile(width: 24, height: 28,
                             bg: idx == i ? .yellow : .teal.opacity(0.45),
                             fg: idx == i ? .black : .white) {
                            Text(String(c)).font(.system(size: 12, weight: .black, design: .monospaced))
                        }
                    }
                }
                HStack(spacing: 2) {
                    ForEach(dp.indices, id: \.self) { idx in
                        tile(width: 24, height: 22,
                             bg: dp[idx] ? .green.opacity(0.65) : .red.opacity(0.35)) {
                            Text(dp[idx] ? "✓" : "·").font(.system(size: 10, weight: .heavy))
                        }
                    }
                }
                if let s2 = splitAt {
                    Text("dp[\(s2)] = true → 後ろを判定")
                        .font(.system(.caption2, design: .monospaced)).foregroundStyle(.teal)
                }
                Text("dp[i] = ∃ j<i, dp[j] && s[j..i] ∈ dict").font(.caption2).foregroundStyle(.secondary)
                Text("辞書: " + dict.joined(separator: ", "))
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        i = -1; dp = [true] + Array(repeating: false, count: s.count); splitAt = nil
        var d = [true] + Array(repeating: false, count: s.count)
        let arr = Array(s)
        for ii in 1...s.count {
            for j in 0..<ii {
                if d[j] {
                    let sub = String(arr[j..<ii])
                    if dict.contains(sub) {
                        d[ii] = true
                        let snap = d; let cs = ii - 1; let split = j
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(ii - 1) * 0.8) {
                            guard t == token else { return }
                            withAnimation { i = cs; dp = snap; splitAt = split }
                        }
                        break
                    }
                }
            }
        }
    }
}

// MARK: - Count Bits (DP using i & (i-1))

struct CountBitsAnim: View {
    let n = 8
    @State private var dp: [Int] = []
    @State private var cur = -1
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Count Bits (DP)", tint: .indigo, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    ForEach(0...n, id: \.self) { i in
                        VStack(spacing: 2) {
                            tile(width: 28, height: 22,
                                 bg: i == cur ? .yellow : .indigo.opacity(0.45),
                                 fg: i == cur ? .black : .white) { Text("\(i)") }
                            if i < dp.count {
                                Text(String(i, radix: 2))
                                    .font(.system(size: 8, design: .monospaced))
                                    .foregroundStyle(.secondary)
                                Text("\(dp[i])")
                                    .font(.system(size: 11, weight: .black))
                                    .foregroundStyle(.indigo)
                            }
                        }
                    }
                }
                Text("dp[i] = dp[i >> 1] + (i & 1)")
                    .font(.system(.caption, design: .monospaced)).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        dp = []; cur = -1
        var d: [Int] = []
        for i in 0...n {
            let v: Int
            if i == 0 { v = 0 } else { v = d[i >> 1] + (i & 1) }
            d.append(v)
            let snap = d
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.6) {
                guard t == token else { return }
                withAnimation { cur = i; dp = snap }
            }
        }
    }
}

// MARK: - Decode Ways (string DP)

struct DecodeWaysAnim: View {
    let s = "226"
    @State private var dp: [Int] = []
    @State private var cur = -1
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Decode Ways (\"\(s)\")", tint: .purple, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    ForEach(Array(s.enumerated()), id: \.offset) { i, c in
                        tile(width: 28, height: 30,
                             bg: i == cur ? .yellow : .purple.opacity(0.45),
                             fg: i == cur ? .black : .white) {
                            Text(String(c)).font(.system(size: 13, weight: .black, design: .monospaced))
                        }
                    }
                }
                HStack(spacing: 4) {
                    Text("dp:").font(.caption2.weight(.black)).foregroundStyle(.purple)
                    ForEach(dp.indices, id: \.self) { i in
                        tile(width: 28, height: 22,
                             bg: i == dp.count - 1 ? .yellow : .purple.opacity(0.55),
                             fg: i == dp.count - 1 ? .black : .white) { Text("\(dp[i])") }
                    }
                }
                Text("dp[i] = (s[i-1] ≠ '0') ? dp[i-1] : 0 + (10..26 ? dp[i-2] : 0)")
                    .font(.system(.caption2, design: .monospaced)).foregroundStyle(.secondary)
                if let last = dp.last {
                    Text("= \(last) 通り").font(.caption.weight(.bold)).foregroundStyle(.purple)
                }
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        dp = [1]; cur = -1   // dp[0] = 1 (空文字)
        var d = [1]
        let chars = Array(s)
        for i in 1...chars.count {
            let one = Int(String(chars[i - 1]))!
            let two = i >= 2 ? Int(String(chars[i - 2 ... i - 1]))! : 0
            var v = 0
            if one >= 1 { v += d[i - 1] }
            if 10 <= two, two <= 26 { v += d[i - 2] }
            d.append(v)
            let snap = d; let pos = i - 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(i - 1) * 0.8) {
                guard t == token else { return }
                withAnimation { cur = pos; dp = snap }
            }
        }
    }
}

// MARK: - Regex Match (DP grid for s & p)

struct RegexMatchAnim: View {
    let s = "aab"
    let p = "c*a*b"
    @State private var dp: [[Bool]] = []
    @State private var cur: (Int, Int)? = nil
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Regex Match \"\(s)\" vs \"\(p)\"", tint: .purple, onReplay: play) {
            VStack(spacing: 3) {
                HStack(spacing: 2) {
                    tile(width: 20, height: 20, bg: .purple.opacity(0.15)) { Text(" ") }
                    tile(width: 20, height: 20, bg: .purple.opacity(0.3)) { Text("ε") }
                    ForEach(Array(p.enumerated()), id: \.offset) { _, c in
                        tile(width: 20, height: 20, bg: .purple.opacity(0.3)) {
                            Text(String(c)).font(.system(size: 10, weight: .black, design: .monospaced))
                        }
                    }
                }
                ForEach(dp.indices, id: \.self) { i in
                    HStack(spacing: 2) {
                        let lbl = i == 0 ? "ε" : String(Array(s)[i - 1])
                        tile(width: 20, height: 20, bg: .purple.opacity(0.3)) { Text(lbl) }
                        ForEach(dp[i].indices, id: \.self) { j in
                            let isCur = cur.map { $0 == (i, j) } ?? false
                            tile(width: 20, height: 20,
                                 bg: isCur ? .yellow : (dp[i][j] ? .green.opacity(0.65) : .red.opacity(0.30)),
                                 fg: isCur ? .black : .white) {
                                Text(dp[i][j] ? "T" : "·")
                                    .font(.system(size: 10, weight: .black, design: .monospaced))
                            }
                        }
                    }
                }
            }
            Text("'*' は直前文字が 0 回以上、'.' は任意 1 文字")
                .font(.caption2).foregroundStyle(.secondary)
            if let last = dp.last?.last {
                Text(last ? "🎯 match" : "❌ no match")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(last ? .green : .red)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        let n = s.count, m = p.count
        dp = Array(repeating: Array(repeating: false, count: m + 1), count: n + 1)
        cur = nil
        let sArr = Array(s), pArr = Array(p)
        // dp[0][0] = true
        var d = dp
        d[0][0] = true
        for j in 1...m where pArr[j - 1] == "*" {
            d[0][j] = j >= 2 ? d[0][j - 2] : false
        }
        var k = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + Double(k) * 0.12) {
            guard t == token else { return }
            withAnimation { dp = d; cur = (0, 0) }
        }
        k += 1
        for i in 1...n {
            for j in 1...m {
                let pc = pArr[j - 1]
                var v = false
                if pc == "*" {
                    let prev = pArr[j - 2]
                    v = d[i][j - 2] || ((prev == "." || prev == sArr[i - 1]) && d[i - 1][j])
                } else if pc == "." || pc == sArr[i - 1] {
                    v = d[i - 1][j - 1]
                }
                d[i][j] = v
                let snap = d; let ii = i, jj = j
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + Double(k) * 0.18) {
                    guard t == token else { return }
                    withAnimation { dp = snap; cur = (ii, jj) }
                }
                k += 1
            }
        }
    }
}

// MARK: - Wildcard Match

struct WildcardMatchAnim: View {
    let s = "adceb"
    let p = "*a*b"
    @State private var dp: [[Bool]] = []
    @State private var cur: (Int, Int)? = nil
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Wildcard Match \"\(s)\" vs \"\(p)\"", tint: .indigo, onReplay: play) {
            VStack(spacing: 3) {
                HStack(spacing: 2) {
                    tile(width: 20, height: 20, bg: .indigo.opacity(0.15)) { Text(" ") }
                    tile(width: 20, height: 20, bg: .indigo.opacity(0.3)) { Text("ε") }
                    ForEach(Array(p.enumerated()), id: \.offset) { _, c in
                        tile(width: 20, height: 20, bg: .indigo.opacity(0.3)) {
                            Text(String(c)).font(.system(size: 10, weight: .black, design: .monospaced))
                        }
                    }
                }
                ForEach(dp.indices, id: \.self) { i in
                    HStack(spacing: 2) {
                        let lbl = i == 0 ? "ε" : String(Array(s)[i - 1])
                        tile(width: 20, height: 20, bg: .indigo.opacity(0.3)) { Text(lbl) }
                        ForEach(dp[i].indices, id: \.self) { j in
                            let isCur = cur.map { $0 == (i, j) } ?? false
                            tile(width: 20, height: 20,
                                 bg: isCur ? .yellow : (dp[i][j] ? .green.opacity(0.65) : .red.opacity(0.30)),
                                 fg: isCur ? .black : .white) {
                                Text(dp[i][j] ? "T" : "·")
                                    .font(.system(size: 10, weight: .black, design: .monospaced))
                            }
                        }
                    }
                }
            }
            Text("'*' は任意の文字列、'?' は任意 1 文字")
                .font(.caption2).foregroundStyle(.secondary)
            if let last = dp.last?.last {
                Text(last ? "🎯 match" : "❌ no match")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(last ? .green : .red)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        let n = s.count, m = p.count
        dp = Array(repeating: Array(repeating: false, count: m + 1), count: n + 1)
        cur = nil
        let sArr = Array(s), pArr = Array(p)
        var d = dp
        d[0][0] = true
        for j in 1...m where pArr[j - 1] == "*" { d[0][j] = d[0][j - 1] }
        var k = 0
        for i in 1...n {
            for j in 1...m {
                let pc = pArr[j - 1]
                if pc == "*" { d[i][j] = d[i - 1][j] || d[i][j - 1] }
                else if pc == "?" || pc == sArr[i - 1] { d[i][j] = d[i - 1][j - 1] }
                else { d[i][j] = false }
                let snap = d; let ii = i, jj = j
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + Double(k) * 0.18) {
                    guard t == token else { return }
                    withAnimation { dp = snap; cur = (ii, jj) }
                }
                k += 1
            }
        }
    }
}
