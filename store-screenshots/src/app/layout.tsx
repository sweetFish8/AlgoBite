import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "AlgoBite App Store Screenshots",
  description: "Design and export AlgoBite App Store screenshots.",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="ja">
      <body>{children}</body>
    </html>
  );
}
