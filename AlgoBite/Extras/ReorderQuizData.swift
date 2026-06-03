import SwiftUI
import Charts

// MARK: - Reorder Quizzes (②) — 追加問題

extension ReorderQuiz {
    static let mergeSortMerge: ReorderQuiz = .init(
        id: "merge-sort-merge",
        title: "マージソートのマージ",
        topic: "ソート / マージソート",
        prompt: "ソート済みの2つの配列 [1, 4, 5] と [2, 3, 6] をマージした結果になるように、要素を順番にタップしてね。",
        pool: ["1","2","3","4","5","6"],
        answer: ["1","2","3","4","5","6"],
        explanation: "2つのソート済み配列の先頭を比較して小さい方から取り出していくと、O(n+m) でマージできる。"
    )

    static let selectionSortPass: ReorderQuiz = .init(
        id: "selection-sort-pass-1",
        title: "選択ソート 1パス目",
        topic: "ソート / 選択ソート",
        prompt: "配列 [5, 2, 4, 1, 3] から選択ソートを1パス実行した直後の配列を作ってね。",
        pool: ["1","2","3","4","5"],
        answer: ["1","2","4","5","3"],
        explanation: "未ソート部分 [5,2,4,1,3] の最小値は 1（index 3）。これを先頭の 5 と入れ替えるので [1, 2, 4, 5, 3] になる。"
    )

    static let bfsTraversal: ReorderQuiz = .init(
        id: "bfs-traversal",
        title: "BFS の訪問順",
        topic: "グラフ / BFS",
        prompt: "グラフを A から幅優先探索したときの訪問順を並べて。\n辺: A-B, A-C, B-D, C-E, D-F  (隣接リストはアルファベット順)",
        pool: ["A","B","C","D","E","F"],
        answer: ["A","B","C","D","E","F"],
        explanation: "BFSはキューで管理し、開始点から近い順に訪問する。同じ距離の場合は隣接リスト順。"
    )

    static let dfsTraversal: ReorderQuiz = .init(
        id: "dfs-traversal",
        title: "DFS の訪問順",
        topic: "グラフ / DFS",
        prompt: "同じグラフを A から深さ優先探索（隣接アルファベット順）したときの訪問順を並べて。\n辺: A-B, A-C, B-D, C-E, D-F",
        pool: ["A","B","C","D","E","F"],
        answer: ["A","B","D","F","C","E"],
        explanation: "DFSは「行けるところまで進んで戻る」。A→B→D→F まで行き、詰まったら戻って C→E。"
    )

    static let stackPushPop: ReorderQuiz = .init(
        id: "stack-push-pop",
        title: "スタックの中身",
        topic: "データ構造 / スタック",
        prompt: "空のスタックに push(1), push(2), push(3), pop, push(4) を実行した直後、上から順にスタックの中身を並べて。",
        pool: ["1","2","4"],
        answer: ["4","2","1"],
        explanation: "push(3)後に pop で 3 が消え、その後 push(4) で先頭が 4。下に向かって [4, 2, 1] となる。"
    )

    // MARK: - 追加 25 問

    static let insertionSortStep: ReorderQuiz = .init(
        id: "insertion-sort-step-1",
        title: "挿入ソート 1 ステップ",
        topic: "ソート / 挿入ソート",
        prompt: "配列 [5, 2, 4, 1, 3] で index=1 の要素 (2) を挿入ソートで正しい位置に挿入した直後。",
        pool: ["1","2","3","4","5"],
        answer: ["2","5","4","1","3"],
        explanation: "未ソート部分の左から見て、2 を 5 の前に差し込む。残りはそのまま。"
    )

