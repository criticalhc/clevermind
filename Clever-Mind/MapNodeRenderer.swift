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
    
    var xCorHolder = 150 as CGFloat
    
    @State var xPosition = 0 as CGFloat
    
    @StateObject var nodePositionHolder = NodePositionHolder()
    
    
    //can be used to control the number of nodes on screen
    func getNodes(_ nodes : [MindNode]) -> Array<(offset: Int, element: MindNode)>  {
        if someNodes.count >= 1 {
            return Array(Array(someNodes.enumerated()))
        } else {
            return Array(someNodes.enumerated())
        }
    }
    
    
    var body : some View {
        ForEach(getNodes(someNodes), id: \.offset) { index, data in
            GeometryReader { geo in
                    ZStack {
                        
                        Circle()
                            .size(width: 400, height: 300)
                            .offset(x: -135, y: -120)
                            .onTapGesture {
                                print("Global centre:  \(geo.frame(in: .global).midX) x \(geo.frame(in: .global).midY)")
                            }
                        
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
                        }.border(.black)
                  
                    .position(x: nodePositionHolder.x(data, geo), y: nodePositionHolder.y(data, geo) )
                            .fixedSize()
            }

        }
//        ZStack {
//            NavigationLink(destination: {
//                Text("Hello")
//
//            }, label: {
//                Ellipse().fill(Color.mint).shadow(radius: 3)
//            })
//
//            Text("test")
//        }.border(.black)
//            .position(x: 100, y: 200)
//
//
//        ZStack {
//
//            NavigationLink(destination: {
//                Text("Hello")
//
//            }, label: {
//                Ellipse().fill(Color.mint).shadow(radius: 3)
//            })
//
//            Text("test")
//        }
        
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
                
                ForEach(placeNumbersInCircularPath(), id: \.self) { cord in
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
    
    static func placeNumbersInCircularPath() -> [NodeCoordinate] {
        let number = 3.0 // how many number to be placed
        let size = 50.0 // size of circle i.e. w = h = 260
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
