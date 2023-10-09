//
//  ImagePickerViews.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-21.
//

import SwiftUI
import PhotosUI
struct ImagePickerSwiftUi:View {
    @Binding var docContent: DocumentContent
    @State private var selectedItem: PhotosPickerItem? = nil
    @State var image: Image?
    
    func resizeUiImage(_ uiImage:UIImage){
        DispatchQueue.global().async{
            uiImage.resizeImageIfNeeded(
                compressionQuality:1.0,
                maxSize:MAX_STORAGE_JPEG_SIZE,
                minSize:MIN_STORAGE_JPEG_SIZE,
                maxAttempts:10,
                data:&docContent.data)
            DispatchQueue.main.async{
                image = Image(uiImage: uiImage)
            }
        }
    }
    
    
    var body:some View{
        ZStack{
            PhotosPicker(
                selection: $selectedItem,
                matching: .images,
                photoLibrary: .shared()) {
                    VStack(spacing:V_SPACING_REG){
                        Label("Attach photo",systemImage: "photo.on.rectangle.angled").hLeading()
                        if image != nil{
                            HStack{
                                image?
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                                .hLeading()
                                Button("\(Image(systemName: "xmark"))", action: {
                                    withAnimation{
                                        image = nil
                                    }
                                    
                                })
                                .foregroundColor(.red)
                                .vBottom()
                                .hTrailing()
                            }
                        }
                        
                    }
                    .foregroundColor(Color.systemGray)
                }
                .onChange(of: selectedItem) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            guard let uiImage = UIImage(data: data) else { return }
                            resizeUiImage(uiImage)
                            //docContent.data = data
                            //image = Image(uiImage: uiImage)
                        }
                    }
                }
        }
        .hLeading()
        .halfSheetWhitePadding()
        
    }
}



struct UserImage: View{
    @Binding var profilePicture:Image?
    @Binding var activeImagePicker:ActiveImagePickerActionSheet?
    @Binding var isPrivacyResult:Bool
    @StateObject var photoGalleryPermissionHandler = PhotoGalleryPermissionHandler()
    
    var body: some View{
        HStack(alignment: .center){
            Spacer()
            profilePicture?
                .resizable()
                .scaledToFit()
                .frame(height: 100)
                //.clipShape(Circle())
                .foregroundColor(.backgroundPrimary)
                .onTapGesture {
                    activeImagePicker = .ORIGINAL_PICKER
                    photoGalleryPermissionHandler.checkPermission()
                    switch photoGalleryPermissionHandler.authorizationStatus {
                     case .notDetermined:
                            photoGalleryPermissionHandler.requestPermission()
                     case .denied, .restricted:
                            activateAccessDeniedAlert()
                            isPrivacyResult.toggle()
                     case .authorized:
                        activeImagePicker = .ORIGINAL_PICKER
                     case .limited:
                        activeImagePicker = .MULTIPLE_PICKER
                      @unknown default:
                         fatalError("PHPhotoLibrary::execute - \"Unknown case\"")
                    }
                }
            Spacer()
        }
        .listRowBackground(Color.clear)
    }
    
    func activateAccessDeniedAlert(){
        ALERT_PRIVACY_TITLE = "Missing Permission"
        ALERT_PRIVACY_MESSAGE = "Please go to settings to set permission"
    }
}


