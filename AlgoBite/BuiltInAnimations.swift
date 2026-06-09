import SwiftUI

// MARK: - Binary Search Animation

struct BinarySearchAnim: View {
    let nums: [Int]
    let target: Int
    let caption: String

    init(nums: [Int] = [-1, 0, 3, 5, 9, 12, 14, 18, 22],
         target: Int = 9,
         caption: String = "ソート済 nums の中から target を探す") {
        self.nums = nums
        self.target = target
        self.caption = caption
    }

    @State private var step = 0
    @State private var found = false
    @State private var token = 0

    var steps: [(l: Int, r: Int, mid: Int)] {
        var s: [(Int, Int, Int)] = []
        var l = 0, r = nums.count - 1
        while l <= r {
            let m = (l + r) / 2
            s.append((l, r, m))
            if nums[m] == target { break }
            if nums[m] < target { l = m + 1 } else { r = m - 1 }
        }
        return s
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Text("🔍").font(.title3)
                Text("二分探索の動き")
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(Color(red: 0.05, green: 0.46, blue: 0.55))   // teal
            }
            Text(caption)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color(red: 0.42, green: 0.42, blue: 0.46))
            Text("target = \(target)")
                .font(.caption.weight(.heavy))
                .foregroundStyle(Color(red: 0.42, green: 0.42, blue: 0.46))

            HStack(spacing: 5) {
                ForEach(nums.indices, id: \.self) { i in
                    cell(i)
                }
            }

            if step < steps.count {
                let s = steps[step]
                Text("l=\(s.l)  mid=\(s.mid) (nums[mid]=\(nums[s.mid]))  r=\(s.r)")
                    .font(.system(.caption2, design: .monospaced).weight(.semibold))
                    .foregroundStyle(Color(red: 0.42, green: 0.42, blue: 0.46))
            } else if found {
                Text("🎯 見つかった！")
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(Color(red: 0.08, green: 0.32, blue: 0.18))
            }

            Button { play() } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                    Text("もう一度")
                }
                .font(.caption.weight(.heavy))
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(Color(red: 0.05, green: 0.71, blue: 0.85), in: Capsule())   // teal
                .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.93, green: 1.00, blue: 1.00),                          // #ECFEFF
                    in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14)
            .stroke(Color(red: 0.65, green: 0.95, blue: 0.97), lineWidth: 1.2))
        .onAppear { play() }
    }

    private func cell(_ i: Int) -> some View {
        let cur = step < steps.count ? steps[step] : steps.last!
        let inRange = i >= cur.l && i <= cur.r
        let isMid = i == cur.mid && step < steps.count
        let isFound = found && i == cur.mid

        let bg: Color
        if isFound { bg = Color(red: 0.13, green: 0.77, blue: 0.37) }      // green
        else if isMid { bg = Color(red: 1.00, green: 0.78, blue: 0.04) }   // amber
        else if inRange { bg = Color(red: 0.75, green: 0.94, blue: 0.97) } // light teal
        else { bg = Color(red: 0.95, green: 0.95, blue: 0.95) }

        let fg: Color = (isMid || isFound) ? .white : Color(red: 0.17, green: 0.18, blue: 0.20)

        return Text("\(nums[i])")
            .font(.system(size: 12, weight: .black, design: .monospaced))
            .frame(width: 30, height: 30)
            .background(bg, in: RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black.opacity(0.08), lineWidth: 0.8))
            .foregroundStyle(fg)
            .scaleEffect(isMid ? 1.18 : 1.0)
            .shadow(color: isMid ? Color(red: 1.00, green: 0.78, blue: 0.04).opacity(0.4)
                                : .clear,
                    radius: 4, y: 1)
            .animation(.spring(response: 0.35), value: step)
            .animation(.spring(response: 0.35), value: found)
    }

    private func play() {
        token += 1
        let t = token
        step = 0
        found = false
        for i in 0..<steps.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.9 + 0.4) {
                guard t == token else { return }
                withAnimation { step = i }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(steps.count) * 0.9 + 0.3) {
            guard t == token else { return }
            withAnimation { found = true }
        }
    }
}

// MARK: - Rotated Binary Search Animation

struct RotatedBinarySearchAnim: View {
    private let nums = [4, 5, 6, 7, 0, 1, 2]
    private let target = 0
    @State private var step = 0
    @State private var found = false
    @State private var token = 0

    private var steps: [(l: Int, r: Int, mid: Int)] {
        var result: [(Int, Int, Int)] = []
        var l = 0
        var r = nums.count - 1
        while l <= r {
            let mid = (l + r) / 2
            result.append((l, r, mid))
            if nums[mid] == target { break }
            if nums[l] <= nums[mid] {
                if nums[l] <= target && target < nums[mid] {
                    r = mid - 1
                } else {
                    l = mid + 1
                }
            } else if nums[mid] < target && target <= nums[r] {
                l = mid + 1
            } else {
                r = mid - 1
            }
        }
        return result
    }

