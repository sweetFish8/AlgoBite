import SwiftUI

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

// MARK: - Roman to Int (char-by-char)

struct RomanToIntAnim: View {
    let s: String = "MCMXCIV"   // 1994
    @State private var idx = -1
    @State private var total = 0
    @State private var note: String = ""
    @State private var token = 0

    private let map: [Character: Int] = ["I":1,"V":5,"X":10,"L":50,"C":100,"D":500,"M":1000]

    var body: some View {
        AnimFrame(title: "Roman → Int  (\"\(s)\")", tint: .brown, onReplay: play) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 4) {
                    ForEach(Array(s.enumerated()), id: \.offset) { i, c in
                        tile(width: 28, height: 32,
                             bg: i == idx ? .yellow : (i < idx ? .brown.opacity(0.45) : .white.opacity(0.18)),
                             fg: i == idx ? .black : .white) {
                            Text(String(c)).font(.system(size: 13, weight: .black, design: .serif))
                        }
                    }
                }
                Text("total = \(total)")
                    .font(.system(.title3, design: .monospaced).weight(.black))
                    .foregroundStyle(.brown)
                if !note.isEmpty {
                    Text(note).font(.caption2.weight(.semibold)).foregroundStyle(.secondary)
                }
            }
        }
        .onAppear { play() }
    }

    private func play() {
        token += 1; let t = token
        idx = -1; total = 0; note = ""
        let chars = Array(s)
        for i in chars.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.7) {
                guard t == token else { return }
                let v = map[chars[i]] ?? 0
                let nv = (i + 1 < chars.count) ? (map[chars[i + 1]] ?? 0) : 0
                withAnimation {
                    idx = i
                    if v < nv {
                        total -= v
                        note = "\(chars[i]) < \(chars[i+1]) → 引く (-\(v))"
                    } else {
                        total += v
                        note = "\(chars[i]) = \(v) → 加える"
                    }
                }
            }
        }
    }
}

// MARK: - KMP Failure Function

struct KMPFailureAnim: View {
    let pat: String = "AAACAAAA"
    @State private var fail: [Int] = []
    @State private var idx = -1
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "KMP failure 関数", tint: .indigo, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    ForEach(Array(pat.enumerated()), id: \.offset) { i, c in
                        tile(width: 28, height: 28,
                             bg: i == idx ? .yellow : .indigo.opacity(0.35),
                             fg: i == idx ? .black : .white) {
                            Text(String(c)).font(.system(size: 12, weight: .black, design: .monospaced))
                        }
                    }
                }
                HStack(spacing: 4) {
                    Text("fail").font(.system(size: 10, weight: .black, design: .monospaced))
                        .foregroundStyle(.indigo).frame(width: 28, alignment: .leading)
                    ForEach(fail.indices, id: \.self) { i in
                        tile(width: 28, height: 28,
                             bg: i == idx ? .green : .indigo.opacity(0.25)) {
                            Text("\(fail[i])")
                        }
                    }
                }
                Text("fail[i] = 接頭辞=接尾辞 となる最大長")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        fail = []; idx = -1
        let p = Array(pat); var lps = Array(repeating: 0, count: p.count)
        var len = 0, i = 1
        var seq: [(idx: Int, val: Int)] = [(0, 0)]
        while i < p.count {
            if p[i] == p[len] { len += 1; lps[i] = len; seq.append((i, len)); i += 1 }
            else if len > 0 { len = lps[len - 1] }
            else { lps[i] = 0; seq.append((i, 0)); i += 1 }
        }
        for (k, step) in seq.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(k) * 0.7) {
                guard t == token else { return }
                withAnimation {
                    idx = step.idx
                    while fail.count <= step.idx { fail.append(0) }
                    fail[step.idx] = step.val
                }
            }
        }
    }
}

// MARK: - Longest Palindrome (Expand around center)

