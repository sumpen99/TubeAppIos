//
//  TubeHelpView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-07-10.
//

import SwiftUI

struct TubeHelpView: View{
    @EnvironmentObject var firebaseAuth: FirebaseAuth
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
        NavigationView{
            AppBackgroundStack(content: {
                helpBody
            })
            .modifier(NavigationViewModifier(title: ""))
        }
        .hiddenBackButtonWithCustomTitle("Home")
    }
    
    var helpBody: some View{
        VStack(spacing:10){
            List{
                Section(header: Text("Measurement").listSectionHeader(), footer: Text("")) {
                    Image("tubeskiss_3")
                        .resizable()
                        .scaledToFit()
                        //.offset(CGSizeMake(reader.size.width/2, reader.size.height/2))
                        .scaleEffect(currentMagnification * pinchMagnification)
                        .rotationEffect(currentRotation + twistAngle)
                        //.position(location)
                        //.simultaneousGesture(simpleDragGesture.simultaneously(with: fingerDragGesture))
                        .simultaneousGesture(rotationGesture.simultaneously(with: magnificationGesture))
                    
                }
                
                Section(header: Text("Information").listSectionHeader(), footer: Text("")) {
                   HeaderSubHeaderView(header: "Unit", subHeader: "Millimeter.")
                   HeaderSubHeaderView(header: "Radius", subHeader: "Measure radius from middle of steel.")
                   HeaderSubHeaderView(header: "Len A & Len B", subHeader: "Select overlap option to add 100mm on each side.")
                   if firebaseAuth.loggedInAs == .ANONYMOUS_USER{
                       HeaderSubHeaderView(header: "Share & Save", subHeader: "Register an free account to save and share tubes.")
                   }
               }
           }
           .scrollContentBackground(.hidden)
        }
    }
    
}
