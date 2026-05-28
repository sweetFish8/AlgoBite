import Foundation

struct PuzzleData {
    static let all: [PuzzleProblem] = p1_50 + p51_100
}

// MARK: - Problems 51–100
private let p51_100: [PuzzleProblem] = [

    // 51. Combinations
    PuzzleProblem(
        id: "combinations", title: "Combinations", difficulty: "Medium", topic: "Backtracking",
        prompt: "1〜n の中から k 個を選ぶ全組み合わせを返してください。",
        example: "例: n=4, k=2  →  [[1,2],[1,3],[1,4],[2,3],[2,4],[3,4]]",
        template: [
            "def combine(n, k):",
            "    result = []",
            "    def bt(start, path):",
            "        if len(path) == {{tgt}}:",
            "            result.append(path[:]); return",
            "        for i in range(start, n + 1):",
            "            bt({{nxt}}, path + [i])",
            "    bt(1, []); return result"
        ],
        slots: [
            "tgt": PuzzleSlot(id: "tgt", label: "目標の長さ", answer: "k",     choices: ["k", "n", "k - 1"]),
            "nxt": PuzzleSlot(id: "nxt", label: "次の開始",   answer: "i + 1", choices: ["i + 1", "i", "start + 1"])
        ]
    ),

    // 52. N-Queens
    PuzzleProblem(
        id: "n-queens", title: "N-Queens", difficulty: "Hard", topic: "Backtracking",
        prompt: "n×n のチェスボードに n 個のクイーンを互いに攻撃しないよう配置する方法の数を返してください。",
        example: "例: n=4  →  2",
        template: [
            "def solve_n_queens(n):",
            "    result = []",
            "    def safe(board, row, col):",
            "        for i in range(row):",
            "            if board[i]==col: return False",
            "            if abs(board[i]-col)=={{diag}}: return False",
            "        return True",
            "    def bt(row, board):",
            "        if row == {{base}}:",
            "            result.append(board[:]); return",
            "        for col in range(n):",
            "            if safe(board, row, col):",
            "                board.append(col)",
            "                bt({{nr}}, board)",
            "                board.pop()",
            "    bt(0, []); return len(result)"
        ],
        slots: [
            "diag": PuzzleSlot(id: "diag", label: "対角チェック",  answer: "abs(i - row)", choices: ["abs(i - row)", "i - row", "row - i"]),
            "base": PuzzleSlot(id: "base", label: "基底条件",      answer: "n",            choices: ["n", "0", "n - 1"]),
            "nr":   PuzzleSlot(id: "nr",   label: "次の行",        answer: "row + 1",      choices: ["row + 1", "row", "row - 1"])
        ]
    ),

    // 53. Word Search
    PuzzleProblem(
        id: "word-search", title: "Word Search", difficulty: "Medium", topic: "Backtracking / DFS",
        prompt: "グリッド上に隣接セルをたどって単語を構成できるか判定してください。",
        example: "例: board=[['A','B'],['C','D']], word='ABDC'  →  True",
        template: [
            "def exist(board, word):",
            "    R, C = len(board), len(board[0])",
            "    def dfs(r, c, i):",
            "        if i == {{done}}: return True",
            "        if r<0 or r>=R or c<0 or c>=C: return False",
            "        if board[r][c] != word[i]: return False",
            "        tmp, board[r][c] = board[r][c], {{mk}}",
            "        found = any(dfs(r+dr,c+dc,{{ni}})",
            "                    for dr,dc in [(1,0),(-1,0),(0,1),(0,-1)])",
            "        board[r][c] = tmp; return found",
            "    return any(dfs(r,c,0) for r in range(R) for c in range(C))"
        ],
        slots: [
            "done": PuzzleSlot(id: "done", label: "完了条件",    answer: "len(word)", choices: ["len(word)", "len(word) - 1", "0"]),
            "mk":   PuzzleSlot(id: "mk",   label: "訪問済みマーク", answer: "'#'",    choices: ["'#'", "None", "' '"]),
            "ni":   PuzzleSlot(id: "ni",   label: "次の文字インデックス", answer: "i + 1", choices: ["i + 1", "i", "i - 1"])
        ]
    ),

    // 54. Palindrome Check
    PuzzleProblem(
        id: "palindrome-check", title: "Valid Palindrome", difficulty: "Easy", topic: "Two Pointers / String",
        prompt: "英数字のみを考慮し、大文字小文字を無視して回文か判定してください。",
        example: "例: 'A man a plan a canal Panama'  →  True",
        template: [
            "def is_palindrome(s):",
            "    s = ''.join(c.lower() for c in s if c.{{flt}}())",
            "    l, r = 0, len(s) - 1",
            "    while l < r:",
            "        if s[l] != s[{{cmp}}]: return False",
            "        l += 1; r -= {{dec}}",
            "    return True"
        ],
        slots: [
            "flt": PuzzleSlot(id: "flt", label: "フィルタ条件",  answer: "isalnum", choices: ["isalnum", "isalpha", "isdigit"]),
            "cmp": PuzzleSlot(id: "cmp", label: "比較対象",      answer: "r",       choices: ["r", "l", "0"]),
            "dec": PuzzleSlot(id: "dec", label: "右ポインタ減少", answer: "1",       choices: ["1", "2", "l"])
        ],
        explanation: "左右両端から1文字ずつポインタを動かし、対応位置の文字を比較します。一致しなければ即座に False を返し、l < r でなくなったら True。Two Pointers の典型例で O(n)、追加メモリ O(1)。"
    ),

    // 55. Longest Palindromic Substring
    PuzzleProblem(
        id: "longest-palindrome", title: "Longest Palindromic Substring", difficulty: "Medium", topic: "String / Expand",
        prompt: "最長の回文部分文字列を返してください（中心展開法）。",
        example: "例: s = 'babad'  →  'bab'",
        template: [
            "def longest_palindrome(s):",
            "    res = ''",
            "    for i in range(len(s)):",
            "        for l, r in [(i,i), (i,{{er}})]:  # 奇数/偶数",
            "            while l>=0 and r<len(s) and s[l]==s[r]:",
            "                if r-l+1 > len(res):",
            "                    res = s[{{sl}}]",
            "                l -= 1; r += {{exp}}",
            "    return res"
        ],
        slots: [
            "er":  PuzzleSlot(id: "er",  label: "偶数拡張の右端", answer: "i + 1",    choices: ["i + 1", "i", "i - 1"]),
            "sl":  PuzzleSlot(id: "sl",  label: "スライス",       answer: "l:r+1",    choices: ["l:r+1", "l:r", "l+1:r"]),
            "exp": PuzzleSlot(id: "exp", label: "右への拡張",     answer: "1",        choices: ["1", "2", "-1"])
        ]
    ),

    // 56. Anagram Check
    PuzzleProblem(
        id: "anagram-check", title: "Valid Anagram", difficulty: "Easy", topic: "String / Hash",
        prompt: "文字列 t が s のアナグラムかどうか判定してください。",
        example: "例: s='anagram', t='nagaram'  →  True",
        template: [
            "def is_anagram(s, t):",
            "    if len(s) != len(t): return False",
            "    count = [0] * {{sz}}",
            "    for c in s: count[ord(c) - ord({{bc}})] += 1",
            "    for c in t: count[ord(c) - ord('a')] -= 1",
            "    return all(x == {{exp}} for x in count)"
        ],
        slots: [
            "sz":  PuzzleSlot(id: "sz",  label: "配列サイズ",  answer: "26",  choices: ["26", "256", "len(s)"]),
            "bc":  PuzzleSlot(id: "bc",  label: "基準文字",    answer: "'a'", choices: ["'a'", "'A'", "'z'"]),
            "exp": PuzzleSlot(id: "exp", label: "期待値",      answer: "0",   choices: ["0", "1", "-1"])
        ],
        explanation: "サイズ26の文字カウント配列を用意し、s で +1、t で -1 します。最後に全要素が0なら同じ文字構成＝アナグラム。ソートして比較する方法もありますが、カウント法は O(n) で高速。"
    ),

    // 57. Group Anagrams
    PuzzleProblem(
        id: "group-anagrams", title: "Group Anagrams", difficulty: "Medium", topic: "String / Hash Map",
        prompt: "文字列リストをアナグラムごとにグルーピングしてください。",
        example: "例: ['eat','tea','tan','ate','nat','bat']  →  [['eat','tea','ate'],['tan','nat'],['bat']]",
        template: [
            "from collections import defaultdict",
            "",
            "def group_anagrams(strs):",
            "    groups = defaultdict({{dt}})",
            "    for s in strs:",
            "        key = tuple({{srt}})",
            "        groups[key].append(s)",
            "    return list(groups.{{vs}}())"
        ],
        slots: [
            "dt":  PuzzleSlot(id: "dt",  label: "デフォルト型",  answer: "list",   choices: ["list", "set", "dict"]),
            "srt": PuzzleSlot(id: "srt", label: "ソート方法",    answer: "sorted(s)", choices: ["sorted(s)", "reversed(s)", "list(s)"]),
            "vs":  PuzzleSlot(id: "vs",  label: "値の取得",      answer: "values", choices: ["values", "keys", "items"])
        ]
    ),

    // 58. Roman to Integer
    PuzzleProblem(
        id: "roman-to-int", title: "Roman to Integer", difficulty: "Easy", topic: "String / Math",
        prompt: "ローマ数字の文字列を整数に変換してください。",
        example: "例: 'MCMXCIV'  →  1994",
        template: [
            "def roman_to_int(s):",
            "    val = {'I':1,'V':5,'X':10,'L':50,'C':100,'D':500,'M':1000}",
            "    result = 0",
            "    for i in range(len(s)):",
            "        if i < len(s)-1 and val[s[i]] < val[{{nc}}]:",
            "            result -= val[s[i]]",
            "        else:",
            "            result {{add}}= val[{{cc}}]",
            "    return result"
        ],
        slots: [
            "nc":  PuzzleSlot(id: "nc",  label: "次の文字",   answer: "s[i+1]", choices: ["s[i+1]", "s[i]", "s[i-1]"]),
            "add": PuzzleSlot(id: "add", label: "演算子",     answer: "+",      choices: ["+", "-", "*"]),
            "cc":  PuzzleSlot(id: "cc",  label: "現在の文字", answer: "s[i]",   choices: ["s[i]", "s[i+1]", "s[-1]"])
        ]
    ),

    // 59. Reverse String
    PuzzleProblem(
        id: "reverse-string", title: "Reverse String", difficulty: "Easy", topic: "Two Pointers",
        prompt: "文字のリストを in-place で逆順にしてください。",
        example: "例: ['h','e','l','l','o']  →  ['o','l','l','e','h']",
        template: [
            "def reverse_string(s):",
            "    l, r = 0, len(s) - 1",
            "    while l < r:",
            "        s[l], s[r] = s[{{rl}}], s[{{lr}}]",
            "        l += 1; r -= {{dec}}",
            "    return s"
        ],
        slots: [
            "rl":  PuzzleSlot(id: "rl",  label: "s[l]の新値", answer: "r",  choices: ["r", "l", "0"]),
            "lr":  PuzzleSlot(id: "lr",  label: "s[r]の新値", answer: "l",  choices: ["l", "r", "-1"]),
            "dec": PuzzleSlot(id: "dec", label: "rの減少量",  answer: "1",  choices: ["1", "2", "l"])
        ]
    ),

    // 60. Container With Most Water
    PuzzleProblem(
        id: "container-water", title: "Container With Most Water", difficulty: "Medium", topic: "Two Pointers",
        prompt: "2本の垂線で挟まれる最大の水量を返してください。",
        example: "例: height=[1,8,6,2,5,4,8,3,7]  →  49",
        template: [
            "def max_area(height):",
            "    l, r = 0, len(height) - 1",
            "    best = 0",
            "    while l < r:",
            "        h = min(height[l], height[r])",
            "        best = max(best, h * {{w}})",
            "        if height[l] < height[r]: l += 1",
            "        else: r -= {{dec}}",
            "    return best"
        ],
        slots: [
            "w":   PuzzleSlot(id: "w",   label: "幅の計算", answer: "r - l",  choices: ["r - l", "r + l", "l - r"]),
            "dec": PuzzleSlot(id: "dec", label: "rの減少量", answer: "1",     choices: ["1", "2", "r"])
        ]
    ),

    // 61. Trapping Rain Water
    PuzzleProblem(
        id: "trapping-rain", title: "Trapping Rain Water", difficulty: "Hard", topic: "Two Pointers",
        prompt: "高さの配列が与えられる。トラップされる雨水の量を返してください。",
        example: "例: height=[0,1,0,2,1,0,1,3,2,1,2,1]  →  6",
        template: [
            "def trap(height):",
            "    l, r = 0, len(height) - 1",
            "    lmax = rmax = water = 0",
            "    while l < r:",
            "        if height[l] < height[r]:",
            "            if height[l] >= lmax: lmax = {{ul}}",
            "            else: water += {{al}}",
            "            l += 1",
            "        else:",
            "            if height[r] >= rmax: rmax = height[r]",
            "            else: water += {{ar}}",
            "            r -= 1",
            "    return water"
        ],
        slots: [
            "ul": PuzzleSlot(id: "ul", label: "lmaxの更新",  answer: "height[l]",          choices: ["height[l]", "lmax + 1", "water"]),
            "al": PuzzleSlot(id: "al", label: "左側の水量",  answer: "lmax - height[l]",   choices: ["lmax - height[l]", "height[l] - lmax", "lmax"]),
            "ar": PuzzleSlot(id: "ar", label: "右側の水量",  answer: "rmax - height[r]",   choices: ["rmax - height[r]", "height[r] - rmax", "rmax"])
        ]
    ),

    // 62. Product Except Self
    PuzzleProblem(
        id: "product-except-self", title: "Product Except Self", difficulty: "Medium", topic: "Array / Prefix",
        prompt: "自分以外の全要素の積を返す配列を O(n)・除算なしで求めてください。",
        example: "例: nums=[1,2,3,4]  →  [24,12,8,6]",
        template: [
            "def product_except_self(nums):",
            "    n = len(nums); out = [1]*n; pre = 1",
            "    for i in range({{pr}}):",
            "        out[i] = pre; pre *= nums[i]",
            "    suf = 1",
            "    for i in range(n-1, -1, -1):",
            "        out[i] *= {{sm}}; suf *= nums[i]",
            "    return out"
        ],
        slots: [
            "pr": PuzzleSlot(id: "pr", label: "前置積のrange", answer: "n",    choices: ["n", "n - 1", "n + 1"]),
            "sm": PuzzleSlot(id: "sm", label: "後置積を掛ける", answer: "suf", choices: ["suf", "out[i]", "nums[i]"])
        ]
    ),

    // 63. Find Duplicate (Floyd's)
    PuzzleProblem(
        id: "find-duplicate", title: "Find Duplicate Number", difficulty: "Medium", topic: "Array / Floyd's Cycle",
        prompt: "1〜n の整数が入った n+1 の配列で、重複している数を O(1) 空間で求めてください。",
        example: "例: nums=[1,3,4,2,2]  →  2",
        template: [
            "def find_duplicate(nums):",
            "    slow = fast = nums[0]",
            "    while True:",
            "        slow = nums[{{sn}}]",
            "        fast = nums[nums[{{fn}}]]",
            "        if slow == fast: break",
            "    slow = nums[{{rst}}]",
            "    while slow != fast:",
            "        slow = nums[slow]; fast = nums[fast]",
            "    return slow"
        ],
        slots: [
            "sn":  PuzzleSlot(id: "sn",  label: "slowの次",  answer: "slow", choices: ["slow", "fast", "0"]),
            "fn":  PuzzleSlot(id: "fn",  label: "fastの次",  answer: "fast", choices: ["fast", "slow", "0"]),
            "rst": PuzzleSlot(id: "rst", label: "slowのリセット", answer: "0", choices: ["0", "slow", "fast"])
        ]
    ),

    // 64. Rotate Array
    PuzzleProblem(
        id: "rotate-array", title: "Rotate Array", difficulty: "Medium", topic: "Array / Two Pointers",
        prompt: "配列を右に k 要素回転させてください（in-place）。",
        example: "例: nums=[1,2,3,4,5,6,7], k=3  →  [5,6,7,1,2,3,4]",
        template: [
            "def rotate(nums, k):",
            "    n = len(nums); k %= n",
            "    nums.{{ra}}()",
            "    nums[:k] = nums[:k][::-1]",
            "    nums[k:] = nums[{{rs}}][::-1]"
        ],
        slots: [
            "ra": PuzzleSlot(id: "ra", label: "全体を逆順",  answer: "reverse", choices: ["reverse", "sort", "clear"]),
            "rs": PuzzleSlot(id: "rs", label: "右半分スライス", answer: "k:",   choices: ["k:", ":k", "k+1:"])
        ]
    ),

    // 65. Merge Intervals
    PuzzleProblem(
        id: "merge-intervals", title: "Merge Intervals", difficulty: "Medium", topic: "Array / Sorting",
        prompt: "重なり合う区間をマージして返してください。",
        example: "例: [[1,3],[2,6],[8,10],[15,18]]  →  [[1,6],[8,10],[15,18]]",
        template: [
            "def merge(intervals):",
            "    intervals.sort(key=lambda x: x[{{sk}}])",
            "    merged = [intervals[0]]",
            "    for s, e in intervals[1:]:",
            "        if s <= merged[-1][{{le}}]:",
            "            merged[-1][1] = max(merged[-1][1], {{ne}})",
            "        else:",
            "            merged.append([s, e])",
            "    return merged"
        ],
        slots: [
            "sk": PuzzleSlot(id: "sk", label: "ソートキー",   answer: "0",  choices: ["0", "1", "-1"]),
            "le": PuzzleSlot(id: "le", label: "最後の終端",   answer: "1",  choices: ["1", "0", "-1"]),
            "ne": PuzzleSlot(id: "ne", label: "新しい終端",   answer: "e",  choices: ["e", "s", "merged[-1][0]"])
        ]
    ),

    // 66. Search in Rotated Sorted Array
    PuzzleProblem(
        id: "search-rotated", title: "Search in Rotated Array", difficulty: "Medium", topic: "Binary Search",
        prompt: "回転されたソート済み配列から target を検索してください。",
        example: "例: nums=[4,5,6,7,0,1,2], target=0  →  4",
        template: [
            "def search(nums, target):",
            "    l, r = 0, len(nums) - 1",
            "    while l <= r:",
            "        mid = (l + r) // 2",
            "        if nums[mid] == target: return mid",
            "        if nums[l] <= nums[mid]:  # 左半分がソート済み",
            "            if nums[l] <= target < {{ub}}:",
            "                r = mid - 1",
            "            else: l = mid + 1",
            "        else:  # 右半分がソート済み",
            "            if {{lb}} < target <= nums[r]:",
            "                l = mid + 1",
            "            else: r = mid - 1",
            "    return -1"
        ],
        slots: [
            "ub": PuzzleSlot(id: "ub", label: "左半分の上限", answer: "nums[mid]", choices: ["nums[mid]", "nums[r]", "target"]),
            "lb": PuzzleSlot(id: "lb", label: "右半分の下限", answer: "nums[mid]", choices: ["nums[mid]", "nums[l]", "target"])
        ]
    ),

    // 67. Find First and Last Position
    PuzzleProblem(
        id: "first-last-pos", title: "First & Last Position", difficulty: "Medium", topic: "Binary Search",
        prompt: "ソート済み配列で target の最初と最後のインデックスを返してください。",
        example: "例: nums=[5,7,7,8,8,10], target=8  →  [3,4]",
        template: [
            "def search_range(nums, target):",
            "    def find(left_bias):",
            "        lo, hi, res = 0, len(nums)-1, -1",
            "        while lo <= hi:",
            "            mid = (lo + hi) // 2",
            "            if nums[mid] == target:",
            "                res = {{sv}}",
            "                if left_bias: hi = mid - 1",
            "                else: lo = {{gr}}",
            "            elif nums[mid] < target: lo = mid + 1",
            "            else: hi = mid - 1",
            "        return res",
            "    return [find(True), find(False)]"
        ],
        slots: [
            "sv": PuzzleSlot(id: "sv", label: "結果を保存",  answer: "mid",     choices: ["mid", "lo", "hi"]),
            "gr": PuzzleSlot(id: "gr", label: "右へ絞り込み", answer: "mid + 1", choices: ["mid + 1", "mid - 1", "mid"])
        ]
    ),

    // 68. Count Bits
    PuzzleProblem(
        id: "count-bits", title: "Count Bits", difficulty: "Easy", topic: "Bit Manipulation / DP",
        prompt: "0〜n の各整数の2進数表現の 1 の個数を配列で返してください。",
        example: "例: n=5  →  [0,1,1,2,1,2]",
        template: [
            "def count_bits(n):",
            "    dp = [0] * (n + 1)",
            "    for i in range(1, n + 1):",
            "        dp[i] = dp[{{rs}}] + {{lb}}",
            "    return dp"
        ],
        slots: [
            "rs": PuzzleSlot(id: "rs", label: "右シフト参照", answer: "i >> 1", choices: ["i >> 1", "i << 1", "i - 1"]),
            "lb": PuzzleSlot(id: "lb", label: "最下位ビット", answer: "i & 1",  choices: ["i & 1", "i | 1", "i ^ 1"])
        ]
    ),

    // 69. Single Number
    PuzzleProblem(
        id: "single-number", title: "Single Number", difficulty: "Easy", topic: "Bit Manipulation",
        prompt: "1つだけ重複していない要素を O(n) 時間・O(1) 空間で返してください。",
        example: "例: nums=[4,1,2,1,2]  →  4",
        template: [
            "def single_number(nums):",
            "    result = {{init}}",
            "    for n in nums:",
            "        result {{op}}= n",
            "    return result"
        ],
        slots: [
            "init": PuzzleSlot(id: "init", label: "初期値",  answer: "0",  choices: ["0", "1", "nums[0]"]),
            "op":   PuzzleSlot(id: "op",   label: "演算子",  answer: "^",  choices: ["^", "&", "|"])
        ]
    ),

    // 70. Power of Two
    PuzzleProblem(
        id: "power-of-two", title: "Power of Two", difficulty: "Easy", topic: "Bit Manipulation",
        prompt: "整数 n が 2 の累乗かどうか O(1) で判定してください。",
        example: "例: n=16  →  True  /  n=6  →  False",
        template: [
            "def is_power_of_two(n):",
            "    if n <= 0: return False",
            "    return (n & {{mask}}) == {{exp}}"
        ],
        slots: [
            "mask": PuzzleSlot(id: "mask", label: "マスク値",  answer: "n - 1", choices: ["n - 1", "n + 1", "n"]),
            "exp":  PuzzleSlot(id: "exp",  label: "期待値",   answer: "0",     choices: ["0", "1", "n"])
        ]
    ),

    // 71. Reverse Bits
    PuzzleProblem(
        id: "reverse-bits", title: "Reverse Bits", difficulty: "Easy", topic: "Bit Manipulation",
        prompt: "32ビット符号なし整数のビットを逆順にしてください。",
        example: "例: n=43261596(00000010100101000001111010011100)  →  964176192",
        template: [
            "def reverse_bits(n):",
            "    result = 0",
            "    for _ in range({{bits}}):",
            "        result = (result << 1) | (n & {{lsb}})",
            "        n {{shr}}= 1",
            "    return result"
        ],
        slots: [
            "bits": PuzzleSlot(id: "bits", label: "ビット数",    answer: "32", choices: ["32", "16", "64"]),
            "lsb":  PuzzleSlot(id: "lsb",  label: "最下位ビット取得", answer: "1",  choices: ["1", "0", "2"]),
            "shr":  PuzzleSlot(id: "shr",  label: "右シフト演算子",   answer: ">>", choices: [">>", "<<", "//"])
        ]
    ),

    // 72. GCD (Euclidean)
    PuzzleProblem(
        id: "gcd", title: "GCD (Euclidean Algorithm)", difficulty: "Easy", topic: "Math",
        prompt: "ユークリッドの互除法で最大公約数を求めてください。",
        example: "例: gcd(48, 18)  →  6",
        template: [
            "def gcd(a, b):",
            "    while {{cond}}:",
            "        a, b = b, {{rem}}",
            "    return a"
        ],
        slots: [
            "cond": PuzzleSlot(id: "cond", label: "ループ条件", answer: "b",     choices: ["b", "a", "a > b"]),
            "rem":  PuzzleSlot(id: "rem",  label: "余りの計算", answer: "a % b", choices: ["a % b", "b % a", "a - b"])
        ]
    ),

    // 73. Sieve of Eratosthenes
    PuzzleProblem(
        id: "sieve", title: "Sieve of Eratosthenes", difficulty: "Medium", topic: "Math / Prime",
        prompt: "エラトステネスの篩で n 以下の全素数を求めてください。",
        example: "例: n=10  →  [2,3,5,7]",
        template: [
            "def sieve(n):",
            "    is_p = [True]*(n+1)",
            "    is_p[0] = is_p[{{one}}] = False",
            "    p = 2",
            "    while p*p <= n:",
            "        if is_p[p]:",
            "            for i in range({{st}}, n+1, p):",
            "                is_p[i] = {{mk}}",
            "        p += 1",
            "    return [i for i in range(2, n+1) if is_p[i]]"
        ],
        slots: [
            "one": PuzzleSlot(id: "one", label: "1を除外",     answer: "1",     choices: ["1", "0", "2"]),
            "st":  PuzzleSlot(id: "st",  label: "篩の開始位置", answer: "p * p", choices: ["p * p", "p + 1", "2 * p"]),
            "mk":  PuzzleSlot(id: "mk",  label: "合成数マーク", answer: "False", choices: ["False", "True", "not is_p[i]"])
        ]
    ),

    // 74. Fast Exponentiation
    PuzzleProblem(
        id: "fast-pow", title: "Fast Exponentiation", difficulty: "Medium", topic: "Math / Divide & Conquer",
        prompt: "繰り返し二乗法で (base^exp) % mod を O(log n) で計算してください。",
        example: "例: fast_pow(2, 10, 1000)  →  24",
        template: [
            "def fast_pow(base, exp, mod):",
            "    result = 1; base %= mod",
            "    while exp > 0:",
            "        if {{odd}}:",
            "            result = result * base % mod",
            "        exp {{shr}}= 1",
            "        base = base * base % mod",
            "    return result"
        ],
        slots: [
            "odd": PuzzleSlot(id: "odd", label: "奇数判定",   answer: "exp & 1",      choices: ["exp & 1", "exp % 2 == 0", "exp > 1"]),
            "shr": PuzzleSlot(id: "shr", label: "expの更新",  answer: ">>",           choices: [">>", "<<", "-"])
        ]
    ),

    // 75. Bubble Sort
    PuzzleProblem(
        id: "bubble-sort", title: "Bubble Sort", difficulty: "Easy", topic: "Sorting",
        prompt: "バブルソートで配列を昇順に並べてください（早期終了あり）。",
        example: "例: [64,34,25,12,22,11,90]  →  [11,12,22,25,34,64,90]",
        template: [
            "def bubble_sort(arr):",
            "    n = len(arr)",
            "    for i in range(n):",
            "        swapped = False",
            "        for j in range(0, n - {{ie}}):",
            "            if arr[j] > arr[{{nj}}]:",
            "                arr[j], arr[j+1] = arr[j+1], arr[j]",
            "                swapped = True",
            "        if not {{early}}: break",
            "    return arr"
        ],
        slots: [
            "ie":    PuzzleSlot(id: "ie",    label: "内側ループ終端", answer: "i + 1",  choices: ["i + 1", "i", "1"]),
            "nj":    PuzzleSlot(id: "nj",    label: "比較対象",       answer: "j + 1",  choices: ["j + 1", "j", "j - 1"]),
            "early": PuzzleSlot(id: "early", label: "早期終了条件",   answer: "swapped", choices: ["swapped", "arr", "i"])
        ]
    ),

    // 76. Insertion Sort
    PuzzleProblem(
        id: "insertion-sort", title: "Insertion Sort", difficulty: "Easy", topic: "Sorting",
        prompt: "挿入ソートで配列を昇順に並べてください。",
        example: "例: [12,11,13,5,6]  →  [5,6,11,12,13]",
        template: [
            "def insertion_sort(arr):",
            "    for i in range(1, len(arr)):",
            "        key = arr[i]",
            "        j = {{sj}}",
            "        while j >= 0 and arr[j] > {{cmp}}:",
            "            arr[j+1] = arr[{{fj}}]",
            "            j -= 1",
            "        arr[j+1] = key",
            "    return arr"
        ],
        slots: [
            "sj":  PuzzleSlot(id: "sj",  label: "j の初期値",  answer: "i - 1", choices: ["i - 1", "i", "0"]),
            "cmp": PuzzleSlot(id: "cmp", label: "比較対象",     answer: "key",   choices: ["key", "arr[i]", "arr[j+1]"]),
            "fj":  PuzzleSlot(id: "fj",  label: "シフト元",     answer: "j",     choices: ["j", "j + 1", "j - 1"])
        ]
    ),

    // 77. Selection Sort
    PuzzleProblem(
        id: "selection-sort", title: "Selection Sort", difficulty: "Easy", topic: "Sorting",
        prompt: "選択ソートで配列を昇順に並べてください。",
        example: "例: [64,25,12,22,11]  →  [11,12,22,25,64]",
        template: [
            "def selection_sort(arr):",
            "    n = len(arr)",
            "    for i in range(n):",
            "        min_i = i",
            "        for j in range({{inner}}, n):",
            "            if arr[j] < arr[{{ci}}]: min_i = j",
            "        arr[i], arr[{{si}}] = arr[min_i], arr[i]",
            "    return arr"
        ],
        slots: [
            "inner": PuzzleSlot(id: "inner", label: "内側の開始", answer: "i + 1", choices: ["i + 1", "i", "0"]),
            "ci":    PuzzleSlot(id: "ci",    label: "最小値の比較対象", answer: "min_i", choices: ["min_i", "i", "j"]),
            "si":    PuzzleSlot(id: "si",    label: "スワップ対象",    answer: "min_i", choices: ["min_i", "i", "j"])
        ]
    ),

    // 78. Counting Sort
    PuzzleProblem(
        id: "counting-sort", title: "Counting Sort", difficulty: "Easy", topic: "Sorting",
        prompt: "計数ソートで非負整数の配列を O(n+k) でソートしてください。",
        example: "例: arr=[4,2,2,8,3,3,1], max=8  →  [1,2,2,3,3,4,8]",
        template: [
            "def counting_sort(arr, max_val):",
            "    count = [0] * (max_val + 1)",
            "    for n in arr:",
            "        count[{{key}}] += 1",
            "    result = []",
            "    for val, freq in {{itr}}:",
            "        result.extend([val] * freq)",
            "    return result"
        ],
        slots: [
            "key": PuzzleSlot(id: "key", label: "カウントキー", answer: "n",               choices: ["n", "n - 1", "n + 1"]),
            "itr": PuzzleSlot(id: "itr", label: "イテレーション", answer: "enumerate(count)", choices: ["enumerate(count)", "count.items()", "zip(arr, count)"])
        ]
    ),

    // 79. Merge Sort
    PuzzleProblem(
        id: "merge-sort", title: "Merge Sort", difficulty: "Medium", topic: "Sorting / Divide & Conquer",
        prompt: "マージソートを実装してください。",
        example: "例: [38,27,43,3,9,82,10]  →  [3,9,10,27,38,43,82]",
        template: [
            "def merge_sort(arr):",
            "    if len(arr) <= 1: return arr",
            "    mid = {{mid}}",
            "    l = merge_sort(arr[:mid])",
            "    r = merge_sort(arr[{{rs}}:])",
            "    res, i, j = [], 0, 0",
            "    while i < len(l) and j < len(r):",
            "        if l[i] <= r[j]: res.append(l[i]); i += 1",
            "        else: res.append(r[j]); j += {{aj}}",
            "    return res + l[i:] + r[j:]"
        ],
        slots: [
            "mid": PuzzleSlot(id: "mid", label: "中点",        answer: "len(arr) // 2", choices: ["len(arr) // 2", "len(arr) - 1", "len(arr)"]),
            "rs":  PuzzleSlot(id: "rs",  label: "右半分スライス", answer: "mid",         choices: ["mid", "mid + 1", "mid - 1"]),
            "aj":  PuzzleSlot(id: "aj",  label: "jの増加量",    answer: "1",             choices: ["1", "2", "i"])
        ]
    ),

    // 80. Dutch National Flag
    PuzzleProblem(
        id: "dutch-flag", title: "Dutch National Flag", difficulty: "Medium", topic: "Two Pointers / Sorting",
        prompt: "0, 1, 2 のみからなる配列を in-place でソートしてください（3-way partition）。",
        example: "例: [2,0,2,1,1,0]  →  [0,0,1,1,2,2]",
        template: [
            "def sort_colors(nums):",
            "    lo = mid = 0; hi = len(nums) - 1",
            "    while mid <= {{bound}}:",
            "        if nums[mid] == 0:",
            "            nums[lo], nums[{{sm}}] = nums[mid], nums[lo]",
            "            lo += 1; mid += 1",
            "        elif nums[mid] == 1:",
            "            mid += {{inc}}",
            "        else:",
            "            nums[mid], nums[hi] = nums[hi], nums[mid]",
            "            hi -= 1",
            "    return nums"
        ],
        slots: [
            "bound": PuzzleSlot(id: "bound", label: "ループ境界",  answer: "hi",   choices: ["hi", "lo", "len(nums)"]),
            "sm":    PuzzleSlot(id: "sm",    label: "スワップ対象", answer: "mid",  choices: ["mid", "lo", "hi"]),
            "inc":   PuzzleSlot(id: "inc",   label: "midの増加量", answer: "1",    choices: ["1", "2", "0"])
        ]
    ),

    // 81. Balanced Binary Tree
    PuzzleProblem(
        id: "balanced-bt", title: "Balanced Binary Tree", difficulty: "Easy", topic: "Tree",
        prompt: "二分木が高さ平衡かどうか判定してください（任意ノードで左右の差≤1）。",
        example: "例: [3,9,20,null,null,15,7]  →  True",
        template: [
            "def is_balanced(root):",
            "    def h(node):",
            "        if not node: return 0",
            "        lh = h(node.left)",
            "        if lh == {{sentinel}}: return -1",
            "        rh = h(node.right)",
            "        if rh == -1: return -1",
            "        if abs(lh - rh) > {{thresh}}: return -1",
            "        return 1 + max(lh, rh)",
            "    return h(root) != {{chk}}"
        ],
        slots: [
            "sentinel": PuzzleSlot(id: "sentinel", label: "不平衡のセンチネル", answer: "-1", choices: ["-1", "0", "1"]),
            "thresh":   PuzzleSlot(id: "thresh",   label: "許容差",            answer: "1",  choices: ["1", "0", "2"]),
            "chk":      PuzzleSlot(id: "chk",      label: "不平衡チェック",    answer: "-1", choices: ["-1", "0", "1"])
        ]
    ),

    // 82. Build Tree from Inorder + Postorder
    PuzzleProblem(
        id: "build-tree-post", title: "Build Tree (Inorder+Postorder)", difficulty: "Medium", topic: "Tree / Divide & Conquer",
        prompt: "中順・後順のトラバーサル結果から二分木を再構成してください。",
        example: "例: inorder=[9,3,15,20,7], postorder=[9,15,7,20,3]  →  root=3",
        template: [
            "def build_tree(inorder, postorder):",
            "    if not postorder: return None",
            "    root = TreeNode(postorder[{{ri}}])",
            "    mid = inorder.index(root.val)",
            "    root.left  = build_tree(inorder[:mid],",
            "                            postorder[:{{pl}}])",
            "    root.right = build_tree(inorder[{{ir}}:],",
            "                            postorder[mid:-1])",
            "    return root"
        ],
        slots: [
            "ri": PuzzleSlot(id: "ri", label: "ルートのインデックス", answer: "-1",      choices: ["-1", "0", "len(postorder) // 2"]),
            "pl": PuzzleSlot(id: "pl", label: "左の後順終端",        answer: "mid",     choices: ["mid", "mid + 1", "len(inorder)"]),
            "ir": PuzzleSlot(id: "ir", label: "右の中順開始",        answer: "mid + 1", choices: ["mid + 1", "mid", "mid - 1"])
        ]
    ),

    // 83. LCA of Binary Tree (General)
    PuzzleProblem(
        id: "lca-bt", title: "LCA of Binary Tree", difficulty: "Medium", topic: "Tree",
        prompt: "一般の二分木で2ノード p, q の最低共通祖先を求めてください。",
        example: "例: tree=[3,5,1,6,2,0,8], p=5, q=1  →  node(3)",
        template: [
            "def lca(root, p, q):",
            "    if not root or root==p or root=={{cq}}: return root",
            "    left  = lca(root.{{gl}}, p, q)",
            "    right = lca(root.right, p, q)",
            "    if left and right: return {{both}}",
            "    return left {{or_op}} right"
        ],
        slots: [
            "cq":    PuzzleSlot(id: "cq",    label: "qとの一致確認", answer: "q",    choices: ["q", "p", "None"]),
            "gl":    PuzzleSlot(id: "gl",    label: "左へ再帰",      answer: "left", choices: ["left", "right", "val"]),
            "both":  PuzzleSlot(id: "both",  label: "両側で見つかった", answer: "root", choices: ["root", "left", "right"]),
            "or_op": PuzzleSlot(id: "or_op", label: "片側のみの場合", answer: "or",   choices: ["or", "and", "if left else"])
        ]
    ),

    // 84. Flatten BT to Linked List
    PuzzleProblem(
        id: "flatten-bt", title: "Flatten BT to Linked List", difficulty: "Medium", topic: "Tree",
        prompt: "二分木を前順でリンクリストに平坦化してください（in-place）。",
        example: "例: [1,2,5,3,4,null,6]  →  1→2→3→4→5→6",
        template: [
            "def flatten(root):",
            "    curr = root",
            "    while curr:",
            "        if curr.left:",
            "            pre = curr.left",
            "            while pre.{{trav}}: pre = pre.right",
            "            pre.right = curr.{{att}}",
            "            curr.right = curr.left",
            "            curr.left = {{clr}}",
            "        curr = curr.right"
        ],
        slots: [
            "trav": PuzzleSlot(id: "trav", label: "右端を探す",   answer: "right", choices: ["right", "left", "val"]),
            "att":  PuzzleSlot(id: "att",  label: "右を付け替え", answer: "right", choices: ["right", "left", "val"]),
            "clr":  PuzzleSlot(id: "clr",  label: "左をクリア",   answer: "None",  choices: ["None", "curr.right", "root"])
        ]
    ),

    // 85. Meeting Rooms II
    PuzzleProblem(
        id: "meeting-rooms", title: "Meeting Rooms II", difficulty: "Medium", topic: "Greedy / Heap",
        prompt: "全会議を開催するために必要な最小の会議室数を返してください。",
        example: "例: intervals=[[0,30],[5,10],[15,20]]  →  2",
        template: [
            "import heapq",
            "",
            "def min_rooms(intervals):",
            "    intervals.sort(key=lambda x: x[{{sk}}])",
            "    heap = []",
            "    for s, e in intervals:",
            "        if heap and heap[0] <= {{cmp}}:",
            "            heapq.heapreplace(heap, e)",
            "        else:",
            "            heapq.heappush(heap, {{push}})",
            "    return len(heap)"
        ],
        slots: [
            "sk":   PuzzleSlot(id: "sk",   label: "開始時刻でソート", answer: "0",   choices: ["0", "1", "-1"]),
            "cmp":  PuzzleSlot(id: "cmp",  label: "空き部屋の確認",  answer: "s",   choices: ["s", "e", "heap[-1]"]),
            "push": PuzzleSlot(id: "push", label: "終了時刻を追加",  answer: "e",   choices: ["e", "s", "e - s"])
        ]
    ),

    // 86. Decode Ways
    PuzzleProblem(
        id: "decode-ways", title: "Decode Ways", difficulty: "Medium", topic: "Dynamic Programming",
        prompt: "'A'=1〜'Z'=26 のマッピングで数字列のデコード方法の数を返してください。",
        example: "例: s='226'  →  3  ('BZ','VF','BBF')",
        template: [
            "def num_decodings(s):",
            "    if not s or s[0] == {{z}}: return 0",
            "    n = len(s)",
            "    dp = [0]*(n+1); dp[0]=1",
            "    dp[1] = 0 if s[0]=='0' else 1",
            "    for i in range(2, n+1):",
            "        one = int(s[i-1:i])",
            "        two = int(s[{{sl}}:i])",
            "        if one >= 1: dp[i] += dp[i-1]",
            "        if 10 <= two <= {{mx}}: dp[i] += dp[i-2]",
            "    return dp[n]"
        ],
        slots: [
            "z":  PuzzleSlot(id: "z",  label: "先頭0チェック", answer: "'0'", choices: ["'0'", "'1'", "None"]),
            "sl": PuzzleSlot(id: "sl", label: "2桁スライス",   answer: "i-2", choices: ["i-2", "i-1", "0"]),
            "mx": PuzzleSlot(id: "mx", label: "2桁の最大値",   answer: "26",  choices: ["26", "99", "20"])
        ]
    ),

    // 87. Minimum Path Sum
    PuzzleProblem(
        id: "min-path-sum", title: "Minimum Path Sum", difficulty: "Medium", topic: "Dynamic Programming",
        prompt: "グリッドの左上から右下へ右か下にしか進めないとき、最小コストを返してください。",
        example: "例: [[1,3,1],[1,5,1],[4,2,1]]  →  7",
        template: [
            "def min_path_sum(grid):",
            "    m, n = len(grid), len(grid[0])",
            "    for i in range(m):",
            "        for j in range(n):",
            "            if i==0 and j==0: continue",
            "            elif i==0: grid[i][j] += grid[i][j-1]",
            "            elif j==0: grid[i][j] += grid[{{ab}}][j]",
            "            else: grid[i][j] += min(grid[i-1][j], grid[i][{{lft}}])",
            "    return grid[{{ri}}][{{rj}}]"
        ],
        slots: [
            "ab":  PuzzleSlot(id: "ab",  label: "上からの参照", answer: "i-1", choices: ["i-1", "i", "i+1"]),
            "lft": PuzzleSlot(id: "lft", label: "左からの参照", answer: "j-1", choices: ["j-1", "j", "j+1"]),
            "ri":  PuzzleSlot(id: "ri",  label: "返り値の行",   answer: "m-1", choices: ["m-1", "0", "m"]),
            "rj":  PuzzleSlot(id: "rj",  label: "返り値の列",   answer: "n-1", choices: ["n-1", "0", "n"])
        ]
    ),

    // 88. Regular Expression Matching
    PuzzleProblem(
        id: "regex-matching", title: "Regular Expression Matching", difficulty: "Hard", topic: "Dynamic Programming",
        prompt: "パターン p（'.' は任意の1文字、'*' は0個以上の前文字）で文字列 s が完全一致するか判定してください。",
        example: "例: s='aa', p='a*'  →  True",
        template: [
            "def is_match(s, p):",
            "    m, n = len(s), len(p)",
            "    dp = [[False]*(n+1) for _ in range(m+1)]",
            "    dp[0][0] = True",
            "    for j in range(1, n+1):",
            "        if p[j-1] == {{star}}: dp[0][j] = dp[0][{{sb}}]",
            "    for i in range(1, m+1):",
            "        for j in range(1, n+1):",
            "            if p[j-1] == '*':",
            "                dp[i][j] = (dp[i][j-2] or",
            "                            (dp[{{pr}}][j] and",
            "                             (p[j-2]==s[i-1] or p[j-2]=='.')))",
            "            elif p[j-1]=='.' or p[j-1]==s[i-1]:",
            "                dp[i][j] = dp[i-1][{{dg}}]",
            "    return dp[m][n]"
        ],
        slots: [
            "star": PuzzleSlot(id: "star", label: "スター文字", answer: "'*'", choices: ["'*'", "'.'", "'?'"]),
            "sb":   PuzzleSlot(id: "sb",   label: "スター基底", answer: "j-2", choices: ["j-2", "j-1", "0"]),
            "pr":   PuzzleSlot(id: "pr",   label: "前行参照",   answer: "i-1", choices: ["i-1", "i", "i+1"]),
            "dg":   PuzzleSlot(id: "dg",   label: "対角参照",   answer: "j-1", choices: ["j-1", "j", "j+1"])
        ]
    ),

    // 89. Minimum Window Substring
    PuzzleProblem(
        id: "min-window-substring", title: "Minimum Window Substring", difficulty: "Hard", topic: "Sliding Window",
        prompt: "s の部分文字列で t の全文字を含む最小のものを返してください。",
        example: "例: s='ADOBECODEBANC', t='ABC'  →  'BANC'",
        template: [
            "from collections import Counter",
            "",
            "def min_window(s, t):",
            "    need = Counter(t); missing = {{init}}",
            "    l = 0; best = ''",
            "    for r, ch in enumerate(s, 1):",
            "        if need[ch] > 0: missing -= 1",
            "        need[ch] -= 1",
            "        if missing == 0:",
            "            while need[s[l]] < {{sh}}: need[s[l]]+=1; l+=1",
            "            win = s[l:r]",
            "            if not best or len(win)<len({{cb}}): best=win",
            "            need[s[l]]+=1; missing+=1; l+=1",
            "    return best"
        ],
        slots: [
            "init": PuzzleSlot(id: "init", label: "missing初期値", answer: "len(t)", choices: ["len(t)", "len(s)", "0"]),
            "sh":   PuzzleSlot(id: "sh",   label: "縮小条件",      answer: "0",      choices: ["0", "1", "-1"]),
            "cb":   PuzzleSlot(id: "cb",   label: "最良解の比較",  answer: "best",   choices: ["best", "win", "s"])
        ]
    ),

    // 90. Largest Rectangle in Histogram
    PuzzleProblem(
        id: "largest-rectangle", title: "Largest Rectangle in Histogram", difficulty: "Hard", topic: "Monotonic Stack",
        prompt: "ヒストグラムの中に収まる最大の長方形の面積を返してください。",
        example: "例: heights=[2,1,5,6,2,3]  →  10",
        template: [
            "def largest_rectangle(heights):",
            "    stack = []",
            "    max_a = 0",
            "    for i, h in enumerate(heights + {{sent}}):",
            "        start = i",
            "        while stack and stack[-1][1] >= h:",
            "            idx, height = stack.pop()",
            "            max_a = max(max_a, height * (i - {{wd}}))",
            "            start = {{ns}}",
            "        stack.append((start, h))",
            "    return max_a"
        ],
        slots: [
            "sent": PuzzleSlot(id: "sent", label: "番兵の追加",  answer: "[0]",  choices: ["[0]", "[heights[0]]", "[]"]),
            "wd":   PuzzleSlot(id: "wd",   label: "幅の計算",    answer: "idx",  choices: ["idx", "start", "i"]),
            "ns":   PuzzleSlot(id: "ns",   label: "start更新",   answer: "idx",  choices: ["idx", "i", "start"])
        ]
    ),

    // 91. Longest Valid Parentheses
    PuzzleProblem(
        id: "longest-valid-parens", title: "Longest Valid Parentheses", difficulty: "Hard", topic: "Stack / DP",
        prompt: "括弧の文字列で有効な括弧の最長部分文字列の長さを返してください。",
        example: "例: s=')()())'  →  4",
        template: [
            "def longest_valid(s):",
            "    stack = [{{init}}]",
            "    max_len = 0",
            "    for i, ch in enumerate(s):",
            "        if ch == '(':",
            "            stack.append(i)",
            "        else:",
            "            stack.{{rem}}()",
            "            if not stack:",
            "                stack.append(i)",
            "            else:",
            "                max_len = max(max_len, i - {{base}})",
            "    return max_len"
        ],
        slots: [
            "init": PuzzleSlot(id: "init", label: "スタック初期値", answer: "-1",        choices: ["-1", "0", "None"]),
            "rem":  PuzzleSlot(id: "rem",  label: "スタックから削除", answer: "pop",     choices: ["pop", "append", "popleft"]),
            "base": PuzzleSlot(id: "base", label: "長さの基底",     answer: "stack[-1]", choices: ["stack[-1]", "stack[0]", "i"])
        ]
    ),

    // 92. Serialize / Deserialize Binary Tree
    PuzzleProblem(
        id: "serialize-bt", title: "Serialize Binary Tree", difficulty: "Hard", topic: "Tree / BFS",
        prompt: "BFS で二分木をシリアライズし、デシリアライズしてください。",
        example: "例: serialize([1,2,3,null,null,4,5])  →  '1,2,3,N,N,4,5'",
        template: [
            "from collections import deque",
            "",
            "def serialize(root):",
            "    if not root: return ''",
            "    q, res = deque([root]), []",
            "    while q:",
            "        node = q.popleft()",
            "        if node:",
            "            res.append(str(node.val))",
            "            q.append({{lch}}); q.append(node.right)",
            "        else: res.append({{ns}})",
            "    return ','.join(res)",
            "",
            "def deserialize(data):",
            "    if not data: return None",
            "    vals = data.split(',')",
            "    root = TreeNode(int(vals[0]))",
            "    q = deque([root]); i = {{si}}",
            "    while q:",
            "        node = q.popleft()",
            "        for side in ['left','right']:",
            "            if vals[i]!='N':",
            "                setattr(node,side,TreeNode(int(vals[i])))",
            "                q.append(getattr(node,side))",
            "            i+=1",
            "    return root"
        ],
        slots: [
            "lch": PuzzleSlot(id: "lch", label: "左の子をキューへ", answer: "node.left", choices: ["node.left", "node.right", "root"]),
            "ns":  PuzzleSlot(id: "ns",  label: "Nullの表現",      answer: "'N'",        choices: ["'N'", "'#'", "'null'"]),
            "si":  PuzzleSlot(id: "si",  label: "デシリアライズ開始", answer: "1",        choices: ["1", "0", "2"])
        ]
    ),

    // 93. Wildcard Matching
    PuzzleProblem(
        id: "wildcard-matching", title: "Wildcard Matching", difficulty: "Hard", topic: "Dynamic Programming",
        prompt: "'?' は任意の1文字、'*' は任意の文字列（空含む）にマッチするパターンマッチを実装してください。",
        example: "例: s='adceb', p='*a*b'  →  True",
        template: [
            "def is_match(s, p):",
            "    m, n = len(s), len(p)",
            "    dp = [[False]*(n+1) for _ in range(m+1)]",
            "    dp[0][0] = True",
            "    for j in range(1, n+1):",
            "        if p[j-1] == {{wc}}: dp[0][j] = dp[0][{{wb}}]",
            "    for i in range(1, m+1):",
            "        for j in range(1, n+1):",
            "            if p[j-1] == '*':",
            "                dp[i][j] = dp[i-1][j] or dp[i][{{sp}}]",
            "            elif p[j-1]=='?' or p[j-1]==s[i-1]:",
            "                dp[i][j] = dp[{{di}}][j-1]",
            "    return dp[m][n]"
        ],
        slots: [
            "wc": PuzzleSlot(id: "wc", label: "ワイルドカード文字", answer: "'*'", choices: ["'*'", "'?'", "'.'"]),
            "wb": PuzzleSlot(id: "wb", label: "スター基底条件",     answer: "j-1", choices: ["j-1", "j", "j+1"]),
            "sp": PuzzleSlot(id: "sp", label: "スターの遷移",       answer: "j-1", choices: ["j-1", "j", "j+1"]),
            "di": PuzzleSlot(id: "di", label: "対角参照",           answer: "i-1", choices: ["i-1", "i", "i+1"])
        ]
    ),

    // 94. KMP Failure Function
    PuzzleProblem(
        id: "kmp-lps", title: "KMP Failure Function", difficulty: "Hard", topic: "String / KMP",
        prompt: "KMP の失敗関数（LPS 配列）を計算してください。",
        example: "例: pattern='AAACAAAA'  →  [0,1,2,0,1,2,3,3]",
        template: [
            "def compute_lps(pattern):",
            "    m = len(pattern)",
            "    lps = [0] * m",
            "    length = 0; i = {{start}}",
            "    while i < m:",
            "        if pattern[i] == pattern[{{cj}}]:",
            "            length += 1",
            "            lps[i] = length; i += 1",
            "        else:",
            "            if length != 0:",
            "                length = lps[{{back}}]",
            "            else:",
            "                lps[i] = 0; i += 1",
            "    return lps"
        ],
        slots: [
            "start": PuzzleSlot(id: "start", label: "開始インデックス", answer: "1",        choices: ["1", "0", "2"]),
            "cj":    PuzzleSlot(id: "cj",    label: "比較対象",        answer: "length",   choices: ["length", "i", "i - 1"]),
            "back":  PuzzleSlot(id: "back",  label: "フォールバック",  answer: "length - 1", choices: ["length - 1", "length", "i - 1"])
        ]
    ),

    // 95. Median of Two Sorted Arrays
    PuzzleProblem(
        id: "median-two-arrays", title: "Median of Two Sorted Arrays", difficulty: "Hard", topic: "Binary Search",
        prompt: "2つのソート済み配列のメジアンを O(log(m+n)) で求めてください。",
        example: "例: A=[1,3], B=[2]  →  2.0",
        template: [
            "def find_median(A, B):",
            "    if len(A)>len(B): A,B=B,A",
            "    m,n=len(A),len(B)",
            "    lo,hi=0,m",
            "    while lo<=hi:",
            "        i=(lo+hi)//2; j={{jc}}",
            "        Al=A[i-1] if i>0 else float('-inf')",
            "        Ar=A[i]   if i<m else float('inf')",
            "        Bl=B[j-1] if j>0 else float('-inf')",
            "        Br=B[j]   if j<n else float('inf')",
            "        if Al<=Br and {{chk}}:",
            "            if (m+n)%2==1: return float({{odd}})",
            "            return (max(Al,Bl)+min(Ar,Br))/2.0",
            "        elif Al>Br: hi=i-1",
            "        else: lo=i+1",
            "    return 0.0"
        ],
        slots: [
            "jc":  PuzzleSlot(id: "jc",  label: "jの計算",    answer: "(m+n+1)//2 - i", choices: ["(m+n+1)//2 - i", "(m+n)//2 - i", "m+n-i"]),
            "chk": PuzzleSlot(id: "chk", label: "パーティション条件", answer: "Bl<=Ar",  choices: ["Bl<=Ar", "Bl>=Ar", "Bl<Ar"]),
            "odd": PuzzleSlot(id: "odd", label: "奇数長のメジアン",   answer: "max(Al,Bl)", choices: ["max(Al,Bl)", "min(Ar,Br)", "(Al+Bl)/2"])
        ]
    ),

    // 96. Minimum Spanning Tree (Kruskal's)
    PuzzleProblem(
        id: "kruskal", title: "Minimum Spanning Tree (Kruskal)", difficulty: "Hard", topic: "Graph / Union Find",
        prompt: "Kruskal 法で最小全域木のコストを求めてください。",
        example: "例: n=4, edges=[[0,1,1],[1,2,2],[0,2,4],[1,3,3]]  →  6",
        template: [
            "def kruskal(n, edges):",
            "    parent = list(range(n))",
            "    def find(x):",
            "        while parent[x]!=x:",
            "            parent[x]=parent[parent[x]]; x=parent[{{fc}}]",
            "        return x",
            "    edges.sort(key=lambda e: e[{{sk}}])",
            "    cost = 0",
            "    for u,v,w in edges:",
            "        pu,pv=find(u),find(v)",
            "        if pu!=pv:",
            "            parent[pu]={{mg}}; cost+=w",
            "    return cost"
        ],
        slots: [
            "fc": PuzzleSlot(id: "fc", label: "経路圧縮",   answer: "x",  choices: ["x", "parent[x]", "0"]),
            "sk": PuzzleSlot(id: "sk", label: "重みでソート", answer: "2", choices: ["2", "0", "1"]),
            "mg": PuzzleSlot(id: "mg", label: "マージ先",    answer: "pv", choices: ["pv", "pu", "u"])
        ]
    ),

    // 97. Jump Game II
    PuzzleProblem(
        id: "jump-game-ii", title: "Jump Game II", difficulty: "Medium", topic: "Greedy",
        prompt: "最後まで到達するのに必要な最小ジャンプ数を返してください。",
        example: "例: nums=[2,3,1,1,4]  →  2",
        template: [
            "def jump(nums):",
            "    jumps = cur_end = far = 0",
            "    for i in range(len(nums) - 1):",
            "        far = max(far, {{reach}})",
            "        if i == {{bound}}:",
            "            jumps += 1",
            "            cur_end = far",
            "    return jumps"
        ],
        slots: [
            "reach": PuzzleSlot(id: "reach", label: "到達可能な最大", answer: "i + nums[i]", choices: ["i + nums[i]", "nums[i]", "i + far"]),
            "bound": PuzzleSlot(id: "bound", label: "ジャンプ境界",   answer: "cur_end",     choices: ["cur_end", "far", "len(nums) - 1"])
        ]
    ),

    // 98. Pascal's Triangle
    PuzzleProblem(
        id: "pascals-triangle", title: "Pascal's Triangle", difficulty: "Easy", topic: "Array / DP",
        prompt: "パスカルの三角形の最初の numRows 行を返してください。",
        example: "例: numRows=5  →  [[1],[1,1],[1,2,1],[1,3,3,1],[1,4,6,4,1]]",
        template: [
            "def generate(numRows):",
            "    triangle = [[1]]",
            "    for i in range(1, numRows):",
            "        prev = triangle[{{prev_row}}]",
            "        row = [1] + [prev[j] + prev[{{nj}}] for j in range(len(prev)-1)] + [1]",
            "        triangle.append({{add_row}})",
            "    return triangle"
        ],
        slots: [
            "prev_row": PuzzleSlot(id: "prev_row", label: "前の行を取得", answer: "-1",  choices: ["-1", "0", "i"]),
            "nj":       PuzzleSlot(id: "nj",       label: "隣接インデックス", answer: "j+1", choices: ["j+1", "j", "j-1"]),
            "add_row":  PuzzleSlot(id: "add_row",  label: "行を追加",    answer: "row", choices: ["row", "prev", "[row]"])
        ]
    ),

    // 99. Best Time to Buy and Sell Stock
    PuzzleProblem(
        id: "buy-sell-stock", title: "Best Time to Buy/Sell Stock", difficulty: "Easy", topic: "Array / Greedy",
        prompt: "1回だけ売買できるとき、最大利益を返してください。利益が出ない場合は 0。",
        example: "例: prices=[7,1,5,3,6,4]  →  5",
        template: [
            "def max_profit(prices):",
            "    min_p = float('inf')",
            "    profit = 0",
            "    for p in prices:",
            "        min_p = min(min_p, {{um}})",
            "        profit = max(profit, {{up}})",
            "    return profit"
        ],
        slots: [
            "um": PuzzleSlot(id: "um", label: "最安値の更新", answer: "p",          choices: ["p", "profit", "min_p"]),
            "up": PuzzleSlot(id: "up", label: "利益の更新",   answer: "p - min_p",  choices: ["p - min_p", "min_p - p", "p + min_p"])
        ]
    ),

    // 100. Spiral Matrix
    PuzzleProblem(
        id: "spiral-matrix", title: "Spiral Matrix", difficulty: "Medium", topic: "Array / Simulation",
        prompt: "m×n の行列の全要素をスパイラル順に返してください。",
        example: "例: [[1,2,3],[4,5,6],[7,8,9]]  →  [1,2,3,6,9,8,7,4,5]",
        template: [
            "def spiral_order(matrix):",
            "    res=[]",
            "    top,bottom=0,len(matrix)-1",
            "    left,right=0,len(matrix[0])-1",
            "    while top<=bottom and left<=right:",
            "        for c in range(left, right+1): res.append(matrix[{{t}}][c])",
            "        top += 1",
            "        for r in range(top, bottom+1): res.append(matrix[r][right])",
            "        right -= 1",
            "        if top<=bottom:",
            "            for c in range(right, left-1, {{st}}): res.append(matrix[bottom][c])",
            "            bottom -= 1",
            "        if left<=right:",
            "            for r in range(bottom, top-1, -1): res.append(matrix[r][{{cl}}])",
            "            left += 1",
            "    return res"
        ],
        slots: [
            "t":  PuzzleSlot(id: "t",  label: "上辺の行",  answer: "top",  choices: ["top", "bottom", "left"]),
            "st": PuzzleSlot(id: "st", label: "下辺のstep", answer: "-1",  choices: ["-1", "1", "0"]),
            "cl": PuzzleSlot(id: "cl", label: "左辺の列",  answer: "left", choices: ["left", "right", "top"])
        ]
    )
]

