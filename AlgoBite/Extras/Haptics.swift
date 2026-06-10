import SwiftUI
import Charts
import AVFoundation

// MARK: - SoundFX（UI効果音・コード内合成・外部ファイル不要）

enum SoundFX {
    /// 効果音ON/OFF（設定で切替・UserDefaults永続化）
    static var isEnabled: Bool {
        get {
            if appDefaults.object(forKey: "algobite.sound.enabled") == nil { return true }
            return appDefaults.bool(forKey: "algobite.sound.enabled")
        }
        set { appDefaults.set(newValue, forKey: "algobite.sound.enabled") }
    }

    private static var players: [String: AVAudioPlayer] = [:]
    private static var sessionReady = false

    private static func prepareSession() {
        guard !sessionReady else { return }
        sessionReady = true
        // .ambient: マナースイッチ（消音）を尊重し、他アプリの音とも共存する
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    // 1音 = (周波数, 開始秒, 長さ秒, 音量, 減衰係数)
    private typealias Note = (freq: Double, start: Double, dur: Double, amp: Double, decay: Double)

    private static func render(_ notes: [Note], total: Double) -> Data {
        let sr = 44100.0
        let n = Int(total * sr)
        var buf = [Double](repeating: 0, count: n)
        for note in notes {
            let s0 = Int(note.start * sr)
            let cnt = Int(note.dur * sr)
            for k in 0..<cnt {
                let i = s0 + k
                if i >= n { break }
                let t = Double(k) / sr
                let env = t < 0.004 ? t / 0.004 : exp(-(t - 0.004) * note.decay)
                buf[i] += note.amp * sin(2 * .pi * note.freq * t) * env
            }
        }
        var samples = [Int16](repeating: 0, count: n)
        for i in 0..<n {
            let v = max(-1.0, min(1.0, buf[i]))
            samples[i] = Int16(v * 32767)
        }
        return wav(samples: samples, sampleRate: Int(sr))
    }

    private static func wav(samples: [Int16], sampleRate: Int) -> Data {
        var d = Data()
        let dataSize = samples.count * 2
        func str(_ s: String) { d.append(s.data(using: .ascii)!) }
        func u32(_ v: UInt32) { var x = v.littleEndian; d.append(Data(bytes: &x, count: 4)) }
        func u16(_ v: UInt16) { var x = v.littleEndian; d.append(Data(bytes: &x, count: 2)) }
        str("RIFF"); u32(UInt32(36 + dataSize)); str("WAVE")
        str("fmt "); u32(16); u16(1); u16(1)
        u32(UInt32(sampleRate)); u32(UInt32(sampleRate * 2)); u16(2); u16(16)
        str("data"); u32(UInt32(dataSize))
        samples.withUnsafeBufferPointer { d.append(Data(buffer: $0)) }
        return d
    }

    private static func play(_ key: String, volume: Float, _ make: () -> [Note], total: Double) {
        guard isEnabled else { return }
        prepareSession()
        let p: AVAudioPlayer
        if let cached = players[key] {
            p = cached
        } else {
            guard let np = try? AVAudioPlayer(data: render(make(), total: total)) else { return }
            np.prepareToPlay()
            players[key] = np
            p = np
        }
        p.volume = volume
        p.currentTime = 0
        p.play()
    }

    /// ボタン/タイルのタップ音（軽いポップ）
    static func tap() {
        play("tap", volume: 0.5, { [(660, 0, 0.07, 0.6, 60), (1320, 0, 0.05, 0.18, 80)] }, total: 0.08)
    }
    /// スロット選択など（高めの短いティック）
    static func select() {
        play("select", volume: 0.42, { [(900, 0, 0.05, 0.55, 70)] }, total: 0.06)
    }
    /// 正解/クリア（上昇アルペジオ ド-ミ-ソ-ド）
    static func correct() {
        play("correct", volume: 0.6, {
            [(523.25, 0, 0.5, 0.45, 5), (659.25, 0.09, 0.5, 0.45, 5),
             (783.99, 0.18, 0.55, 0.45, 4.5), (1046.50, 0.27, 0.6, 0.5, 4)]
        }, total: 0.9)
    }
    /// 不正解（低めのブッ）
    static func wrong() {
        play("wrong", volume: 0.45, { [(180, 0, 0.18, 0.55, 16), (120, 0, 0.18, 0.35, 16)] }, total: 0.2)
    }
    /// ヒント（やわらかい2音）
    static func hint() {
        play("hint", volume: 0.4, { [(880, 0, 0.12, 0.45, 12), (1174.66, 0.08, 0.14, 0.45, 11)] }, total: 0.24)
    }
}

// MARK: - Haptics (①)

enum Haptics {
    static func success() {
        let g = UINotificationFeedbackGenerator()
        g.prepare(); g.notificationOccurred(.success)
    }
    static func error() {
        let g = UINotificationFeedbackGenerator()
        g.prepare(); g.notificationOccurred(.error)
    }
    static func warning() {
        let g = UINotificationFeedbackGenerator()
        g.prepare(); g.notificationOccurred(.warning)
    }
    static func selection() {
        let g = UISelectionFeedbackGenerator()
        g.prepare(); g.selectionChanged()
    }
    static func light()  { UIImpactFeedbackGenerator(style: .light ).impactOccurred() }
    static func medium() { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
    static func rigid()  { UIImpactFeedbackGenerator(style: .rigid ).impactOccurred() }
}