    static let quicksortPartition: ReorderQuiz = .init(
        id: "quicksort-partition",
        title: "クイックソート partition",
        topic: "ソート / クイックソート",
        prompt: "配列 [3, 1, 4, 2] で pivot=2 (末尾) の Lomuto partition を1回実行した直後。",
        pool: ["1","2","3","4"],
        answer: ["1","2","4","3"],
        explanation: "Lomuto: 境界 i=-1 から走査し、pivot 未満を見つけたら i を進めて swap。j=1 で 1<2 → i=0, swap a[0]↔a[1] で [1,3,4,2]。最後に a[i+1=1] と pivot a[末尾] を swap して [1,2,4,3]。(Hoare partition だと別配置になる点に注意)"
    )

    static let minHeapInsert: ReorderQuiz = .init(
        id: "min-heap-insert",
        title: "Min-heap への挿入",
        topic: "データ構造 / ヒープ",
        prompt: "空の min-heap に 5, 3, 8, 1, 4 を順に挿入した直後、配列表現 (level order) を並べて。",
        pool: ["1","3","4","5","8"],
        answer: ["1","3","8","5","4"],
        explanation: "挿入のたび parent と比較して swap up。最終的に root が最小、各 parent ≤ children を満たす形に整う。"
    )

    static let binarySearchVisits: ReorderQuiz = .init(
        id: "binary-search-visits",
        title: "二分探索の訪問インデックス",
        topic: "二分探索",
        prompt: "ソート済 [1, 3, 5, 7, 9, 11, 13] で target=11 を二分探索した時、訪問する index を訪問順に並べて。",
        pool: ["0","1","2","3","4","5","6"],
        answer: ["3","5"],
        explanation: "L=0,R=6 → M=3 (値 7、target>7 で右へ)、L=4,R=6 → M=5 (値 11、ヒット)。"
    )

    static let treePreorder: ReorderQuiz = .init(
        id: "tree-preorder",
        title: "二分木 preorder",
        topic: "木 / DFS",
        prompt: "下記の木を preorder (NLR) で訪問した順:\n         A\n        / \\\n       B   C\n      / \\   \\\n     D   E   F",
        pool: ["A","B","C","D","E","F"],
        answer: ["A","B","D","E","C","F"],
        explanation: "Node→Left→Right の順。再帰: visit(A) → preorder(B) → preorder(C)。"
    )

    static let treeInorder: ReorderQuiz = .init(
        id: "tree-inorder",
        title: "二分木 inorder",
        topic: "木 / DFS",
        prompt: "上と同じ木を inorder (LNR) で訪問した順を並べて。",
        pool: ["A","B","C","D","E","F"],
        answer: ["D","B","E","A","C","F"],
        explanation: "Left→Node→Right。BST なら昇順になる性質と同じ走査順序。"
    )

    static let treePostorder: ReorderQuiz = .init(
        id: "tree-postorder",
        title: "二分木 postorder",
        topic: "木 / DFS",
        prompt: "上と同じ木を postorder (LRN) で訪問した順を並べて。",
        pool: ["A","B","C","D","E","F"],
        answer: ["D","E","B","F","C","A"],
        explanation: "Left→Right→Node。子をすべて処理してから親、ボトムアップに使う。"
    )

    static let treeLevelOrder: ReorderQuiz = .init(
        id: "tree-level-order",
        title: "二分木 level order",
        topic: "木 / BFS",
        prompt: "上と同じ木を level order (深さ順) で訪問した結果を並べて。",
        pool: ["A","B","C","D","E","F"],
        answer: ["A","B","C","D","E","F"],
        explanation: "BFS と同じ。キューで管理し、深さの浅い順に出していく。"
    )

    static let dijkstraOrder: ReorderQuiz = .init(
        id: "dijkstra-finalize-order",
        title: "ダイクストラの確定順",
        topic: "グラフ / ダイクストラ",
        prompt: "辺 A-B(2), A-C(5), B-C(1), B-D(4), C-D(2) で A からの最短距離が確定する順を並べて。",
        pool: ["A","B","C","D"],
        answer: ["A","B","C","D"],
        explanation: "距離 0,2,3,5 の順に確定。C は A→B→C=3 が更新されてから確定する。"
    )

