//
//  UITableViewBinding.swift
//  Mixpanel
//
//  Created by Yarden Eitan on 8/24/16.
//  Copyright © 2016 Mixpanel. All rights reserved.
//

import Foundation

class UITableViewBinding: CodelessBinding {


    init(eventName: String, path: String, delegate: AnyClass) {
        //setSwizzleClass
        super.init(eventName: eventName, path: path)
    }

    convenience init?(object: [String: Any]) {
        guard let path = object["path"] as? String, path.characters.count >= 1 else {
            Logger.warn(message: "must supply a view path to bind by")
            return nil
        }

        guard let eventName = object["event_name"] as? String, eventName.characters.count >= 1 else {
            Logger.warn(message: "binding requires an event name")
            return nil
        }

        guard let tableDelegate = object["table_delegate"] as? String, let tableDelegateClass = NSClassFromString(tableDelegate) else {
            Logger.warn(message: "binding requires a table_delegate class")
            return nil
        }

        self.init(eventName: eventName,
                  path: path,
                  delegate: tableDelegateClass)

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    override func execute() {
        if !running {
            let executeBlock = { (view: UITableView?, command: Selector, tableView: UITableView?, indexPath: IndexPath) in
                if let root = UIApplication.shared.keyWindow?.rootViewController {
                    // select targets based off path
                    if let tableView = tableView, self.path.isLeafSelected(leaf: tableView, root: root) {
                        var label = ""
                        if let cellText = tableView.cellForRow(at: indexPath)?.textLabel?.text {
                            label = cellText
                        }
                        self.track(event: self.eventName, properties: ["Cell Index": "\(indexPath.row)",
                                                                       "Cell Section": "\(indexPath.section)",
                                                                       "Cell Label": label])
                    }
                }
            }

            //swizzle
            running = true
        }
    }

    override func stop() {
        if running {
            //swizzle
            running = false
        }
    }

    func parentTableView(cell: UIView) -> UITableView {
        return UITableView()
    }

    override var description: String {
        return "UITableView Codeless Binding: \(eventName) for \(path)"
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? UITableViewBinding else {
            return false
        }

        if object === self {
            return true
        } else {
            return super.isEqual(object)
        }
    }

    override var hash: Int {
        return super.hash
    }
}