    var body: some View {
        AnimFrame(title: "Rotated Binary Search", tint: .teal, onReplay: play) {
            let current = steps[min(step, steps.count - 1)]
            HStack(spacing: 5) {
                ForEach(nums.indices, id: \.self) { index in
                    let isMid = index == current.mid
                    let isFound = found && isMid
                    tile(width: 30, height: 30,
                         bg: isFound ? .green :
                             isMid ? .yellow :
                             (current.l...current.r).contains(index) ? .teal.opacity(0.35) : .gray.opacity(0.15),
                         fg: isMid && !isFound ? .black : .white) {
                        Text("\(nums[index])")
                    }
                    .scaleEffect(isMid ? 1.15 : 1)
                    .animation(.spring(response: 0.35), value: step)
                }
            }
            Text(found
                 ? "index 4 で target=0 を発見"
                 : "片側のソート済み範囲を判定して探索側を絞る")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .onAppear { play() }
    }

    private func play() {
        token += 1
        let currentToken = token
        step = 0
        found = false
        for index in steps.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(index) * 0.8) {
                guard currentToken == token else { return }
                withAnimation { step = index }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(steps.count) * 0.8) {
            guard currentToken == token else { return }
            withAnimation { found = true }
        }
    }
}

// MARK: - First and Last Position Animation

struct SearchRangeAnim: View {
    private let nums = [5, 7, 7, 8, 8, 10]
    private let target = 8
    private let visits = [2, 4, 3, 2, 4, 5]
    @State private var visitCount = 0
    @State private var result: [Int] = []
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "First / Last Position", tint: .purple, onReplay: play) {
            HStack(spacing: 5) {
                ForEach(nums.indices, id: \.self) { index in
                    let isCurrent = visitCount > 0 && visits[visitCount - 1] == index
                    let isAnswer = result.contains(index)
                    tile(width: 30, height: 30,
                         bg: isAnswer ? .green.opacity(0.75) :
                             isCurrent ? .yellow : .purple.opacity(0.3),
                         fg: isCurrent && !isAnswer ? .black : .white) {
                        Text("\(nums[index])")
                    }
                    .scaleEffect(isCurrent ? 1.15 : 1)
                    .animation(.spring(response: 0.35), value: visitCount)
                }
            }
            Text(result.count == 2
                 ? "target=8 の範囲は [\(result[0]), \(result[1])]"
                 : visitCount <= 3 ? "lower bound を二分探索" : "upper bound を二分探索")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .onAppear { play() }
    }

    private func play() {
        token += 1
        let currentToken = token
        visitCount = 0
        result = []
        for count in 1...visits.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35 + Double(count - 1) * 0.55) {
                guard currentToken == token else { return }
                withAnimation {
                    visitCount = count
                    if count == 3 { result = [3] }
                    if count == visits.count { result = [3, 4] }
                }
            }
        }
    }
}

// MARK: - Median of Two Sorted Arrays Animation

struct MedianTwoArraysAnim: View {
    private let a = [1, 3]
    private let b = [2]
    @State private var stage = 0
    @State private var token = 0

    var body: some View {
        AnimFrame(title: "Median Partition", tint: .indigo, onReplay: play) {
            VStack(alignment: .leading, spacing: 5) {
                arrayRow(label: "A", values: a)
                arrayRow(label: "B", values: b)
                Text(caption)
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(stage == 2 ? .green : .secondary)
            }
        }
        .onAppear { play() }
    }

    private var caption: String {
        switch stage {
        case 0: return "入力 A=[1,3], B=[2]。短い B を内部の A に交換"
        case 1: return "交換後 A=[2], B=[1,3]: i=0, j=2 は Bl=3 > Ar=2"
        default: return "i=1, j=1 で分割成功 → median = 2.0"
        }
    }

    private func arrayRow(label: String, values: [Int]) -> some View {
        HStack(spacing: 5) {
            Text(label + ":")
                .font(.caption2.weight(.black))
                .foregroundStyle(.indigo)
            ForEach(values.indices, id: \.self) { index in
                tile(width: 30, height: 28,
                     bg: stage == 2 && values[index] == 2 ? .green.opacity(0.75) : .indigo.opacity(0.35)) {
                    Text("\(values[index])")
                }
            }
        }
    }

    private func play() {
        token += 1
        let currentToken = token
        stage = 0
        for nextStage in 1...2 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6 + Double(nextStage - 1) * 0.9) {
                guard currentToken == token else { return }
                withAnimation { stage = nextStage }
            }
        }
    }
}

// MARK: - Two Pointer (Palindrome) Animation

struct TwoPointerAnim: View {
    let word: String
    @State private var l = 0
    @State private var r = 0
    @State private var done = false
    @State private var token = 0

    var chars: [Character] { Array(word) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Text("👉👈").font(.title3)
                Text("Two Pointers")
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(Color(red: 0.55, green: 0.27, blue: 0.68))   // purple
            }
            Text("\"\(word)\" を両端から比較")
                .font(.caption.weight(.heavy))
                .foregroundStyle(Color(red: 0.42, green: 0.42, blue: 0.46))

            HStack(spacing: 5) {
                ForEach(chars.indices, id: \.self) { i in
                    cell(i)
                }
            }

