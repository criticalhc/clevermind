//
//  AddNode.swift
//  cryptrps
//
//  Created by Heydon Costello on 07/09/2022.
//

import Foundation
import SwiftUI


struct AddNode : View {
    
    @State var shouldShowAddNode = false
    
    let addNewNodeToGraph : () -> Void
    
    init(addNewNodeToGraph : @escaping () -> Void ) {
        self.addNewNodeToGraph = addNewNodeToGraph
    }
    
    var body : some View {
        VStack {
            Spacer()
            
            HStack(alignment: .bottom) {
                Spacer()
                Section {
                    Button(action: {
                        addNewNodeToGraph()
                        
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 30))
                    }
                }
                .frame(width: 100, height: 100, alignment: .center)
            }
        
        }
    }

}


