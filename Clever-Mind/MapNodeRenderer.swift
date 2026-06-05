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
    
    enum Foucusable : Hashable {
        case none
        case row(id: String)
    }
    
    @Binding var aString :  String
    
    @State var textFieldContents : String = ""
    
    var xCorHolder = 150 as CGFloat
    
    @State var xPosition = 0 as CGFloat
    
    @StateObject var nodePositionHolder = NodePositionHolder()
    
    @FocusState private var focusedField : Foucusable? {
        didSet {
            print("Focused field has been set")
            print(focusedField)
        }
    }
    
    @State var childNodeText = ""
    
    @State var parentNodeCoordinates : CGPoint = CGPoint()
    
    @State var someText = ""
    
    @Binding var selectedMindNodes : [MindNode]
    var onPersist: () -> Void = {}
    
    @State private var detailNode: MindNode?
    @State private var mapRevision = 0
    
    //can be used to control the number of nodes on screen
    func getNodes(_ nodes : [MindNode]) -> Array<(offset: Int, element: MindNode)>  {
        if someNodes.count >= 1 {
            return Array(Array(someNodes.enumerated()))
        } else {
            return Array(someNodes.enumerated())
        }
    }
    
    
    var body : some View {
        let laidOut = layoutMindMap(nodes: someNodes)
        
        ZStack {
            Canvas { context, _ in
                for item in laidOut {
                    guard let parentId = item.node.parentId,
                          let parent = laidOut.first(where: { $0.node.id == parentId }) else { continue }
                    
                    var line = Path()
                    line.move(to: CGPoint(x: parent.coordinate.xCor, y: parent.coordinate.yCor))
                    line.addLine(to: CGPoint(x: item.coordinate.xCor, y: item.coordinate.yCor))
                    context.stroke(line, with: .color(.black), lineWidth: 1)
                }
            }
            .allowsHitTesting(false)
            
            ForEach(laidOut) { item in
                let index = computeIndexOfMindNode(targetNode: item.node, someNodes: someNodes)
                
                Group {
                    if item.node.isParent {
                        parentNodeView(index: index, item: item)
                    } else {
                        childNodeView(index: index, item: item)
                    }
                }
                .offset(
                    x: CGFloat(item.coordinate.xCor) - MindMapCanvas.width / 2,
                    y: CGFloat(item.coordinate.yCor) - MindMapCanvas.height / 2
                )
            }
        }
        .frame(width: MindMapCanvas.width, height: MindMapCanvas.height)
        .id(mapRevision)
        .sheet(item: $detailNode, onDismiss: onPersist) { node in
            NavigationView {
                NodeDetail(with: node)
            }
        }
    }
    
    @ViewBuilder
    private func parentNodeView(index: Int, item: MindNodeWithCoordinate) -> some View {
        ZStack {
            NavigationLink(destination: NodeDetail(with: someNodes[index]).onDisappear(perform: onPersist)) {
                Ellipse()
                    .fill(Color.mint)
                    .shadow(radius: 3)
                    .overlay(
                        Ellipse()
                            .stroke(someNodes[index].selected ? Color.blue : Color.clear, lineWidth: 3)
                    )
            }
            .buttonStyle(.plain)
            .frame(width: 125, height: 75)
            
            TextField(
                item.node.title.isEmpty ? "Central idea" : item.node.title,
                text: $someNodes[index].title
            )
            .multilineTextAlignment(.center)
            .textFieldStyle(.plain)
            .frame(width: 100, height: 50)
            .background(Color.clear)
            
            if nodeHasChildren(someNodes[index]) {
                collapseButton(
                    isCollapsed: someNodes[index].isCollapsed,
                    childCount: childCount(for: someNodes[index]),
                    action: { toggleCollapsed(for: someNodes[index]) }
                )
                .offset(x: 52, y: -28)
                .zIndex(2)
            }
        }
        .nodeInteractionHandlers(
            isCollapsed: someNodes[index].isCollapsed,
            onSelect: { setSelectedStatusOfNode(someNodes[index], true) },
            onToggleCollapse: { toggleCollapsed(for: someNodes[index]) },
            onEditNotes: { detailNode = someNodes[index] },
            hasChildren: nodeHasChildren(someNodes[index])
        )
    }
    
    @ViewBuilder
    private func childNodeView(index: Int, item: MindNodeWithCoordinate) -> some View {
        ZStack(alignment: .topTrailing) {
            TextField("New topic", text: $someNodes[index].title)
                .padding(6)
                .textFieldStyle(.plain)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(item.node.selected ? Color.blue.opacity(0.15) : Color.gray.opacity(0.25))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(item.node.selected ? Color.blue : Color.clear, lineWidth: 2)
                )
                .shadow(radius: 2)
                .fixedSize()
            
            if nodeHasChildren(someNodes[index]) {
                collapseButton(
                    isCollapsed: someNodes[index].isCollapsed,
                    childCount: childCount(for: someNodes[index]),
                    action: { toggleCollapsed(for: someNodes[index]) }
                )
                .offset(x: 8, y: -10)
                .zIndex(2)
            }
        }
        .nodeInteractionHandlers(
            isCollapsed: someNodes[index].isCollapsed,
            onSelect: { setSelectedStatusOfNode(someNodes[index], true) },
            onToggleCollapse: { toggleCollapsed(for: someNodes[index]) },
            onEditNotes: { detailNode = someNodes[index] },
            hasChildren: nodeHasChildren(someNodes[index])
        )
    }
    
    @ViewBuilder
    private func collapseButton(isCollapsed: Bool, childCount: Int, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 2) {
                Image(systemName: isCollapsed ? "chevron.right" : "chevron.down")
                    .font(.caption2.bold())
                Text("\(childCount)")
                    .font(.caption2.bold())
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(Capsule().fill(Color.white.opacity(0.95)))
            .overlay(Capsule().stroke(Color.secondary.opacity(0.5), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .contentShape(Capsule())
        #if os(macOS)
        .help(isCollapsed ? "Expand children" : "Collapse children")
        #endif
    }
        
    func computeIndexOfMindNode(targetNode : MindNode, someNodes : [MindNode]) -> Int{
        var counter = 0
        for node in someNodes {
            if node == targetNode {
                break
            } else {
                counter += 1
            }
        }
        return counter
    }
    
    func setSelectedStatusOfNode(_ targetNode : MindNode, _ isSelected : Bool) {
        someNodes.forEach { $0.selected = false }
        selectedMindNodes.removeAll()
        guard isSelected else { return }
        targetNode.selected = true
        selectedMindNodes.append(targetNode)
    }
    
    func nodeHasChildren(_ node: MindNode) -> Bool {
        someNodes.contains { $0.parentId == node.id }
    }
    
    func childCount(for node: MindNode) -> Int {
        someNodes.filter { $0.parentId == node.id }.count
    }
    
    func toggleCollapsed(for node: MindNode) {
        guard let index = someNodes.firstIndex(where: { $0.id == node.id }),
              nodeHasChildren(someNodes[index]) else { return }
        
        someNodes[index].isCollapsed.toggle()
        
        if someNodes[index].isCollapsed {
            let visibleIds = Set(layoutMindMap(nodes: someNodes).map(\.node.id))
            selectedMindNodes.removeAll { !visibleIds.contains($0.id) }
            someNodes.forEach { if !visibleIds.contains($0.id) { $0.selected = false } }
        }
        
        mapRevision += 1
        onPersist()
    }
    
}

private struct NodeInteractionHandlers: ViewModifier {
    let isCollapsed: Bool
    let onSelect: () -> Void
    let onToggleCollapse: () -> Void
    let onEditNotes: () -> Void
    let hasChildren: Bool
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.4)
                    .onEnded { _ in
                        if hasChildren {
                            onToggleCollapse()
                        } else {
                            onSelect()
                        }
                    }
            )
            .contextMenu {
                if hasChildren {
                    Button(isCollapsed ? "Expand children" : "Collapse children") {
                        onToggleCollapse()
                    }
                }
                Button("Select node") {
                    onSelect()
                }
                Button("Edit notes") {
                    onEditNotes()
                }
            }
    }
}

