import UIKit
import Down

@objc class MarkDownViewController: UIViewController {

	private var content: String
	private var textView: UITextView!

	@objc init(content: String) {
		self.content = content
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "Markdown 预览"
		view.backgroundColor = .white
		setupTextView()
		renderMarkdown(content)
	}

	private func setupTextView() {
		textView = UITextView(frame: view.bounds)
		textView.isEditable = false
		textView.isSelectable = true
		textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		textView.backgroundColor = .white
		view.addSubview(textView)
	}

	// MARK: - 核心渲染逻辑（文字用 Down，图片自己处理）
	private func renderMarkdown(_ markdown: String) {
		let documentPath = NSSearchPathForDirectoriesInDomains(
			.documentDirectory, .userDomainMask, true
		).first!
		let assertPath = documentPath + "/assert"

		print("Documents 路径: \(documentPath)")
		print("assert 目录路径: \(assertPath)")

		let pattern = #"\!\[(.*?)\]\((app://assert/.*?)\)"#
		let regex = try! NSRegularExpression(pattern: pattern)

		let nsMarkdown = markdown as NSString
		let matches = regex.matches(
			in: markdown,
			range: NSRange(location: 0, length: nsMarkdown.length)
		)

		let result = NSMutableAttributedString()
		var lastIndex = 0

		for match in matches {

			// 图片前的 Markdown 文本
			let textRange = NSRange(
				location: lastIndex,
				length: match.range.location - lastIndex
			)

			let textPart = nsMarkdown.substring(with: textRange)
			if let textAttr = try? Down(markdownString: textPart)
				.toAttributedString(.default, stylesheet: customCSS) {
				result.append(textAttr)
			}

			// 解析 app://assert 路径
			let altText = nsMarkdown.substring(with: match.range(at: 1))
			let appURL = nsMarkdown.substring(with: match.range(at: 2))

			let relativePath = appURL.replacingOccurrences(of: "app://assert/", with: "")
			let filePath = assertPath + "/" + relativePath

			print("Markdown 图片:")
			print("alt: \(altText)")
			print("appURL: \(appURL)")
			print("实际路径: \(filePath)")

			// 读取并显示图片
			if let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)),
			   let image = UIImage(data: data) {

				let attachment = NSTextAttachment()
				attachment.image = image

				let maxWidth = textView.bounds.width - 20
				let ratio = image.size.height / image.size.width
				attachment.bounds = CGRect(
					x: 0,
					y: 0,
					width: maxWidth,
					height: maxWidth * ratio
				)

				result.append(NSAttributedString(attachment: attachment))
				result.append(NSAttributedString(string: "\n\n"))
			} else {
				print("图片读取失败: \(filePath)")
			}

			lastIndex = match.range.location + match.range.length
		}

		// 最后一段文本
		if lastIndex < nsMarkdown.length {
			let tail = nsMarkdown.substring(from: lastIndex)
			if let tailAttr = try? Down(markdownString: tail)
				.toAttributedString(.default, stylesheet: customCSS) {
				result.append(tailAttr)
			}
		}

		textView.attributedText = result
	}

	// MARK: - CSS 样式
	private var customCSS: String {
		"""
		body {
			font-family: -apple-system;
			font-size: 16px;
			line-height: 1.6;
		}
		h1 { font-size: 24px; font-weight: bold; }
		h2 { font-size: 20px; font-weight: bold; }
		code, pre {
			font-family: Menlo;
			background-color: #f4f4f4;
			padding: 2px 4px;
			border-radius: 4px;
		}
		"""
	}
}
