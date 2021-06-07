//
//  ViewController.swift
//  PNTester
//
//  Created by Pallav Trivedi on 31/05/21.
//

import Cocoa

enum Payload: String, CaseIterable {
    case Basic
    case Rich
    case Silent
    case Deeplink
    case CTA
}

class ViewController: NSViewController {
    
    @IBOutlet weak var editSimulatorButton: NSButton!
    @IBOutlet weak var simulatorComboBox: NSComboBox!
    @IBOutlet weak var pushButton: NSButton!
    @IBOutlet weak var payloadTextView: NSScrollView!
    @IBOutlet weak var identifierLabel: NSTextField!
    @IBOutlet weak var identifierContainerView: NSView!
    @IBOutlet weak var resultLabel: NSTextField!
    @IBOutlet weak var payloadsTableView: NSTableView!
    
    var simulators: [String: String] = [:]
    var payloads: [String: String] = [:]
    
    // MARK:- Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Uncomment this line for removing simulators saved in Defaults. 
//        UserDefaults.standard.setValue(simulators, forKey: "simulators")
        
        if let savedSimulators = UserDefaults.standard.value(forKey: "simulators") as? [String: String] {
            simulators = savedSimulators
            populateSimulatorComboBox()
        }
        
        if let payloadsData = UserDefaults.standard.value(forKey: "payloads") as? [String: String] {
            payloads = payloadsData
        } else {
            populateDefaultPayloads()
        }
        
        if simulators.isEmpty {
            editSimulatorButton.isEnabled = false
            identifierContainerView.isHidden = true
            pushButton.isEnabled = false
        }
        
