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
        NavigationView {
            VStack {
                TextEditor(text: $mindNode.data)
                    .padding()
                    .navigationBarTitleDisplayMode(.inline)
                    .frame(maxWidth :.infinity, alignment: .topLeading)
                Spacer()
            }.frame(maxWidth :.infinity, alignment: .leading)
            Spacer()
        }.border(.black)
            .navigationTitle(mindNode.title)
    }
    
    func printMessage() -> Void {
        print("Hello")
    }
}
