//
//  LinkPreviewViewModel.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 13.07.2023.
//

import SwiftUI
import LinkPresentation
import UniformTypeIdentifiers

struct LinkPreviewModel: Hashable {
    var image: UIImage?
    var title: String?
    var url: String?
    var previewURL: URL
}