        simulatorComboBox.isEditable = false
        payloadsTableView.delegate = self
        payloadsTableView.dataSource = self
        simulatorComboBox.delegate = self
        payloadsTableView.reloadData()
    }
    
    //MARK:- Helper Methods
    
    func showAddSimulatorAlert(shouldEdit: Bool) {
        let alert = NSAlert()
        alert.messageText = shouldEdit ? "Edit simulator details" : "Enter simulator details"
        alert.addButton(withTitle: "Save")
        alert.addButton(withTitle: "Cancel")
        
        let nameTextField = NSTextField(frame: NSRect(x: 0, y: 36, width: 300, height: 24))
        let uuidTextField = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
        
        if shouldEdit {
            nameTextField.stringValue = getSimulatorDetails(for: simulatorComboBox.stringValue).0
            uuidTextField.stringValue = getSimulatorDetails(for: simulatorComboBox.stringValue).1
        } else {
            nameTextField.placeholderString = ("Enter simulator name")
            uuidTextField.placeholderString = ("Enter identifier")
        }
        
        let stackView = NSStackView(frame: NSRect(x: 0, y: 0, width: 300, height: 80))
        stackView.addSubview(nameTextField)
        stackView.addSubview(uuidTextField)
        
        alert.accessoryView = stackView
        alert.runModal()
        
        let name = nameTextField.stringValue
        let identifier = uuidTextField.stringValue
        
        if simulators.keys.filter({$0 == identifier}).count > 0 {
            //already exist
            print("A simulator with this identifer already exist")
        } else {
            simulators[identifier] = name
            populateSimulatorComboBox(item: name)
            
            UserDefaults.standard.setValue(simulators, forKey: "simulators")
        }
    }
    
    func getSimulatorDetails(for key: String) -> (String, String) {
        for (id, name) in simulators {
            if name == key {
                return (name,id)
            }
        }
        return ("","")
    }
    
    func populateSimulatorComboBox(item: String? = nil) {
        if item != nil {
            simulatorComboBox.addItem(withObjectValue: item!)
        }
        if !simulators.isEmpty {
            if simulatorComboBox.numberOfItems == 0 {
                for (_,value) in simulators {
                    simulatorComboBox.addItem(withObjectValue: value)
                }
            }
            
            simulatorComboBox.selectItem(at: 0)
            identifierContainerView.isHidden = false
            identifierLabel.stringValue = simulators.first?.key ?? ""
            editSimulatorButton.isEnabled = true
            pushButton.isEnabled = true
        }
    }
    
    func populateDefaultPayloads() {
        for payloadCase in Payload.allCases {
            switch payloadCase {
            case .Basic:
                payloads[payloadCase.rawValue] = Payloads.basic
            case .Rich:
                payloads[payloadCase.rawValue] = Payloads.rich
            case .Silent:
                payloads[payloadCase.rawValue] = Payloads.silent
            case .Deeplink:
                payloads[payloadCase.rawValue] = Payloads.deeplink
            case .CTA:
                payloads[payloadCase.rawValue] = Payloads.cta
            }
        }
    }

    func deleteExistingPayload() {
        let fileNameToDelete = "TestPayload.apns"
        var filePath = ""
        let dirs : [String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
        if dirs.count > 0 {
            let dir = dirs[0] //documents directory
            filePath = dir.appendingFormat("/" + fileNameToDelete)
            
        } else {
            print("Could not find local directory to store file")
            return
        }
        do {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                try fileManager.removeItem(atPath: filePath)
            } else {
                print("File does not exist")
            }
            
        }
        catch let error as NSError {
            print("An error took place: \(error)")
        }
    }
    
    //MARK: Actions
    
    @IBAction func didClickOnAddSimulatorButton(_ sender: Any) {
        showAddSimulatorAlert(shouldEdit: false)
    }
    
    @IBAction func didClickOnEditSimulatorButton(_ sender: Any) {
        showAddSimulatorAlert(shouldEdit: true)
    }
    
    
    @IBAction func didClickOnPushButton(_ sender: Any) {
        resultLabel.stringValue = ""
        
        guard let textView : NSTextView = payloadTextView?.documentView as? NSTextView, !textView.string.isEmpty else {
            return
        }
        
        do {
            deleteExistingPayload()
            let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            let fileURL = directoryURL.appendingPathComponent("TestPayload.apns")
            
            let payloadString = textView.string.replacingOccurrences(of: "”", with: "\"")
            try payloadString.write(to: fileURL, atomically: true, encoding: .utf8)
            
            let task = Process()
            task.launchPath = "/usr/bin/env"
            task.arguments = ["xcrun", "simctl", "push", identifierLabel.stringValue, fileURL.absoluteString.replacingOccurrences(of: "file://", with: "")]
            
            let pipe = Pipe()
            
            task.standardOutput = pipe
            task.standardError = pipe
            
            task.launch()
            task.waitUntilExit()
            _ = task.terminationStatus
            
            let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: outputData, encoding: .utf8)!
            
            resultLabel.stringValue = output
            print(output)
        } catch {
            print(error.localizedDescription)
        }
    }
}

// MARK: Combo Box Delgate Methods
extension ViewController: NSComboBoxDelegate {
    func comboBoxSelectionDidChange(_ notification: Notification) {
        if let selectedSimulator = simulatorComboBox.itemObjectValue(at: simulatorComboBox.indexOfSelectedItem) as? String {
            identifierLabel.stringValue = getSimulatorDetails(for: selectedSimulator).1
        }
    }
}

// MARK: Table View Delegate Methods
extension ViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return payloads.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?{
        var result:NSTableCellView
        result  = tableView.makeView(withIdentifier: (tableColumn?.identifier)!, owner: self) as! NSTableCellView
        
        result.textField?.stringValue = Array(payloads.keys)[row]
        return result
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let table = notification.object as? NSTableView else {
            return
        }
        let row = table.selectedRow
        if payloads.keys.count > row && row != -1 {
            print(payloads[Array(payloads.keys)[row]] ?? "")
            if let textView : NSTextView = payloadTextView?.documentView as? NSTextView {
                textView.string = payloads[Array(payloads.keys)[row]] ?? ""
            }
        }
    }
}