struct LongestPalindromeAnim: View {
    let s: String = "babad"
    @State private var center = 0
    @State private var l = 0
    @State private var r = 0
    @State private var best: (l: Int, r: Int) = (0, 0)
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Longest Palindrome (中心展開)", tint: .pink, onReplay: play) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 4) {
                    ForEach(Array(s.enumerated()), id: \.offset) { i, c in
                        let inBest = i >= best.l && i <= best.r
                        let inCur = i >= l && i <= r
                        tile(width: 28, height: 30,
                             bg: inBest ? .pink : (inCur ? .yellow : .white.opacity(0.18)),
                             fg: inBest ? .white : (inCur ? .black : .white)) {
                            Text(String(c)).font(.system(size: 12, weight: .black, design: .serif))
                        }
                    }
                }
                Text("center=\(center) → [\(l), \(r)]")
                    .font(.system(.caption2, design: .monospaced)).foregroundStyle(.secondary)
                Text("best = \"\(String(Array(s)[best.l...best.r]))\"")
                    .font(.caption.weight(.heavy)).foregroundStyle(.pink)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        l = 0; r = 0; center = 0; best = (0, 0)
        let chars = Array(s)
        var stepDelay = 0.4
        for i in chars.indices {
            // odd expansion
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDelay) {
                guard t == token else { return }
                withAnimation { center = i; l = i; r = i }
            }
            stepDelay += 0.5
            var (a, b) = (i, i)
            while a >= 0 && b < chars.count && chars[a] == chars[b] {
                let (la, rb) = (a, b)
                DispatchQueue.main.asyncAfter(deadline: .now() + stepDelay) {
                    guard t == token else { return }
                    withAnimation {
                        l = la; r = rb
                        if rb - la > best.r - best.l { best = (la, rb) }
                    }
                }
                stepDelay += 0.4
                a -= 1; b += 1
            }
        }
    }
}

// MARK: - Anagram Check (char count buckets)

struct AnagramCheckAnim: View {
    let s = "anagram"
    let p = "nagaram"
    @State private var idx = -1
    @State private var counts: [Character: Int] = [:]
    @State private var phase = 0   // 0=adding s, 1=subtracting p, 2=done
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Anagram Check", tint: .orange, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Text("s").font(.system(size: 10, weight: .black, design: .monospaced)).frame(width: 14).foregroundStyle(.green)
                    ForEach(Array(s.enumerated()), id: \.offset) { i, c in
                        tile(width: 22, height: 22,
                             bg: phase == 0 && i == idx ? .yellow : .green.opacity(0.4),
                             fg: phase == 0 && i == idx ? .black : .white) { Text(String(c)) }
                    }
                }
                HStack(spacing: 4) {
                    Text("p").font(.system(size: 10, weight: .black, design: .monospaced)).frame(width: 14).foregroundStyle(.red)
                    ForEach(Array(p.enumerated()), id: \.offset) { i, c in
                        tile(width: 22, height: 22,
                             bg: phase == 1 && i == idx ? .yellow : .red.opacity(0.4),
                             fg: phase == 1 && i == idx ? .black : .white) { Text(String(c)) }
                    }
                }
                HStack(spacing: 4) {
                    ForEach(counts.sorted(by: { $0.key < $1.key }), id: \.key) { kv in
                        VStack(spacing: 1) {
                            Text(String(kv.key)).font(.system(size: 10, weight: .black, design: .monospaced))
                            Text("\(kv.value)").font(.system(size: 11, weight: .heavy))
                                .foregroundStyle(kv.value == 0 ? .green : (kv.value > 0 ? .blue : .red))
                        }
                        .padding(.horizontal, 4)
                    }
                }
                if phase == 2 {
                    let isAnagram = counts.values.allSatisfy { $0 == 0 }
                    Text(isAnagram ? "✅ アナグラム" : "❌ 違う")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(isAnagram ? .green : .red)
                }
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        idx = -1; counts = [:]; phase = 0
        let sArr = Array(s), pArr = Array(p)
        for i in sArr.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + Double(i) * 0.4) {
                guard t == token else { return }
                withAnimation { idx = i; counts[sArr[i], default: 0] += 1 }
            }
        }
        let base = 0.3 + Double(sArr.count) * 0.4 + 0.3
        for i in pArr.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + base + Double(i) * 0.4) {
                guard t == token else { return }
                withAnimation { phase = 1; idx = i; counts[pArr[i], default: 0] -= 1 }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + base + Double(pArr.count) * 0.4 + 0.2) {
            guard t == token else { return }
            withAnimation { phase = 2 }
        }
    }
}

