//
//  ViewController.swift
//  LazyHackintoshGenerator
//
//  Created by ئ‍ارسلان ئابلىكىم on 2/5/16.
//  Copyright © 2016 PCBETA. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSWindowDelegate,BatchProcessAPIProtocol {
	@IBOutlet weak var filePath: NSTextField!
	@IBOutlet weak var progress: NSProgressIndicator!
	@IBOutlet weak var progressLable: NSTextField!
	@IBOutlet weak var kernel: OtherFileDrop!
	@IBOutlet weak var start: NSButton!
	@IBOutlet weak var MBRPatch: NSButton!
	@IBOutlet weak var XCPMPatch: NSButton!
	lazy var XCPMver:Int = 0;
	@IBOutlet weak var cdr: NSButton!
	@IBOutlet weak var extra: OtherFileDrop!
	@IBOutlet weak var SizeCustomize: NSButton!
	@IBOutlet weak var CustomSize: NSTextField!
	@IBOutlet weak var SizeUnit: NSTextField!
	@IBOutlet weak var exitButton: NSButton!
	var language: String?
	lazy var api : BatchProcessAPI = BatchProcessAPI(delegate: self)
	let concurrentInsertingQueue = dispatch_queue_create("kext inserting", DISPATCH_QUEUE_CONCURRENT)
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		language = NSLocale.preferredLanguages()[0]
		if self.language != "zh-Hans" || self.language != "en" { //|| self.language != "ja"
			self.language = "en"
		}
		progress.hidden = true
		progressLable.hidden = true
		CustomSize.hidden = true
		SizeUnit.hidden = true
		XCPMPatch.state = NSOffState
		cdr.state = NSOffState
		exitButton.hidden = true
		// Do any additional setup after loading the view.
	}
	override func viewDidAppear() {
		super.viewDidAppear()
		self.view.window?.delegate = self
		self.view.window!.title = "#TITLE#".localized(self.language!)
	}
	
	override var representedObject: AnyObject? {
		didSet {
			// Update the view, if already loaded.
		}
	}
	func windowShouldClose(sender: AnyObject) -> Bool {
		exit(0)
	}
	@IBAction func StartProcessing(sender: NSButton) {
		if !NSURL(fileURLWithPath:filePath.stringValue).checkResourceIsReachableAndReturnError(nil){
			let a = NSAlert()
			a.messageText = "#INPUTVOID#".localized(self.language!)
			a.runModal()
		}else if kernel.droppedFilePath != "" && NSURL(fileURLWithPath: kernel.droppedFilePath).lastPathComponent! !=  "kernel"{
			let a = NSAlert()
			a.messageText = "#KernelNameError#".localized(self.language!)
			a.runModal()
		}else if extra.droppedFilePath != "" && NSURL(fileURLWithPath: extra.droppedFilePath).lastPathComponent! !=  "Extra"{
			let a = NSAlert()
			a.messageText = "#ExtraNameError#".localized(self.language!)
			a.runModal()
		}else {
			start.hidden = true
			progress.hidden = false
			progressLable.hidden = false
			progress.startAnimation(self)
			var UsingCustomSize = false
			if SizeCustomize.state == NSOnState {
				if Double(CustomSize.stringValue) <= 0 || Double(CustomSize.stringValue) > 100 {
					let a = NSAlert()
					a.messageText = "#WRONGSIZE#".localized(self.language!)
					a.runModal()
					exit(0)
				}else{
					UsingCustomSize = true
				}
			}
			var SizeVal = "7.65"
			if UsingCustomSize {
				SizeVal = CustomSize.stringValue
			}
			let MBRPatchState = (MBRPatch.state == NSOnState) ? true : false
			if XCPMPatch.state == NSOffState {
				XCPMver=0
			}
			let cdrState = (cdr.state == NSOnState) ? true : false
			MBRPatch.enabled=false
			XCPMPatch.enabled=false
			cdr.enabled=false
			SizeCustomize.enabled=false
			CustomSize.enabled=false
			kernel.hidden=true
			extra.hidden=true
			api.startGenerating(filePath.stringValue,SizeVal: SizeVal,MBRPatchState: MBRPatchState,XCPMver: XCPMver,cdrState: cdrState,kernelDroppedFilePath: kernel.droppedFilePath,extraDroppedFilePath: extra.droppedFilePath)
		}
	}
	@IBAction func XCPMClicked(sender: NSButton) {
		if XCPMPatch.state == NSOnState {
			if kernel.droppedFilePath == "" {
				let a = NSAlert()
				a.messageText = "#NOKERNEL#".localized(self.language!)
				a.runModal()
				XCPMPatch.state = NSOffState
			}else {
				let myPopup: NSAlert = NSAlert()
				myPopup.messageText = "#AskVersion#".localized(self.language!)
				myPopup.alertStyle = NSAlertStyle.WarningAlertStyle
				myPopup.addButtonWithTitle("10.10.0 ~ 10.11.0")
				myPopup.addButtonWithTitle(">10.11.1 beta 15B38b")
				let res = myPopup.runModal()
				if res == NSAlertFirstButtonReturn {
					XCPMver=1
				}else {
					XCPMver=2
				}
			}
		}
	}
	@IBAction func SizeClicked(sender: NSButton) {
		if SizeCustomize.state == NSOnState {
			CustomSize.hidden = false
			SizeUnit.hidden = false
		}else {
			CustomSize.hidden = true
			SizeUnit.hidden = true
		}
	}
	@IBAction func exitButtonPressed(sender: NSButton) {
		exit(0)
	}
	func didReceiveProcessName(results: String){
		dispatch_sync(self.concurrentInsertingQueue,{
			self.progressLable.stringValue = results.localized(self.language!)
		})
	}
	func didReceiveProgress(results: Double){
		dispatch_sync(self.concurrentInsertingQueue,{
			self.progress.incrementBy(results)
		})
	}
	func didReceiveErrorMessage(results: String){
		let a = NSAlert()
		a.messageText = results.localized(self.language!)
		a.runModal()
		exit(0)
	}
	func didReceiveThreadExitMessage(){
		progress.stopAnimation(self)
		filePath.stringValue = ""
		exitButton.hidden = false
	}
}