            if done {
                Text("🎈 回文だった！")
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(Color(red: 0.08, green: 0.32, blue: 0.18))
            } else {
                Text("l=\(l)  r=\(r)")
                    .font(.system(.caption2, design: .monospaced).weight(.semibold))
                    .foregroundStyle(Color(red: 0.42, green: 0.42, blue: 0.46))
            }

            Button { play() } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                    Text("もう一度")
                }
                .font(.caption.weight(.heavy))
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(Color(red: 0.55, green: 0.27, blue: 0.68), in: Capsule())
                .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.98, green: 0.96, blue: 1.00),
                    in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14)
            .stroke(Color(red: 0.87, green: 0.84, blue: 0.99), lineWidth: 1.2))
        .onAppear { play() }
    }

    private func cell(_ i: Int) -> some View {
        let isL = i == l && !done
        let isR = i == r && !done
        let visited = (i < l) || (i > r) || done

        let bg: Color
        if isL || isR { bg = Color(red: 1.00, green: 0.78, blue: 0.04) }       // amber
        else if visited { bg = Color(red: 0.73, green: 0.97, blue: 0.82) }     // light green
        else { bg = Color(red: 0.96, green: 0.93, blue: 1.00) }                // pastel purple

        let fg: Color = (isL || isR) ? .white : Color(red: 0.17, green: 0.18, blue: 0.20)

        return VStack(spacing: 2) {
            Text(String(chars[i]))
                .font(.system(size: 14, weight: .black, design: .monospaced))
                .frame(width: 28, height: 28)
                .background(bg, in: RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.black.opacity(0.08), lineWidth: 0.8))
                .foregroundStyle(fg)
                .scaleEffect((isL || isR) ? 1.18 : 1.0)
                .shadow(color: (isL || isR) ? Color(red: 1.00, green: 0.78, blue: 0.04).opacity(0.4)
                                            : .clear,
                        radius: 4, y: 1)
            Text(isL ? "l" : (isR ? "r" : " "))
                .font(.system(size: 10, weight: .black, design: .monospaced))
                .foregroundStyle(Color(red: 0.84, green: 0.46, blue: 0.05))
        }
        .animation(.spring(response: 0.3), value: l)
        .animation(.spring(response: 0.3), value: r)
    }

    private func play() {
        token += 1
        let t = token
        l = 0
        r = chars.count - 1
        done = false
        var step = 0
        while l + step < r - step {
            let s = step
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(s + 1) * 0.8) {
                guard t == token else { return }
                withAnimation { l += 1; r -= 1 }
            }
            step += 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(step + 1) * 0.8 + 0.3) {
            guard t == token else { return }
            withAnimation { done = true }
        }
    }
}

// MARK: - Anagram Animation

struct AnagramAnim: View {
    let a: String
    let b: String
    @State private var sortedA: [Character] = []
    @State private var sortedB: [Character] = []
    @State private var matched = false
    @State private var token = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Text("🔤").font(.title3)
                Text("ソートで比較")
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(Color(red: 0.04, green: 0.58, blue: 0.50))   // mint
            }

            row(label: "A", chars: sortedA.isEmpty ? Array(a) : sortedA)
            row(label: "B", chars: sortedB.isEmpty ? Array(b) : sortedB)

            if matched {
                Text("🎈 アナグラムだった！")
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(Color(red: 0.08, green: 0.32, blue: 0.18))
            }

            Button { play() } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                    Text("もう一度")
                }
                .font(.caption.weight(.heavy))
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(Color(red: 0.04, green: 0.72, blue: 0.61), in: Capsule())
                .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.93, green: 1.00, blue: 0.98),
                    in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14)
            .stroke(Color(red: 0.65, green: 0.95, blue: 0.86), lineWidth: 1.2))
        .onAppear { play() }
    }

    @ViewBuilder
    private func row(label: String, chars: [Character]) -> some View {
        HStack(spacing: 5) {
            Text(label)
                .font(.system(size: 12, weight: .black, design: .monospaced))
                .foregroundStyle(Color(red: 0.04, green: 0.58, blue: 0.50))
                .frame(width: 16)
            ForEach(chars.indices, id: \.self) { i in
                Text(String(chars[i]))
                    .font(.system(size: 13, weight: .black, design: .monospaced))
                    .frame(width: 24, height: 24)
                    .background(matched
                                ? Color(red: 0.73, green: 0.97, blue: 0.82)
                                : Color(red: 0.65, green: 0.95, blue: 0.86),
                                in: RoundedRectangle(cornerRadius: 6))
                    .overlay(RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.black.opacity(0.08), lineWidth: 0.8))
                    .foregroundStyle(Color(red: 0.04, green: 0.34, blue: 0.30))
            }
        }
    }

    private func play() {
        token += 1
        let t = token
        sortedA = []
        sortedB = []
        matched = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            guard t == token else { return }
            withAnimation { sortedA = Array(a).sorted() }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            guard t == token else { return }
            withAnimation { sortedB = Array(b).sorted() }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
            guard t == token else { return }
            withAnimation { matched = (Array(a).sorted() == Array(b).sorted()) }
        }
    }
}

#Preview {
    ContentView()
}

// MARK: - Reorder Quiz (LCS判定の並べ替え練習)
