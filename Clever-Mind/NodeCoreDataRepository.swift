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
        print("Persisting to core data")
        clearCoreData()
        
        nodes.forEach { node in
            
            print(self.moc)
            
            
            let mocNode = Node(context: moc)
            
//                mocNode.id = node.id
//                mocNode.data = node.data
//                mocNode.title = node.title
            
            mocNode.data = "data"
            mocNode.title = node.title
            
            moc.insert(mocNode)
            
        }
        
        do {
            try moc.save()
            print("Nodes has been updated")

        } catch {
            print("Could not update nodes: \(error)")
        }
        
    }
    
    func getNodesFromCoreData() -> [MindNode] {
        print("Object context overridden")
        var fetchedNodes = try! moc.fetch(NSFetchRequest(entityName: "Node"))
        print("Fetched nodes \(fetchedNodes)")
        
        
        var nodesToMindNode : [MindNode] =  fetchedNodes.map { node in
            var nodeAsNode = node as! Node
            
            var mindNode = MindNode(nodeAsNode.title ?? "" ,nodeAsNode.data ?? "" , nodeAsNode.isParentNode)
            
            return mindNode
        }
        
        return nodesToMindNode
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