// MARK: - Sliding Window Substring (live window)

struct LongestSubstringAnim: View {
    let s = "abcabcbb"
    @State private var l = 0
    @State private var r = 0
    @State private var best: (l: Int, r: Int) = (0, 0)
    @State private var seen: [Character: Int] = [:]
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Longest Substring w/o Repeat", tint: .pink, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    ForEach(Array(s.enumerated()), id: \.offset) { i, c in
                        let inWindow = i >= l && i <= r && r >= l
                        let inBest = i >= best.l && i <= best.r
                        tile(width: 26, height: 30,
                             bg: inWindow ? .yellow : (inBest ? .pink.opacity(0.55) : .white.opacity(0.18)),
                             fg: inWindow ? .black : .white) {
                            Text(String(c)).font(.system(size: 12, weight: .black, design: .monospaced))
                        }
                    }
                }
                Text("window = [\(l), \(r)]  len = \(max(0, r - l + 1))")
                    .font(.system(.caption2, design: .monospaced)).foregroundStyle(.secondary)
                Text("best = \"\(best.r >= best.l ? String(Array(s)[best.l...best.r]) : "")\"  len=\(best.r - best.l + 1)")
                    .font(.caption.weight(.bold)).foregroundStyle(.pink)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        l = 0; r = -1; best = (0, -1); seen = [:]
        let arr = Array(s)
        var ll = 0
        var k = 0
        for ri in arr.indices {
            let c = arr[ri]
            if let prev = seen[c], prev >= ll { ll = prev + 1 }
            seen[c] = ri
            let curL = ll, curR = ri
            let newBest = (curR - curL) > (best.r - best.l) ? (curL, curR) : best
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.6) {
                guard t == token else { return }
                withAnimation { l = curL; r = curR; best = newBest }
            }
            k += 1
        }
    }
}

// MARK: - Longest Valid Parens (stack of indices)

struct LongestValidParensAnim: View {
    let s: String = ")()())"
    @State private var idx = -1
    @State private var stack: [Int] = [-1]
    @State private var bestLen = 0
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Longest Valid Parentheses", tint: .indigo, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    ForEach(Array(s.enumerated()), id: \.offset) { i, c in
                        tile(width: 26, height: 28,
                             bg: i == idx ? .yellow : .indigo.opacity(0.4),
                             fg: i == idx ? .black : .white) {
                            Text(String(c)).font(.system(size: 13, weight: .black, design: .monospaced))
                        }
                    }
                }
                HStack(spacing: 4) {
                    Text("stack:").font(.caption2.weight(.black)).foregroundStyle(.indigo)
                    ForEach(stack.indices, id: \.self) { k in
                        tile(width: 22, height: 22, bg: .indigo.opacity(0.55)) {
                            Text("\(stack[k])")
                        }
                    }
                }
                Text("best valid length = \(bestLen)")
                    .font(.caption.weight(.bold)).foregroundStyle(.indigo)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        idx = -1; stack = [-1]; bestLen = 0
        var st: [Int] = [-1]; var best = 0
        let arr = Array(s)
        for i in arr.indices {
            if arr[i] == "(" { st.append(i) }
            else {
                st.removeLast()
                if st.isEmpty { st.append(i) }
                else { best = max(best, i - st.last!) }
            }
            let snap = st; let curBest = best
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.7) {
                guard t == token else { return }
                withAnimation { idx = i; stack = snap; bestLen = curBest }
            }
        }
    }
}

