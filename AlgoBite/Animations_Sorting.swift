import SwiftUI

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

// MARK: - Bubble Sort Pass (per-pass swap visualization)

struct BubbleSortPassAnim: View {
    @State private var arr = [64, 34, 25, 12, 22, 11, 90]
    @State private var i = 0   // j 位置
    @State private var swapping = false
    @State private var done = false
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Bubble Sort 1 パス", tint: .blue, onReplay: play) {
            HStack(spacing: 5) {
                ForEach(arr.indices, id: \.self) { idx in
                    let isCmp = idx == i || idx == i + 1
                    tile(width: 32, height: 32,
                         bg: swapping && isCmp ? .red : (isCmp ? .yellow : .blue.opacity(0.4)),
                         fg: isCmp ? .black : .white) { Text("\(arr[idx])") }
                }
            }
            Text("隣り合う 2 要素を比較し、左 > 右 なら swap")
                .font(.caption2).foregroundStyle(.secondary)
            if done {
                Text("✅ 1 パス完了 (最大値が末尾)")
                    .font(.caption.weight(.bold)).foregroundStyle(.blue)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        arr = [64, 34, 25, 12, 22, 11, 90]; i = 0; swapping = false; done = false
        var a = arr
        var k = 0
        for j in 0..<(a.count - 1) {
            let needSwap = a[j] > a[j + 1]
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.9) {
                guard t == token else { return }
                withAnimation { i = j; swapping = needSwap }
            }
            if needSwap {
                a.swapAt(j, j + 1)
                let snap = a
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.9 + 0.5) {
                    guard t == token else { return }
                    withAnimation { arr = snap }
                }
            }
            k += 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.9 + 0.3) {
            guard t == token else { return }
            withAnimation { swapping = false; done = true }
        }
    }
}

// MARK: - Selection Sort (find-min and swap)

struct SelectionSortAnim: View {
    @State private var arr = [64, 25, 12, 22, 11]
    @State private var startIdx = 0
    @State private var scanIdx = 0
    @State private var minIdx = 0
    @State private var done = false
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Selection Sort 1 パス", tint: .purple, onReplay: play) {
            HStack(spacing: 5) {
                ForEach(arr.indices, id: \.self) { i in
                    tile(width: 32, height: 32,
                         bg: i == minIdx ? .green :
                              (i == scanIdx ? .yellow :
                                (i < startIdx ? .purple.opacity(0.4) : .purple.opacity(0.20))),
                         fg: i == scanIdx || i == minIdx ? .black : .white) { Text("\(arr[i])") }
                }
            }
            Text("未ソート部から最小値を探し、先頭と swap")
                .font(.caption2).foregroundStyle(.secondary)
            if done {
                Text("✅ 1 パス完了 (先頭が最小)")
                    .font(.caption.weight(.bold)).foregroundStyle(.purple)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        arr = [64, 25, 12, 22, 11]; startIdx = 0; scanIdx = 0; minIdx = 0; done = false
        let a = arr
        var k = 0
        var mIdx = 0
        for j in 1..<a.count {
            if a[j] < a[mIdx] { mIdx = j }
            let curMin = mIdx
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.8) {
                guard t == token else { return }
                withAnimation { scanIdx = j; minIdx = curMin }
            }
            k += 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.8 + 0.3) {
            guard t == token else { return }
            var b = a; b.swapAt(0, mIdx)
            withAnimation { arr = b; done = true }
        }
    }
}

// MARK: - Insertion Sort

struct InsertionSortAnim: View {
    @State private var arr = [12, 11, 13, 5, 6]
    @State private var sortedEnd = 0   // 0..sortedEnd is sorted
    @State private var cur = 0
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Insertion Sort 1 パス", tint: .green, onReplay: play) {
            HStack(spacing: 5) {
                ForEach(arr.indices, id: \.self) { i in
                    tile(width: 32, height: 32,
                         bg: i == cur ? .yellow :
                              (i <= sortedEnd ? .green : .gray.opacity(0.5)),
                         fg: i == cur ? .black : .white) { Text("\(arr[i])") }
                }
            }
            Text("緑 = ソート済、黄 = 挿入中。後ろへ shift して正しい位置へ")
                .font(.caption2).foregroundStyle(.secondary)
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        arr = [12, 11, 13, 5, 6]; sortedEnd = 0; cur = 0
        var a = arr
        var k = 0
        for i in 1..<a.count {
            let key = a[i]
            var j = i - 1
            while j >= 0 && a[j] > key { a[j + 1] = a[j]; j -= 1 }
            a[j + 1] = key
            let snap = a; let pos = j + 1; let end = i
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.9) {
                guard t == token else { return }
                withAnimation { arr = snap; cur = pos; sortedEnd = end }
            }
            k += 1
        }
    }
}

