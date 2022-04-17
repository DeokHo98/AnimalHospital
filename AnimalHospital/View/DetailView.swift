//
//  DetailView.swift
//  AnimalHospital
//
//  Created by 정덕호 on 2022/04/16.
//

import UIKit

//스크롤을 아래로 내린뒤의 시점을 델리게이트패턴으로 전송
protocol DetailViewDelegate: AnyObject {
    func scrollDown()
}


class DetailView: UIView {
    
    
    //MARK: - 디테일 속성
    
    weak var delegate: DetailViewDelegate?
    
    var viewModel: DetailViewModel? {
        willSet {
            tableView.reloadData()
        }
    }
    
    //이미지 뷰
    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .systemGray5
        iv.contentMode = .scaleAspectFill
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapImage))
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(tap)
        let button = UIButton()
        button.setImage(UIImage(systemName: "camera"), for: .normal)
        button.setTitle(" 사진 제공하기", for: .normal)
        button.backgroundColor = .clear
        button.tintColor = .systemBlue
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18)
        button.addTarget(self, action: #selector(tapImage), for: .touchUpInside)
        iv.addSubview(button)
        button.centerY(inView: iv)
        button.centerX(inView: iv)
        return iv
    }()
    
    //상단에 보여지는 작은 뷰
    private let topView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.setHeight(5)
        view.setWidth(40)
        view.layer.cornerRadius = 5  / 2
        return view
    }()
    
    
    
    //테이블뷰
    private var tableView: UITableView = UITableView(frame: .zero, style: .grouped)
    
    
    
    //MARK: - 라이프사이클
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init")
    }
    
    
    //MARK: - 셀렉터메서드
    
    //이미지를 터치했을때 호출되는 메서드
    @objc private func tapImage() {
        print(1231231231)
    }
    
    
    //MARK: - 뷰 도움메서드
    private func configure() {
        self.backgroundColor = .white
        self.addShadow()
        self.addSubview(topView)
        topView.centerX(inView: self)
        topView.anchor(top: self.topAnchor, paddingTop: 10)
        
        
        self.addSubview(tableView)
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DetailHeader.self, forHeaderFooterViewReuseIdentifier: DetailHeader.identifier)
        tableView.register(DetailFooter.self, forHeaderFooterViewReuseIdentifier: DetailFooter.identifier)
        tableView.register(DetailCell.self, forCellReuseIdentifier: DetailCell.identifier)
        tableView.backgroundColor = .white
        tableView.allowsSelection = false
        tableView.showsVerticalScrollIndicator = false
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.rowHeight = 70
        tableView.anchor(top: topView.bottomAnchor, leading: self.leadingAnchor, bottom: self.bottomAnchor,trailing: self.trailingAnchor, paddingTop: 20)
        
    }
    
    
    
    //MARK: - 도움메서드
    func showUp() {
        self.addSubview(imageView)
        imageView.anchor(top: self.safeAreaLayoutGuide.topAnchor, leading: self.leadingAnchor, trailing: self.trailingAnchor, height: (self.frame.height) / 4)
        
        topView.removeFromSuperview()
        
        tableView.anchor(top: imageView.bottomAnchor, leading: self.leadingAnchor, trailing: self.trailingAnchor,paddingTop: 20)
        tableView.isScrollEnabled = true
    }
    
    func showDown() {
        imageView.removeFromSuperview()
        
        self.addSubview(topView)
        topView.centerX(inView: self)
        topView.anchor(top: self.safeAreaLayoutGuide.topAnchor, paddingTop: 10)
        
        tableView.anchor(top: topView.bottomAnchor, leading: self.leadingAnchor, trailing: self.trailingAnchor,paddingTop: 20)
        tableView.contentOffset = CGPoint(x: 0, y: 0 - (tableView.contentInset.top))
        tableView.isScrollEnabled = false
        
    }
}
extension DetailView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DetailCell.identifier, for: indexPath) as! DetailCell
        switch indexPath.row {
        case 0:
            cell.cellImage.image = UIImage(systemName: "timer")
            cell.cellLabel.text = viewModel?.runtime
            return cell
        case 1:
            cell.cellImage.image = UIImage(systemName: "dollarsign.circle")
            cell.cellLabel.text = viewModel?.tax
            return cell
        case 2:
            cell.cellImage.image = UIImage(systemName: "map")
            cell.cellLabel.text = viewModel?.address
            return cell
        case 3:
            cell.cellImage.image = UIImage(systemName: "phone")
            cell.cellLabel.text = viewModel?.phoneNumber
            return cell
        default:
            return cell
        }
    }
    
    
}

//MARK: - 테이블뷰 델리게이트

extension DetailView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: DetailHeader.identifier) as! DetailHeader
        guard let viewModel = viewModel else {return header}
        header.nameLabel.text = viewModel.name
        header.viewModel = HeaderViewModel(model: viewModel.model)
        return header
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: DetailFooter.identifier) as! DetailFooter
        return footer
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 170
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 145
    }
}


//MARK: - 스크롤뷰 델리게이트
extension DetailView: UIScrollViewDelegate {
    //테이블뷰의 contentoffset.y 가 0보다 작은경우라면 뷰를 내린다
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (tableView.contentOffset.y) < 0 {
            delegate?.scrollDown()
        }
    }
}
