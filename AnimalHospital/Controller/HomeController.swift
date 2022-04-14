//
//  HomeController.swift
//  AnimalHospital
//
//  Created by 정덕호 on 2022/04/14.
//

import UIKit
import CoreLocation
import NMapsMap

enum SearchButtonType {
    case search
    case back
}

class HomeController: UIViewController {



    //MARK: - 속성

    //뷰모델
    var viewModel = SearchViewModel()

    //네이버맵
   private let naverMapView = NMFMapView()

    //네이버맵 마커
    private let marker = NMFMarker()


    //키보드가 보이는지 안보이는지에 대한 메서드
    private var keyboard = true


    //버튼타입 열거형
    private var buttonType = SearchButtonType.search

    //위치 매니저
    var locationManger = CLLocationManager()

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
        tf.attributedPlaceholder = NSAttributedString(string: "지명으로 검색하기..", attributes: [.foregroundColor : UIColor(white: 1, alpha: 0.5), .font : UIFont.boldSystemFont(ofSize: 18)])

        return tf
    }()

    //돋보기 버튼
    private let searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.setImage(UIImage(systemName: "magnifyingglass"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(searchButtonTap), for: .touchUpInside)
        return button
    }()

    //즐겨찾기버튼
    private let favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.clipsToBounds = true
        button.setImage(UIImage(systemName: "list.dash"), for: .normal)
        button.tintColor = .systemBlue
        button.setTitle(" 즐겨찾기", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        return button
    }()


    //내 위치 버튼
    private let locationButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.clipsToBounds = true
        button.setImage(UIImage(systemName: "location"), for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(locationButtonTap), for: .touchUpInside)
        return button
    }()

    //테이블뷰
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .white
        tv.separatorStyle = .none
        return tv
    }()


    //검색할때 호출되는 인디게이터뷰
    private let activity = UIActivityIndicatorView()


    //카메라 줌 인아웃 버튼
    private let zoominButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.clipsToBounds = true
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .systemBlue
        button.addShadow()
        button.setHeight(50)
        button.setWidth(50)
        button.layer.cornerRadius = 50 / 2
        button.addTarget(self, action: #selector(zoomIn), for: .touchUpInside)
        return button
    }()

    private let zommOutbutton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.clipsToBounds = true
        button.setImage(UIImage(systemName: "minus"), for: .normal)
        button.tintColor = .systemBlue
        button.addShadow()
        button.setHeight(50)
        button.setWidth(50)
        button.layer.cornerRadius = 50 / 2
        button.addTarget(self, action: #selector(zoomOut), for: .touchUpInside)
        return button
    }()


    private lazy var buttonStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [zoominButton, zommOutbutton])
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }()


    //MARK: - 라이프사이클
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        UIconfigure()
        mapConfigure()
        tableViewConfiure()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        locationMangerConfirm()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.isHidden = true
    }


    //MARK: - 셀렉터메서드
    //location버튼을 클릭하면 권한상태에 따라 현재 위치로 이동하는 메서드
    @objc func locationButtonTap() {
        switch locationManger.authorizationStatus {
        case .denied:
            diniedAlert()
        case .authorizedAlways:
            marker.mapView = nil
            naverMapView.positionMode = .direction
            cameraZoom()
        case .authorizedWhenInUse:
            marker.mapView = nil
            naverMapView.positionMode = .direction
            cameraZoom()
        case .notDetermined:
            break
        case .restricted:
            diniedAlert()
        @unknown default:
            break
        }
    }


    //돋보기 버튼을 눌렀을때
    @objc func searchButtonTap() {
        switch buttonType {
        case .search:
            textfield.becomeFirstResponder()
        case .back:
            viewModel.models = []
            tableView.reloadData()
            tableView.removeFromSuperview()
            keyboard = false
            buttonType = .search
            searchButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
            view.endEditing(true)
            textfield.text = ""
            textfield.attributedPlaceholder = NSAttributedString(string: "지명으로 검색하기..", attributes: [.foregroundColor : UIColor(white: 1, alpha: 0.5), .font : UIFont.boldSystemFont(ofSize: 18)])
        }
    }

    @objc func zoomIn() {
        let current = naverMapView.zoomLevel
        let camZoom = NMFCameraUpdate(zoomTo: current + 1)
        naverMapView.moveCamera(camZoom)
    }

    @objc func zoomOut() {
        let current = naverMapView.zoomLevel
        let camZoom = NMFCameraUpdate(zoomTo: current - 1)
        naverMapView.moveCamera(camZoom)
    }

    //MARK: - 도움메서드

    //UI구성 메서드
    func UIconfigure() {
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = true


        view.addSubview(naverMapView)
        naverMapView.frame = view.frame

        view.addSubview(topView)
        topView.anchor(top: view.topAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, height: 100)

        view.addSubview(searchButton)
        searchButton.setDimensions(height: 30, width: 30)
        searchButton.anchor(leading: view.leadingAnchor, bottom: topView.bottomAnchor,paddingLeading: 20,paddingBottom: 15)

        view.addSubview(textfield)
        textfield.delegate = self
        textfield.centerY(inView: searchButton)
        textfield.anchor(leading: searchButton.trailingAnchor, trailing: view.trailingAnchor, paddingLeading: 20, paddingTrailing: 20)

        view.addSubview(favoriteButton)
        favoriteButton.addShadow()
        favoriteButton.centerX(inView: view)
        favoriteButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 20,width: 120,height: 40)
        favoriteButton.layer.cornerRadius = 40 / 2

        view.addSubview(locationButton)
        locationButton.addShadow()
        locationButton.anchor(top: topView.bottomAnchor, leading: view.leadingAnchor, paddingTop: 30, paddingLeading: 20,width: 50,height: 50)
        locationButton.layer.cornerRadius = 50 / 2

        view.addSubview(buttonStack)
        buttonStack.centerY(inView: view)
        buttonStack.anchor(trailing: view.trailingAnchor, paddingTrailing: 20)

        viewModel.loddingStart = { [weak self] in
            self?.activityON()
        }

        viewModel.lodingEnd = { [weak self] in
            self?.activityOFF()
        }

        viewModel.alert = { [weak self] in
            self?.errorAlter()
        }

    }

    //테이블뷰 구성 메서드
    func tableViewConfiure() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SearchCell.self, forCellReuseIdentifier: SearchCell.identifier)

    }

    //테이블뷰 보여주는 메서드
    func tableViewShow() {
        view.addSubview(tableView)
        tableView.anchor(top: topView.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor ,trailing: view.trailingAnchor)
    }


    // 로케이션 매니저 구성 메서드
    func mapConfigure() {
        locationManger.delegate = self
        locationManger.requestWhenInUseAuthorization()

    }

    //현재 권항 상태를 확인하는 메서드
    func locationMangerConfirm() {
        switch locationManger.authorizationStatus {
        case .denied:
            break
        case .authorizedAlways:
            cameraZoom()
            naverMapView.positionMode = .direction
        case .authorizedWhenInUse:
            cameraZoom()
            naverMapView.positionMode = .direction
        case .notDetermined:
            break
        case .restricted:
            break
        @unknown default:
            break
        }
    }

    //현재 위치 권한이 없는 상태일때 얼럿을 띄어 위치권한 설정화면으로 넘어가는 얼럿 메서드
    func diniedAlert() {
        let alert = UIAlertController(title: "위치권한 설정을 다시 설정해주세요", message: "설정 > 24시 동물병원 에서 위치서비스를 허용하시면 현재위치 기준의 정보를 보실수 있습니다", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "네", style: .default) { action in
            UIApplication.shared.open(NSURL(string:UIApplication.openSettingsURLString)! as URL)
        }

        let noAction = UIAlertAction(title: "아니요", style: .default, handler: nil)

        alert.addAction(okAction)
        alert.addAction(noAction)
        present(alert, animated: true, completion: nil)
    }


    //액티비티 뷰 메서드
    func activityON() {
        view.addSubview(activity)
        activity.tintColor = .gray
        activity.centerX(inView: view)
        activity.centerY(inView: view)
        activity.startAnimating()
    }

    func activityOFF() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.activity.stopAnimating()
            self.activity.removeFromSuperview()
        }
    }

    //에러 얼럿 메서드

    func errorAlter() {
        let alert = UIAlertController(title: "에러가 발생했습니다", message: "네트워크를 확인하고 다시 시도해보십시오", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "확인", style: .default, handler: nil)

        alert.addAction(okButton)
        present(alert, animated: true, completion: nil)
    }

    //카메라 줌 메서드
    func cameraZoom() {
        let camZoom = NMFCameraUpdate(zoomTo: 14)
        naverMapView.moveCamera(camZoom)
    }
}

