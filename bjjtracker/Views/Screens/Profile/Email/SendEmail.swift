//
//  SendEmail.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 08.08.2023.
//

import SwiftUI
import UIKit
import MessageUI

struct ComposeMailData {
    let subject: String
    let recipients: [String]?
    let message: String
    let attachments: [AttachmentData]?
}

struct AttachmentData {
    let data: Data
    let mimeType: String
    let fileName: String
}
class EmailController: NSObject, MFMailComposeViewControllerDelegate {
    public static let shared = EmailController()
    private override init() { }
    
    func sendEmail(subject: String, body: String, to: String){
        // Check if the device is able to send emails
        if !MFMailComposeViewController.canSendMail() {
           print("This device cannot send emails.")
           return
        }
        // Create the email composer
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        mailComposer.setToRecipients([to])
        mailComposer.setSubject(subject)
        mailComposer.setMessageBody(body, isHTML: false)
        EmailController.getRootViewController()?.present(mailComposer, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        EmailController.getRootViewController()?.dismiss(animated: true, completion: nil)
    }
    
    static func getRootViewController() -> UIViewController? {
        // In SwiftUI 2.0
        UIApplication.shared.windows.first?.rootViewController
    }
}
//
//struct SendEmail_Previews: PreviewProvider {
//    static var previews: some View {
//        MailViewTest()
//    }
//}
