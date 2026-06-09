import SwiftUI

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
    // 問題例 (n=10 → [2,3,5,7]) に合わせる
    let n = 10
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

// MARK: - Floyd's cycle detection (visualized linearly)

struct FloydAnim: View {
    @State private var slow = 0
    @State private var fast = 0
    @State private var caption = ""
    @State private var token = 0
    // 問題例 (nums=[1,3,4,2,2] → 重複 2) に合わせる
    let arr = [1, 3, 4, 2, 2]

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

// MARK: - Single Number (XOR cascade)

struct SingleNumberAnim: View {
    let nums = [4, 1, 2, 1, 2]
    @State private var i = -1
    @State private var xor = 0
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Single Number (XOR)", tint: .indigo, onReplay: play) {
            HStack(spacing: 5) {
                ForEach(nums.indices, id: \.self) { idx in
                    tile(width: 32, height: 32,
                         bg: idx == i ? .yellow : .indigo.opacity(0.4),
                         fg: idx == i ? .black : .white) { Text("\(nums[idx])") }
                }
            }
            VStack(spacing: 3) {
                HStack(spacing: 6) {
                    Text("xor →").font(.system(.caption, design: .monospaced))
                    Text("\(xor)")
                        .font(.system(.title3, design: .monospaced).weight(.black))
                        .foregroundStyle(.indigo)
                }
                Text("a ^ a = 0, 0 ^ b = b なので重複は消えて単独だけ残る")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        i = -1; xor = 0
        var x = 0
        for (k, v) in nums.enumerated() {
            x ^= v
            let curX = x
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(k) * 0.7) {
                guard t == token else { return }
                withAnimation { i = k; xor = curX }
            }
        }
    }
}

// MARK: - Reverse Bits

struct ReverseBitsAnim: View {
    let n: UInt32 = 0b0000_0010_1001_0100_0001_1110_1001_1100
    @State private var step = -1
    @State private var rev: UInt32 = 0
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Reverse Bits (32bit)", tint: .blue, onReplay: play) {
            VStack(alignment: .leading, spacing: 4) {
                bitRow("in", value: n, highlight: step, fromLeft: true)
                bitRow("out", value: rev, highlight: 31 - step, fromLeft: false)
                Text("各 i について out の (31-i) 番ビットに in の i 番をコピー")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func bitRow(_ label: String, value: UInt32, highlight: Int, fromLeft: Bool) -> some View {
        HStack(spacing: 1) {
            Text(label).font(.system(size: 9, weight: .black, design: .monospaced))
                .frame(width: 26, alignment: .leading).foregroundStyle(.blue)
            ForEach(0..<32, id: \.self) { i in
                let bitIdx = fromLeft ? (31 - i) : (31 - i)
                let on = ((value >> bitIdx) & 1) == 1
                let isHi = i == (fromLeft ? (31 - highlight) : highlight)
                Rectangle()
                    .fill(isHi ? .yellow : (on ? .blue : .gray.opacity(0.35)))
                    .frame(width: 7, height: 16)
            }
        }
    }
    private func play() {
        token += 1; let t = token
        step = -1; rev = 0
        var r: UInt32 = 0
        for i in 0..<32 {
            let bit = (n >> i) & 1
            r |= bit << (31 - i)
            let curR = r
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + Double(i) * 0.12) {
                guard t == token else { return }
                withAnimation { step = i; rev = curR }
            }
        }
    }
}

// MARK: - Power of Two

struct PowerOfTwoAnim: View {
    // 問題例 (n=16 → True / n=6 → False) を含む候補列
    let candidates = [16, 6, 1, 2, 4, 8, 17, 32, 100]
    @State private var idx = -1
    @State private var results: [(Int, Bool)] = []
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Power of Two: n & (n-1) == 0 ?", tint: .blue, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    ForEach(candidates.indices, id: \.self) { i in
                        tile(width: 32, height: 26,
                             bg: i == idx ? .yellow : .blue.opacity(0.4),
                             fg: i == idx ? .black : .white) { Text("\(candidates[i])") }
                    }
                }
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(results.indices, id: \.self) { i in
                        let r = results[i]
                        HStack(spacing: 4) {
                            Text(r.1 ? "✓" : "×")
                                .font(.caption.weight(.heavy))
                                .foregroundStyle(r.1 ? .green : .red)
                            Text("\(r.0) (\(String(r.0, radix: 2)))")
                                .font(.system(size: 10, weight: .heavy, design: .monospaced))
                            Text("→ \(r.0) & \(r.0 - 1) = \(r.0 & (r.0 - 1))")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        idx = -1; results = []
        for (i, n) in candidates.enumerated() {
            let isPow = n > 0 && (n & (n - 1)) == 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.7) {
                guard t == token else { return }
                withAnimation { idx = i; results.append((n, isPow)) }
            }
        }
    }
}

// MARK: - Power: Fast Exponentiation (binary expand)

struct FastPowBinaryAnim: View {
    // 問題例 (fast_pow(2, 10, 1000) → 24) に合わせる
    let base: Double = 2
    let exp: Int = 10
    let mod: Double = 1000
    @State private var step = -1
    @State private var bits: [Int] = []
    @State private var partials: [(Double, Bool)] = []   // (val, contributed)
    @State private var result: Double = 1
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Fast Pow: \(Int(base))^\(exp) % \(Int(mod))", tint: .yellow, onReplay: play) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Text("\(exp) =").font(.system(size: 10, weight: .black, design: .monospaced))
                    ForEach(bits.indices.reversed(), id: \.self) { i in
                        let b = bits[i]
                        tile(width: 20, height: 22,
                             bg: i == step ? .red : (b == 1 ? .green.opacity(0.6) : .gray.opacity(0.3))) {
                            Text("\(b)").font(.system(size: 11, weight: .black, design: .monospaced))
                        }
                    }
                }
                HStack(spacing: 4) {
                    ForEach(partials.indices, id: \.self) { i in
                        let p = partials[i]
                        tile(width: 38, height: 24,
                             bg: p.1 ? .yellow : .gray.opacity(0.3)) {
                            Text(String(format: "%.0f", p.0))
                                .font(.system(size: 9, weight: .heavy, design: .monospaced))
                        }
                    }
                }
                Text("result = " + String(format: "%.0f", result))
                    .font(.caption.weight(.bold)).foregroundStyle(.yellow)
                Text("bit が 1 のところだけ部分積を掛けて mod \(Int(mod)) を取る")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .onAppear { play() }
    }
    private func play() {
        token += 1; let t = token
        bits = []; partials = []; result = 1; step = -1
        var b: [Int] = []
        var e = exp
        while e > 0 { b.append(e & 1); e >>= 1 }
        bits = b
        var p: [(Double, Bool)] = []
        var cur: Double = base.truncatingRemainder(dividingBy: mod)
        var res: Double = 1
        for i in b.indices {
            let contribute = b[i] == 1
            if contribute { res = (res * cur).truncatingRemainder(dividingBy: mod) }
            p.append((cur, contribute))
            let snap = p; let curRes = res
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(i) * 0.8) {
                guard t == token else { return }
                withAnimation { step = i; partials = snap; result = curRes }
            }
            cur = (cur * cur).truncatingRemainder(dividingBy: mod)
        }
    }
}
