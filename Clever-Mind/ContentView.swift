//
//  ContentView.swift
//  cryptrps
//
//  Created by Heydon Costello on 10/02/2022.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    let tokens = ["rock", "paper", "sissors"]
    
    @State var activeVNodes : [MindNode] = [MindNode("test","test")] //Vertical nodes
    
    @Environment(\.managedObjectContext) var moc
    
    @State var vNodeContainer = [MindNode](){
        didSet {
            print("Content view nodes have been updated : \(vNodeContainer)")
            //nodeRepository.persistToMoc(vNodeContainer)
        }
        
    }
    
    @State var someString = "" {
        didSet {
            print("someString field was updated")
        }
    }
    
    var nodeRepository : NodeCoreDataRepository

    @State var activeHaNodes = [String]()
    @State var activeHbNodes = [String]()
    
    @State var shouldShowAddNode = false
    
    @State var isDragging = false
    
    @State var verticalScrollAreaSize = 100.0
    @State var horizontalScrollAreaSize = 100.0
    
    @State var textFieldContents = ""
    
    @State var initialLoad = true
    
    var someClojure : () -> Void  = {
        print("doing something")
    }
    
    var drag: some Gesture {
        DragGesture()
            .onChanged {_ in self.isDragging = true }
            .onEnded {_ in self.isDragging = false }
    }
    
    var body2: some View {
            ScrollView([.horizontal, .vertical]) {
                VStack {
                    Rectangle()
                        .frame(width: 300, height: 500)
                        .foregroundColor(Color.red)
                }.frame(width: 1000, height: 1000)
            }
        }
    
    
    
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView([.horizontal, .vertical]) {
                    VStack {
    //                    ForEach(activeHaNodes, id: \.self) { data in
    //                        Section {
    //                            Text(data)
    //                                .frame(width: 200, height: 100)
    //                                .background(Ellipse().fill(Color.blue).shadow(radius: 3))
    //
    //                         }
    //                        .frame(width: 200, height: 100, alignment: .center)
    //                        .gesture(drag)
    //                    }.padding().padding()
                        
                        MapNodeRenderer(someNodes: $vNodeContainer, aString: $someString).onChange(of: vNodeContainer) { newValue in
                            print("Content view nodes have been updated : \(vNodeContainer)")
                            if !initialLoad {
                                nodeRepository.persistToMoc(vNodeContainer)
                            }
                           
                        }
                        
                    }.frame(width: horizontalScrollAreaSize, height: verticalScrollAreaSize, alignment: .center)
                    
                }
                
                AddNode(addNewNodeToGraph: addNewNodeToGraph)
             
                
            }.toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink {
                        Text("Hello")
                    } label: {
                        Text("Help")
                    }
                                    }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        initVnodeContainer()
                    }, label: {
                          Image(systemName: "trash.fill")
                      })
                }
            }.onAppear {
                print("Content view did appear")
                //clearCoreData()
                if initialLoad {
                    vNodeContainer = []
                    loadNodesFromCoreData()
                    initialLoad.toggle()
                }
                
            }
        }
    }
    
    func loadNodesFromCoreData() {
        print("Loading nodes from core data")
        self.vNodeContainer = nodeRepository.getNodesFromCoreData()
    }
    
    func addNewNodeToGraph() {
        var selectedNodes = vNodeContainer.filter { node in
            return node.selected
        }
        
        let seletecNodeStrings = selectedNodes.map { node in
            return node.id
        }
        print("Selected nodes \(seletecNodeStrings)")
        vNodeContainer.append(MindNode("","test"))
        verticalScrollAreaSize += 100
        print("Vertical scroll area size \(verticalScrollAreaSize)")
        print(vNodeContainer)
        
        clearCoreData()
        
        nodeRepository.persistToMoc(vNodeContainer)
        
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
    
    func initVnodeContainer() {
        clearCoreData()
        vNodeContainer = []
    }
       
    
}