    static let topologicalSort: ReorderQuiz = .init(
        id: "topological-sort",
        title: "トポロジカルソート",
        topic: "グラフ / DAG",
        prompt: "DAG: A→B, A→C, B→D, C→D, D→E を Kahn (BFS、入次数 0 をアルファベット順) で出力した順。",
        pool: ["A","B","C","D","E"],
        answer: ["A","B","C","D","E"],
        explanation: "入次数 0 の A をキューに、次に B/C、両方処理後に D の入次数が 0 になり、最後 E。"
    )

    static let queueOps: ReorderQuiz = .init(
        id: "queue-enqueue-dequeue",
        title: "キューの中身",
        topic: "データ構造 / キュー",
        prompt: "空のキューに enqueue(1), enqueue(2), enqueue(3), dequeue, enqueue(4) を実行した直後、front から rear へ並べて。",
        pool: ["1","2","3","4"],
        answer: ["2","3","4"],
        explanation: "FIFO。dequeue で先頭の 1 が消え、enqueue(4) で末尾に 4 が追加されて [2,3,4]。"
    )

    static let dequeBothEnds: ReorderQuiz = .init(
        id: "deque-both-ends",
        title: "デックの両端操作",
        topic: "データ構造 / デック",
        prompt: "空の deque に push_front(1), push_back(2), push_front(3), pop_back を順に実行した直後、front から back へ並べて。",
        pool: ["1","2","3","4"],
        answer: ["3","1"],
        explanation: "[1] → [1,2] → [3,1,2] → 末尾 2 を pop → [3,1]。"
    )

    static let hanoi2Disks: ReorderQuiz = .init(
        id: "hanoi-2-disks",
        title: "ハノイの塔 (2 枚)",
        topic: "再帰 / ハノイ",
        prompt: "円盤 2 枚を A→C へ移動する手順 (最短 3 手) を並べて。",
        pool: ["A→B","A→C","B→A","B→C","C→A","C→B"],
        answer: ["A→B","A→C","B→C"],
        explanation: "上の円盤を退避先 B へ、大円盤を C へ、退避した円盤を C へ重ねる。"
    )

    static let fibMemoOrder: ReorderQuiz = .init(
        id: "fib-memo-order",
        title: "fib(5) memo の確定順",
        topic: "DP / メモ化",
        prompt: "fib(5) をメモ化再帰で計算した時、memo[n] が確定する順 (n) を並べて (fib(0)=0, fib(1)=1 は base)。",
        pool: ["2","3","4","5"],
        answer: ["2","3","4","5"],
        explanation: "DFS で fib(2) まで降りて戻りながら確定。一度 memo に入れたら再計算しない。"
    )

    static let lisDpValues: ReorderQuiz = .init(
        id: "lis-dp-values",
        title: "LIS の dp 値",
        topic: "DP / LIS",
        prompt: "配列 [3, 1, 4, 1, 5] の LIS dp[i] (i 番目で終わる増加部分列の長さ) を i=0 から順に並べて。",
        pool: ["1","1","1","2","3"],
        answer: ["1","1","2","1","3"],
        explanation: "dp = [1,1,2,1,3]。例えば dp[2]=2 は (1→4 または 3→4)、dp[4]=3 は (1→4→5 など)。"
    )

    static let stringReverse: ReorderQuiz = .init(
        id: "string-reverse",
        title: "文字列を反転",
        topic: "文字列 / 反転",
        prompt: "'hello' を 2 ポインタで in-place 反転した結果を文字単位で並べて。",
        pool: ["e","h","l","l","o"],
        answer: ["o","l","l","e","h"],
        explanation: "i=0,j=4 swap → olllh → i=1,j=3 swap → olleh。中央 (l) はそのまま。"
    )

