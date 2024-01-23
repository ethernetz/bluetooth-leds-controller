import SwiftUI

struct ColorPickerImageView: View {
    var uiImage: UIImage
    var onColorChange: (CGFloat?) -> Void // Closure to notify about color changes
    
    var body: some View {
        let originalSize = uiImage.size
        let newWidth: CGFloat = 350
        let newHeight: CGFloat = (originalSize.height / originalSize.width) * newWidth
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        Image(uiImage: uiImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: newWidth)
            .cornerRadius(10)
            .coordinateSpace(name: "Color-picker")
            .gesture(
                DragGesture(coordinateSpace: .named("Color-picker"))
                    .onChanged({ value in
                        let point = mapPointToOriginalImage(pointOnNewImage: value.location, originalSize: originalSize, newSize: newSize)
                        let hue = getHueFromPoint(image: uiImage, point: point)
                        onColorChange(hue)
                    })
            )
            .onTapGesture(coordinateSpace: .local) { location in
                let point = mapPointToOriginalImage(pointOnNewImage: location, originalSize: originalSize, newSize: newSize)
                let hue = getHueFromPoint(image: uiImage, point: point)
                onColorChange(hue)
            }
    }
    
    private func mapPointToOriginalImage(pointOnNewImage: CGPoint, originalSize: CGSize, newSize: CGSize) -> CGPoint {
        let scaleX = originalSize.width / newSize.width
        let scaleY = originalSize.height / newSize.height
        return CGPoint(x: pointOnNewImage.x * scaleX, y: pointOnNewImage.y * scaleY)
    }
}
