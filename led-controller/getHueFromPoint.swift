import SwiftUI

func getHueFromPoint(image: UIImage, point: CGPoint) -> CGFloat? {
    guard point.x >= 0 && point.x < image.size.width && point.y >= 0 && point.y < image.size.height else {
        return nil
    }
    
    // Adjust the y-coordinate
    let adjustedY = image.size.height - point.y
    
    let pixelPoint: CGPoint = CGPoint(x: point.x * image.scale, y: adjustedY * image.scale)
    
    let cgImage = image.cgImage!
    let width = cgImage.width
    let height = cgImage.height
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    var pixelData = [UInt8](repeating: 0, count: 4)
    let context = CGContext(data: &pixelData,
                            width: 1,
                            height: 1,
                            bitsPerComponent: 8,
                            bytesPerRow: 4,
                            space: colorSpace,
                            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
    
    context?.translateBy(x: -pixelPoint.x, y: -pixelPoint.y)
    context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
    
    let red = CGFloat(pixelData[0]) / 255.0
    let green = CGFloat(pixelData[1]) / 255.0
    let blue = CGFloat(pixelData[2]) / 255.0
    let alpha = CGFloat(pixelData[3]) / 255.0
    
    let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
    
    var hue: CGFloat = 0
    color.getHue(&hue, saturation: nil, brightness: nil, alpha: nil)
    
    return hue
}