private extension View {
    func nodeInteractionHandlers(
        isCollapsed: Bool,
        onSelect: @escaping () -> Void,
        onToggleCollapse: @escaping () -> Void,
        onEditNotes: @escaping () -> Void,
        hasChildren: Bool
    ) -> some View {
        modifier(NodeInteractionHandlers(
            isCollapsed: isCollapsed,
            onSelect: onSelect,
            onToggleCollapse: onToggleCollapse,
            onEditNotes: onEditNotes,
            hasChildren: hasChildren
        ))
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static func getSomeRandomNodes() -> [MindNode] {
        return [MindNode("node 1", "test", true)]
    }
    
    init() {
    }
    
    static var previews: some View {
        //        MapNodeRenderer(someNodes: Binding.constant(getSomeRandomNodes()), aString: Binding.constant("test"))
        //            .previewLayout(PreviewLayout.sizeThatFits)
        //            .padding()
        //            .previewDisplayName("Default preview")
        
        
        
        ZStack{
            Section {
                
                ForEach(placeNumbersInCircularPath(3), id: \.self) { cord in
                    HStack{
                        Text("\(cord.xCor) \(cord.yCor)")
                       Circle().size(width: 10, height: 10).position(x: CGFloat(cord.xCor), y: CGFloat(cord.yCor)).fixedSize()

                       // Circle().size(width: 30, height: 30).position(x: 250  , y:0 )
                    }


                }
                
            
                
               // Circle().size(width: 30, height: 30).position(x: 0  , y: 0).fixedSize()
               // Circle().size(width: 30, height: 30).position(x: 0  , y: 0 ).fixedSize()


                
            }
            
            
        }}
    
  
}

enum MindMapCanvas {
    static let width: CGFloat = 1000
    static let height: CGFloat = 1000
    static let center = NodeCoordinate(xCor: 500, yCor: 500)
    static let rootChildRadius = 170
    static let nestedChildRadius = 110
}

struct MindNodeWithCoordinate : Identifiable {
    var id: UUID { node.id }
    
