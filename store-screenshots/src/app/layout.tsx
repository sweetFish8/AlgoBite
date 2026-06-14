import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "AlgoBite App Store Screenshots",
  description: "Design and export AlgoBite App Store screenshots.",
};

// サンプル比較用：SAMPLE_FONT 環境変数で本文フォントを切り替える。
// 未指定なら従来どおりシステムゴシック。
const SAMPLE_FONT = process.env.SAMPLE_FONT;
const FONT_STACK = SAMPLE_FONT
  ? `"${SAMPLE_FONT}", "Hiragino Sans", "Noto Sans JP", sans-serif`
  : undefined;

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="ja">
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
        <link
          href="https://fonts.googleapis.com/css2?family=M+PLUS+Rounded+1c:wght@400;500;700;800&family=Zen+Maru+Gothic:wght@400;500;700;900&family=Kiwi+Maru:wght@400;500&display=swap"
          rel="stylesheet"
        />
      </head>
      <body style={FONT_STACK ? { fontFamily: FONT_STACK } : undefined}>{children}</body>
    </html>
  );
}
