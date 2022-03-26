//
//  TGIndexView.swift
//  SwiftApp
//
//  Created by 杨佩 on 2022/3/4.
//

import UIKit

protocol TGIndexViewDelegate: AnyObject {
    func viewToShowOverlayIn() -> UIView?
    func selectedItem(_ item: TableIndexItem)
    func beganSelection()
    func endedSelection()
}

public class TGIndexView: UIView {

    //label 相关
    let label = UILabel()
    var font = UIFont.systemFont(ofSize: 12, weight: .semibold) {
        didSet {
            setLabel()
        }
    }
    
    //距离相关
    let lineSpace: CGFloat = 1
    let itemHeight: CGFloat
    private let sidePadding: CGFloat = 2.0
    let verticalPadding: CGFloat = 7.0
    private let overlaySize = CGSize(width: 110, height: 110);
    
    //模型相关
    private var items: [TableIndexItem] = []
    private var itemsShown: [TableIndexItem] = []
    private var mostRecentSelection: TableIndexItem?
    
    //响应相关
    private lazy var longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
    private var generator = UISelectionFeedbackGenerator()//点击态
    private var impactGenerator = UIImpactFeedbackGenerator(style: .rigid)//转换态
    var tgDelegate: TGIndexViewDelegate?
    lazy var overlayView = TableIndexViewOverlay()
    
    //响应显示相关
    
    
    init() {
        //初始化 Label
        itemHeight = font.lineHeight + lineSpace
        super.init(frame: .zero)
        label.numberOfLines = 0;
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.isUserInteractionEnabled = true
        addSubview(label)
        
        //设置手势
        longPressGesture.minimumPressDuration = 0.3
        label.addGestureRecognizer(longPressGesture)
        //
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func longPress(_ ges: UILongPressGestureRecognizer) {
        //处理点击状态
        let statas = ges.state
        let percentage = (ges.location(in: label).y - lineSpace) / (label.frame.self.height - 2 * verticalPadding)
        let itemIndex = max(0, min(items.count - 1, Int((CGFloat(items.count) * percentage))))
        let selectedItem = items[itemIndex]
        
        if statas == .began {
            //触发响应
            impactGenerator.impactOccurred()
            tgDelegate?.beganSelection()
            label.backgroundColor = UIColor.init(white: 0.85, alpha: 1.0)
            
            if let v = tgDelegate?.viewToShowOverlayIn() {
                v.addSubview(overlayView)
                positionAndSizeOverlayView()
            }
        }
        
        showSelectedItem(selectedItem)
        tgDelegate?.selectedItem(selectedItem)
        if statas == .changed {
            if mostRecentSelection != selectedItem {
                generator.selectionChanged()
            }
            
            mostRecentSelection = selectedItem
        }
        
        if [.ended, .cancelled, .failed].contains(statas) {
            label.backgroundColor = .clear
            tgDelegate?.endedSelection()
            overlayView.removeFromSuperview()
        }
        
    }
    
    
    func setLabel() {
        let totalCanFits = Int(bounds.height / itemHeight)
        if totalCanFits >= items.count {
            showAllItemInLabel()
        } else {
            showIncompleteItemInLabel(totalCanFits)
        }
        
        let labelHeight = label.sizeThatFits(.zero).height + verticalPadding * 2
        label.frame = CGRect(x: 0, y: (bounds.height - labelHeight) / 2.0, width: bounds.width, height: labelHeight)
        addSubview(label)
    }
    
    private func showAllItemInLabel() {
        itemsShown = items
        showItemsInLabel(itemsShown)
    }
    
    
    
    private func showIncompleteItemInLabel(_ count: Int) {
        let isOddNumber = count % 2 == 1
        var totalShow = isOddNumber ? count : count - 1
        
        totalShow -= 2
        
        let totalUserItemsToShow = totalShow / 2
        let showEveryNthCharacter = CGFloat(items.count - 2) / CGFloat(totalUserItemsToShow)
        
        var userItemsToShow: [TableIndexItem] = []
        for i in stride(from: CGFloat(1), to: CGFloat(items.count - 1), by: showEveryNthCharacter) {
            userItemsToShow.append(items[Int(i.rounded())])
            
            if userItemsToShow.count == totalUserItemsToShow {break}
        }
        
        var itemsToShow: [TableIndexItem] = [items.first!]
        
        userItemsToShow.forEach({
            itemsToShow.append(.letter("•"))
            itemsToShow.append($0)
        })
        
        itemsToShow.append(.letter("•"))
        itemsToShow.append(items.last!)
        
        self.itemsShown = itemsToShow
        showItemsInLabel(itemsToShow)
    }
    
    private func showItemsInLabel(_ items: [TableIndexItem]) {
        
        let attrM = NSMutableAttributedString()
        items.forEach({
            switch $0 {
            case .letter(let aChar)://拼接字符
                //字符间距
                let p = NSMutableParagraphStyle()
                p.alignment = .center
                p.lineSpacing = self.lineSpace
                
                attrM.append(NSAttributedString(string: "\(aChar)\n", attributes: [.font : self.font, .paragraphStyle : p]))
                
            case .symbol(let s, isCustom: let isCustom):
                let p = NSMutableParagraphStyle()
                p.alignment = .center
                p.lineSpacing = self.lineSpace + 2
                
                let symbolAttri = NSMutableAttributedString()
                let aAttatchment = NSTextAttachment()
                let font = UIFont(descriptor: self.font.fontDescriptor, size: self.font.pointSize - 1)
                let config = UIImage.SymbolConfiguration(font: font)
                let img: UIImage = {
                    if isCustom {
                        return UIImage(named: s, in: nil, with: config)!

                    } else {
                        return UIImage(systemName: s, withConfiguration: config)!
                    }
                }()
                aAttatchment.image = img
                
                symbolAttri.append(NSMutableAttributedString(attachment: aAttatchment))
                symbolAttri.append(NSMutableAttributedString(string: "\n", attributes: nil))
                symbolAttri.addAttributes([.paragraphStyle : p], range: NSRange(location: 0, length: symbolAttri.length))
                
                attrM.append(symbolAttri)
            }
        })//end forEach
        
        attrM.mutableString.deleteCharacters(in: NSRange(location: attrM.length - 1, length: 1))
        let fullRange = NSRange(location: 0, length: attrM.length)
        attrM.addAttributes([.font : font], range: fullRange)
        label.attributedText = attrM
    }
    
    func update(with items: [TableIndexItem]) {
        self.items = items
        setLabel()
    }
    

    private func showSelectedItem(_ selectedItem: TableIndexItem) {
        overlayView.updateSelectionTo(selectedItem)
    }
    
    func positionAndSizeOverlayView() {
        guard let viewToOverlayIn = tgDelegate?.viewToShowOverlayIn(),
              let overSuperView = viewToOverlayIn.superview else {
            fatalError("Both should be available at this point")
        }
        overlayView.frame.size = overlaySize
        overlayView.frame.origin = CGPoint(x: (overSuperView.bounds.width - overlaySize.width) / 2.0, y: (overSuperView.bounds.height - overlaySize.height) / 2.0)
        overlayView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
    }
    
    
    
    static var alphanumericItems: [TableIndexItem] {
        return ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "#"].map({.letter($0)})
    }
}


