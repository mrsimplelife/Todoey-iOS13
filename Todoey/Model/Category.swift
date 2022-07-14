//
//  Category.swift
//  Todoey
//
//  Created by 박윤철 on 2022/07/12.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @Persisted var name: String = ""
    @Persisted var color: String = ""
    @Persisted var items = List<Item>()
}
