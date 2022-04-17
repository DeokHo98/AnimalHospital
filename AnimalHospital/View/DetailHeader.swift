//
//  Header.swift
//  AnimalHospital
//
//  Created by 정덕호 on 2022/04/16.
//

import UIKit

class DetailHeader: UITableViewHeaderFooterView {
    static let identifier = "detailHeader"
    
    
    
    //MARK: - 속성
    
    var viewModel: HeaderViewModel?
    
     let nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 22)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var callView: UIView = {
        let view = UIView().specialView(imageName: "phone", text: "전화걸기")
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapCall))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var editView: UIView = {
        let view = UIView().specialView(imageName: "square.and.pencil", text: "수정요청")
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapEdit))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var favoriteView: UIView = {
        let view = UIView().specialView(imageName: "star", text: "즐겨찾기")
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapFavorite))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var naviView: UIView = {
        let view = UIView().specialView(imageName: "arrow.right.square", text: "내비게이션")
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapNavi))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    
    private lazy var specialStack: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [callView,editView,favoriteView,naviView])
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 50
        return sv
    }()
    
    private let bottomView: UIView = {
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
    
    @objc func tapCall() {
        guard let viewModel = viewModel else {return}
        if let url = URL(string: "tel://" + "\(viewModel.phoneNumber)"), UIApplication.shared.canOpenURL(url) {
            print("전화걸기 시도합니다")
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc func tapEdit() {
        print("qweqweqwe")
    }
    
    @objc func tapFavorite() {
        print("mcx,vnc,nvmxcn,vn")
    }
    
    @objc func tapNavi() {
        print("한구버ㅏㅈ귑주기ㅏㅂ주깁지구ㅏ")
    }
    
    //MARK: - 도움메서드
    private func configure() {
        let view = UIView()
        view.backgroundColor = .white
        
        self.addSubview(view)
        view.anchor(top:self.topAnchor,leading: self.leadingAnchor,bottom: self.bottomAnchor,trailing: self.trailingAnchor)
        view.addSubview(nameLabel)
        nameLabel.anchor(top: self.topAnchor, leading: self.leadingAnchor, trailing: self.trailingAnchor)
        
        view.addSubview(specialStack)
        specialStack.anchor(top: nameLabel.bottomAnchor, paddingTop: 30)
        specialStack.centerX(inView: self)
        
        view.addSubview(bottomView)
        bottomView.anchor(top: specialStack.bottomAnchor,leading: self.leadingAnchor , trailing: self.trailingAnchor, paddingTop: 60)
    }
    
    
}

