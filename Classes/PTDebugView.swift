//
//  GXDebugView.swift
//  KidReading
//
//  Created by zoe on 2019/6/17.
//  Copyright © 2019 putao. All rights reserved.
//  输出web log日志

import Foundation
import GGXSwiftExtension
import SnapKit

public enum GXDebugViewButtonEvent {
    case ChangeUrl(GXDebugView)
    case ReloadWeb
    case pkgAction(Int) //离线包操作
    case otherAction(Int) //其他按钮操作
}

public typealias DebugButtonEvent = (_ event: GXDebugViewButtonEvent) -> Void

var web_log = ""

public class GXDebugView: UIView {
    
    private var debugTextView =  UITextView.init()
    
    private var clickButtonEvent :((GXDebugViewButtonEvent)->Void)? = nil
    
    public var reloadButtonEvent :DebugButtonEvent?
    
    public var headInfoLog: String?
//    public var defaultApiUrl: String = ""
//    public var baseWebUrl: String = ""
    
    public static func addLog(_ log : String) {
#if DEBUG
        let wStr = "\n-------\(Date.getCurrentDateStr("yyyy-MM-dd HH:mm:ss SSS"))日志-------\n" + log
        web_log = wStr + web_log
//        ZKWLog.Log(wStr)
#endif
    }
    public func supportIn(superView: UIView ,apiURL: String = "", debugEvent :@escaping (GXDebugViewButtonEvent)->Void) {
        superView.addSubview(self)
        self.clickButtonEvent = debugEvent
        self.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
//            maker.top.equalToSuperview()
//            maker.left.bottom.right.equalToSuperview()
        }
//        defaultApiUrl = apiURL
        self.setUI()
        self.isHidden = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(clickEvent))
        tap.numberOfTapsRequired = 6
        //        tap.numberOfTouchesRequired = 2
        superView.addGestureRecognizer(tap)
        
    }
    
    @objc func clickEvent( _ tap : UIGestureRecognizer) {
        guard let sup = self.superview else {
            return
        }
        let translation = tap.location(in:sup )
        let windowHeight = UIApplication.rootWindow?.height
        if translation.x < 200 && translation.y > (windowHeight ?? 600) - 200 {
            if self.isHidden {
                self.isHidden = false
                //                self.superview?.bringSubviewToFront(self)
//                let url = "Base URL : " + defaultApiUrl + "\n"
//                let weburl = "Web  URL : " + baseWebUrl  + "\n"
//                let appVersion = kAppVersion ?? ""
//                let appBuildVersion = UserDefaults.webVersion ?? ""
//                let build = "App Version : " + appVersion + "   web version : " + appBuildVersion  + "\n\n\n"
                if let info = self.headInfoLog {
                    self.debugTextView.text = info + web_log
                } else {
                    self.debugTextView.text = web_log
                }
            }
        }
    }
    
    var actionBtnTag = 0
    
    private func setUI() {
        self.backgroundColor = UIColor.white
        self.addSubview(debugTextView)
        debugTextView.backgroundColor = UIColor.white
        debugTextView.isEditable = false
        debugTextView.snp.makeConstraints { (maker) in
            if #available(iOS 11.0, *) {
                maker.left.equalTo(safeAreaLayoutGuide.snp.left)
            } else {
                maker.left.equalTo(10)
            }
            maker.bottom.equalTo(10)
            maker.top.equalTo(10)
            maker.right.equalTo(0)
        }
        
        self.addButton(title: "隐藏", right: 10, action: #selector(closeDebugView))
        self.addButton(title: "刷新", right: 10+90, action: #selector(reload))
        self.addButton(title: "切换地址", right: 10+90+90, action: #selector(changeUrl))
        self.addButton(title: "清除log", right: 10+90+90+90, action: #selector(clearLog))
        self.addButton(title: "打开bridge", right: 10+90+90+90+90, action: #selector(openBridgeCall))
        //        self.addButton(title: "清WebStore", right: 10+90, top: 60,action: #selector(clearWebCache))
        self.addButton(title: "启用离线包", right: 10+90+90, top: 60,action: #selector(didOfflineBtnCache(sender:)))
        self.addButton(title: "禁用离线包", right: 10+90+90+90, top:60,action: #selector(didOfflineBtnCache(sender:)))
        self.addButton(title: "清除离线包", right: 10+90+90+90+90, top: 60, action: #selector(didOfflineBtnCache(sender:)))
    }
    
    
    public func addButton(title:String, right:CGFloat,top: CGFloat = 10,action: Selector) {
        let button = UIButton.init()
        button.setTitle(title, for: UIControl.State.normal)
        button.addTarget(self, action: action, for: UIControl.Event.touchUpInside)
        button.setTitleColor(UIColor.gray, for: UIControl.State.normal)
        button.backgroundColor = UIColor.clear
        button.layer.masksToBounds = true
        button.layer.borderColor = UIColor.gray.cgColor
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 10
        button.tag = actionBtnTag
        actionBtnTag+=1
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.addSubview(button)
        button.snp.makeConstraints { (make) in
            //            make.left.equalTo(left)
            make.right.equalTo(-right)
            make.width.equalTo(80)
            make.top.equalTo(top)
            make.height.equalTo(40)
        }
    }
    
    @objc func closeDebugView (){
        self.isHidden = true
        self.debugTextView.text = ""
    }
    
    func openDebugView (){
        self.isHidden = false
        //        self.debugTextView.text = ZKWLog.read
    }
    
    @objc func reload (){
        
        self.isHidden = true
        self.debugTextView.text = ""
        
        if self.clickButtonEvent != nil {
            self.clickButtonEvent?(.ReloadWeb)
        }
    }
    
    @objc func changeUrl (){
        if self.clickButtonEvent != nil {
            self.clickButtonEvent!(GXDebugViewButtonEvent.ChangeUrl(self))
        }
    }
    
    @objc func openBridgeCall(_ sender: UIButton){
        //关闭调试
        closeDebugView()
        self.clickButtonEvent?(.otherAction(sender.tag))
    }
    
    @objc func clearWebCache() {
//        ZKUtils.removeWebsiteDataStore()
    }
    
    @objc func openAppTestVc(){
        //        let jsTestVc = RSTestViewController()
        //        homepageVc.navigationController?.pushViewController(jsTestVc, animated: true)
    }
    
    @objc func clearLog (){
        web_log = ""
        self.debugTextView.text = ""
        //        ZKWLog.clear()
    }
    
    @objc func didOfflineBtnCache(sender: UIButton) {
        self.clickButtonEvent?(.pkgAction(sender.tag))
        //        RSWebOfflineManager.sha
        //            URLProtocol.unregisterClass(PTURLProtocol.self)
        //            URLProtocol.wk_unregisterScheme("http")
        //            URLProtocol.wk_unregisterScheme("https")
        //            HUD.flash("禁用成功")
    }
}
