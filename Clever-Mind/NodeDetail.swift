//
//  NodeDetail.swift
//  cryptrps
//
//  Created by Heydon Costello on 07/09/2022.
//

import SwiftUI

struct NodeDetail: View {
  
    @ObservedObject var mindNode : MindNode
    
    init(with someNode: MindNode) {
        self.mindNode = someNode
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            TextEditor(text: $mindNode.data)
                .padding()
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .navigationTitle(mindNode.title.isEmpty ? "Notes" : mindNode.title)
    }
}