    static let permutationsLex: ReorderQuiz = .init(
        id: "permutations-lex",
        title: "Permutations 辞書順",
        topic: "バックトラック / 順列",
        prompt: "[1, 2, 3] のすべての順列を辞書順に並べて。",
        pool: ["123","132","213","231","312","321"],
        answer: ["123","132","213","231","312","321"],
        explanation: "next_permutation を繰り返すと辞書順に列挙される。6 通り = 3!"
    )

    static let factorialReturnOrder: ReorderQuiz = .init(
        id: "factorial-return-order",
        title: "fact(4) の戻り値順",
        topic: "再帰 / コールスタック",
        prompt: "fact(4) を再帰で評価した時、return される値の順を並べて。",
        pool: ["1","2","6","24"],
        answer: ["1","2","6","24"],
        explanation: "深い呼び出しから先に戻る: fact(1)=1, fact(2)=2, fact(3)=6, fact(4)=24。"
    )

    static let bubbleSortFullPass: ReorderQuiz = .init(
        id: "bubble-sort-2-passes",
        title: "バブルソート 2 パス目",
        topic: "ソート / バブルソート",
        prompt: "[5, 2, 4, 1, 3] にバブルソートを 2 パス実行した直後。",
        pool: ["1","2","3","4","5"],
        answer: ["2","1","3","4","5"],
        explanation: "1 パス目: [2,4,1,3,5]、2 パス目: [2,1,3,4,5]。最大 2 つが右端に固定される。"
    )

    static let countingSortCount: ReorderQuiz = .init(
        id: "counting-sort-count",
        title: "Counting sort の度数表",
        topic: "ソート / counting sort",
        prompt: "[1, 3, 1, 2, 3] の counting sort で count[i] (i=0..4) を順に並べて。",
        pool: ["0","0","1","2","2"],
        answer: ["0","2","1","2","0"],
        explanation: "値 0 が 0 回、1 が 2 回、2 が 1 回、3 が 2 回、4 が 0 回。"
    )

    static let kmpFailure: ReorderQuiz = .init(
        id: "kmp-failure",
        title: "KMP failure 関数",
        topic: "文字列 / KMP",
        prompt: "pattern = 'abab' の failure 関数 fail[i] を i=0,1,2,3 の順に並べて。",
        pool: ["0","0","1","2"],
        answer: ["0","0","1","2"],
        explanation: "fail[i] は接頭辞=接尾辞となる最大長。'a'→0, 'ab'→0, 'aba'→1, 'abab'→2。"
    )

    static let unionFindMerge: ReorderQuiz = .init(
        id: "union-find-merge",
        title: "Union-Find の代表元",
        topic: "グラフ / Union Find",
        prompt: "5 要素 (0..4) に union(0,1), union(2,3), union(1,3) を順に適用した後、各要素の代表元 (root) を 0,1,2,3,4 の順に並べて。\n注: union(a,b) では a の root を b の root の親にする (= 左側の root が親になる) ルール、path compression あり。",
        pool: ["0","0","0","0","4"],
        answer: ["0","0","0","0","4"],
        explanation: "union(0,1): root(1)=1 の親を root(0)=0 にする → {0,1} 全部 root 0。union(2,3): {2,3} 全部 root 2。union(1,3): root(3)=2 の親を root(1)=0 にする → 全要素 (4 以外) が root 0 に統合。4 は単独なので root 4。"
    )

    static let mergeSortSplitMerge: ReorderQuiz = .init(
        id: "merge-sort-merge-step",
        title: "マージソートの最終マージ",
        topic: "ソート / マージソート",
        prompt: "ソート済 [2, 4] と [1, 3, 5] をマージした結果を並べて。",
        pool: ["1","2","3","4","5"],
        answer: ["1","2","3","4","5"],
        explanation: "両端を比較して小さい方を出す: 2 vs 1 → 1, 2 vs 3 → 2, 4 vs 3 → 3, 4 vs 5 → 4, 5。"
    )

