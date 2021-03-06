//
//  DesktopWidgetWindowController.swift
//  Blik
//
//  Created by Patrick Smith on 30/12/2015.
//  Copyright © 2015 Burnt Caramel. All rights reserved.
//

import Cocoa
import QuartzCore
import BurntFoundation


class DesktopWidgetWindow: NSWindow {
	/*override func sendEvent(theEvent: NSEvent) {
		Swift.print("\(theEvent)")
		
		super.sendEvent(theEvent)
	}*/
}

private let activeWindowLevel = CGWindowLevelForKey(.desktopIconWindow) + 1
private let inactiveWindowLevel = CGWindowLevelForKey(.desktopIconWindow) + 0

@objc(GLADesktopWidgetWindowController) class DesktopWidgetWindowController: NSWindowController, NSWindowDelegate {
	@IBOutlet fileprivate var mainViewController: NowWidgetViewController!
	
	override func windowDidLoad() {
		let window = self.window!
		window.isMovableByWindowBackground = true
		window.acceptsMouseMovedEvents = true
		
		window.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)
		
		/*
		let childWindow = NSWindow(contentViewController: mainViewController)
		childWindow.level = Int(CGWindowLevelForKey(.DesktopIconWindowLevelKey) + 1)
		window.addChildWindow(childWindow, ordered: .Above)
*/
		
		window.title = NSLocalizedString("Blik Desktop Widget", comment: "Title for main window as it appears in Mission Control")
		window.level = Int(inactiveWindowLevel)
		
		NSApp.addWindowsItem(window, title: NSLocalizedString("Desktop Widget", comment: "Title for desktop widget as it appears in the Windows menu"), filename: false)
		
		setUpContentView()
	}
	
	func setUpContentView() {
		let contentView = mainViewController.view
		contentView.wantsLayer = true
		contentView.layer!.backgroundColor = GLAUIStyle.active().contentBackgroundColor.cgColor
	}
	
	func windowDidBecomeKey(_ notification: Notification) {
		window!.level = Int(activeWindowLevel)
	}
	
	func windowDidResignKey(_ notification: Notification) {
		window!.level = Int(inactiveWindowLevel)
	}
}
