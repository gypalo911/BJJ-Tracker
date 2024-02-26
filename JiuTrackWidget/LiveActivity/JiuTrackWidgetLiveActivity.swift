//
//  JiuTrackWidgetLiveActivity.swift
//  JiuTrackWidget
//
//  Created by Petro Hupalo on 25.02.2024.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct SessionAttributes: ActivityAttributes {
    public struct ContentState: Codable & Hashable {
        // Dynamic stateful properties about your activity go here!
        
    }
    // Fixed non-changing properties about your activity go here!
    
}

@available(iOS 16.1, *)
struct JiuTrackWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SessionAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                if let session = PersistanceManager.preview.fetchSessions().first {
                    LiveActivityView(session: session)
                } else {
                    Text("sda")
                }
            }
            //            .activityBackgroundTint(Color.red)
            //            .activitySystemActionForegroundColor(Color.black)
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Create the expanded presentation.
                DynamicIslandExpandedRegion(.leading) {
                    EmptyView()
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    EmptyView()
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    EmptyView()
                }
            } compactLeading: {
                // Create the compact leading presentation.
                EmptyView()
            } compactTrailing: {
                // Create the compact trailing presentation.
                EmptyView()
            } minimal: {
                // Create the minimal presentation.
                EmptyView()
            }
        }
    }
}

extension SessionAttributes {
    fileprivate static var preview: SessionAttributes {
        SessionAttributes()
    }
}

//#Preview("Notification", as: .content, using: SessionAttributes.preview) {
//   JiuTrackWidgetLiveActivity()
//} contentStates: {
//    SessionAttributes.ContentState()
////    JiuTrackWidgetAttributes.ContentState(isCompleted: true)
//}