    static let heapSortRemoveMin: ReorderQuiz = .init(
        id: "heap-sort-extract",
        title: "Min-heap から取り出し順",
        topic: "ソート / ヒープソート",
        prompt: "min-heap = [1, 3, 8, 5, 4] から extract-min を繰り返した時、取り出される順を並べて。",
        pool: ["1","3","4","5","8"],
        answer: ["1","3","4","5","8"],
        explanation: "毎回 root (最小) が取り出され、ヒープ全体が再構成される。結果は昇順。"
    )

    static let bfsLevelDistances: ReorderQuiz = .init(
        id: "bfs-distances",
        title: "BFS の距離",
        topic: "グラフ / BFS",
        prompt: "辺 A-B, A-C, B-D, C-E, D-F で A から BFS した時、各ノードまでの距離を A,B,C,D,E,F の順に並べて。",
        pool: ["0","1","1","2","2","3"],
        answer: ["0","1","1","2","2","3"],
        explanation: "A=0, B/C=1, D/E=2, F=3。BFS は距離の浅い順に確定。"
    )

    static let allList: [ReorderQuiz] = [
        // 既存
        .bubbleSortPass,
        .selectionSortPass,
        .mergeSortMerge,
        .bfsTraversal,
        .dfsTraversal,
        .stackPushPop,
        // 追加: ソート
        .insertionSortStep,
        .quicksortPartition,
        .bubbleSortFullPass,
        .countingSortCount,
        .mergeSortSplitMerge,
        .heapSortRemoveMin,
        // データ構造
        .minHeapInsert,
        .queueOps,
        .dequeBothEnds,
        // 探索
        .binarySearchVisits,
        // 木
        .treePreorder,
        .treeInorder,
        .treePostorder,
        .treeLevelOrder,
        // グラフ
        .dijkstraOrder,
        .topologicalSort,
        .unionFindMerge,
        .bfsLevelDistances,
        // 再帰 / 順列 / DP
        .hanoi2Disks,
        .fibMemoOrder,
        .lisDpValues,
        .permutationsLex,
        .factorialReturnOrder,
        // 文字列
        .stringReverse,
        .kmpFailure,
    ]

    var emoji: String {
        switch id {
        // 既存
        case "bubble-sort-pass-1":     return "🫧"
        case "selection-sort-pass-1":  return "👉"
        case "merge-sort-merge":       return "🧩"
        case "bfs-traversal":          return "🌊"
        case "dfs-traversal":          return "🕳️"
        case "stack-push-pop":         return "📚"
        // 追加
        case "insertion-sort-step-1":  return "📥"
        case "quicksort-partition":    return "⚡"
        case "bubble-sort-2-passes":   return "🫧"
        case "counting-sort-count":    return "🔢"
        case "merge-sort-merge-step":  return "🔀"
        case "heap-sort-extract":      return "⛰️"
        case "min-heap-insert":        return "🏔️"
        case "queue-enqueue-dequeue":  return "🚌"
        case "deque-both-ends":        return "↔️"
        case "binary-search-visits":   return "🎯"
        case "tree-preorder":          return "🌲"
        case "tree-inorder":           return "🌳"
        case "tree-postorder":         return "🌴"
        case "tree-level-order":       return "🪴"
        case "dijkstra-finalize-order":return "🛣️"
        case "topological-sort":       return "🪜"
        case "union-find-merge":       return "🧷"
        case "bfs-distances":          return "📏"
        case "hanoi-2-disks":          return "🗼"
        case "fib-memo-order":         return "🐚"
        case "lis-dp-values":          return "📈"
        case "permutations-lex":       return "🔄"
        case "factorial-return-order": return "↩️"
        case "string-reverse":         return "🔃"
        case "kmp-failure":            return "🧵"
        default:                       return "📋"
        }
    }
}

