import UIKit

public class GroupQuizProgressLabel : NSObject {

    //// Drawing Methods

    @objc dynamic public class func drawMemberQuizStatusLabel(frame: CGRect = CGRect(x: 0, y: 0, width: 341, height: 50), checkIfQuizComplete: Bool = true) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        // This non-generic function dramatically improves compilation times of complex expressions.
        func fastFloor(_ x: CGFloat) -> CGFloat { return floor(x) }

        //// Color Declarations
        let color = UIColor(red: 0.331, green: 0.896, blue: 0.920, alpha: 1.000)
        let color2 = UIColor(red: 0.956, green: 0.244, blue: 0.000, alpha: 1.000)
        let shadowColor = UIColor(red: 0.839, green: 0.977, blue: 0.000, alpha: 1.000)
        let color3 = UIColor(red: 0.000, green: 0.735, blue: 1.000, alpha: 1.000)

        //// Gradient Declarations
        let gradient = CGGradient(colorsSpace: nil, colors: [UIColor.red.cgColor, UIColor.white.cgColor] as CFArray, locations: [0, 1])!
        let gradient2 = CGGradient(colorsSpace: nil, colors: [UIColor.green.cgColor, UIColor.white.cgColor] as CFArray, locations: [0, 1])!

        //// Shadow Declarations
        let shadow = NSShadow()
        shadow.shadowColor = shadowColor
        shadow.shadowOffset = CGSize(width: 3, height: 3)
        shadow.shadowBlurRadius = 12


        //// Subframes
        let complete: CGRect = CGRect(x: frame.minX + 1, y: frame.minY + 1, width: fastFloor((frame.width - 1) * 0.99706 + 0.5), height: fastFloor((frame.height - 1) * 0.97959 + 0.5))
        let inprogress: CGRect = CGRect(x: frame.minX + 1, y: frame.minY + 1, width: fastFloor((frame.width - 1) * 1.00000 + 0.5), height: fastFloor((frame.height - 1) * 0.97959 + 0.5))


        //// Complete
        //// groupQuizComplete Drawing
        let groupQuizCompleteRect = CGRect(x: complete.minX + fastFloor(complete.width * 0.00000 + 0.5), y: complete.minY + fastFloor(complete.height * 0.00000 + 0.5), width: fastFloor(complete.width * 1.00000 + 0.5) - fastFloor(complete.width * 0.00000 + 0.5), height: fastFloor(complete.height * 1.00000 + 0.5) - fastFloor(complete.height * 0.00000 + 0.5))
        let groupQuizCompletePath = UIBezierPath(roundedRect: groupQuizCompleteRect, cornerRadius: 5)
        color.setFill()
        groupQuizCompletePath.fill()
        UIColor.blue.setStroke()
        groupQuizCompletePath.lineWidth = 2
        groupQuizCompletePath.stroke()
        let groupQuizCompleteTextContent = "          Complete"
        let groupQuizCompleteStyle = NSMutableParagraphStyle()
        groupQuizCompleteStyle.alignment = .center
        let groupQuizCompleteFontAttributes = [
            .font: UIFont.boldSystemFont(ofSize: 15),
            .foregroundColor: UIColor.white,
            .paragraphStyle: groupQuizCompleteStyle,
        ] as [NSAttributedStringKey: Any]

        let groupQuizCompleteTextHeight: CGFloat = groupQuizCompleteTextContent.boundingRect(with: CGSize(width: groupQuizCompleteRect.width, height: CGFloat.infinity), options: .usesLineFragmentOrigin, attributes: groupQuizCompleteFontAttributes, context: nil).height
        context.saveGState()
        context.clip(to: groupQuizCompleteRect)
        groupQuizCompleteTextContent.draw(in: CGRect(x: groupQuizCompleteRect.minX, y: groupQuizCompleteRect.minY + (groupQuizCompleteRect.height - groupQuizCompleteTextHeight) / 2, width: groupQuizCompleteRect.width, height: groupQuizCompleteTextHeight), withAttributes: groupQuizCompleteFontAttributes)
        context.restoreGState()