class TableIndexViewOverlay: UIVisualEffectView {
    let label = UILabel()
    let imageView = UIImageView()
    
    let labelFontSize: CGFloat = 55
    let imageFontSize: CGFloat = 44
    
    init() {
        super.init(effect: UIBlurEffect(style: .systemMaterial))
        layer.masksToBounds = true
        layer.cornerRadius = 20.0
        layer.cornerCurve = .continuous
        
        let baseFont = UIFont.systemFont(ofSize: labelFontSize, weight: .medium)
        let roundFont = UIFont(descriptor: baseFont.fontDescriptor.withDesign(.rounded)!, size: baseFont.pointSize)
        
        let overlayTextColor = UIColor(white: 0.3, alpha: 1.0)
        label.font = roundFont
        label.textAlignment = .center
        label.textColor = overlayTextColor
        label.isHidden = true
        contentView.addSubview(label)
        
        imageView.contentMode = .center
        imageView.tintColor = overlayTextColor
        imageView.isHidden = true
        contentView.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
        imageView.frame = bounds
    }
    
    func updateSelectionTo(_ newSelection: TableIndexItem) {
        switch newSelection {
        case let .letter(letter):
            label.text = "\(letter)"
            label.isHidden = false
            imageView.isHidden = true
            
        case let .symbol(name, isCustom: isCustom):
            imageView.image = {
                let font = UIFont.systemFont(ofSize: imageFontSize, weight: .semibold)
                let config = UIImage.SymbolConfiguration(font: font)
                if isCustom {
                    return UIImage(named: name, in: nil, with: config)
                } else {
                    return UIImage(systemName: name, withConfiguration: config)
                }
            }()
            
            label.isHidden = true
            imageView.isHidden = false
        }
    }
    
   
}


enum TableIndexItem: Equatable {
    case letter(_ : Character)
    case symbol(_ : String, isCustom: Bool)
}


