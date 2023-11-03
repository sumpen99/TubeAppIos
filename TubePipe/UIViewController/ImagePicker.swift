//
//  ImagePicker.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-06-10.
//

import PhotosUI
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: Image?
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        //let library = PHPhotoLibrary.shared()
        //library.presentLimitedLibraryPicker(from: picker)
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        config.preferredAssetRepresentationMode = .current
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {

    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        let fileName = USER_PROFILE_PIC_PATH + ".png"
     
        init(_ parent: ImagePicker) {
             self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            if let itemProvider = results.first?.itemProvider,
                   itemProvider.canLoadObject(ofClass: UIImage.self) {
                    itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                        guard let strongSelf = self else { return }
                        if let uiImage = image as? UIImage {
                            DispatchQueue.main.async {
                                strongSelf.parent.image = Image(uiImage: uiImage)
                            }
                            /*FileHandler.removeFileFromDocuments(strongSelf.fileName)
                            FileHandler.writeImageToDocuments(uiImage, fileName: strongSelf.fileName){ result in
                                if result.finishedWithoutError{
                                    DispatchQueue.main.async {
                                        strongSelf.parent.image = Image(uiImage: uiImage)
                                        
                                    }
                                }
                            }*/
                            
                            //DispatchQueue.main.async {
                                //strongSelf.parent.image = Image(uiImage: uiImage)
                            //}
                        }
                    }
                }
        }
        
        func imagePickerControllerDidCancel(_ picker: PHPickerViewController) {
            picker.dismiss(animated: true)
        }
        
        
    }
}
