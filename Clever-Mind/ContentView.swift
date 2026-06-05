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
    
    @State var activeVNodes = [MindNode]() //Vertical nodes
    
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
    
    private var toolbarLeadingPlacement: ToolbarItemPlacement {
        #if os(macOS)
        .automatic
        #else
        .navigationBarLeading
        #endif
    }
    
    private var toolbarTrailingPlacement: ToolbarItemPlacement {
        #if os(macOS)
        .primaryAction
        #else
        .navigationBarTrailing
        #endif
    }
    
    @GestureState var magnifyBy = 1.0
    
    var magnification: some Gesture {
            MagnificationGesture()
                .updating($magnifyBy) { currentState, gestureState, transaction in
                    print("Magnification gesture triggered")
                    gestureState = currentState
                }
        }

    @State var activeHaNodes = [String]()
    @State var activeHbNodes = [String]()
    
    @State var shouldShowAddNode = false
    
    @State var isDragging = false
    
    @State var verticalScrollAreaSize = 100.0
    @State var horizontalScrollAreaSize = 100.0
    
    @State var textFieldContents = ""
    
    @State var initialLoad = true
    
    @State var selectedMindNodes = [MindNode]()
    @State private var showClearConfirmation = false
    
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
                }.frame(width: 500, height: 500)
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
                        
                        MapNodeRenderer(
                            someNodes: $vNodeContainer,
                            aString: $someString,
                            selectedMindNodes: $selectedMindNodes,
                            onPersist: { nodeRepository.persistToMoc(vNodeContainer) }
                        ).onChange(of: vNodeContainer) { newValue in
                            print("Content view nodes have been updated : \(vNodeContainer)")
                            if !initialLoad {
                                nodeRepository.persistToMoc(vNodeContainer)
                            }
                            
                        }
                        
                    }
                    .frame(width: 1000, height: 1000, alignment: .center)
                    
                }
                
                
                .scrollIndicators(.hidden)
                
                AddNode(addNewNodeToGraph: addNewNodeToGraph)
                
                if vNodeContainer.isEmpty {
                    Text("Tap + to add your central topic")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                
            }.gesture(magnification)
            
            
            .toolbar {
                ToolbarItem(placement: toolbarLeadingPlacement) {
                    NavigationLink {
                        Text("Hello")
                    } label: {
                        Text("Help")
                    }
                }
                ToolbarItem(placement: toolbarTrailingPlacement) {
                    Button(action: {
                        showClearConfirmation = true
                    }, label: {
                          Image(systemName: "trash.fill")
                      })
                }
            }
            .alert("Delete all nodes?", isPresented: $showClearConfirmation) {
                Button("Delete All", role: .destructive) {
                    initVnodeContainer()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will remove every node and note from the map. This cannot be undone.")
            }
            .onAppear {
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
        if let selected = selectedMindNodes.first {
            vNodeContainer.append(MindNode("New topic", "", false, parentId: selected.id))
        } else if vNodeContainer.isEmpty {
            vNodeContainer.append(MindNode("Central idea", "", true))
        } else if let root = vNodeContainer.first(where: { $0.isParent }) {
            vNodeContainer.append(MindNode("New topic", "", false, parentId: root.id))
        } else {
            vNodeContainer.append(MindNode("New topic", "", false))
        }
        
        verticalScrollAreaSize += 100
        vNodeContainer.forEach { $0.selected = false }
        selectedMindNodes = []
        nodeRepository.persistToMoc(vNodeContainer)
    }
    
    fileprivate func clearCoreData() {
        selectedMindNodes = []
        
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
    
    struct myPreview : PreviewProvider {
        
        static var previews : some View  {
            Text("Hello")
        }
    }
       
    
}
