import Foundation
struct PIX: Hashable {
    let r, g, b, a: Int
    init(_ r: Int, _ g: Int, _ b: Int, _ a: Int) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
    func description() -> String {
        return "R: \(r), G: \(g), B:\(b), A: \(a)"
    }
}

var dic = [PIX: Int]()
func run() {
    print("请输入输入图片名（默认为test.png）:")
    if var inputPath = readLine() {
        if inputPath.count == 0 {
            inputPath = "test.png"
        }
        let url  = URL(fileURLWithPath: inputPath)
        if let img = getInputImage(url: url) {
            let W = Int(img.width)
            let H = Int(img.height)
            print("宽：\(W) 高：\(H)")
            for w in 0..<W {
                for h in 0..<H {
                    if let pix = cxg_getPointColor(withImage: img, point: CGPoint(x: w, y: h)) {
                        dic[pix, default: 0] += 1
                    }
                }
            }

            for (k, v) in dic {
                print("总数: " + "\(v)   " + k.description())
            }
            print("像素总数: \(dic.keys.count)")
        }
    } else {
        print("输入失败")
    }
}

func getInputImage(url: URL) -> CGImage? {
    do{
        let inoutData = try Data(contentsOf: url)
        let dataProvider = CGDataProvider(data: inoutData as CFData)
        if let img = CGImage(pngDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent) {
            return img
        }else {
            return nil
        }
    } catch {
        print(error.localizedDescription)
        return nil
    }
}

func cxg_getPointColor(withImage cgImage: CGImage, point: CGPoint) -> PIX? {
    let pointX = trunc(point.x);
    let pointY = trunc(point.y);

    let width = cgImage.width;
    let height = cgImage.height;
    let colorSpace = CGColorSpaceCreateDeviceRGB();
    var pixelData: [UInt8] = [0, 0, 0, 0]

    pixelData.withUnsafeMutableBytes { pointer in
        if let context = CGContext(data: pointer.baseAddress, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) {
            context.setBlendMode(.copy)
            context.translateBy(x: -pointX, y: pointY - CGFloat(height))
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        }
    }

    let red = Int(pixelData[0])
    let green = Int(pixelData[1])
    let blue = Int(pixelData[2])
    let alpha = Int(pixelData[3])

    return PIX(red, green, blue, alpha)
}

run()


