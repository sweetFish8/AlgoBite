import SwiftUI

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

// MARK: - Min Stack (sync min track)

struct MinStackAnim: View {
    let ops: [(String, Int?)] = [("push", 3), ("push", 5), ("push", 2), ("push", 1),
                                  ("pop", nil), ("getMin", nil), ("pop", nil), ("getMin", nil)]
    @State private var stack: [Int] = []
    @State private var mins: [Int] = []
    @State private var op = ""
    @State private var step = -1
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Min Stack", tint: .green, onReplay: play) {
            HStack(alignment: .bottom, spacing: 20) {
                stackCol("stack", arr: stack, color: .green)
                stackCol("mins", arr: mins, color: .orange)
            }
            VStack(spacing: 2) {
                Text(op).font(.caption.weight(.heavy)).foregroundStyle(.green)
                Text("push 時 min(top, val) も mins に push、pop 時に両方 pop")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func stackCol(_ label: String, arr: [Int], color: Color) -> some View {
        VStack(spacing: 2) {
            ForEach(arr.indices.reversed(), id: \.self) { i in
                tile(width: 38, height: 24,
                     bg: i == arr.count - 1 ? color : color.opacity(0.5)) { Text("\(arr[i])") }
            }
            ForEach(0..<max(0, 4 - arr.count), id: \.self) { _ in
                tile(width: 38, height: 24, bg: color.opacity(0.12), fg: .white.opacity(0.5)) { Text("·") }
            }
            Text(label).font(.caption2.weight(.heavy)).foregroundStyle(color)
        }
    }
    private func play() {
        token += 1; let t = token
        stack = []; mins = []; op = ""; step = -1
        for (k, (a, v)) in ops.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.9) {
                guard t == token else { return }
                withAnimation {
                    step = k
                    if a == "push", let x = v {
                        stack.append(x)
                        mins.append(min(mins.last ?? x, x))
                        op = "push(\(x))"
                    } else if a == "pop" {
                        let p = stack.popLast() ?? 0
                        _ = mins.popLast()
                        op = "pop → \(p)"
                    } else {
                        op = "getMin → \(mins.last ?? 0)"
                    }
                }
            }
        }
    }
}

// MARK: - Valid Parentheses (stack match)

struct ValidParensAnim: View {
    let s: String = "({[]})"
    @State private var idx = -1
    @State private var stack: [Character] = []
    @State private var matched: Bool = false
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Valid Parentheses", tint: .green, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    ForEach(Array(s.enumerated()), id: \.offset) { i, c in
                        tile(width: 26, height: 28,
                             bg: i == idx ? .yellow : (i < idx ? .green.opacity(0.45) : .gray.opacity(0.25)),
                             fg: i == idx ? .black : .white) {
                            Text(String(c)).font(.system(size: 13, weight: .black, design: .monospaced))
                        }
                    }
                }
                HStack(spacing: 4) {
                    Text("stack:").font(.caption2.weight(.black)).foregroundStyle(.green)
                    ForEach(stack.indices, id: \.self) { i in
                        tile(width: 22, height: 22, bg: .green.opacity(0.55)) {
                            Text(String(stack[i])).font(.system(size: 11, weight: .black))
                        }
                    }
                }
                if matched && idx == s.count - 1 {
                    Text("✅ すべて対応 → valid")
                        .font(.caption.weight(.bold)).foregroundStyle(.green)
                }
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        idx = -1; stack = []; matched = false
        let chars = Array(s)
        let pair: [Character: Character] = [")": "(", "}": "{", "]": "["]
        var st: [Character] = []; var ok = true
        for (i, c) in chars.enumerated() {
            let snap = st
            let curOk = ok
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.7) {
                guard t == token else { return }
                withAnimation { idx = i; stack = snap; matched = curOk && i == chars.count - 1 && st.isEmpty }
            }
            if let m = pair[c] {
                if st.last == m { st.removeLast() } else { ok = false }
            } else {
                st.append(c)
            }
        }
        let finalOk = ok && st.isEmpty
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(chars.count) * 0.7) {
            guard t == token else { return }
            withAnimation { idx = chars.count - 1; stack = st; matched = finalOk }
        }
    }
}

// MARK: - Next Greater Element (monotonic stack)

