//
//  File.swift
//  Turing Machine
//
//  Created by Rustam Khakhuk on 05.02.2022.
//

import Foundation

protocol JSONSerializable {
    var dict: [String: Any] { get }
}

extension JSONSerializable {
    func json() -> Data {
        try! JSONSerialization.data(withJSONObject: self.dict, options: [])
    }
}