//MARK: - CLLocation 델리게이트
extension HomeController: CLLocationManagerDelegate {
    //권한상태가 바뀐경우 실행되는 델리게이트 메서드
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationMangerConfirm()
    }

}

//MARK: - 텍스트필드 델리게이트
extension HomeController: UITextFieldDelegate {
    //텍스트필드가 켜지기 직전
    func textFieldDidBeginEditing(_ textField: UITextField) {
        tableViewShow()
        keyboard = true
        buttonType = .back
        searchButton.setImage(UIImage(systemName: "arrow.backward"), for: .normal)
        textfield.attributedPlaceholder = nil
    }

    //텍스트필드에서 서치버튼을 눌렀을때
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textfield.text else {return true}
        viewModel.fetch(searhText: text)
       return true
    }

}


//MARK: - 테이블뷰 데이터소스
extension HomeController: UITableViewDataSource {
    //테이블뷰의 셀의 갯수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.count()
    }

    //테이블뷰의 셀
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchCell.identifier, for: indexPath) as! SearchCell
        cell.namelabel.text = viewModel.name(index: indexPath.row)
        cell.adressLabel.text = viewModel.address(index: indexPath.row)
        return cell
    }

    //셀의 높이
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90

    }


}


//MARK: - 테이블뷰 델리게이트
extension HomeController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        marker.mapView = nil
        marker.position = viewModel.lating(index: indexPath.row)
        marker.iconImage = NMF_MARKER_IMAGE_BLACK
        marker.iconTintColor = .systemBlue
        marker.mapView = naverMapView
        let camUpdate = NMFCameraUpdate(scrollTo: viewModel.lating(index: indexPath.row))
        naverMapView.moveCamera(camUpdate)
        cameraZoom()
        searchButtonTap()
    }
}

//MARK: - 스크롤 델리게이트
extension HomeController: UIScrollViewDelegate {
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

