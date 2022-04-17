//
//  SearchViewController.swift
//  AnimalHospital
//
//  Created by 정덕호 on 2022/04/17.
//

import UIKit
import NMapsMap

protocol SearchViewDelegate: AnyObject {
    func locationData(lating: NMGLatLng)
}


class SearchViewController: UIViewController {
    
    //MARK: - 속성
    
    
    
    var delegate: SearchViewDelegate?
    
    //서치 뷰모델
    var searchViewModel: SearchViewModel?
    
    //키보드가 보이는지 안보이는지에 대한 bool값
    private var keyboard = true
    
    //검색할때 호출되는 인디게이터뷰
    private let activity = UIActivityIndicatorView()
    
    
    //탑뷰
    private let topView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        return view
    }()


    //서치 텍스트필드
    private let textfield: UITextField = {
        let tf = UITextField()
        tf.returnKeyType = .search
        tf.borderStyle = .none
        tf.tintColor = .white
        tf.textColor = .white
        tf.keyboardAppearance = .light
        tf.keyboardType = .default
        tf.backgroundColor = .systemBlue
        tf.setHeight(50)
        tf.font = .boldSystemFont(ofSize: 18)
    
        return tf
    }()

    //백 버튼
    private let searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.setImage(UIImage(systemName: "arrow.backward"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(backButtonTap), for: .touchUpInside)
        return button
    }()
    
    //테이블뷰
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .white
        tv.separatorStyle = .none
        return tv
    }()
    
    
    
    
    //MARK: - 라이프사이클

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    
    //MARK: - 도움메서드
    
    private func configure() {
        view.addSubview(topView)
        topView.anchor(top: view.topAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, height: 100)

        view.addSubview(searchButton)
        searchButton.setDimensions(height: 30, width: 30)
        searchButton.anchor(leading: view.leadingAnchor, bottom: topView.bottomAnchor,paddingLeading: 20,paddingBottom: 15)

        view.addSubview(textfield)
        textfield.delegate = self
        textfield.centerY(inView: searchButton)
        textfield.anchor(leading: searchButton.trailingAnchor, trailing: view.trailingAnchor, paddingLeading: 20, paddingTrailing: 20)
        
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SearchCell.self, forCellReuseIdentifier: SearchCell.identifier)

        
        view.addSubview(tableView)
        tableView.anchor(top: topView.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor ,trailing: view.trailingAnchor)
        
        
        textfield.becomeFirstResponder()
    }
    
    private func searhViewModelClosure() {
        searchViewModel?.loddingStart = { [weak self] in
            self?.activityON()
        }

        searchViewModel?.lodingEnd = { [weak self] in
            self?.activityOFF()
        }

        searchViewModel?.alert = { [weak self] in
            self?.errorAlter()
        }
    }
    
    
    //액티비티 뷰 메서드
   private func activityON() {
        view.addSubview(activity)
        activity.tintColor = .gray
        activity.centerX(inView: view)
        activity.centerY(inView: view)
        activity.startAnimating()
    }

    private func activityOFF() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
            self?.activity.stopAnimating()
            self?.activity.removeFromSuperview()
        }
    }
    
    //에러 얼럿 메서드
    private func errorAlter() {
        activityOFF()
        let alert = UIAlertController(title: "에러가 발생했습니다", message: "인터넷 연결을 확인하고 다시 시도해보십시오", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "확인", style: .default, handler: nil)

        alert.addAction(okButton)
        present(alert, animated: true, completion: nil)
    }

    

    
    //MARK: - 셀렉터 메서드
    //백 버튼을 눌렀을때
    @objc private func backButtonTap() {
        navigationController?.popViewController(animated: true)
    }
}

//MARK: - 텍스트필드 델리게이트
extension SearchViewController: UITextFieldDelegate {
    //텍스트필드가 켜지기 직전
    func textFieldDidBeginEditing(_ textField: UITextField) {
        searchViewModel = SearchViewModel()
        searhViewModelClosure()
        keyboard = true
        searchButton.setImage(UIImage(systemName: "arrow.backward"), for: .normal)
        textfield.attributedPlaceholder = nil
    }

    //텍스트필드에서 서치버튼을 눌렀을때
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textfield.text else {return true}
        searchViewModel?.fetch(searhText: text)
        textfield.resignFirstResponder()
       return true
    }

}

//MARK: - 테이블뷰 데이터소스
extension SearchViewController: UITableViewDataSource {
    //테이블뷰의 셀의 갯수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchViewModel?.count() ?? 0
    }

    //테이블뷰의 셀
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchCell.identifier, for: indexPath) as! SearchCell
        
        cell.namelabel.text = searchViewModel?.name(index: indexPath.row)
        cell.adressLabel.text = searchViewModel?.address(index: indexPath.row)
        return cell
    }

    //셀의 높이
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90

    }


}


//MARK: - 테이블뷰 델리게이트
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let lating = searchViewModel?.lating(index: indexPath.row) else {return}
        delegate?.locationData(lating: lating)
        navigationController?.popViewController(animated: true)
    
      
    }
}

//MARK: - 스크롤 델리게이트
extension SearchViewController: UIScrollViewDelegate {
    //키보드가 보일때 keboard = true로 키보드를 내려야할때는 false 로 해서
    //스크롤할때 keyboard를 내리는 메서드
    //대신 키보드를 한번더 내린후에는 다시 false로 설정해줘서 중복으로 계속호출되는걸 방지
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if keyboard {
            view.endEditing(true)
            keyboard = false
        }
    }
}
