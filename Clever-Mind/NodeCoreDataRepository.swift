//
//  HorizontalNodeContainer.swift
//  cryptrps
//
//  Created by Heydon Costello on 07/09/2022.
//

import Foundation
import CoreData
import SwiftUI

struct NodeCoreDataRepository {
    
    var moc : NSManagedObjectContext
    
    
    func persistToMoc(_ nodes : [MindNode]) {
        clearCoreData()
        
        nodes.forEach { node in
            let mocNode = Node(context: moc)
            mocNode.id = node.id
            mocNode.data = node.data
            mocNode.title = node.title
            mocNode.isParentNode = node.isParent
            mocNode.parentId = node.parentId
            mocNode.isCollapsed = node.isCollapsed
            moc.insert(mocNode)
        }
        
        do {
            try moc.save()
        } catch {
            print("Could not update nodes: \(error)")
        }
    }
    
    func getNodesFromCoreData() -> [MindNode] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Node")
        
        do {
            let fetchedNodes = try moc.fetch(request)
            let nodes = fetchedNodes.compactMap { managedObject -> MindNode? in
                guard let node = managedObject as? Node else { return nil }
                return MindNode(
                    node.title ?? "",
                    node.data ?? "",
                    node.isParentNode,
                    id: node.id ?? UUID(),
                    parentId: node.parentId,
                    isCollapsed: node.isCollapsed
                )
            }
            return repairParentLinks(nodes)
        } catch {
            print("Could not fetch nodes: \(error)")
            return []
        }
    }
    
    private func repairParentLinks(_ nodes: [MindNode]) -> [MindNode] {
        guard let root = nodes.first(where: { $0.isParent }) else { return nodes }
        nodes.filter { !$0.isParent && $0.parentId == nil }.forEach { $0.parentId = root.id }
        return nodes
    }
    
    fileprivate func clearCoreData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Node")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try moc.execute(deleteRequest)
        } catch let error as NSError {
            // TODO: handle the error
        }
        
    }
    
}
