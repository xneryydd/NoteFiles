import Foundation
import WebKit
import Down

@MainActor
@objc class MarkdownExporter: NSObject {
    private static var retainedWebViews = [WKWebView]() // 防止 WKWebView 提前释放

    // MARK: - 导出 HTML（去除 app://）
    @MainActor
    @objc static func exportHTML(from markdown: String, completion: @escaping (NSString) -> Void) {
        print("🔹 exportHTML called")
        Task {
            let down = Down(markdownString: markdown)
            do {
                var html = try down.toHTML()
                
                // 去除所有的 app://
                html = html.replacingOccurrences(of: "app://", with: "")
                
                let wrappedHTML = """
                <html>
                <head>
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <style>
                    body { font-family: -apple-system; font-size: 16px; padding: 20px; }
                    img { max-width: 100%; height: auto; }
                    </style>
                </head>
                <body>\(html)</body>
                </html>
                """
                print("✅ HTML export successful")
                completion(wrappedHTML as NSString)
            } catch {
                print("❌ HTML 导出失败: \(error)")
                completion(markdown as NSString) // fallback
            }
        }
    }
}
