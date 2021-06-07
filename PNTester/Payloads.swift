//
//  Payloads.swift
//  PNTester
//
//  Created by Pallav Trivedi on 06/06/21.
//

import Foundation

struct Payloads {
    static var basic = """
                    {
                       "Simulator Target Bundle": "<Bundle Identifier of the App>",
                       "aps": {
                           "badge": 0,
                           "alert": {
                               "title": "Push Notification Test",
                               "subtitle": "Testing Push Notifications on Simulator",
                               "body":"This is 🆒"
                           },
                          "sound":"default"
                       }
                    }
                    """
    
    static var rich = """
                    {
                       "Simulator Target Bundle": "<Bundle Identifier of the App>",
                        "aps": {
                                "alert": {
                                    "title": "Rich Push Notification Test",
                                    "body": "This contains an image"
                                },
                                "mutable-content": 1
                            }
                    }
                    """
    
    static var silent = """
                    {
                        "Simulator Target Bundle": "<Bundle Identifier of the App>",
                        "aps" : {
                            "content-available" : 1
                        },
                         "data" :{
                            "title" : "Some silent request",
                            "body" : "Do something silently"
                         }
                    }
                    """
    
    static var deeplink = ""
    
    static var cta = """
                    {
                       "Simulator Target Bundle": "<Bundle Identifier of the App>",
                        "aps": {
                                "category": "content_added_notification",
                                "alert": {
                                    "title": "This has button",
                                    "body": "Drag to view the button"
                                },
                                "mutable-content": 1
                            }
                    }
                    """
}
