//
//  TubeHelpView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-07-10.
//

import SwiftUI

struct TubeHelpView: View{
    @Environment(\.dismiss) private var dismiss
    @GestureState private var pinchMagnification: CGFloat = 1.0
    @GestureState private var twistAngle: Angle = Angle.zero
    @GestureState private var fingerLocation: CGPoint? = nil
    @GestureState private var startLocation: CGPoint? = nil
    @State var currentMagnification = 1.0
    @State var currentRotation = Angle.zero
    @State var location = CGPoint()
    
    // MARK: - GESTRURES
    var simpleDragGesture: some Gesture {
        DragGesture()
        .onChanged { value in
            var newLocation = startLocation ?? location
            newLocation.x += value.translation.width
            newLocation.y += value.translation.height
            location = newLocation
        }.updating($startLocation) { (value, startLocation, transaction) in
            startLocation = startLocation ?? location
        }
    }
        
    var fingerDragGesture: some Gesture {
        DragGesture()
        .updating($fingerLocation) { (value, fingerLocation, transaction) in
            fingerLocation = value.location
        }
    }
    
    var rotationGesture: some Gesture{
        RotationGesture()
        .updating($twistAngle){ (value, twistAngle, transaction) in
            twistAngle = value
        }
        .onEnded { angle in
            currentRotation += angle
        }
    }
    
    var magnificationGesture: some Gesture{
        MagnificationGesture()
        .updating($pinchMagnification){ (value, pinchMagnification, transaction) in
            pinchMagnification = value
        }
        .onEnded{ scale in
            currentMagnification *= scale
            
        }
    }
    
    var body:some View{
        VStack(spacing:0){
            TopMenu(title: "Information", actionCloseButton: closeView)
            helpBody
        }
        .modifier(HalfSheetModifier())
    }
    
    var helpBody: some View{
        VStack(spacing:10){
            List{
                Section {
                    Image("tubeskiss_3")
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(currentMagnification * pinchMagnification)
                        .rotationEffect(currentRotation + twistAngle)
                        .simultaneousGesture(rotationGesture.simultaneously(with: magnificationGesture))
                } header: {
                    Text("Measurement")
                } footer: {
                    Text("")
                }
                Section {
                    HeaderSubHeaderView(header: "Unit", subHeader: "Millimeter").foregroundColor(Color.darkGray)
                    HeaderSubHeaderView(header: "Radius", subHeader: "Measure from center of tube").foregroundColor(Color.darkGray)
                } header: {
                    Text("Information")
                } footer: {
                    Text("")
                }
           }
           .scrollContentBackground(.hidden)
        }
    }
    
    //MARK: - BUTTON FUNCTIONS
    func closeView(){
        dismiss()
    }
    
}