// MARK: - Group Anagrams

struct GroupAnagramsAnim: View {
    let words = ["eat", "tea", "tan", "ate", "nat", "bat"]
    @State private var groups: [String: [String]] = [:]
    @State private var idx = -1
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Group Anagrams", tint: .purple, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    ForEach(words.indices, id: \.self) { i in
                        tile(width: 38, height: 26,
                             bg: i == idx ? .yellow : .purple.opacity(0.4),
                             fg: i == idx ? .black : .white) {
                            Text(words[i]).font(.system(size: 11, weight: .black, design: .monospaced))
                        }
                    }
                }
                Text("ソート文字列をキーにグルーピング")
                    .font(.caption2).foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(groups.sorted(by: { $0.key < $1.key }), id: \.key) { kv in
                        HStack(spacing: 4) {
                            Text("\"\(kv.key)\":")
                                .font(.system(size: 10, weight: .black, design: .monospaced))
                                .foregroundStyle(.purple)
                            ForEach(kv.value.indices, id: \.self) { i in
                                tile(width: 38, height: 22, bg: .purple.opacity(0.55)) {
                                    Text(kv.value[i]).font(.system(size: 10, weight: .heavy, design: .monospaced))
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
        groups = [:]; idx = -1
        for i in words.indices {
            let key = String(words[i].sorted())
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.7) {
                guard t == token else { return }
                withAnimation {
                    idx = i
                    groups[key, default: []].append(words[i])
                }
            }
        }
    }
}

// MARK: - Min Window Substring (sliding window + counts)

struct MinWindowSubstringAnim: View {
    let s = "ADOBECODEBANC"
    let t = "ABC"
    @State private var l = 0
    @State private var r = 0
    @State private var best: (l: Int, r: Int) = (0, -1)
    @State private var counts: [Character: Int] = [:]
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Min Window Substring", tint: .pink, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 2) {
                    ForEach(Array(s.enumerated()), id: \.offset) { i, c in
                        let inW = i >= l && i <= r
                        let inB = best.r >= 0 && i >= best.l && i <= best.r
                        tile(width: 20, height: 24,
                             bg: inW ? .yellow : (inB ? .pink.opacity(0.6) : .white.opacity(0.18)),
                             fg: inW ? .black : .white) {
                            Text(String(c)).font(.system(size: 11, weight: .black, design: .monospaced))
                        }
                    }
                }
                Text("target \"\(t)\"  window=[\(l),\(r)]")
                    .font(.system(.caption2, design: .monospaced)).foregroundStyle(.secondary)
                Text("best = \"\(best.r >= 0 ? String(Array(s)[best.l...best.r]) : "")\"")
                    .font(.caption.weight(.bold)).foregroundStyle(.pink)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        l = 0; r = -1; best = (0, -1); counts = [:]
        let arr = Array(s)
        var need: [Character: Int] = [:]
        for c in self.t { need[c, default: 0] += 1 }
        var window: [Character: Int] = [:]
        var have = 0, missing = need.count
        var ll = 0
        var bestL = 0, bestR = arr.count + 1
        for ri in arr.indices {
            window[arr[ri], default: 0] += 1
            if let n = need[arr[ri]], window[arr[ri]] == n { have += 1 }
            while have == missing {
                if ri - ll < bestR - bestL { bestL = ll; bestR = ri }
                window[arr[ll], default: 0] -= 1
                if let n = need[arr[ll]], window[arr[ll]]! < n { have -= 1 }
                ll += 1
            }
            let curL = ll, curR = ri, snap = window
            let curBest = bestR <= arr.count ? (bestL, bestR) : (0, -1)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(ri) * 0.45) {
                guard t == token else { return }
                withAnimation { l = curL; r = curR; counts = snap; best = curBest }
            }
        }
    }
}
