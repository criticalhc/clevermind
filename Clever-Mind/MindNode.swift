//
//  MindNode.swift
//  cryptrps
//
//  Created by Heydon Costello on 26/08/2022.
//

import Foundation

class MindNode : Identifiable, ObservableObject, Equatable, CustomStringConvertible{
    
    static func == (lhs: MindNode, rhs: MindNode) -> Bool {
        return lhs.id == rhs.id
    }
    
    var description: String {
        return "\(title)"
    }
    
    var id: UUID = UUID()
    
    var title : String
    var data : String
    var selected = false
    
    init(_ title : String, _ data : String) {
        self.title = title
        self.data = DataConstants.ERGO_TEXT.rawValue
    }
    

    
}
