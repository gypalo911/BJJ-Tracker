//
//  JiuTrackWidgetBundle.swift
//  JiuTrackWidget
//
//  Created by Petro Hupalo on 25.02.2024.
//

import WidgetKit
import SwiftUI

@main
struct JiuTrackWidgetBundle: WidgetBundle {
    var body: some Widget {
        JiuTrackWidget()
        
        if #available(iOS 16.1, *) {
            JiuTrackWidgetLiveActivity()
        }
    }
}
