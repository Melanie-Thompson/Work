import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController

    // Set mobile phone dimensions (iPhone 15 Pro: 393x852)
    let mobileWidth: CGFloat = 393
    let mobileHeight: CGFloat = 852
    let screen = NSScreen.main!
    let screenFrame = screen.visibleFrame
    let x = (screenFrame.width - mobileWidth) / 2 + screenFrame.origin.x
    let y = (screenFrame.height - mobileHeight) / 2 + screenFrame.origin.y
    let mobileFrame = NSRect(x: x, y: y, width: mobileWidth, height: mobileHeight)

    self.setFrame(mobileFrame, display: true)
    self.minSize = NSSize(width: mobileWidth, height: mobileHeight)
    self.maxSize = NSSize(width: mobileWidth, height: mobileHeight)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
