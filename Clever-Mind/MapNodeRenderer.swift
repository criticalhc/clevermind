//
//  MapNodeRenderer.swift
//  cryptrps
//
//  Created by Heydon Costello on 07/09/2022.
//

import Foundation
import SwiftUI

struct MapNodeRenderer : View {
    @Binding var someNodes : [MindNode] {
        didSet {
            print(someNodes)
            print("Node render nodes have been updated")
        }
    }
    
    @Binding var aString :  String
    
    @State var textFieldContents : String = "" 
     
    
    var body : some View {
        ForEach(Array(someNodes.enumerated()), id: \.offset) { index, data in
            Section {
                TextField(
                    data.title,
                    text: $someNodes[index].title,
                    onEditingChanged: { (isBegin) in
                        if isBegin {
                            someNodes[index].selected = true
                            print("Begins editing")
                        } else {
                            someNodes[index].selected = false
                            print("Finishes editing")
                        }
                    },
                    onCommit: {
                        //print("Node renderer removing node at index \(index)")
                        //someNodes.remove(at: index)
                        //print("Node renderer appending node at index \(index)")
                        someNodes.remove(at: index)
                        someNodes.insert(MindNode(data.title, "test"), at: index)
                        print("commit")
                    }
                )
                .multilineTextAlignment(.center)
                .frame(width: 200, height: 100)
                .background(content: {
                    NavigationLink(destination: {
                       Text("Hello")
                        
                    }, label: {
                        Ellipse().fill(Color.mint).shadow(radius: 3)
                    })
                })

             }
            .frame(width: 200, height: 100, alignment: .center).padding()
        }
        
    }
    
}