        //// Star 2 Drawing
        let star2Path = UIBezierPath()
        star2Path.move(to: CGPoint(x: complete.minX + 0.85546 * complete.width, y: complete.minY + 0.10417 * complete.height))
        star2Path.addLine(to: CGPoint(x: complete.minX + 0.87626 * complete.width, y: complete.minY + 0.31858 * complete.height))
        star2Path.addLine(to: CGPoint(x: complete.minX + 0.91157 * complete.width, y: complete.minY + 0.39208 * complete.height))
        star2Path.addLine(to: CGPoint(x: complete.minX + 0.88912 * complete.width, y: complete.minY + 0.59809 * complete.height))
        star2Path.addLine(to: CGPoint(x: complete.minX + 0.89013 * complete.width, y: complete.minY + 0.85792 * complete.height))
        star2Path.addLine(to: CGPoint(x: complete.minX + 0.85546 * complete.width, y: complete.minY + 0.77083 * complete.height))
        star2Path.addLine(to: CGPoint(x: complete.minX + 0.82078 * complete.width, y: complete.minY + 0.85792 * complete.height))
        star2Path.addLine(to: CGPoint(x: complete.minX + 0.82179 * complete.width, y: complete.minY + 0.59809 * complete.height))
        star2Path.addLine(to: CGPoint(x: complete.minX + 0.79935 * complete.width, y: complete.minY + 0.39208 * complete.height))
        star2Path.addLine(to: CGPoint(x: complete.minX + 0.83465 * complete.width, y: complete.minY + 0.31858 * complete.height))
        star2Path.close()
        context.saveGState()
        star2Path.addClip()
        let star2RotatedPath = UIBezierPath()
        star2RotatedPath.append(star2Path)
        var star2Transform = CGAffineTransform(rotationAngle: -135 * -CGFloat.pi/180)
        star2RotatedPath.apply(star2Transform)
        let star2Bounds = star2RotatedPath.cgPath.boundingBoxOfPath
        star2Transform = star2Transform.inverted()
        context.drawLinearGradient(gradient2,
            start: CGPoint(x: star2Bounds.minX, y: star2Bounds.midY).applying(star2Transform),
            end: CGPoint(x: star2Bounds.maxX, y: star2Bounds.midY).applying(star2Transform),
            options: [])
        context.restoreGState()
        context.saveGState()
        context.setShadow(offset: shadow.shadowOffset, blur: shadow.shadowBlurRadius, color: (shadow.shadowColor as! UIColor).cgColor)
        UIColor.red.setStroke()
        star2Path.lineWidth = 2
        star2Path.stroke()
        context.restoreGState()