    var node : MindNode
    var coordinate : NodeCoordinate
}

func layoutMindMap(nodes: [MindNode]) -> [MindNodeWithCoordinate] {
    guard let root = nodes.first(where: { $0.isParent }) else { return [] }
    
    var positions: [UUID: NodeCoordinate] = [root.id: MindMapCanvas.center]
    
    func layoutChildren(of parentId: UUID) {
        guard let parent = nodes.first(where: { $0.id == parentId }),
              !parent.isCollapsed,
              let parentPosition = positions[parentId] else { return }
        
        let children = nodes.filter { $0.parentId == parentId }
        guard !children.isEmpty else { return }
        
        let radius = parent.isParent ? MindMapCanvas.rootChildRadius : MindMapCanvas.nestedChildRadius
        let coordinates = placeNumbersAroundCenter(
            count: children.count,
            center: parentPosition,
            radius: radius
        )
        
        for (child, coordinate) in zip(children, coordinates) {
            positions[child.id] = coordinate
            layoutChildren(of: child.id)
        }
    }
    
    layoutChildren(of: root.id)
    
    return nodes.compactMap { node in
        guard let coordinate = positions[node.id] else { return nil }
        return MindNodeWithCoordinate(node: node, coordinate: coordinate)
    }
}

func placeNumbersAroundCenter(count: Int, center: NodeCoordinate, radius: Int) -> [NodeCoordinate] {
    guard count > 0 else { return [] }
    
    return (0..<count).map { index in
        let angle = (Double(index) / Double(count)) * 2 * .pi - .pi / 2
        let x = Double(center.xCor) + Double(radius) * cos(angle)
        let y = Double(center.yCor) + Double(radius) * sin(angle)
        return NodeCoordinate(xCor: Int(x.rounded()), yCor: Int(y.rounded()))
    }
}

func placeNumbersInCircularPath(_ number: Double) -> [NodeCoordinate] {
    placeNumbersAroundCenter(
        count: Int(number),
        center: NodeCoordinate(xCor: 200, yCor: 200),
        radius: 200
    )
}

func path(to: CGPoint, from: CGPoint) -> Path {
    var path = Path()
    path.move(to: from)
    path.addLine(to: to)
    return path
}

struct NodeCoordinate : Hashable {
    var xCor : Int
    var yCor : Int
}

class NodePositionHolder : ObservableObject {
    var nodeToCordinate = [MindNode : NodeCoordinate]()
    
    var currentXCor = 0
    var currentYCor = 0
    
    func x(_ mindNode : MindNode, _ geometry : GeometryProxy) -> CGFloat {
        return CGFloat(getCoordinates(mindNode, geometry).xCor)
    }
    func y(_ mindNode : MindNode, _ geometry : GeometryProxy) -> CGFloat {
        return CGFloat(getCoordinates(mindNode, geometry).yCor)
    }
    
    func getCoordinates(_ mindNode : MindNode, _ geometry : GeometryProxy) -> NodeCoordinate {
        if mindNode.isParent {
            print("Got a node that is the parent")
            var middleX = (geometry.frame(in: .global).midX)
            var middleY = (geometry.frame(in: .global).midY)
            print("MiddleX : \(middleX), MiddleY: \(middleY)")
            return NodeCoordinate(xCor : middleX.exponent + 45, yCor :middleY.exponent + 50)
            //return (xCor :25 , yCor :425)
        }
        else if let foundCordinate = nodeToCordinate[mindNode] {
            return foundCordinate
        } else {
            print("returning new node")
            nodeToCordinate[mindNode] = NodeCoordinate(xCor : currentXCor , yCor : currentYCor)
            currentXCor += 25
            currentYCor += 25
            return nodeToCordinate[mindNode]!
        }
        
    }
}