// MARK: - Dutch National Flag (3-way partition)

struct DutchFlagAnim: View {
    @State private var arr: [Int] = [2, 0, 2, 1, 1, 0]
    @State private var lo = 0
    @State private var mid = 0
    @State private var hi = 5
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Dutch National Flag", tint: .orange, onReplay: play) {
            HStack(spacing: 3) {
                ForEach(arr.indices, id: \.self) { i in
                    let bg: Color = arr[i] == 0 ? .red : (arr[i] == 1 ? .white : .blue)
                    let fg: Color = arr[i] == 1 ? .black : .white
                    tile(width: 24, height: 28, bg: bg, fg: fg) { Text("\(arr[i])") }
                }
            }
            HStack(spacing: 12) {
                Text("lo=\(lo)")
                    .font(.system(.caption2, design: .monospaced)).foregroundStyle(.red)
                Text("mid=\(mid)")
                    .font(.system(.caption2, design: .monospaced)).foregroundStyle(.orange)
                Text("hi=\(hi)")
                    .font(.system(.caption2, design: .monospaced)).foregroundStyle(.blue)
            }
            Text("0 を左へ、2 を右へ、1 はそのまま")
                .font(.caption2).foregroundStyle(.secondary)
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        var a = [2, 0, 2, 1, 1, 0]
        arr = a; lo = 0; mid = 0; hi = a.count - 1
        var l = 0, m = 0, h = a.count - 1
        var k = 0
        while m <= h {
            if a[m] == 0 { a.swapAt(l, m); l += 1; m += 1 }
            else if a[m] == 2 { a.swapAt(m, h); h -= 1 }
            else { m += 1 }
            let snap = a; let pl = l, pm = m, ph = h
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.6) {
                guard t == token else { return }
                withAnimation { arr = snap; lo = pl; mid = pm; hi = ph }
            }
            k += 1
        }
    }
}

// MARK: - Quicksort (Lomuto partition + recursion)

struct QuicksortAnim: View {
    @State private var arr = [3, 6, 8, 10, 1, 2]
    @State private var pivotIdx: Int? = nil
    @State private var i = -1
    @State private var j = -1
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Quicksort (Lomuto)", tint: .purple, onReplay: play) {
            HStack(spacing: 3) {
                ForEach(arr.indices, id: \.self) { k in
                    let isPivot = k == pivotIdx
                    let isI = k == i, isJ = k == j
                    tile(width: 26, height: 28,
                         bg: isPivot ? .red : (isI ? .yellow : (isJ ? .orange : .purple.opacity(0.4))),
                         fg: isPivot || isI || isJ ? .black : .white) { Text("\(arr[k])") }
                }
            }
            VStack(spacing: 2) {
                Text("pivot=最後の要素、i=境界、j=走査位置")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        arr = [3, 6, 8, 10, 1, 2]; pivotIdx = nil; i = -1; j = -1
        var a = arr
        var k = 0
        // 部分配列 [0..n-1] の partition
        func partition(_ lo: Int, _ hi: Int) {
            guard lo < hi else { return }
            let piv = a[hi]
            var ii = lo - 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.5) {
                guard t == token else { return }
                withAnimation { pivotIdx = hi; i = ii; j = lo }
            }
            k += 1
            for jj in lo..<hi {
                if a[jj] <= piv { ii += 1; a.swapAt(ii, jj) }
                let snap = a; let curI = ii, curJ = jj
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.4) {
                    guard t == token else { return }
                    withAnimation { arr = snap; i = curI; j = curJ }
                }
                k += 1
            }
            a.swapAt(ii + 1, hi)
            let snap = a
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.4) {
                guard t == token else { return }
                withAnimation { arr = snap; pivotIdx = nil; i = -1; j = -1 }
            }
            k += 1
        }
        partition(0, a.count - 1)
    }
}

// MARK: - Merge Sort (divide visualization)

