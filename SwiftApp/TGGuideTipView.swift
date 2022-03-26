//
//  TGGuideToastView.swift
//  TGToolsKit
//
//  Created by 杨佩 on 2022/3/15.
//

import UIKit

public enum angleDirection {
    case left, right
    case topLeft, topCenter, topRight
    case bottomLeft, bottomCenter, bottomRight
}

enum direction {//内部使用
    case left, bottom, right, top
}

public typealias closeCompletionBlock = (()->())

@objcMembers
public class TGGuideTipsView: UIView {

    private lazy var l: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.textColor = .white
        l.lineBreakMode = .byTruncatingTail
        l.numberOfLines = 1
        l.font = .systemFont(ofSize: 14)
        return l
    }()
    
    private lazy var maxLabelW: CGFloat = {
        if getDirection == .left, getDirection == .right {//箭头在左右 - 则左右边距4pt, 其余情况 16pt
            return UIView.screnWidth() - 8 - 16 * 2 - 12 - 8
        }
        
        return UIView.screnWidth() - 32 - 16 * 2 - 12 - 8
    }()
    
    private var lableW: CGFloat {
        get {
            l.sizeThatFits(CGSize(width: 666, height: l.font.lineHeight)).width
        }
    }
    
    private var angleDirection: angleDirection = .bottomCenter

    private var closeButton: UIButton = {
        let b = UIButton(type: .custom)
        b.setEnlargeEdge(20)
        
        b.setTitle("x", for: .normal)
        b.titleLabel?.font = UIFont.init(name: "iconfont", size: 16)
        b.tintColor = UIColor.blue.withAlphaComponent(0.4)
        b.addTarget(self, action: #selector(onClose), for: .touchUpInside)
        b.backgroundColor = .clear
        return b
    }()
    
    private lazy var getCotentSize: CGSize = {
        var contentSize = frame.size
        if getDirection == .left || getDirection == .right {
            contentSize.width = contentSize.width - 6 - 8

        } else {
            contentSize.height = contentSize.height - 6
            contentSize.width = contentSize.width - 32
        }
        
        return contentSize
    }()
    
    private lazy var contentLayerView: UIView = {
        let contentLayerView = UIView()
        contentLayerView.backgroundColor = .white.withAlphaComponent(0.5)
        contentLayerView.layer.shadowColor = UIColor.blue.withAlphaComponent(0.4).cgColor
        contentLayerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        contentLayerView.layer.shadowOpacity = 1
        contentLayerView.layer.shadowRadius = 8
        
        return contentLayerView
    }()
    
    
    private var contentView: UIView = {
        let v = TGBaseView()
        v.backgroundColor = UIColor.tg_mainTheme()
        v.layer.cornerRadius = kMargin_8
        v.clipsToBounds = true
        return v
    }()
    
    
//    public var triangleCenterX: CGFloat = .zero
    
    private lazy var triangelView: UIView = {
        let v = TriangleView()
        
        return v
    }()
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        var angle: CGFloat = 0
        switch getDirection {
        case .bottom :
            break
        case .left :
            angle = CGFloat.pi / 2
        case .top :
            angle = CGFloat.pi
        case .right :
            angle = -CGFloat.pi / 2
        }
        
        triangelView.transform = CGAffineTransform(rotationAngle: angle)
        
    }
    
    
    @objc private func onClose() {
        completionBlock?()
        
        DispatchQueue.main.async {
            self.removeFromSuperview()
        }
        
    }
    
    
    private lazy var getDirection: direction = {
        //方向
        var d:direction = .bottom
        
        if angleDirection == .left {
            d = .left
        } else if angleDirection == .right {
            d = .right
        } else if angleDirection == .topLeft ||
                    angleDirection == .topRight ||
                    angleDirection == .topCenter {
            d = .top
        } else {
            d = .bottom
        }
        
        return d
    }()
    
    private var completionBlock: closeCompletionBlock?
    
    /// 带箭头的提示文字
    /// - Parameters:
    ///   - with: 文字内容 -值显示一行,超出内容...
    ///   - direction: 箭头方向, 总共八个方向, topLeft,离父控件左边40,以此类推
    ///   - completion: 点击回调,可为空
    /// - Returns: 返回标准提示大小
    public static func config(with :String, direction:angleDirection, _ completion:closeCompletionBlock?) -> TGGuideTipsView {
        let view = TGGuideTipsView()
        
        view.completionBlock = completion

        view.angleDirection = direction

        view.l.text = with
        
        view.setupFrame()
        
        view.setupUI(with: view.getDirection)
        
        return view
    }
    
    private func setupFrame() {
        let angleH = 6

        var w = maxLabelW//最大文字宽度
        var h = 36//内容高度
        if angleDirection == .left || angleDirection == .right {
            w = w - angleH//三角位置为左右, label 距离要减去 angleH
        } else {
            h = h + angleH
        }
        
        if lableW > w {//超出位置
            frame = CGRect(x: 0, y: 0, width: UIView.screnWidth(), height: h)
        } else {
            let viewW = lableW + 32 + 16 * 2 + 12 + 8
            frame = CGRect(x: 0, y: 0, width: viewW, height: h)
        }
    }
    
    
    
    private func setupUI(with d: direction) {
        
        [contentLayerView, contentView, triangelView].forEach({self.addSubview($0)})
        [l, closeButton].forEach({contentView.addSubview($0)})
        
        contentLayerView.snp.makeConstraints({
            $0.center.equalToSuperview()
            $0.size.equalTo(getCotentSize)
        })
        
        contentView.snp.makeConstraints({
            
            if getDirection == .left || getDirection == .right {
                let offsetX = (getDirection == .left) ? kMargin_7 : -kMargin_7
                $0.centerX.equalToSuperview().offset(offsetX)
                $0.centerY.equalToSuperview()

            } else {

                let offsetY = (getDirection == .top) ? kMargin_3 : -kMargin_3
                $0.centerY.equalToSuperview().offset(offsetY)
                $0.centerX.equalToSuperview()
            }
            
            $0.size.equalTo(getCotentSize)
        })
        
        
        
        triangelView.snp.makeConstraints({
            
            $0.size.equalTo(CGSize(width: kMargin_12, height: kMargin_6))

            switch angleDirection {
                case .left:
                    $0.right.equalTo(contentView.snp.left).offset(kMargin_6)
                    $0.centerY.equalTo(contentView)

                case .right:
                    $0.left.equalTo(contentView.snp.right).offset(-kMargin_6)
                    $0.centerY.equalTo(contentView)

                case .topLeft:
                    $0.left.equalTo(contentView).offset(kMargin(40))
                    $0.bottom.equalTo(contentView.snp.top)

                case .topCenter:
                    $0.centerX.equalTo(contentView)
                    $0.bottom.equalTo(contentView.snp.top)

                case .topRight:
                    $0.right.equalTo(contentView).offset(-kMargin(40))
                    $0.bottom.equalTo(contentView.snp.top)

                case .bottomLeft:
                    $0.left.equalTo(contentView).offset(kMargin(40))
                    $0.top.equalTo(contentView.snp.bottom)

                case .bottomCenter:
                    $0.centerX.equalTo(contentView)
                    $0.top.equalTo(contentView.snp.bottom)

                case .bottomRight:
                    $0.right.equalTo(contentView).offset(-kMargin(40))
                    $0.top.equalTo(contentView.snp.bottom)
            }
            
        })
        
        
        closeButton.snp.makeConstraints({
            $0.size.equalTo(CGSize(width: kMargin_16, height: kMargin_16))
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().offset(-kMargin_12)
        })
        
        l.snp.makeConstraints({
            $0.centerY.equalToSuperview()
            $0.right.equalTo(closeButton.snp.left).offset(-kMargin_8)
            $0.left.equalToSuperview().offset(kMargin_16)
        })
    }

}



class TriangleView: UIView {
    
    override func draw(_ rect: CGRect) {
        
        UIColor.blue.set()
        
        let b = UIBezierPath()
        b.lineWidth = 1
        b.lineJoinStyle = .round
        b.move(to: .zero)
        b.addLine(to: CGPoint(x: 6, y: kMargin_6))
        b.addLine(to: CGPoint(x: 12, y: 0))
        b.addLine(to: .zero)
        b.fill()

        
        b.stroke()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .clear
    }
}

