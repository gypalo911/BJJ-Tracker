//
//  JiuTrackWidgetLiveActivity.swift
//  JiuTrackWidget
//
//  Created by Petro Hupalo on 25.02.2024.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct JiuTrackWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct JiuTrackWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: JiuTrackWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension JiuTrackWidgetAttributes {
    fileprivate static var preview: JiuTrackWidgetAttributes {
        JiuTrackWidgetAttributes(name: "World")
    }
}

extension JiuTrackWidgetAttributes.ContentState {
    fileprivate static var smiley: JiuTrackWidgetAttributes.ContentState {
        JiuTrackWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: JiuTrackWidgetAttributes.ContentState {
         JiuTrackWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: JiuTrackWidgetAttributes.preview) {
   JiuTrackWidgetLiveActivity()
} contentStates: {
    JiuTrackWidgetAttributes.ContentState.smiley
    JiuTrackWidgetAttributes.ContentState.starEyes
}
