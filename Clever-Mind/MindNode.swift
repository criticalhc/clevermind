//
//  MindNode.swift
//  cryptrps
//
//  Created by Heydon Costello on 26/08/2022.
//

import Foundation
import Combine

class MindNode : Identifiable, ObservableObject, Equatable, CustomStringConvertible, Hashable{
    
    static func == (lhs: MindNode, rhs: MindNode) -> Bool {
        return lhs.id == rhs.id
    }
    
    var description: String {
        return "\(title)"
    }
    
    var id: UUID = UUID()
    
    @Published var title : String
    @Published var data : String
    @Published var selected = false
    @Published var isCollapsed = false
    var isParent : Bool
    var parentId: UUID?
    
    var children = [String]()
    
    init(
        _ title: String,
        _ data: String,
        _ isParent: Bool,
        id: UUID = UUID(),
        parentId: UUID? = nil,
        isCollapsed: Bool = false
    ) {
        self.id = id
        self.title = title
        self.data = data.isEmpty ? DataConstants.ERGO_TEXT.rawValue : data
        self.isParent = isParent
        self.parentId = parentId
        self.isCollapsed = isCollapsed
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    
}