// MARK: - Problems 1–50
private let p1_50: [PuzzleProblem] = [

    // 1. Binary Search
    PuzzleProblem(
        id: "binary-search", title: "Binary Search", difficulty: "Easy", topic: "Binary Search",
        prompt: "昇順ソート済み配列 nums から target の index を返してください。見つからない場合は -1。",
        example: "例: nums = [-1,0,3,5,9,12],  target = 9  →  4",
        template: [
            "def search(nums, target):",
            "    left = 0",
            "    right = {{right_init}}",
            "    while {{loop_cond}}:",
            "        mid = (left + right) // 2",
            "        if nums[mid] == target:",
            "            return mid",
            "        elif nums[mid] < target:",
            "            left = {{left_upd}}",
            "        else:",
            "            right = {{right_upd}}",
            "    return -1"
        ],
        slots: [
            "right_init": PuzzleSlot(id: "right_init", label: "初期 right",  answer: "len(nums) - 1", choices: ["len(nums)", "len(nums) - 1", "target - 1"]),
            "loop_cond":  PuzzleSlot(id: "loop_cond",  label: "while条件",   answer: "left <= right",  choices: ["left < right", "left <= right", "left >= right"]),
            "left_upd":   PuzzleSlot(id: "left_upd",   label: "left更新",    answer: "mid + 1",        choices: ["mid", "mid - 1", "mid + 1"]),
            "right_upd":  PuzzleSlot(id: "right_upd",  label: "right更新",   answer: "mid - 1",        choices: ["mid - 1", "mid", "mid + 1"])
        ],
        explanation: "ソート済み配列に対し、毎ステップで探索範囲を半分に絞り込みます。mid = (l+r)/2 を比較し、target より小さければ左半分を捨てて l = mid+1、大きければ右半分を捨てて r = mid-1。範囲が交差した時点で見つからないと確定し -1 を返します。計算量は O(log n)。"
    ),

    // 2. Two Sum
    PuzzleProblem(
        id: "two-sum", title: "Two Sum", difficulty: "Easy", topic: "Hash Map",
        prompt: "配列 nums の中から合計が target になる2つの要素の index を返してください。",
        example: "例: nums = [2,7,11,15],  target = 9  →  [0, 1]",
        template: [
            "def two_sum(nums, target):",
            "    seen = {}",
            "    for i, n in enumerate(nums):",
            "        diff = {{diff_expr}}",
            "        if diff in seen:",
            "            return [seen[diff], i]",
            "        seen[{{seen_key}}] = {{seen_val}}"
        ],
        slots: [
            "diff_expr": PuzzleSlot(id: "diff_expr", label: "差分式",  answer: "target - n", choices: ["n - target", "target - n", "target + n"]),
            "seen_key":  PuzzleSlot(id: "seen_key",  label: "辞書キー", answer: "n",          choices: ["i", "n", "diff"]),
            "seen_val":  PuzzleSlot(id: "seen_val",  label: "辞書値",  answer: "i",          choices: ["i", "n", "target"])
        ]
    ),

    // 3. Valid Parentheses
    PuzzleProblem(
        id: "valid-parentheses", title: "Valid Parentheses", difficulty: "Easy", topic: "Stack",
        prompt: "文字列 s の括弧が正しく対応しているか判定してください。",
        example: "例: s = '()[]{}'  →  True",
        template: [
            "def is_valid(s):",
            "    stack = []",
            "    pairs = {')':'(', ']':'[', '}':'{'}",
            "    for ch in s:",
            "        if ch in pairs.values():",
            "            stack.append(ch)",
            "        else:",
            "            if {{empty_check}}:",
            "                return False",
            "            if stack.pop() != pairs[ch]:",
            "                return False",
            "    return {{final_check}}"
        ],
        slots: [
            "empty_check": PuzzleSlot(id: "empty_check", label: "空スタック判定", answer: "not stack",  choices: ["not stack", "stack", "len(stack) > 0"]),
            "final_check": PuzzleSlot(id: "final_check", label: "最終判定",      answer: "not stack",  choices: ["True", "not stack", "len(stack) > 0"])
        ]
    ),

    // 4. Fibonacci (Memoization)
    PuzzleProblem(
        id: "fibonacci-memo", title: "Fibonacci (Memo)", difficulty: "Easy", topic: "Dynamic Programming",
        prompt: "メモ化再帰で n 番目のフィボナッチ数を求めてください（fib(0)=0, fib(1)=1）。",
        example: "例: fib(6)  →  8",
        template: [
            "def fib(n, memo={}):",
            "    if n <= 1:",
            "        return n",
            "    if {{cache_check}}:",
            "        return memo[n]",
            "    memo[n] = fib({{rec1}}, memo) + fib({{rec2}}, memo)",
            "    return memo[n]"
        ],
        slots: [
            "cache_check": PuzzleSlot(id: "cache_check", label: "キャッシュ確認", answer: "n in memo", choices: ["n in memo", "memo[n]", "n > 1"]),
            "rec1":        PuzzleSlot(id: "rec1",        label: "再帰1",         answer: "n - 1",     choices: ["n - 1", "n - 2", "n + 1"]),
            "rec2":        PuzzleSlot(id: "rec2",        label: "再帰2",         answer: "n - 2",     choices: ["n - 2", "n - 1", "n + 2"])
        ]
    ),

    // 5. Maximum Subarray (Kadane's)
    PuzzleProblem(
        id: "max-subarray", title: "Maximum Subarray", difficulty: "Medium", topic: "DP / Array",
        prompt: "配列 nums の連続部分配列の最大和を返してください（Kadane's Algorithm）。",
        example: "例: nums = [-2,1,-3,4,-1,2,1,-5,4]  →  6",
        template: [
            "def max_subarray(nums):",
            "    cur = max_sum = nums[0]",
            "    for n in nums[1:]:",
            "        cur = {{cur_upd}}",
            "        max_sum = {{max_upd}}",
            "    return max_sum"
        ],
        slots: [
            "cur_upd": PuzzleSlot(id: "cur_upd", label: "cur更新",     answer: "max(n, cur + n)",    choices: ["max(n, cur + n)", "max(0, cur + n)", "cur + n"]),
            "max_upd": PuzzleSlot(id: "max_upd", label: "max_sum更新", answer: "max(max_sum, cur)",  choices: ["max(max_sum, cur)", "max(max_sum, n)", "max_sum + cur"])
        ]
    ),

    // 6. Reverse Linked List
    PuzzleProblem(
        id: "reverse-linked-list", title: "Reverse Linked List", difficulty: "Easy", topic: "Linked List",
        prompt: "連結リストを逆順にして新しい先頭ノードを返してください。",
        example: "例: 1→2→3→4→5  →  5→4→3→2→1",
        template: [
            "def reverse_list(head):",
            "    prev = None",
            "    curr = head",
            "    while curr:",
            "        nxt = curr.next",
            "        curr.next = {{point_to}}",
            "        prev = {{adv_prev}}",
            "        curr = nxt",
            "    return {{ret_val}}"
        ],
        slots: [
            "point_to": PuzzleSlot(id: "point_to", label: "next付け替え先", answer: "prev",  choices: ["prev", "nxt", "None"]),
            "adv_prev": PuzzleSlot(id: "adv_prev", label: "prev更新",      answer: "curr",  choices: ["curr", "nxt", "prev"]),
            "ret_val":  PuzzleSlot(id: "ret_val",  label: "返り値",         answer: "prev",  choices: ["prev", "curr", "head"])
        ]
    ),

    // 7. BFS
    PuzzleProblem(
        id: "bfs", title: "BFS", difficulty: "Easy", topic: "Graph / BFS",
        prompt: "グラフを幅優先探索し、訪問済みノードの集合を返してください。",
        example: "例: graph={0:[1,2],1:[3]},  start=0  →  {0,1,2,3}",
        template: [
            "from collections import deque",
            "",
            "def bfs(graph, start):",
            "    visited = set([start])",
            "    queue = deque([start])",
            "    while queue:",
            "        node = queue.{{deq}}()",
            "        for nb in graph[node]:",
            "            if nb not in visited:",
            "                visited.add(nb)",
            "                queue.{{enq}}(nb)",
            "    return visited"
        ],
        slots: [
            "deq": PuzzleSlot(id: "deq", label: "取り出し(FIFO)", answer: "popleft", choices: ["popleft", "pop", "append"]),
            "enq": PuzzleSlot(id: "enq", label: "追加方向",       answer: "append",  choices: ["append", "appendleft", "popleft"])
        ]
    ),

    // 8. DFS (Iterative)
    PuzzleProblem(
        id: "dfs-iterative", title: "DFS (Iterative)", difficulty: "Easy", topic: "Graph / DFS",
        prompt: "スタックを使った反復 DFS でグラフを探索し、訪問済みノード集合を返してください。",
        example: "例: graph={0:[1,2],1:[3]},  start=0  →  {0,1,2,3}",
        template: [
            "def dfs(graph, start):",
            "    visited = set()",
            "    stack = [start]",
            "    while {{loop_cond}}:",
            "        node = stack.{{pop_m}}()",
            "        if node not in visited:",
            "            visited.add(node)",
            "            for nb in graph[node]:",
            "                stack.append({{push}})",
            "    return visited"
        ],
        slots: [
            "loop_cond": PuzzleSlot(id: "loop_cond", label: "ループ条件",       answer: "stack",  choices: ["stack", "visited", "True"]),
            "pop_m":     PuzzleSlot(id: "pop_m",     label: "取り出し(LIFO)",   answer: "pop",    choices: ["pop", "popleft", "append"]),
            "push":      PuzzleSlot(id: "push",      label: "スタックに積む値", answer: "nb",     choices: ["nb", "node", "start"])
        ]
    ),

    // 9. Longest Substring Without Repeating
    PuzzleProblem(
        id: "longest-substring", title: "Longest Substring", difficulty: "Medium", topic: "Sliding Window",
        prompt: "同じ文字を含まない最長の部分文字列の長さを返してください。",
        example: "例: s = 'abcabcbb'  →  3  ('abc')",
        template: [
            "def length_of_longest_substring(s):",
            "    char_set = set()",
            "    left = 0",
            "    max_len = 0",
            "    for right in range(len(s)):",
            "        while {{shrink}}:",
            "            char_set.remove(s[left])",
            "            left += 1",
            "        char_set.add(s[right])",
            "        max_len = max(max_len, {{win}})",
            "    return max_len"
        ],
        slots: [
            "shrink": PuzzleSlot(id: "shrink", label: "縮小条件",   answer: "s[right] in char_set", choices: ["s[right] in char_set", "left > right", "right >= len(s)"]),
            "win":    PuzzleSlot(id: "win",    label: "ウィンドウ幅", answer: "right - left + 1",    choices: ["right - left + 1", "right - left", "right + 1"])
        ]
    ),

    // 10. Quicksort
    PuzzleProblem(
        id: "quicksort", title: "Quicksort", difficulty: "Medium", topic: "Sorting",
        prompt: "ピボットを中央要素とし、再帰的に配列をソートしてください（関数型スタイル）。",
        example: "例: [3,6,8,10,1,2]  →  [1,2,3,6,8,10]",
        template: [
            "def quicksort(arr):",
            "    if len(arr) <= {{base}}:",
            "        return arr",
            "    pivot = arr[{{pivot}}]",
            "    left  = [x for x in arr if x < pivot]",
            "    mid   = [x for x in arr if x == pivot]",
            "    right = [x for x in arr if x > pivot]",
            "    return quicksort({{l_arg}}) + mid + quicksort(right)"
        ],
        slots: [
            "base":  PuzzleSlot(id: "base",  label: "基底条件",    answer: "1",             choices: ["1", "0", "2"]),
            "pivot": PuzzleSlot(id: "pivot", label: "ピボット位置", answer: "len(arr) // 2", choices: ["len(arr) // 2", "0", "-1"]),
            "l_arg": PuzzleSlot(id: "l_arg", label: "左再帰の引数", answer: "left",          choices: ["left", "mid", "right"])
        ]
    ),

    // 11. Climbing Stairs
    PuzzleProblem(
        id: "climbing-stairs", title: "Climbing Stairs", difficulty: "Easy", topic: "Dynamic Programming",
        prompt: "n 段の階段を1または2段ずつ登る場合の方法の数を返してください。",
        example: "例: n = 5  →  8",
        template: [
            "def climb_stairs(n):",
            "    dp = [0] * (n + 1)",
            "    dp[1] = 1",
            "    dp[2] = {{dp2}}",
            "    for i in range(3, n + 1):",
            "        dp[i] = {{recur}}",
            "    return dp[n]"
        ],
        slots: [
            "dp2":  PuzzleSlot(id: "dp2",  label: "dp[2]の初期値", answer: "2",                 choices: ["2", "1", "3"]),
            "recur": PuzzleSlot(id: "recur", label: "漸化式",       answer: "dp[i-1] + dp[i-2]", choices: ["dp[i-1] + dp[i-2]", "dp[i-1] * dp[i-2]", "dp[i-2] + dp[i-3]"])
        ]
    ),

    // 12. House Robber
    PuzzleProblem(
        id: "house-robber", title: "House Robber", difficulty: "Medium", topic: "Dynamic Programming",
        prompt: "隣接する家は同時に盗めない条件で、盗める最大金額を返してください。",
        example: "例: nums = [2,7,9,3,1]  →  12",
        template: [
            "def rob(nums):",
            "    if not nums: return 0",
            "    n = len(nums)",
            "    dp = [0] * (n + 1)",
            "    dp[1] = {{dp1}}",
            "    for i in range(2, n + 1):",
            "        dp[i] = max(dp[{{prev1}}], dp[i-2] + nums[i-1])",
            "    return dp[n]"
        ],
        slots: [
            "dp1":  PuzzleSlot(id: "dp1",  label: "dp[1]の初期値", answer: "nums[0]",           choices: ["nums[0]", "0", "nums[1]"]),
            "prev1": PuzzleSlot(id: "prev1", label: "直前を参照",    answer: "i-1",               choices: ["i-1", "i-2", "i"])
        ]
    ),

    // 13. Coin Change
    PuzzleProblem(
        id: "coin-change", title: "Coin Change", difficulty: "Medium", topic: "Dynamic Programming",
        prompt: "コインで amount を作る最小枚数を返してください。不可能なら -1。",
        example: "例: coins=[1,5,10], amount=11  →  2",
        template: [
            "def coin_change(coins, amount):",
            "    dp = [float('inf')] * (amount + 1)",
            "    dp[{{base}}] = 0",
            "    for i in range(1, amount + 1):",
            "        for c in coins:",
            "            if c <= i:",
            "                dp[i] = min(dp[i], dp[{{sub}}] + 1)",
            "    return dp[amount] if dp[amount] != float('inf') else -1"
        ],
        slots: [
            "base": PuzzleSlot(id: "base", label: "基底条件",   answer: "0",     choices: ["0", "1", "amount"]),
            "sub":  PuzzleSlot(id: "sub",  label: "部分問題",   answer: "i - c", choices: ["i - c", "i - 1", "c"])
        ]
    ),

    // 14. Longest Common Subsequence
    PuzzleProblem(
        id: "lcs", title: "Longest Common Subsequence", difficulty: "Medium", topic: "Dynamic Programming",
        prompt: "2つの文字列の最長共通部分列の長さを返してください。",
        example: "例: text1='abcde', text2='ace'  →  3",
        template: [
            "def lcs(text1, text2):",
            "    m, n = len(text1), len(text2)",
            "    dp = [[0]*(n+1) for _ in range(m+1)]",
            "    for i in range(1, m+1):",
            "        for j in range(1, n+1):",
            "            if text1[i-1] == text2[j-1]:",
            "                dp[i][j] = {{match}}",
            "            else:",
            "                dp[i][j] = {{mismatch}}",
            "    return dp[m][n]"
        ],
        slots: [
            "match":    PuzzleSlot(id: "match",    label: "一致時",  answer: "dp[i-1][j-1] + 1",          choices: ["dp[i-1][j-1] + 1", "dp[i][j-1] + 1", "dp[i-1][j-1]"]),
            "mismatch": PuzzleSlot(id: "mismatch", label: "不一致時", answer: "max(dp[i-1][j], dp[i][j-1])", choices: ["max(dp[i-1][j], dp[i][j-1])", "dp[i-1][j-1]", "dp[i-1][j] + dp[i][j-1]"])
        ]
    ),

    // 15. Longest Increasing Subsequence
    PuzzleProblem(
        id: "lis", title: "LIS", difficulty: "Medium", topic: "Dynamic Programming",
        prompt: "配列の最長増加部分列の長さを返してください。",
        example: "例: nums = [10,9,2,5,3,7,101,18]  →  4",
        template: [
            "def length_of_lis(nums):",
            "    dp = [1] * len(nums)",
            "    for i in range(1, len(nums)):",
            "        for j in range({{inner}}):",
            "            if nums[j] < nums[i]:",
            "                dp[i] = max(dp[i], dp[j] + {{add}})",
            "    return max(dp)"
        ],
        slots: [
            "inner": PuzzleSlot(id: "inner", label: "内側のrange", answer: "i",  choices: ["i", "len(nums)", "i + 1"]),
            "add":   PuzzleSlot(id: "add",   label: "加算値",      answer: "1",  choices: ["1", "2", "dp[i]"])
        ]
    ),

    // 16. Jump Game
    PuzzleProblem(
        id: "jump-game", title: "Jump Game", difficulty: "Medium", topic: "Greedy",
        prompt: "各要素が最大ジャンプ距離を示す配列で、最後まで到達できるか判定してください。",
        example: "例: nums = [2,3,1,1,4]  →  True",
        template: [
            "def can_jump(nums):",
            "    reach = 0",
            "    for i, n in enumerate(nums):",
            "        if i > {{check}}:",
            "            return False",
            "        reach = max(reach, {{upd}})",
            "    return True"
        ],
        slots: [
            "check": PuzzleSlot(id: "check", label: "到達不可条件", answer: "reach",  choices: ["reach", "n", "len(nums)"]),
            "upd":   PuzzleSlot(id: "upd",   label: "reach更新",   answer: "i + n",  choices: ["i + n", "reach + 1", "n"])
        ]
    ),

    // 17. Word Break
    PuzzleProblem(
        id: "word-break", title: "Word Break", difficulty: "Medium", topic: "Dynamic Programming",
        prompt: "文字列 s が word_dict の単語だけで構成できるか判定してください。",
        example: "例: s='leetcode', dict=['leet','code']  →  True",
        template: [
            "def word_break(s, word_dict):",
            "    n = len(s)",
            "    dp = [False] * (n + 1)",
            "    dp[{{base}}] = True",
            "    for i in range(1, n + 1):",
            "        for j in range(i):",
            "            if dp[j] and s[{{sl}}] in word_dict:",
            "                dp[i] = True; break",
            "    return dp[n]"
        ],
        slots: [
            "base": PuzzleSlot(id: "base", label: "基底条件", answer: "0",   choices: ["0", "1", "n"]),
            "sl":   PuzzleSlot(id: "sl",   label: "スライス", answer: "j:i", choices: ["j:i", "i:j", "j:n"])
        ]
    ),

    // 18. Edit Distance
    PuzzleProblem(
        id: "edit-distance", title: "Edit Distance", difficulty: "Hard", topic: "Dynamic Programming",
        prompt: "word1 を word2 に変換する最小の編集操作数（挿入/削除/置換）を返してください。",
        example: "例: word1='horse', word2='ros'  →  3",
        template: [
            "def edit_dist(w1, w2):",
            "    m, n = len(w1), len(w2)",
            "    dp = [[0]*(n+1) for _ in range(m+1)]",
            "    for i in range(m+1): dp[i][0] = {{row}}",
            "    for j in range(n+1): dp[0][j] = j",
            "    for i in range(1, m+1):",
            "        for j in range(1, n+1):",
            "            if w1[i-1] == w2[j-1]:",
            "                dp[i][j] = dp[{{diag}}][j-1]",
            "            else:",
            "                dp[i][j] = 1 + min(dp[i-1][j], dp[i][j-1], dp[i-1][j-1])",
            "    return dp[m][n]"
        ],
        slots: [
            "row":  PuzzleSlot(id: "row",  label: "行の初期化", answer: "i",   choices: ["i", "j", "0"]),
            "diag": PuzzleSlot(id: "diag", label: "対角参照",   answer: "i-1", choices: ["i-1", "i", "i+1"])
        ]
    ),

    // 19. 0-1 Knapsack
    PuzzleProblem(
        id: "knapsack", title: "0-1 Knapsack", difficulty: "Medium", topic: "Dynamic Programming",
        prompt: "重さと価値が与えられた n 個のアイテムから、重さ W 以内で最大価値を求めてください。",
        example: "例: W=4, wt=[1,3,4], val=[1,4,5]  →  5",
        template: [
            "def knapsack(W, wt, val):",
            "    n = len(wt)",
            "    dp = [[0]*(W+1) for _ in range(n+1)]",
            "    for i in range(1, n+1):",
            "        for w in range(W+1):",
            "            if wt[i-1] <= w:",
            "                dp[i][w] = max(dp[{{prev}}][w],",
            "                              dp[i-1][w-wt[i-1]] + {{vali}})",
            "            else:",
            "                dp[i][w] = dp[i-1][{{sw}}]",
            "    return dp[n][W]"
        ],
        slots: [
            "prev": PuzzleSlot(id: "prev", label: "前行参照",  answer: "i-1",      choices: ["i-1", "i", "i+1"]),
            "vali": PuzzleSlot(id: "vali", label: "価値の追加", answer: "val[i-1]", choices: ["val[i-1]", "wt[i-1]", "1"]),
            "sw":   PuzzleSlot(id: "sw",   label: "同重さ参照", answer: "w",        choices: ["w", "w-1", "0"])
        ]
    ),

    // 20. Unique Paths
    PuzzleProblem(
        id: "unique-paths", title: "Unique Paths", difficulty: "Easy", topic: "Dynamic Programming",
        prompt: "m×n のグリッドの左上から右下へ、右か下にしか進めない場合の経路数を返してください。",
        example: "例: m=3, n=7  →  28",
        template: [
            "def unique_paths(m, n):",
            "    dp = [[1] * {{cols}} for _ in range(m)]",
            "    for i in range(1, m):",
            "        for j in range(1, n):",
            "            dp[i][j] = dp[{{rf}}][j] + dp[i][{{cf}}]",
            "    return dp[{{ret}}][n-1]"
        ],
        slots: [
            "cols": PuzzleSlot(id: "cols", label: "列数",      answer: "n",   choices: ["n", "m", "n + 1"]),
            "rf":   PuzzleSlot(id: "rf",   label: "上からの参照", answer: "i-1", choices: ["i-1", "i", "i+1"]),
            "cf":   PuzzleSlot(id: "cf",   label: "左からの参照", answer: "j-1", choices: ["j-1", "j", "j+1"]),
            "ret":  PuzzleSlot(id: "ret",  label: "返り値の行",   answer: "m-1", choices: ["m-1", "0", "m"])
        ]
    ),

    // 21. Number of Islands
    PuzzleProblem(
        id: "num-islands", title: "Number of Islands", difficulty: "Medium", topic: "Graph / DFS",
        prompt: "グリッドで '1'(陸)と '0'(水)が与えられる。島の数を返してください。",
        example: "例: 2×2グリッド [['1','1'],['0','1']]  →  1",
        template: [
            "def num_islands(grid):",
            "    def dfs(i, j):",
            "        if not (0<=i<len(grid) and 0<=j<len(grid[0])): return",
            "        if grid[i][j] != {{tgt}}: return",
            "        grid[i][j] = {{vis}}",
            "        for di,dj in [(1,0),(-1,0),(0,1),(0,-1)]:",
            "            dfs(i+di, {{nj}})",
            "    count = 0",
            "    for i in range(len(grid)):",
            "        for j in range(len(grid[0])):",
            "            if grid[i][j] == '1':",
            "                dfs(i, j); count += 1",
            "    return count"
        ],
        slots: [
            "tgt": PuzzleSlot(id: "tgt", label: "探索対象",  answer: "'1'", choices: ["'1'", "'0'", "1"]),
            "vis": PuzzleSlot(id: "vis", label: "訪問済みマーク", answer: "'0'", choices: ["'0'", "'#'", "'1'"]),
            "nj":  PuzzleSlot(id: "nj",  label: "隣接j計算",  answer: "j+dj", choices: ["j+dj", "j", "dj"])
        ]
    ),

    // 22. Course Schedule
    PuzzleProblem(
        id: "course-schedule", title: "Course Schedule", difficulty: "Medium", topic: "Graph / Topological",
        prompt: "前提条件リストが循環しているか判定し、全コース受講可能なら True を返してください。",
        example: "例: n=2, prereqs=[[1,0]]  →  True",
        template: [
            "def can_finish(n, prereqs):",
            "    g = [[] for _ in range(n)]",
            "    for a, b in prereqs:",
            "        g[b].append({{edge}})",
            "    state = [0] * n",
            "    def dfs(v):",
            "        if state[v] == {{cyc}}: return False",
            "        if state[v] == 2: return True",
            "        state[v] = 1",
            "        for nb in g[v]:",
            "            if not dfs({{rec}}): return False",
            "        state[v] = {{done}}; return True",
            "    return all(dfs(i) for i in range(n))"
        ],
        slots: [
            "edge": PuzzleSlot(id: "edge", label: "エッジの向き", answer: "a",  choices: ["a", "b", "0"]),
            "cyc":  PuzzleSlot(id: "cyc",  label: "サイクル判定値", answer: "1",  choices: ["1", "2", "0"]),
            "rec":  PuzzleSlot(id: "rec",  label: "再帰引数",      answer: "nb", choices: ["nb", "v", "g[v]"]),
            "done": PuzzleSlot(id: "done", label: "完了マーク",    answer: "2",  choices: ["2", "1", "0"])
        ]
    ),

    // 23. Topological Sort (Kahn's)
    PuzzleProblem(
        id: "topo-sort", title: "Topological Sort", difficulty: "Medium", topic: "Graph / BFS",
        prompt: "Kahn's Algorithm でトポロジカル順序を求めてください。",
        example: "例: n=4, edges=[[0,1],[1,2],[2,3]]  →  [0,1,2,3]",
        template: [
            "from collections import deque",
            "",
            "def topo_sort(n, edges):",
            "    indeg = [0]*n; adj = [[] for _ in range(n)]",
            "    for u,v in edges:",
            "        adj[u].append(v); indeg[{{inc}}] += 1",
            "    q = deque(i for i in range(n) if indeg[i] == {{zero}})",
            "    order = []",
            "    while q:",
            "        u = q.popleft(); order.append(u)",
            "        for v in adj[u]:",
            "            indeg[v] -= 1",
            "            if indeg[v] == {{rdy}}: q.append(v)",
            "    return order if len(order) == {{chk}} else []"
        ],
        slots: [
            "inc":  PuzzleSlot(id: "inc",  label: "in次数を増やす対象", answer: "v",  choices: ["v", "u", "0"]),
            "zero": PuzzleSlot(id: "zero", label: "初期キュー条件",     answer: "0",  choices: ["0", "1", "-1"]),
            "rdy":  PuzzleSlot(id: "rdy",  label: "追加条件",          answer: "0",  choices: ["0", "1", "-1"]),
            "chk":  PuzzleSlot(id: "chk",  label: "完全性チェック",     answer: "n",  choices: ["n", "len(edges)", "0"])
        ]
    ),

    // 24. Union Find
    PuzzleProblem(
        id: "union-find", title: "Union Find", difficulty: "Medium", topic: "Graph / Union Find",
        prompt: "Union-Find データ構造を実装してください（経路圧縮・ランク付き）。",
        example: "例: UF(5); union(0,1); find(0)==find(1)  →  True",
        template: [
            "class UF:",
            "    def __init__(self, n):",
            "        self.parent = list(range({{init}}))",
            "        self.rank = [0]*n",
            "    def find(self, x):",
            "        if self.parent[x] != x:",
            "            self.parent[x] = self.find({{compress}})",
            "        return self.parent[x]",
            "    def union(self, x, y):",
            "        px,py = self.find(x),self.find(y)",
            "        if px==py: return",
            "        if self.rank[px]<self.rank[py]: px,py=py,px",
            "        self.parent[{{child}}] = px",
            "        if self.rank[px]==self.rank[py]: self.rank[px]+=1"
        ],
        slots: [
            "init":     PuzzleSlot(id: "init",     label: "初期化",   answer: "n",               choices: ["n", "n + 1", "0"]),
            "compress": PuzzleSlot(id: "compress", label: "経路圧縮", answer: "self.parent[x]",  choices: ["self.parent[x]", "x", "0"]),
            "child":    PuzzleSlot(id: "child",    label: "子ノード", answer: "py",              choices: ["py", "px", "y"])
        ]
    ),

    // 25. Dijkstra's
    PuzzleProblem(
        id: "dijkstra", title: "Dijkstra's Algorithm", difficulty: "Hard", topic: "Graph / Shortest Path",
        prompt: "重み付きグラフの単一始点最短路を求めてください（Dijkstra）。",
        example: "例: graph={0:[(1,4),(2,1)],1:[(3,1)],2:[(1,2),(3,5)],3:[]}, src=0\n→ {0:0, 1:3, 2:1, 3:4}",
        template: [
            "import heapq",
            "",
            "def dijkstra(graph, src):",
            "    dist = {v: float('inf') for v in graph}",
            "    dist[src] = {{init_d}}",
            "    pq = [(0, src)]",
            "    while pq:",
            "        d, u = heapq.{{pop}}(pq)",
            "        if d > dist[u]: continue",
            "        for v, w in graph[u]:",
            "            if dist[u]+w < dist[{{nb}}]:",
            "                dist[v] = dist[u]+w",
            "                heapq.heappush(pq, (dist[v], v))",
            "    return dist"
        ],
        slots: [
            "init_d": PuzzleSlot(id: "init_d", label: "始点の距離",    answer: "0",        choices: ["0", "1", "float('inf')"]),
            "pop":    PuzzleSlot(id: "pop",    label: "最小取り出し",   answer: "heappop",  choices: ["heappop", "heappush", "heapify"]),
            "nb":     PuzzleSlot(id: "nb",     label: "隣接ノード参照", answer: "v",        choices: ["v", "u", "src"])
        ]
    ),

    // 26. Merge Two Sorted Lists
    PuzzleProblem(
        id: "merge-two-lists", title: "Merge Two Sorted Lists", difficulty: "Easy", topic: "Linked List",
        prompt: "ソート済み2つの連結リストを1つにマージしてください。",
        example: "例: 1→2→4  と  1→3→4  →  1→1→2→3→4→4",
        template: [
            "def merge(l1, l2):",
            "    dummy = ListNode(0); curr = dummy",
            "    while l1 and l2:",
            "        if l1.val <= l2.val:",
            "            curr.next = l1",
            "            l1 = {{adv_l1}}",
            "        else:",
            "            curr.next = l2",
            "            l2 = l2.next",
            "        curr = curr.{{adv_c}}",
            "    curr.next = {{tail}}",
            "    return dummy.next"
        ],
        slots: [
            "adv_l1": PuzzleSlot(id: "adv_l1", label: "l1を進める",   answer: "l1.next",   choices: ["l1.next", "l2.next", "None"]),
            "adv_c":  PuzzleSlot(id: "adv_c",  label: "currを進める", answer: "next",      choices: ["next", "val", "prev"]),
            "tail":   PuzzleSlot(id: "tail",   label: "残りの接続",   answer: "l1 or l2",  choices: ["l1 or l2", "None", "l1 and l2"])
        ]
    ),

    // 27. Detect Cycle (Floyd's)
    PuzzleProblem(
        id: "detect-cycle", title: "Detect Cycle (Floyd's)", difficulty: "Easy", topic: "Linked List",
        prompt: "連結リストが循環しているか判定してください（Floyd's 亀とウサギ）。",
        example: "例: 1→2→3→4→2(cycle)  →  True",
        template: [
            "def has_cycle(head):",
            "    slow = fast = head",
            "    while {{cond}}:",
            "        slow = slow.next",
            "        fast = fast.{{step}}",
            "        if slow == fast:",
            "            return {{found}}",
            "    return False"
        ],
        slots: [
            "cond":  PuzzleSlot(id: "cond",  label: "ループ条件",   answer: "fast and fast.next",  choices: ["fast and fast.next", "fast", "slow != fast"]),
            "step":  PuzzleSlot(id: "step",  label: "fastのステップ", answer: "next.next",           choices: ["next.next", "next", "prev"]),
            "found": PuzzleSlot(id: "found", label: "サイクル検出",  answer: "True",                choices: ["True", "False", "slow"])
        ]
    ),

    // 28. Add Two Numbers (LL)
    PuzzleProblem(
        id: "add-two-numbers", title: "Add Two Numbers", difficulty: "Medium", topic: "Linked List",
        prompt: "連結リストで逆順に表された2数を加算し、結果を連結リストで返してください。",
        example: "例: 2→4→3  +  5→6→4  →  7→0→8  (342+465=807)",
        template: [
            "def add_two_numbers(l1, l2):",
            "    dummy = ListNode(0); curr = dummy; carry = 0",
            "    while l1 or l2 or {{cc}}:",
            "        v1 = l1.val if l1 else 0",
            "        v2 = l2.val if l2 else 0",
            "        total = v1 + v2 + carry",
            "        carry = {{nc}}",
            "        curr.next = ListNode({{dig}})",
            "        curr = curr.next",
            "        l1 = l1.next if l1 else None",
            "        l2 = l2.next if l2 else None",
            "    return dummy.next"
        ],
        slots: [
            "cc":  PuzzleSlot(id: "cc",  label: "繰り上がり条件", answer: "carry",      choices: ["carry", "l1 and l2", "False"]),
            "nc":  PuzzleSlot(id: "nc",  label: "次の繰り上がり", answer: "total // 10", choices: ["total // 10", "total % 10", "total - 10"]),
            "dig": PuzzleSlot(id: "dig", label: "桁の値",         answer: "total % 10", choices: ["total % 10", "total // 10", "total"])
        ]
    ),

    // 29. Intersection of Two Linked Lists
    PuzzleProblem(
        id: "intersection-ll", title: "Intersection of Two LLs", difficulty: "Easy", topic: "Linked List",
        prompt: "2つの連結リストが交差するノードを返してください。ない場合は None。",
        example: "例: A:4→1→8→4→5,  B:5→6→1→8→4→5  →  node(8)",
        template: [
            "def get_intersection(hA, hB):",
            "    a, b = hA, hB",
            "    while a != b:",
            "        a = a.next if a else {{sa}}",
            "        b = b.next if b else {{sb}}",
            "    return a"
        ],
        slots: [
            "sa": PuzzleSlot(id: "sa", label: "Aのスイッチ先", answer: "hB", choices: ["hB", "hA", "None"]),
            "sb": PuzzleSlot(id: "sb", label: "Bのスイッチ先", answer: "hA", choices: ["hA", "hB", "None"])
        ]
    ),

    // 30. Middle of Linked List
    PuzzleProblem(
        id: "middle-ll", title: "Middle of Linked List", difficulty: "Easy", topic: "Linked List",
        prompt: "連結リストの中央ノードを返してください（偶数個の場合は2番目の中央）。",
        example: "例: 1→2→3→4→5  →  node(3)",
        template: [
            "def middle_node(head):",
            "    slow = fast = head",
            "    while fast and fast.{{chk}}:",
            "        slow = slow.next",
            "        fast = fast.next.{{stp}}",
            "    return slow"
        ],
        slots: [
            "chk": PuzzleSlot(id: "chk", label: "fastの確認",   answer: "next",  choices: ["next", "val", "prev"]),
            "stp": PuzzleSlot(id: "stp", label: "fastのステップ", answer: "next",  choices: ["next", "next.next", "val"])
        ]
    ),

    // 31. Inorder Traversal (Iterative)
    PuzzleProblem(
        id: "inorder-iter", title: "Inorder Traversal", difficulty: "Easy", topic: "Tree",
        prompt: "スタックを使った反復中順走査を実装してください。",
        example: "例: BST [4,2,6,1,3]  →  [1,2,3,4,6]",
        template: [
            "def inorder(root):",
            "    res, stack, curr = [], [], root",
            "    while curr or {{extra}}:",
            "        while curr:",
            "            stack.append(curr)",
            "            curr = curr.{{left}}",
            "        curr = stack.pop()",
            "        res.append(curr.val)",
            "        curr = curr.{{right}}",
            "    return res"
        ],
        slots: [
            "extra": PuzzleSlot(id: "extra", label: "ループ継続条件", answer: "stack", choices: ["stack", "res", "curr"]),
            "left":  PuzzleSlot(id: "left",  label: "左へ進む",      answer: "left",  choices: ["left", "right", "val"]),
            "right": PuzzleSlot(id: "right", label: "右へ進む",      answer: "right", choices: ["right", "left", "next"])
        ]
    ),

    // 32. Level Order Traversal
    PuzzleProblem(
        id: "level-order", title: "Level Order Traversal", difficulty: "Easy", topic: "Tree / BFS",
        prompt: "二分木の幅優先探索（レベル順）を実装してください。",
        example: "例: [3,9,20,null,null,15,7]  →  [[3],[9,20],[15,7]]",
        template: [
            "from collections import deque",
            "",
            "def level_order(root):",
            "    if not root: return []",
            "    res, q = [], deque([root])",
            "    while q:",
            "        level = []",
            "        for _ in range({{sz}}):",
            "            node = q.{{deq}}()",
            "            level.append(node.val)",
            "            if node.left:  q.append(node.left)",
            "            if node.right: q.append(node.right)",
            "        res.append(level)",
            "    return res"
        ],
        slots: [
            "sz":  PuzzleSlot(id: "sz",  label: "レベルのサイズ",  answer: "len(q)",   choices: ["len(q)", "q.maxlen", "1"]),
            "deq": PuzzleSlot(id: "deq", label: "取り出し(FIFO)",  answer: "popleft",  choices: ["popleft", "pop", "append"])
        ]
    ),

    // 33. Maximum Depth of Binary Tree
    PuzzleProblem(
        id: "max-depth-bt", title: "Max Depth of BT", difficulty: "Easy", topic: "Tree",
        prompt: "二分木の最大深さ（ルートから最遠リーフまでのノード数）を返してください。",
        example: "例: [3,9,20,null,null,15,7]  →  3",
        template: [
            "def max_depth(root):",
            "    if not root: return {{base}}",
            "    return 1 + max(max_depth(root.{{lft}}),",
            "                   max_depth(root.{{rgt}}))"
        ],
        slots: [
            "base": PuzzleSlot(id: "base", label: "基底条件",  answer: "0",     choices: ["0", "1", "-1"]),
            "lft":  PuzzleSlot(id: "lft",  label: "左の再帰",  answer: "left",  choices: ["left", "right", "val"]),
            "rgt":  PuzzleSlot(id: "rgt",  label: "右の再帰",  answer: "right", choices: ["right", "left", "next"])
        ]
    ),

    // 34. Validate BST
    PuzzleProblem(
        id: "validate-bst", title: "Validate BST", difficulty: "Medium", topic: "Tree",
        prompt: "二分木が有効な BST（二分探索木）かどうか検証してください。",
        example: "例: [2,1,3]  →  True  /  [5,1,4,null,null,3,6]  →  False",
        template: [
            "def is_valid_bst(root, lo=float('-inf'), hi=float('inf')):",
            "    if not root: return {{base}}",
            "    if root.val <= lo or root.val >= hi: return False",
            "    return (is_valid_bst(root.left, lo, {{lhi}}) and",
            "            is_valid_bst(root.right, {{rlo}}, hi))"
        ],
        slots: [
            "base": PuzzleSlot(id: "base", label: "基底条件",  answer: "True",     choices: ["True", "False", "None"]),
            "lhi":  PuzzleSlot(id: "lhi",  label: "左の上限",  answer: "root.val", choices: ["root.val", "hi", "lo"]),
            "rlo":  PuzzleSlot(id: "rlo",  label: "右の下限",  answer: "root.val", choices: ["root.val", "lo", "hi"])
        ]
    ),

    // 35. LCA of BST
    PuzzleProblem(
        id: "lca-bst", title: "LCA of BST", difficulty: "Easy", topic: "Tree",
        prompt: "BST において2つのノード p, q の最低共通祖先（LCA）を返してください。",
        example: "例: BST=[6,2,8,0,4,7,9], p=2, q=8  →  node(6)",
        template: [
            "def lca(root, p, q):",
            "    while root:",
            "        if p.val < root.val and q.val < root.val:",
            "            root = root.{{gl}}",
            "        elif p.val > root.val and q.val > root.val:",
            "            root = root.{{gr}}",
            "        else:",
            "            return {{ret}}",
            "    return None"
        ],
        slots: [
            "gl":  PuzzleSlot(id: "gl",  label: "左へ移動",  answer: "left",  choices: ["left", "right", "val"]),
            "gr":  PuzzleSlot(id: "gr",  label: "右へ移動",  answer: "right", choices: ["right", "left", "next"]),
            "ret": PuzzleSlot(id: "ret", label: "LCA を返す", answer: "root",  choices: ["root", "p", "q"])
        ]
    ),

    // 36. Kth Smallest in BST
    PuzzleProblem(
        id: "kth-smallest-bst", title: "Kth Smallest in BST", difficulty: "Medium", topic: "Tree",
        prompt: "BST の中で k 番目に小さい値を返してください。",
        example: "例: BST=[3,1,4,null,2], k=1  →  1",
        template: [
            "def kth_smallest(root, k):",
            "    stack, curr, cnt = [], root, 0",
            "    while curr or stack:",
            "        while curr:",
            "            stack.append(curr); curr = curr.{{lft}}",
            "        curr = stack.pop()",
            "        cnt += {{inc}}",
            "        if cnt == k: return curr.{{attr}}",
            "        curr = curr.right",
            "    return -1"
        ],
        slots: [
            "lft":  PuzzleSlot(id: "lft",  label: "左へ進む",  answer: "left",  choices: ["left", "right", "val"]),
            "inc":  PuzzleSlot(id: "inc",  label: "カウント増加", answer: "1",   choices: ["1", "k", "cnt"]),
            "attr": PuzzleSlot(id: "attr", label: "返す属性",   answer: "val",  choices: ["val", "left", "right"])
        ]
    ),

    // 37. Invert Binary Tree
    PuzzleProblem(
        id: "invert-bt", title: "Invert Binary Tree", difficulty: "Easy", topic: "Tree",
        prompt: "二分木を左右反転して返してください。",
        example: "例: [4,2,7,1,3,6,9]  →  [4,7,2,9,6,3,1]",
        template: [
            "def invert_tree(root):",
            "    if not root: return {{base}}",
            "    root.left, root.right = {{swap}}",
            "    invert_tree(root.left)",
            "    invert_tree(root.right)",
            "    return root"
        ],
        slots: [
            "base": PuzzleSlot(id: "base", label: "基底条件",  answer: "None",                  choices: ["None", "root", "False"]),
            "swap": PuzzleSlot(id: "swap", label: "左右の入れ替え", answer: "root.right, root.left", choices: ["root.right, root.left", "root.left, root.right", "None, None"])
        ]
    ),

    // 38. Symmetric Tree
    PuzzleProblem(
        id: "symmetric-tree", title: "Symmetric Tree", difficulty: "Easy", topic: "Tree",
        prompt: "二分木が左右対称かどうか判定してください。",
        example: "例: [1,2,2,3,4,4,3]  →  True",
        template: [
            "def is_symmetric(root):",
            "    def check(l, r):",
            "        if not l and not r: return True",
            "        if not l or not r: return {{ne}}",
            "        return (l.val == r.val and",
            "                check(l.left, {{ir}}) and",
            "                check(l.right, r.left))",
            "    return check(root.{{sl}}, root.right)"
        ],
        slots: [
            "ne": PuzzleSlot(id: "ne", label: "片方がNone", answer: "False",   choices: ["False", "True", "None"]),
            "ir": PuzzleSlot(id: "ir", label: "右の内側",   answer: "r.right", choices: ["r.right", "r.left", "l.right"]),
            "sl": PuzzleSlot(id: "sl", label: "開始ノード", answer: "left",    choices: ["left", "right", "val"])
        ]
    ),

    // 39. Path Sum
    PuzzleProblem(
        id: "path-sum", title: "Path Sum", difficulty: "Easy", topic: "Tree",
        prompt: "ルートからリーフまでの合計が target と等しいパスが存在するか判定してください。",
        example: "例: tree=[5,4,8,11,null,13,4,7,2], target=22  →  True",
        template: [
            "def has_path_sum(root, target):",
            "    if not root: return {{base}}",
            "    if not root.left and not root.right:",
            "        return root.val == {{leaf}}",
            "    return (has_path_sum(root.left, target - {{sub}}) or",
            "            has_path_sum(root.right, target - root.val))"
        ],
        slots: [
            "base": PuzzleSlot(id: "base", label: "基底条件",     answer: "False",    choices: ["False", "True", "target == 0"]),
            "leaf": PuzzleSlot(id: "leaf", label: "リーフの判定", answer: "target",   choices: ["target", "0", "root.val"]),
            "sub":  PuzzleSlot(id: "sub",  label: "残りの合計",   answer: "root.val", choices: ["root.val", "target", "1"])
        ]
    ),

    // 40. Diameter of Binary Tree
    PuzzleProblem(
        id: "diameter-bt", title: "Diameter of Binary Tree", difficulty: "Medium", topic: "Tree",
        prompt: "二分木の直径（任意の2ノード間の最長経路のエッジ数）を返してください。",
        example: "例: [1,2,3,4,5]  →  3",
        template: [
            "def diameter(root):",
            "    ans = [0]",
            "    def depth(node):",
            "        if not node: return {{base}}",
            "        l, r = depth(node.left), depth(node.right)",
            "        ans[0] = max(ans[0], {{diam}})",
            "        return 1 + max(l, {{mr}})",
            "    depth(root); return ans[0]"
        ],
        slots: [
            "base": PuzzleSlot(id: "base", label: "基底条件",  answer: "0",     choices: ["0", "-1", "1"]),
            "diam": PuzzleSlot(id: "diam", label: "直径の更新", answer: "l + r", choices: ["l + r", "l + r + 1", "max(l, r)"]),
            "mr":   PuzzleSlot(id: "mr",   label: "高さの計算", answer: "r",     choices: ["r", "l", "l + r"])
        ]
    ),

    // 41. Next Greater Element
    PuzzleProblem(
        id: "next-greater", title: "Next Greater Element", difficulty: "Medium", topic: "Monotonic Stack",
        prompt: "各要素の「次の大きい要素」を返してください（なければ -1）。",
        example: "例: nums = [4,1,2,3]  →  [-1,2,3,-1]",
        template: [
            "def next_greater(nums):",
            "    res = [-1] * len(nums)",
            "    stack = []",
            "    for i, n in enumerate(nums):",
            "        while stack and nums[{{top}}] < n:",
            "            idx = stack.pop()",
            "            res[idx] = {{assign}}",
            "        stack.append({{push}})",
            "    return res"
        ],
        slots: [
            "top":    PuzzleSlot(id: "top",    label: "スタック先頭", answer: "stack[-1]", choices: ["stack[-1]", "stack[0]", "stack.pop()"]),
            "assign": PuzzleSlot(id: "assign", label: "結果に代入",   answer: "n",         choices: ["n", "i", "nums[i-1]"]),
            "push":   PuzzleSlot(id: "push",   label: "スタックに積む", answer: "i",        choices: ["i", "n", "res[i]"])
        ]
    ),

    // 42. Min Stack
    PuzzleProblem(
        id: "min-stack", title: "Min Stack", difficulty: "Easy", topic: "Stack / Design",
        prompt: "push / pop / get_min を O(1) でサポートするスタックを実装してください。",
        example: "例: push(-2),push(0),push(-3),get_min()→-3, pop(), get_min()→-2",
        template: [
            "class MinStack:",
            "    def __init__(self):",
            "        self.stack = []; self.mins = []",
            "    def push(self, val):",
            "        self.stack.append(val)",
            "        m = val if not self.mins else {{mv}}",
            "        self.mins.append(m)",
            "    def pop(self):",
            "        self.stack.pop(); self.mins.{{mp}}()",
            "    def get_min(self):",
            "        return self.mins[{{idx}}]"
        ],
        slots: [
            "mv":  PuzzleSlot(id: "mv",  label: "最小値の更新",  answer: "min(val, self.mins[-1])",  choices: ["min(val, self.mins[-1])", "min(val, self.stack[-1])", "self.mins[-1]"]),
            "mp":  PuzzleSlot(id: "mp",  label: "minスタック削除", answer: "pop",                     choices: ["pop", "append", "clear"]),
            "idx": PuzzleSlot(id: "idx", label: "最小値の取得",   answer: "-1",                      choices: ["-1", "0", "1"])
        ]
    ),

    // 43. LRU Cache
    PuzzleProblem(
        id: "lru-cache", title: "LRU Cache", difficulty: "Medium", topic: "Design / Hash Map",
        prompt: "LRU（最近最も使われていない）キャッシュを OrderedDict で実装してください。",
        example: "例: cap=2; put(1,1);put(2,2);get(1)→1; put(3,3); get(2)→-1",
        template: [
            "from collections import OrderedDict",
            "",
            "class LRUCache:",
            "    def __init__(self, cap):",
            "        self.cap = cap; self.cache = OrderedDict()",
            "    def get(self, key):",
            "        if key not in self.cache: return -1",
            "        self.cache.{{mv}}(key); return self.cache[key]",
            "    def put(self, key, value):",
            "        if key in self.cache: self.cache.move_to_end(key)",
            "        self.cache[key] = value",
            "        if len(self.cache) > self.cap:",
            "            self.cache.{{evict}}(last=False)"
        ],
        slots: [
            "mv":    PuzzleSlot(id: "mv",    label: "最近使用に移動", answer: "move_to_end", choices: ["move_to_end", "popitem", "update"]),
            "evict": PuzzleSlot(id: "evict", label: "最古を削除",     answer: "popitem",     choices: ["popitem", "pop", "move_to_end"])
        ]
    ),

    // 44. Kth Largest Element
    PuzzleProblem(
        id: "kth-largest", title: "Kth Largest Element", difficulty: "Medium", topic: "Heap",
        prompt: "サイズ k の最小ヒープを使い、配列の k 番目に大きい要素を求めてください。",
        example: "例: nums=[3,2,1,5,6,4], k=2  →  5",
        template: [
            "import heapq",
            "",
            "def find_kth_largest(nums, k):",
            "    heap = []",
            "    for n in nums:",
            "        heapq.{{push}}(heap, n)",
            "        if len(heap) > k:",
            "            heapq.{{pop_s}}(heap)",
            "    return heap[{{top}}]"
        ],
        slots: [
            "push":  PuzzleSlot(id: "push",  label: "ヒープに追加",   answer: "heappush",  choices: ["heappush", "heappop", "heapify"]),
            "pop_s": PuzzleSlot(id: "pop_s", label: "最小値を削除",   answer: "heappop",   choices: ["heappop", "heappush", "heapreplace"]),
            "top":   PuzzleSlot(id: "top",   label: "k番目の取得",    answer: "0",         choices: ["0", "-1", "k - 1"])
        ]
    ),

    // 45. Top K Frequent Elements
    PuzzleProblem(
        id: "top-k-freq", title: "Top K Frequent", difficulty: "Medium", topic: "Heap / Hash Map",
        prompt: "配列中に最も多く出現する k 個の要素を返してください。",
        example: "例: nums=[1,1,1,2,2,3], k=2  →  [1,2]",
        template: [
            "from collections import Counter",
            "import heapq",
            "",
            "def top_k_frequent(nums, k):",
            "    freq = Counter({{inp}})",
            "    heap = []",
            "    for num, cnt in freq.items():",
            "        heapq.heappush(heap, ({{hk}}, num))",
            "        if len(heap) > k: heapq.heappop(heap)",
            "    return [x[{{ext}}] for x in heap]"
        ],
        slots: [
            "inp": PuzzleSlot(id: "inp", label: "カウント対象", answer: "nums",  choices: ["nums", "freq", "k"]),
            "hk":  PuzzleSlot(id: "hk",  label: "ヒープキー",   answer: "cnt",   choices: ["cnt", "-cnt", "num"]),
            "ext": PuzzleSlot(id: "ext", label: "要素の取り出し", answer: "1",    choices: ["1", "0", "-1"])
        ]
    ),

    // 46. Trie Insert
    PuzzleProblem(
        id: "trie-insert", title: "Trie Insert", difficulty: "Easy", topic: "Trie",
        prompt: "Trie（プレフィックスツリー）への挿入を実装してください。",
        example: "例: insert('apple') → 'apple' が検索可能になる",
        template: [
            "class TrieNode:",
            "    def __init__(self):",
            "        self.children = {}; self.is_end = False",
            "",
            "def insert(root, word):",
            "    node = root",
            "    for ch in word:",
            "        if ch not in node.children:",
            "            node.children[ch] = {{nn}}",
            "        node = node.children[{{key}}]",
            "    node.{{end}} = True"
        ],
        slots: [
            "nn":  PuzzleSlot(id: "nn",  label: "新しいノード", answer: "TrieNode()", choices: ["TrieNode()", "Trie()", "{}"]),
            "key": PuzzleSlot(id: "key", label: "辞書のキー",   answer: "ch",         choices: ["ch", "word", "node"]),
            "end": PuzzleSlot(id: "end", label: "終端フラグ",   answer: "is_end",     choices: ["is_end", "end", "children"])
        ]
    ),

    // 47. Trie Search
    PuzzleProblem(
        id: "trie-search", title: "Trie Search", difficulty: "Easy", topic: "Trie",
        prompt: "Trie から単語を検索し、完全一致すれば True を返してください。",
        example: "例: insert('apple'); search('apple')→True; search('app')→False",
        template: [
            "def search(root, word):",
            "    node = root",
            "    for ch in word:",
            "        if ch not in node.children:",
            "            return {{nf}}",
            "        node = node.children[ch]",
            "    return {{found}}"
        ],
        slots: [
            "nf":    PuzzleSlot(id: "nf",    label: "見つからない", answer: "False",      choices: ["False", "True", "None"]),
            "found": PuzzleSlot(id: "found", label: "終端チェック", answer: "node.is_end", choices: ["node.is_end", "True", "node.children == {}"])
        ]
    ),

    // 48. Sliding Window Maximum
    PuzzleProblem(
        id: "sliding-window-max", title: "Sliding Window Maximum", difficulty: "Hard", topic: "Deque / Sliding Window",
        prompt: "サイズ k のスライディングウィンドウ内の最大値を返してください。",
        example: "例: nums=[1,3,-1,-3,5,3,6,7], k=3  →  [3,3,5,5,6,7]",
        template: [
            "from collections import deque",
            "",
            "def max_sliding_window(nums, k):",
            "    dq, res = deque(), []",
            "    for i, n in enumerate(nums):",
            "        while dq and nums[{{back}}] < n:",
            "            dq.pop()",
            "        dq.append(i)",
            "        if dq[{{front}}] < i - k + 1:",
            "            dq.popleft()",
            "        if i >= {{start}}:",
            "            res.append(nums[dq[0]])",
            "    return res"
        ],
        slots: [
            "back":  PuzzleSlot(id: "back",  label: "後端インデックス", answer: "dq[-1]",  choices: ["dq[-1]", "dq[0]", "i"]),
            "front": PuzzleSlot(id: "front", label: "前端インデックス", answer: "0",       choices: ["0", "-1", "1"]),
            "start": PuzzleSlot(id: "start", label: "出力開始位置",    answer: "k - 1",   choices: ["k - 1", "k", "0"])
        ]
    ),

    // 49. Permutations
    PuzzleProblem(
        id: "permutations", title: "Permutations", difficulty: "Medium", topic: "Backtracking",
        prompt: "配列 nums の全順列を返してください。",
        example: "例: nums=[1,2,3]  →  [[1,2,3],[1,3,2],[2,1,3],...]",
        template: [
            "def permute(nums):",
            "    result = []",
            "    def bt(path, rem):",
            "        if not rem:",
            "            result.append({{app}})",
            "            return",
            "        for i, n in enumerate(rem):",
            "            bt(path + [n], rem[:i] + {{rest}})",
            "    bt([], nums); return result"
        ],
        slots: [
            "app":  PuzzleSlot(id: "app",  label: "結果に追加",   answer: "path[:]",    choices: ["path[:]", "path", "[path]"]),
            "rest": PuzzleSlot(id: "rest", label: "残りの要素",   answer: "rem[i+1:]",  choices: ["rem[i+1:]", "rem[i:]", "rem[:i]"])
        ]
    ),

    // 50. Subsets
    PuzzleProblem(
        id: "subsets", title: "Subsets", difficulty: "Medium", topic: "Backtracking",
        prompt: "配列 nums の全部分集合を返してください。",
        example: "例: nums=[1,2,3]  →  [[],[1],[2],[1,2],[3],[1,3],[2,3],[1,2,3]]",
        template: [
            "def subsets(nums):",
            "    result = []",
            "    def bt(start, path):",
            "        result.append({{app}})",
            "        for i in range({{rng}}, len(nums)):",
            "            bt(i + 1, path + [nums[i]])",
            "    bt(0, []); return result"
        ],
        slots: [
            "app": PuzzleSlot(id: "app", label: "結果に追加", answer: "path[:]",  choices: ["path[:]", "path", "[path]"]),
            "rng": PuzzleSlot(id: "rng", label: "ループ開始", answer: "start",   choices: ["start", "0", "start + 1"])
        ]
    ),
    PuzzleProblem(
        id: "queue-two-stacks", title: "Implement Queue using Stacks", difficulty: "Easy", topic: "Queue / Design",
        prompt: "2 つのスタックでキューを実装してください。FIFO を保つ。",
        example: "例: push(1), push(2), pop()  →  1",
        template: [
            "class MyQueue:",
            "    def __init__(self):",
            "        self.in_st, self.out_st = [], []",
            "    def push(self, x):",
            "        self.in_st.{{push}}(x)",
            "    def pop(self):",
            "        if not self.out_st:",
            "            while self.in_st:",
            "                self.out_st.append(self.in_st.{{mv}}())",
            "        return self.out_st.pop()",
            "    def empty(self):",
            "        return not self.in_st and {{em}}"
        ],
        slots: [
            "push": PuzzleSlot(id: "push", label: "入庫スタックへ", answer: "append",
                               choices: ["append", "push", "add"]),
            "mv":   PuzzleSlot(id: "mv", label: "in→out 転送", answer: "pop",
                               choices: ["pop", "popleft", "shift"]),
            "em":   PuzzleSlot(id: "em", label: "出庫スタック空チェック", answer: "not self.out_st",
                               choices: ["not self.out_st", "self.out_st", "self.in_st"])
        ],
        explanation: "2 スタックで償却 O(1) push/pop。push は入庫スタックにそのまま積み、pop 時に出庫が空ならまとめて移送し LIFO を 2 回反転して FIFO を作る。"
    ),
    PuzzleProblem(
        id: "queue-bfs-shortest", title: "BFS Shortest Path", difficulty: "Medium", topic: "Queue / BFS",
        prompt: "始点から終点までの最短経路長を BFS で求めてください。",
        example: "例: grid 上で start→end の最短ステップ数",
        template: [
            "from collections import deque",
            "def shortest(adj, s, t):",
            "    q = {{init}}([(s, 0)])",
            "    seen = {s}",
            "    while q:",
            "        node, d = q.{{deq}}()",
            "        if node == t: return d",
            "        for nb in adj[node]:",
            "            if nb not in seen:",
            "                seen.{{add}}(nb)",
            "                q.{{enq}}((nb, d + 1))",
            "    return -1"
        ],
        slots: [
            "init": PuzzleSlot(id: "init", label: "キュー型", answer: "deque",
                               choices: ["deque", "list", "Queue"]),
            "deq":  PuzzleSlot(id: "deq", label: "先頭取り出し", answer: "popleft",
                               choices: ["popleft", "pop", "remove"]),
            "add":  PuzzleSlot(id: "add", label: "訪問済に追加", answer: "add",
                               choices: ["add", "append", "insert"]),
            "enq":  PuzzleSlot(id: "enq", label: "末尾追加", answer: "append",
                               choices: ["append", "appendleft", "push"])
        ],
        explanation: "deque で O(1) の両端操作。BFS は popleft で FIFO 順に取り出すことで距離の浅い順に確定し、最短経路を保証する。"
    ),
    PuzzleProblem(
        id: "queue-circular", title: "Design Circular Queue", difficulty: "Medium", topic: "Queue / Design",
        prompt: "固定容量 k の循環キューを実装してください。",
        example: "例: cap=3, enQ(1), enQ(2), enQ(3), deQ, enQ(4)  →  [2,3,4]",
        template: [
            "class MyCircularQueue:",
            "    def __init__(self, k):",
            "        self.q = [0] * k",
            "        self.head = 0",
            "        self.size = 0",
            "        self.cap = {{cap}}",
            "    def enQueue(self, x):",
            "        if self.size == self.cap: return False",
            "        tail = (self.head + self.size) % {{mod}}",
            "        self.q[tail] = x",
            "        self.size += 1",
            "        return True",
            "    def deQueue(self):",
            "        if self.size == 0: return False",
            "        self.head = (self.head + 1) % {{mod2}}",
            "        self.size -= 1",
            "        return True"
        ],
        slots: [
            "cap":  PuzzleSlot(id: "cap", label: "容量", answer: "k",
                               choices: ["k", "0", "len(self.q)"]),
            "mod":  PuzzleSlot(id: "mod", label: "tail の mod", answer: "self.cap",
                               choices: ["self.cap", "self.size", "self.head"]),
            "mod2": PuzzleSlot(id: "mod2", label: "head の mod", answer: "self.cap",
                               choices: ["self.cap", "self.size", "self.head"])
        ],
        explanation: "配列上で head と size を管理し、index は cap で剰余を取って循環させる。連続メモリのキューを overhead なく実装できる。"
    )
]
