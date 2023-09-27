//
//  Qr.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-21.
//

import SwiftUI

func getQrImage() -> (Image?,String?){
    let token = UUID().uuidString
    guard let data = generateQrCode(qrCodeStr:token),
          let uiImage = UIImage(data: data) else { return (nil,nil)}
    
    return (Image(uiImage:uiImage),token)
}

func generateQrCode(qrCodeStr:String) -> Data?{
    guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
    let data = qrCodeStr.data(using: .ascii, allowLossyConversion: false)
    filter.setValue(data, forKey: "inputMessage")
    guard let ciimage = filter.outputImage else { return nil }
    let transform = CGAffineTransform(scaleX: 10, y: 10)
    let scaledCIImage = ciimage.transformed(by: transform)
    let uiimage = UIImage(ciImage: scaledCIImage)
    return uiimage.pngData()
}
