//
//  DetailFooter.swift
//  AnimalHospital
//
//  Created by 정덕호 on 2022/04/16.
//

import UIKit

class DetailFooter: UITableViewHeaderFooterView {
    static let identifier = "DetailFooter"
    
    //정보 안내 레이블 입니다.
    private let detailText: UILabel = {
        let label = UILabel()
        label.text = "안내하는 병원 정보는 최신 병원 정보와 다를수 있습니다. 방문 전에 꼭 한번 전화를 해보시고 방문을 하시길 바랍니다"
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let topView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.setHeight(8)
        return view
    }()
    
    
    
    //MARK: - 라이프사이클
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configure()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    
    //MARK: - 셀렉터메서드
    

    
    //MARK: - 도움메서드
    private func configure() {
        addSubview(detailText)
        
        addSubview(topView)
        topView.anchor(top: self.topAnchor,leading: self.leadingAnchor , trailing: self.trailingAnchor, paddingTop: 10)
        
        addSubview(detailText)
        detailText.anchor(top: topView.bottomAnchor, leading: self.leadingAnchor, trailing: self.trailingAnchor, paddingTop: 20,paddingLeading: 20,paddingTrailing: 20)
        
    }
    
    
}