struct NextGreaterAnim: View {
    let nums: [Int] = [2, 1, 3, 2, 5, 4, 6]
    @State private var i = -1
    @State private var stack: [Int] = []  // 値を持つ
    @State private var result: [Int] = []
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Next Greater Element", tint: .purple, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    ForEach(nums.indices, id: \.self) { k in
                        tile(width: 28, height: 26,
                             bg: k == i ? .yellow : .purple.opacity(0.4),
                             fg: k == i ? .black : .white) { Text("\(nums[k])") }
                    }
                }
                HStack(spacing: 4) {
                    Text("stack:").font(.caption2.weight(.black)).foregroundStyle(.purple)
                    ForEach(stack.indices, id: \.self) { k in
                        tile(width: 22, height: 22, bg: .purple.opacity(0.55)) { Text("\(stack[k])") }
                    }
                }
                HStack(spacing: 4) {
                    Text("ans:").font(.caption2.weight(.black)).foregroundStyle(.green)
                    ForEach(result.indices, id: \.self) { k in
                        tile(width: 28, height: 22,
                             bg: result[k] == -1 ? .gray.opacity(0.5) : .green.opacity(0.55)) {
                            Text(result[k] == -1 ? "−" : "\(result[k])")
                        }
                    }
                }
                Text("単調減少 stack に積む → 自分より小さい要素を pop して next = 自分")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        i = -1; stack = []; result = []
        var st: [Int] = []
        var ans: [Int] = Array(repeating: -1, count: nums.count)
        // 後ろから走査して各位置の次に大きい値を求める
        for k in stride(from: nums.count - 1, through: 0, by: -1) {
            while let top = st.last, top <= nums[k] { st.removeLast() }
            ans[k] = st.last ?? -1
            st.append(nums[k])
        }
        // 表示は左から
        var seen: [Int] = []
        for k in nums.indices {
            seen.append(ans[k])
            let snap = seen
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.7) {
                guard t == token else { return }
                withAnimation { i = k; result = snap; stack = Array(seen.prefix(k + 1)) }
            }
        }
    }
}

// MARK: - Largest Rectangle in Histogram

struct LargestRectAnim: View {
    let h: [Int] = [2, 1, 5, 6, 2, 3]
    @State private var idx = -1
    @State private var best: (left: Int, right: Int, height: Int) = (0, 0, 0)
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Largest Rectangle in Histogram", tint: .red, onReplay: play) {
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(h.indices, id: \.self) { i in
                    let inBest = i >= best.left && i <= best.right
                    ZStack(alignment: .bottom) {
                        if inBest && best.height > 0 {
                            Rectangle().fill(Color.red.opacity(0.45))
                                .frame(width: 30, height: CGFloat(best.height) * 18)
                        }
                        Rectangle()
                            .fill(i == idx ? .yellow : .gray.opacity(0.65))
                            .frame(width: 26, height: CGFloat(h[i]) * 18)
                    }
                }
            }
            Text("最大面積 = \(best.height) × \(max(0, best.right - best.left + 1)) = \(best.height * max(0, best.right - best.left + 1))")
                .font(.caption.weight(.bold)).foregroundStyle(.red)
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        idx = -1; best = (0, 0, 0)
        // 全 i,j 走査で最大長方形を計算 (デモ用に明示的に表示)
        var seq: [(Int, Int, Int)] = []   // (left, right, height)
        for i in h.indices {
            var minH = h[i]
            for j in i..<h.count {
                minH = min(minH, h[j])
                seq.append((i, j, minH))
            }
        }
        seq.sort { $0.2 * ($0.1 - $0.0 + 1) < $1.2 * ($1.1 - $1.0 + 1) }
        // ランダムにいくつかピックして "拡大していく" 見た目に
        let highlights = seq.suffix(8)
        for (k, b) in highlights.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(k) * 0.55) {
                guard t == token else { return }
                withAnimation { idx = b.1; best = (b.0, b.1, b.2) }
            }
        }
    }
}

// MARK: - Sliding Window Maximum (deque)

struct SlidingWindowMaxAnim: View {
    let nums = [1, 3, -1, -3, 5, 3, 6, 7]
    let k = 3
    @State private var idx = -1
    @State private var dq: [Int] = []   // indices, decreasing by nums[idx]
    @State private var maxes: [Int] = []
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Sliding Window Max (k=\(k))", tint: .red, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 3) {
                    ForEach(nums.indices, id: \.self) { i in
                        let inWindow = i > idx - k && i <= idx
                        tile(width: 28, height: 28,
                             bg: i == idx ? .yellow :
                                  (inWindow ? .red.opacity(0.6) : .red.opacity(0.2)),
                             fg: i == idx ? .black : .white) { Text("\(nums[i])") }
                    }
                }
                HStack(spacing: 4) {
                    Text("deque:").font(.caption2.weight(.black)).foregroundStyle(.red)
                    ForEach(dq.indices, id: \.self) { i in
                        tile(width: 28, height: 22, bg: .red.opacity(0.55)) {
                            Text("\(nums[dq[i]])")
                        }
                    }
                }
                HStack(spacing: 4) {
                    Text("maxes:").font(.caption2.weight(.black)).foregroundStyle(.green)
                    ForEach(maxes.indices, id: \.self) { i in
                        tile(width: 28, height: 22, bg: .green.opacity(0.6)) { Text("\(maxes[i])") }
                    }
                }
                Text("先頭から古い index を pop、末尾から小さい値を pop")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        idx = -1; dq = []; maxes = []
        var d: [Int] = []; var ms: [Int] = []
        for i in nums.indices {
            while let f = d.first, f <= i - k { d.removeFirst() }
            while let b = d.last, nums[b] < nums[i] { d.removeLast() }
            d.append(i)
            if i >= k - 1 { ms.append(nums[d[0]]) }
            let curD = d, curM = ms
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.8) {
                guard t == token else { return }
                withAnimation { idx = i; dq = curD; maxes = curM }
            }
        }
    }
}