        if (checkIfQuizComplete) {
            //// Inprogress
            if (checkIfQuizComplete) {
                //// groupQuizInComplete Drawing
                let groupQuizInCompleteRect = CGRect(x: inprogress.minX + fastFloor(inprogress.width * 0.00000 + 0.5), y: inprogress.minY + fastFloor(inprogress.height * 0.00000 + 0.5), width: fastFloor(inprogress.width * 1.00000 + 0.5) - fastFloor(inprogress.width * 0.00000 + 0.5), height: fastFloor(inprogress.height * 1.00000 + 0.5) - fastFloor(inprogress.height * 0.00000 + 0.5))
                let groupQuizInCompletePath = UIBezierPath(roundedRect: groupQuizInCompleteRect, cornerRadius: 5)
                color2.setFill()
                groupQuizInCompletePath.fill()
                color3.setStroke()
                groupQuizInCompletePath.lineWidth = 2
                groupQuizInCompletePath.lineJoinStyle = .round
                groupQuizInCompletePath.stroke()
                let groupQuizInCompleteTextContent = "          In Progress"
                let groupQuizInCompleteStyle = NSMutableParagraphStyle()
                groupQuizInCompleteStyle.alignment = .center
                let groupQuizInCompleteFontAttributes = [
                    .font: UIFont.boldSystemFont(ofSize: 16),
                    .foregroundColor: UIColor.white,
                    .paragraphStyle: groupQuizInCompleteStyle,
                ] as [NSAttributedStringKey: Any]

                let groupQuizInCompleteTextHeight: CGFloat = groupQuizInCompleteTextContent.boundingRect(with: CGSize(width: groupQuizInCompleteRect.width, height: CGFloat.infinity), options: .usesLineFragmentOrigin, attributes: groupQuizInCompleteFontAttributes, context: nil).height
                context.saveGState()
                context.clip(to: groupQuizInCompleteRect)
                groupQuizInCompleteTextContent.draw(in: CGRect(x: groupQuizInCompleteRect.minX, y: groupQuizInCompleteRect.minY + (groupQuizInCompleteRect.height - groupQuizInCompleteTextHeight) / 2, width: groupQuizInCompleteRect.width, height: groupQuizInCompleteTextHeight), withAttributes: groupQuizInCompleteFontAttributes)
                context.restoreGState()


                //// Star Drawing
                let starPath = UIBezierPath()
                starPath.move(to: CGPoint(x: inprogress.minX + 0.84706 * inprogress.width, y: inprogress.minY + 0.10417 * inprogress.height))
                starPath.addLine(to: CGPoint(x: inprogress.minX + 0.86780 * inprogress.width, y: inprogress.minY + 0.31858 * inprogress.height))
                starPath.addLine(to: CGPoint(x: inprogress.minX + 0.90300 * inprogress.width, y: inprogress.minY + 0.39208 * inprogress.height))
                starPath.addLine(to: CGPoint(x: inprogress.minX + 0.88063 * inprogress.width, y: inprogress.minY + 0.59809 * inprogress.height))
                starPath.addLine(to: CGPoint(x: inprogress.minX + 0.88163 * inprogress.width, y: inprogress.minY + 0.85792 * inprogress.height))
                starPath.addLine(to: CGPoint(x: inprogress.minX + 0.84706 * inprogress.width, y: inprogress.minY + 0.77083 * inprogress.height))
                starPath.addLine(to: CGPoint(x: inprogress.minX + 0.81248 * inprogress.width, y: inprogress.minY + 0.85792 * inprogress.height))
                starPath.addLine(to: CGPoint(x: inprogress.minX + 0.81349 * inprogress.width, y: inprogress.minY + 0.59809 * inprogress.height))
                starPath.addLine(to: CGPoint(x: inprogress.minX + 0.79111 * inprogress.width, y: inprogress.minY + 0.39208 * inprogress.height))
                starPath.addLine(to: CGPoint(x: inprogress.minX + 0.82631 * inprogress.width, y: inprogress.minY + 0.31858 * inprogress.height))
                starPath.close()
                context.saveGState()
                starPath.addClip()
                let starRotatedPath = UIBezierPath()
                starRotatedPath.append(starPath)
                var starTransform = CGAffineTransform(rotationAngle: -135 * -CGFloat.pi/180)
                starRotatedPath.apply(starTransform)
                let starBounds = starRotatedPath.cgPath.boundingBoxOfPath
                starTransform = starTransform.inverted()
                context.drawLinearGradient(gradient,
                    start: CGPoint(x: starBounds.minX, y: starBounds.midY).applying(starTransform),
                    end: CGPoint(x: starBounds.maxX, y: starBounds.midY).applying(starTransform),
                    options: [])
                context.restoreGState()
                context.saveGState()
                context.setShadow(offset: shadow.shadowOffset, blur: shadow.shadowBlurRadius, color: (shadow.shadowColor as! UIColor).cgColor)
                color3.setStroke()
                starPath.lineWidth = 2
                starPath.stroke()
                context.restoreGState()
            }


        }
    }

}
