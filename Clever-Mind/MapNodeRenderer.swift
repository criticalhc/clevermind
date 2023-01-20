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
    
    enum FoucusField : Hashable {
        case field
    }
    
    @Binding var aString :  String
    
    @State var textFieldContents : String = ""
    
    var xCorHolder = 150 as CGFloat
    
    @State var xPosition = 0 as CGFloat
    
    @StateObject var nodePositionHolder = NodePositionHolder()
    
    @FocusState private var focusedField : FoucusField?
    
    @State var childNodeText = ""
    
    @State var parentNodeCoordinates : CGPoint = CGPoint()
    
    
    //can be used to control the number of nodes on screen
    func getNodes(_ nodes : [MindNode]) -> Array<(offset: Int, element: MindNode)>  {
        if someNodes.count >= 1 {
            return Array(Array(someNodes.enumerated()))
        } else {
            return Array(someNodes.enumerated())
        }
    }
    
    
    var body : some View {
        ZStack {
            ForEach(getNodes(someNodes).filter { $0.element.isParent }, id: \.offset) { index, data in
                
                
                    NavigationLink(destination: {
                        Text("Hello")
                        
                    }, label: {
                        Ellipse().fill(Color.mint).shadow(radius: 3)
                        
                        
                    }).frame(width: 125, height: 75)
               
            
                
                
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
                        someNodes.insert(MindNode(data.title, "test", data.isParent), at: index)
                        print("commit")
                    }
                )
                    .multilineTextAlignment(.center)
                    .frame(width: 100, height: 50)
                    .fixedSize()
                
                
            }
            
            
            
            Group {
                ForEach(getCordinatesForChildNodes(nodes: someNodes.filter { !$0.isParent })) { cord in
                    //Text("\(cord.xCor) \(cord.yCor)")
                 
                       

                        TextField("new topic...", text: $someNodes[computeIndexOfMindNode(targetNode: cord.node, someNodes: someNodes)].title)
                            .position(x: CGFloat(cord.coordinate.xCor), y: CGFloat(cord.coordinate.yCor))
                            .gesture (
                                TapGesture().onEnded {
                                    print("I've been tapped")
                                })
                            .fixedSize()
                        path(to: CGPoint(x:cord.coordinate.xCor, y: cord.coordinate.yCor), from: {
                            return CGPoint(x: parentNodeCoordinates.x + 120, y: parentNodeCoordinates.y + 120)
                        }() ).stroke(Color.black, lineWidth: 1).fixedSize().zIndex(-1)              }
                   
                        
            
            }.offset(x: -120, y : -120)
        
                
                
                
            
            
         }
        
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

struct MindNodeWithCoordinate : Identifiable {
    var id = UUID()
    
    var node : MindNode
    var coordinate : NodeCoordinate
}

func getCordinatesForChildNodes(nodes : [MindNode]) -> Array<MindNodeWithCoordinate> {
    print("nodes \(nodes)")
    print("nodes \(nodes.isEmpty)")

    guard nodes.isEmpty != true else {
        return []

    }
    
    var nodeToCordinate = [MindNodeWithCoordinate]()
    let circularPathCordinates = placeNumbersInCircularPath(Double(nodes.count))[0...nodes.count-1]
    
    var loopCounter = 0
    for coordinate in circularPathCordinates {
        nodeToCordinate.append(MindNodeWithCoordinate( node : nodes[loopCounter],coordinate: coordinate))
        loopCounter += 1
    }
    
    return nodeToCordinate
    
    
}

func placeNumbersInCircularPath(_ number : Double) -> [NodeCoordinate] {
     let number = number // how many number to be placed
     let size = 400.0 // size of circle i.e. w = h = 260
    let cx =  size/2 // center of x(in a circle)
    let cy  = size/2// center of y(in a circle)
    let r = size/2 // radius of a circle
    
    var arrayOfInts = Array(1...Int(number))
    var arrayOfFloats = arrayOfInts.map {Double($0)}
    
    var returnArray = [NodeCoordinate]()
    
    arrayOfFloats.forEach { i in
        let ang = i * (Double.pi/(number/2));
        let left = cx + (r * cos(ang));
        let top = cy + (r * sin(ang));
        print("top: ", top, ", left: ", left);
        returnArray.append(NodeCoordinate(xCor: Int(left), yCor: Int(top)))
    }
    
    return returnArray
   
    

}

func path(to: CGPoint, from: CGPoint) -> Path {
    var path = Path()
    print("to: \(to) from: \(from)")
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
