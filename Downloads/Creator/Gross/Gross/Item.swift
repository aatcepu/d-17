//
//  ListModel.swift
//  TODoAPP
//
//  Created by Yagnikk on 12/4/25.
//

import Foundation
import SwiftData

@Model
class Item {
    var title: String
    var isInCart: Bool
    var quantity: Int

    init(title: String, isInCart: Bool = false, quantity: Int = 1) {
        self.title = title
        self.isInCart = isInCart
        self.quantity = quantity
    }
}





