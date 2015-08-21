import Foundation
import MapKit

//This subclass was created to set alpha and for debug purposes
//Can set break point and check tile zoo, x, and y being accessed

class GridTileOverlay : MKTileOverlay {
    var alpha:CGFloat = 0.0
    override func loadTileAtPath(path: MKTileOverlayPath, result: (NSData?, NSError?) -> Void) {
       // super.loadTileAtPath(path, result: result)
        //Set breakpoint or write out path for debug
       // NSLog("Inside load")
        let sz: CGSize = self.tileSize
        let rect: CGRect = CGRectMake(0, 0, sz.width, sz.height)
        UIGraphicsBeginImageContext(sz)
        let ctx: CGContextRef = UIGraphicsGetCurrentContext()!
        UIColor.blackColor().setStroke()
        CGContextSetLineWidth(ctx, 1.0)
        CGContextStrokeRect(ctx, CGRectMake(0, 0, sz.width, sz.height))
        let text: String = "X=\(path.x)\nY=\(path.y)\nZ=\(path.z)"
        text.drawInRect(rect, withAttributes: [NSFontAttributeName: UIFont.systemFontOfSize(20.0), NSForegroundColorAttributeName: UIColor.blackColor()])
        let tileImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let tileData: NSData = UIImagePNGRepresentation(tileImage)!
        result(tileData, nil)
    
    }
}