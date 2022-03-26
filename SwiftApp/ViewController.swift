//
//  ViewController.swift
//  SwiftApp
//
//  Created by 杨佩 on 2022/3/3.
//

import UIKit
import SnapKit


class ViewController: UIViewController {
    func closeButtonDidClick() {
        print("哈麻批")
    }
    
    var l:TGBadgeLabel?
    var s:TGSwitch?

    var bArray: [TGBadgeLabel]?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let l = UILabel(frame: CGRect(x: 20, y: 40, width: 200, height: 80))
        l.text = "\u{e6a0}"
        l.font = .init(name: "iconfont", size: 16)
        l.textColor = .black
        view.addSubview(l)
       
        let s0 = TGSwitch.config(status: .closeDefault) { [weak self] isOn in
            guard let `self` = self else { return }
            let p = isOn ? "打开" : "关闭"

            self.switchStateChange(isOn: isOn)
            print("\(p)")
        }
        
        let s1 = TGSwitch.config(status: .openDefault) { isOn in
            let p = isOn ? "打开" : "关闭"
            print("\(p)")
            
            self.switchStateChange1(isOn: isOn)

        }
        
        let s2 = TGSwitch.config(status: .closeForbidden) { isOn in
            let p = isOn ? "打开" : "关闭"
            print("\(p)")
        }
        
        let s3 = TGSwitch.config(status: .openForbidden) { isOn in
            let p = isOn ? "打开" : "关闭"
            print("\(p)")
        }
        
        
        self.s = s0

        var s: TGSwitch?
        [s0, s1, s2, s3].enumerated().forEach { idx, temp in
            
            view.addSubview(temp)
            temp.snp.makeConstraints({
                $0.centerX.equalToSuperview()
                if let s = s {
                    $0.top.equalTo(s.snp.bottom).offset(100)
                } else {
                    $0.top.equalToSuperview().offset(100)
                }
            })
            s = temp
        }
        
        
        let b0 = TGBadgeLabel.badge(with: .dot)
        let b1 = TGBadgeLabel.badge(with: .new)
        let b2 = TGBadgeLabel.badge(with: .number)
        let b3 = TGBadgeLabel.badge(with: .number)
        let b4 = TGBadgeLabel.badge(with: .number)
        bArray = [b0, b1, b2, b3, b4]

        bArray?.enumerated().forEach({ idx, b in
            view.addSubview(b)
            b.snp.makeConstraints({
                
                if idx == 0 || idx == 2 {
                    $0.centerX.equalTo(s2)
                }
                
                if idx == 1 || idx == 3 {
                    $0.centerY.equalTo(s2)
                }
                
                if idx == 0 {
                    $0.bottom.equalTo(s2.snp.top)
                } else if idx == 1 {
                    $0.right.equalTo(s2.snp.left)
                } else if idx == 2 {
                    $0.top.equalTo(s2.snp.bottom)
                } else if idx == 3 {
                    $0.left.equalTo(s2.snp.right)
                }
                
                if idx == 4 {
                    $0.center.equalTo(s2)
                }
                
                $0.size.equalTo(b.frame.size)
            })
        })
        
        
        bArray![2].update(num: 3)
        bArray![3].update(num: 76)
        bArray![4].update(num: 9991)
        bArray?.enumerated().forEach({ idx, b in
            b.snp.updateConstraints({
                $0.size.equalTo(b.frame.size)
            })
        })
        
        
    }
    func switchStateChange1(isOn: Bool) {
    
        if isOn {
            view.showMessage("奥斯特洛夫斯基.弗拉基米尔")
        } else {
            view.showNotice("奥斯特洛夫斯基", detail: "弗拉基米尔")
        }
    
    }
    
    
    
    func switchStateChange(isOn: Bool) {
        let idx = Int(arc4random() % 8)
        let array:[angleDirection] = [.left, .topLeft, .bottomLeft, .topCenter, .bottomLeft, .bottomRight, .bottomCenter,. right];
        let d = array[idx]
        let tip = TGGuideTipsView.config(with: "奥斯特洛夫斯基", direction: d) {
            print("引导 view 关闭")
        }
        
        view.addSubview(tip)
        let size = tip.frame.size
        tip.snp.makeConstraints({
            
            if d == .topCenter || d == .bottomCenter {//中 上下
                $0.centerX.equalTo(s!)
                if d == .topCenter {
                    $0.centerX.equalTo(s!)
                } else {
                    $0.centerX.equalTo(s!)
                }
            }
            
            if d == .bottomLeft || d == .bottomCenter || d == .bottomRight {//底部 左右
                $0.bottom.equalTo(s!.snp.top)
                
                if d == .bottomLeft {
                    $0.left.equalTo(s!)
                } else if d == .bottomRight {
                    $0.right.equalTo(s!)
                }
            }
            
            if d == .topLeft || d == .topCenter || d == .topRight {//顶部 左右
                $0.top.equalTo(s!.snp.bottom)
                if d == .topLeft {
                    $0.left.equalTo(s!)
                } else if d == .topRight {
                    $0.right.equalTo(s!)
                }
            }
            
            if d == .left || d == .right {//左右
                $0.centerY.equalTo(s!)
                
                if d == .left {
                    $0.left.equalTo(s!.snp.right)
                } else if d == .right {
                    $0.right.equalTo(s!.snp.left)
                }
                
            }
            
            $0.size.equalTo(size)
        })
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        view.showNotice("这是一起", detail: "外乡人这是一起的外乡人这是一起的外乡人")
//        view.showMessage("这是一起的外乡人这是一起的外乡人这是一起的外乡人这是一起的外乡人")
        
        
    }

}

