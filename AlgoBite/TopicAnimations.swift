import SwiftUI

// MARK: - Shared chrome

struct AnimFrame<Content: View>: View {
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

func tile<S: View>(width: CGFloat = 26, height: CGFloat = 26, bg: Color, fg: Color = .white, @ViewBuilder _ content: () -> S) -> some View {
    content()
        .font(.system(size: 11, weight: .bold, design: .monospaced))
        .frame(width: width, height: height)
        .background(bg, in: RoundedRectangle(cornerRadius: 5))
        .foregroundStyle(fg)
}


// MARK: - Tree helper (visualize a 7-node BT and walk)

struct TreeNodeView: View {
    let value: String
    let bg: Color
    let fg: Color
    var body: some View {
        ZStack {
            Circle().fill(bg).frame(width: 28, height: 28)
            Text(value).font(.system(size: 11, weight: .black)).foregroundStyle(fg)
        }
    }
}

struct LeveledTree: View {
    let nodes: [Int]   // 7 nodes, level order
    let highlightVisited: [Int]
    let current: Int?
    let palette: (visited: Color, current: Color, base: Color)
    var body: some View {
        VStack(spacing: 8) {
            // root
            row(indices: [0])
            row(indices: [1, 2])
            row(indices: [3, 4, 5, 6])
        }
    }
    private func row(indices: [Int]) -> some View {
        HStack(spacing: 18) {
            ForEach(indices, id: \.self) { i in
                let v = i < nodes.count ? nodes[i] : 0
                let visited = highlightVisited.contains(v)
                let isCur = current == v
                TreeNodeView(value: "\(v)",
                             bg: isCur ? palette.current : (visited ? palette.visited : palette.base),
                             fg: .white)
            }
        }
    }
}


// MARK: - Topic dispatcher

@ViewBuilder
func topicAnimation(for problem: PuzzleProblem) -> some View {
    switch problem.id {
    // Binary search variants — それぞれ違う配列と target で動かす
    case "binary-search":
        BinarySearchAnim(nums: [1, 3, 5, 7, 9, 11, 13],
                         target: 11,
                         caption: "ソート済の中から 11 を探す")
    case "search-rotated":
        BinarySearchAnim(nums: [6, 7, 8, 1, 2, 3, 4, 5],
                         target: 3,
                         caption: "回転済の配列から 3 を探す (片側がソート済)")
    case "first-last-pos":
        BinarySearchAnim(nums: [1, 2, 2, 2, 3, 4, 5],
                         target: 2,
                         caption: "最初/最後の 2 を求める (lower / upper bound)")
    case "median-two-arrays":
        BinarySearchAnim(nums: [1, 3, 5, 8, 10, 14, 17],
                         target: 8,
                         caption: "2つの配列をマージした中央値の位置を二分探索")
    // Two pointers / strings
    case "palindrome-check": TwoPointerAnim(word: "racecar")
    case "reverse-string": TwoPointerAnim(word: "hello")
    case "container-water": ContainerWaterAnim()
    case "trapping-rain":   TrappingRainAnim()
    // Anagram
    case "anagram-check":  AnagramCheckAnim()
    case "group-anagrams": GroupAnagramsAnim()
    // Sorting — 専用化したものから順次置換
    case "bubble-sort":     BubbleSortPassAnim()
    case "insertion-sort":  InsertionSortAnim()
    case "selection-sort":  SelectionSortAnim()
    case "counting-sort":   CountingSortAnim()
    case "quicksort":       QuicksortAnim()
    case "merge-sort":      MergeSortAnim()
    case "dutch-flag":      DutchFlagAnim()
    case "rotate-array":    RotateArrayAnim()
    case "merge-intervals": MergeIntervalsAnim()
    // Stack — 専用 SwiftUI に置換
    case "valid-parentheses":   ValidParensAnim()
    case "min-stack":            MinStackAnim()
    case "next-greater":         NextGreaterAnim()
    case "largest-rectangle":    LargestRectAnim()
    case "longest-valid-parens": LongestValidParensAnim()
    // Linked list — 各々 専用の SwiftUI 視覚化に置換
    case "reverse-linked-list": ReverseLinkedListAnim()
    case "merge-two-lists":     MergeTwoListsAnim()
    case "middle-ll":           MiddleOfLLAnim()
    case "detect-cycle":        DetectCycleFloydAnim()
    case "add-two-numbers":     AddTwoNumbersAnim()
    case "intersection-ll":     IntersectionLLAnim()
    // Sliding window
    case "longest-substring": LongestSubstringAnim()
    case "min-window-substring": MinWindowSubstringAnim()
    case "sliding-window-max":   SlidingWindowMaxAnim()
    // BFS / DFS / Graph — それぞれ違うグリッド
    case "bfs":           BFSGridCustomAnim()
    case "dfs-iterative": DFSIterativeAnim()
    case "num-islands":   NumIslandsAnim()
    case "level-order":
        TreeTraversalAnim(order: .level, nodes: [3,9,20,1,2,15,7],
                          subtitle: "BFS で同じ深さをまとめて出力")
    case "topo-sort":       TopologicalSortAnim()
    case "course-schedule": TopologicalSortAnim()
    case "dijkstra":        DijkstraAnim()
    case "union-find": UnionFindMergeAnim()
    case "kruskal": KruskalAnim()
    // Tree — それぞれ違う木の形と副題で動かす
    case "inorder-iter":         InorderIterativeAnim()
    case "validate-bst":         ValidateBSTAnim()
    case "kth-smallest-bst":     KthSmallestBSTAnim()
    case "lca-bt":               LCAofBTAnim()
    case "lca-bst":              LCAofBSTAnim()
    case "flatten-bt":           FlattenBTAnim()
    case "build-tree-post":      BuildTreePostAnim()
    case "max-depth-bt":         MaxDepthBTAnim()
    case "balanced-bt":          BalancedBTAnim()
    case "diameter-bt":          DiameterBTAnim()
    case "path-sum":             PathSumAnim()
    case "invert-bt":            InvertTreeAnim()
    case "symmetric-tree":       SymmetricTreeAnim()
    case "serialize-bt":         SerializeBTAnim()
    // DP
    case "fibonacci-memo": FibMemoAnim()
    case "house-robber": HouseRobberAnim()
    case "lcs":          LCSAnim()
    case "lis":          LISAnim()
    case "knapsack":     KnapsackAnim()
    case "unique-paths": UniquePathsAnim()
    case "edit-distance": EditDistanceAnim()
    case "min-path-sum": MinPathSumAnim()
    case "decode-ways": DecodeWaysAnim()
    case "word-break": WordBreakAnim()
    case "regex-matching":    RegexMatchAnim()
    case "wildcard-matching": WildcardMatchAnim()
    case "max-subarray": MaxSubarrayKadaneAnim()
    case "count-bits": CountBitsAnim()
    // Heap
    case "kth-largest": KthLargestAnim()
    case "top-k-freq": TopKFrequentAnim()
    case "meeting-rooms": MeetingRoomsAnim()
    // Bit
    case "single-number": SingleNumberAnim()
    case "power-of-two":  PowerOfTwoAnim()
    case "reverse-bits":  ReverseBitsAnim()
    // Backtracking
    case "combinations": CombinationsAnim()
    case "subsets":      SubsetsAnim()
    case "permutations": PermutationsTreeAnim()
    case "n-queens":     NQueensAnim()
    case "word-search":  WordSearchAnim()
    // Trie
    case "trie-insert": TrieInsertAnim()
    case "trie-search": TrieSearchAnim()
    // Math
    case "gcd": GCDAnim()
    case "fast-pow": FastPowBinaryAnim()
    case "sieve": SieveAnim()
    // Floyd's cycle (Array variant)
    case "find-duplicate": FloydAnim()
    // 追加マッピング (Phase B: 専用アニメ)
    case "longest-palindrome":      LongestPalindromeAnim()
    case "roman-to-int":            RomanToIntAnim()
    case "product-except-self":     ProductExceptSelfAnim()
    case "kmp-lps":                 KMPFailureAnim()
    case "jump-game":               JumpGameAnim(nums: [2, 3, 1, 1, 4], countMode: false)
    case "jump-game-ii":            JumpGameAnim(nums: [2, 3, 1, 1, 4], countMode: true)
    case "buy-sell-stock":          BuySellStockAnim()
    case "spiral-matrix":           SpiralMatrixAnim()
    case "two-sum":                 TwoSumAnim()
    case "lru-cache":               LRUCacheAnim()
    case "climbing-stairs":         ClimbingStairsAnim()
    case "coin-change":             CoinChangeAnim()
    case "pascals-triangle":        PascalsTriangleAnim()
    // Queue 3 問
    case "queue-two-stacks":        TwoStacksQueueAnim()
    case "queue-bfs-shortest":      GridSearchAnim(kind: .bfs,
                                                   grid: [[1,1,1,0,1],[0,1,0,0,1],[0,1,1,1,1],[0,0,0,0,1]],
                                                   subtitle: "deque で最短経路を探す")
    case "queue-circular":          CircularQueueAnim()
    // 上にどれもマッチしなければ、topic 文字列で fallback (TopicIllustration と同じ判定)
    default:
        topicAnimationFallback(topic: problem.topic)
    }
}

/// topic キーワードに応じた汎用アニメ。id 単位のマッピングに漏れた問題のため。
/// 英語 (PuzzleProblem.topic) と日本語 (ReorderQuiz.topic) 両方のキーワードに対応。
@ViewBuilder
func topicAnimationFallback(topic: String) -> some View {
    let t = topic.lowercased()
    if t.contains("two pointer") || t.contains("2 ポインタ") {
        TwoPointerAnim(word: "hello")
    } else if t.contains("binary search") || t.contains("二分探索") {
        BinarySearchAnim()
    } else if t.contains("merge sort") || t.contains("マージソート") {
        SortingAnim(kind: .merge)
    } else if t.contains("quick") || t.contains("クイックソート") {
        SortingAnim(kind: .quick)
    } else if t.contains("insertion") || t.contains("挿入ソート") {
        SortingAnim(kind: .insertion)
    } else if t.contains("bubble") || t.contains("バブルソート") {
        SortingAnim(kind: .bubble)
    } else if t.contains("selection") || t.contains("選択ソート") {
        SortingAnim(kind: .selection)
    } else if t.contains("counting") || t.contains("counting sort") {
        SortingAnim(kind: .counting)
    } else if t.contains("sort") || t.contains("ソート") {
        SortingAnim(kind: .bubble)
    } else if t.contains("hash") || t.contains("ハッシュ") {
        DPTableAnim(kind: .fib)
    } else if t.contains("stack") || t.contains("スタック") {
        StackAnim(input: ["1","2","3"], kind: .parens)
    } else if t.contains("queue") || t.contains("キュー") || t.contains("デック") {
        GridSearchAnim(kind: .bfs)
    } else if t.contains("linked list") || t.contains("リンクリスト") || t.contains("連結リスト") {
        LinkedListAnim(kind: .reverse)
    } else if t.contains("trie") {
        TrieAnim(kind: .insert)
    } else if t.contains("tree") || t.contains("bst") || t.contains("木") {
        TreeTraversalAnim(order: .inorder)
    } else if t.contains("backtrack") || t.contains("バックトラック") || t.contains("順列") {
        // backtrack / bit / sliding は graph(dfs) や dp より先に判定する
        // ("Backtracking / DFS" が graph に、"Bit ... / DP" が dp に誤マッチするのを防ぐ)
        BacktrackingAnim(kind: .combinations)
    } else if t.contains("bit") || t.contains("ビット") {
        BitAnim(kind: .singleNumber)
    } else if t.contains("sliding") || t.contains("スライディング") {
        SlidingWindowAnim(s: "abcabc", initialWidth: 1)
    } else if t.contains("dijkstra") || t.contains("ダイクストラ") {
        GridSearchAnim(kind: .bfs)
    } else if t.contains("graph") || t.contains("bfs") || t.contains("dfs") || t.contains("グラフ") {
        GridSearchAnim(kind: .bfs)
    } else if t.contains("dp") || t.contains("dynamic") || t.contains("メモ化") || t.contains("lis") {
        DPTableAnim(kind: .fib)
    } else if t.contains("greedy") || t.contains("貪欲") {
        SortingAnim(kind: .selection)
    } else if t.contains("heap") || t.contains("ヒープ") {
        HeapAnim(kind: .kthLargest)
    } else if t.contains("union find") || t.contains("union") {
        UnionFindAnim(kind: .basic)
    } else if t.contains("hanoi") || t.contains("ハノイ") || t.contains("再帰") {
        BacktrackingAnim(kind: .combinations)
    } else if t.contains("string") || t.contains("文字列") || t.contains("kmp") {
        TwoPointerAnim(word: "abcab")
    } else if t.contains("math") || t.contains("数学") {
        GCDAnim()
    } else {
        // 最後の砦：何かしら動くものを出す
        SortingAnim(kind: .bubble)
    }
}