struct MergeSortAnim: View {
    let initial = [38, 27, 43, 3, 9, 82, 10]
    @State private var rows: [[Int]] = []   // 各段のグループを連結したもの
    @State private var phase = 0
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Merge Sort (divide & conquer)", tint: .teal, onReplay: play) {
            VStack(spacing: 4) {
                ForEach(rows.indices, id: \.self) { idx in
                    HStack(spacing: 3) {
                        ForEach(rows[idx].indices, id: \.self) { k in
                            tile(width: 24, height: 24, bg: .teal.opacity(0.45)) {
                                Text("\(rows[idx][k])")
                                    .font(.system(size: 10, weight: .black, design: .monospaced))
                            }
                        }
                    }
                }
            }
            Text(phase == 0 ? "分割中..." : "マージ中...")
                .font(.caption2.weight(.heavy)).foregroundStyle(.teal)
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        rows = [initial]; phase = 0
        // 分割
        var levels: [[Int]] = [initial]
        var size = initial.count / 2
        while size >= 1 {
            var nextLevel: [Int] = []
            var src = levels.last!
            var i = 0
            while i < src.count {
                let end = min(i + size, src.count)
                nextLevel.append(contentsOf: src[i..<end])
                i = end
            }
            levels.append(nextLevel)
            if size == 1 { break }
            size /= 2
        }
        var k = 0
        for (idx, lvl) in levels.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(k) * 0.7) {
                guard t == token else { return }
                withAnimation { rows = Array(levels.prefix(idx + 1)) }
            }
            k += 1
        }
        // マージ
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(k) * 0.7) {
            guard t == token else { return }
            withAnimation { phase = 1 }
        }
        let merge2 = [27, 38, 3, 43, 9, 82, 10]
        let merge4 = [3, 27, 38, 43, 9, 10, 82]
        let merge8 = [3, 9, 10, 27, 38, 43, 82]
        let mergeSteps = [merge2, merge4, merge8]
        for (idx, lvl) in mergeSteps.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(k + idx + 1) * 0.8) {
                guard t == token else { return }
                withAnimation { rows.append(lvl) }
            }
        }
    }
}

// MARK: - Counting Sort (bucket counts)

struct CountingSortAnim: View {
    let nums = [4, 2, 2, 8, 3, 3, 1]
    @State private var counts: [Int: Int] = [:]
    @State private var idx = -1
    @State private var output: [Int] = []
    @State private var phase = 0
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Counting Sort", tint: .orange, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    ForEach(nums.indices, id: \.self) { i in
                        tile(width: 26, height: 24,
                             bg: i == idx ? .yellow : .orange.opacity(0.4),
                             fg: i == idx ? .black : .white) { Text("\(nums[i])") }
                    }
                }
                HStack(spacing: 4) {
                    ForEach(0...8, id: \.self) { v in
                        VStack(spacing: 0) {
                            Text("\(v)").font(.system(size: 8, weight: .heavy))
                            tile(width: 22, height: 22,
                                 bg: (counts[v] ?? 0) > 0 ? .orange.opacity(0.6) : .gray.opacity(0.25)) {
                                Text("\(counts[v] ?? 0)")
                                    .font(.system(size: 10, weight: .black, design: .monospaced))
                            }
                        }
                    }
                }
                if phase >= 1 {
                    HStack(spacing: 4) {
                        Text("→").font(.caption2.weight(.heavy)).foregroundStyle(.green)
                        ForEach(output.indices, id: \.self) { i in
                            tile(width: 22, height: 22, bg: .green.opacity(0.6)) {
                                Text("\(output[i])")
                                    .font(.system(size: 10, weight: .heavy, design: .monospaced))
                            }
                        }
                    }
                }
                Text("各値の出現回数を数えて、小さい順に展開")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        counts = [:]; idx = -1; output = []; phase = 0
        var c: [Int: Int] = [:]
        for (i, v) in nums.enumerated() {
            c[v, default: 0] += 1
            let snap = c
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.5) {
                guard t == token else { return }
                withAnimation { idx = i; counts = snap }
            }
        }
        let base = 0.4 + Double(nums.count) * 0.5 + 0.3
        DispatchQueue.main.asyncAfter(deadline: .now() + base) {
            guard t == token else { return }
            withAnimation { phase = 1 }
        }
        var seq: [Int] = []
        for v in 0...8 {
            for _ in 0..<(c[v] ?? 0) { seq.append(v) }
        }
        for (i, v) in seq.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + base + Double(i) * 0.3) {
                guard t == token else { return }
                withAnimation { output.append(v) }
            }
        }
    }
}
