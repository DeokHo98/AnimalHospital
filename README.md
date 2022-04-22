# 24시 동물병원 앱

## 배경
이 앱을 개발하게된 배경은 실제 강아지를 키우면서 꼭두새벽이나 밤에 강아지가 아픈경우가 생깁니다. 그때 당황한 상태로 그 늦은시간에 운영하는 병원을 찾기란 쉽지가 않았습니다. 그래서 앱을통해 내 주변에 어떤병원이 24시간 운영중인지 확인하고 빠르게 병원으로 가 치료를 받을수 있게끔 하는 그런앱을 만들어보고자 했습니다.    

   
## 개발환경
데이터베이스는 Firebase의 FireStore와 CoreData를 이용했습니다.   
지도는 네이버 map Api로 구현했습니다.   
검색기능은 네이버 지역-검색 Api로 구현했습니다.    
네비게이션연동은 현재는 Tmap만 지원하고 Tmap Api로 구현했습니다.   
디자인 패턴은 MVVM 패턴을 사용했습니다.   


## 개발과정
   
### 네이버맵 API   
![Simulator Screen Recording - iPhone 13 Pro - 2022-04-22 at 16 21 12](https://user-images.githubusercontent.com/93653997/164626619-d5240888-7b01-4306-9784-d019eff5a7fb.gif)


동물병원의 위치를 나타낼 지도는 네이버 맵 Api를 활용했습니다.    
네이버맵 API같은경우 여러가지 기능을 제공하는데       
그중 병원의 위치를 알수있는 마커를 활용했습니다.
앱을 키자마자 데이터 로딩화면이 표시되고   
데이터 로딩이 완료되면 로딩화면이 사라진후에 받아온 데이터를 반복문을 활용해 마커로 표시합니다.   
그럼 결과적으로 화면에 모든 동물병원의 위치가 마커로 표시됩니다.
<details>

파이어베이스에서 데이터를 받아오는 Service 코드   

```swift
struct HospitalService {
    static func fetchHospital(compltion: @escaping (Result<[HospitalModel],Error>) -> Void) {
        let db = Firestore.firestore().collection("hospital")
        db.getDocuments() { snapshot, error in
            if let error = error {
                compltion(.failure(error))
                return
            }
            guard let doc = snapshot?.documents else {return}
            let model = doc.map {
                HospitalModel(dic: $0.data())
            }
            compltion(.success(model))
        }
    }
}
```

파이어베이스에서 받아온 데이터를 모델로 만드는 코드   

```swift
struct HospitalModel {
    var name: String
    var address: String
    var phoneNumber: String
    var runtime: String
    var imageURL: String
    var tax: String
    var x: Double
    var y: Double
    
    init(dic: [String: Any]) {
        self.name = dic["name"] as? String ?? ""
        self.address = dic["address"] as? String ?? ""
        self.phoneNumber = dic["phoneNumber"] as? String ?? ""
        self.runtime = dic["runtime"] as? String ?? ""
        self.imageURL = dic["image"] as? String ?? "이미지 없음"
        self.tax = dic["tax"] as? String ?? "야간 할증 정보가 없습니다"
        self.x = dic["x"] as? Double ?? 0
        self.y = dic["y"] as? Double ?? 0
    }
}


```


모델을 이용해 뷰에서 필요한데이터로 만든 ViewModel 코드   
데이터를 받은게 끝나는 시점을 알기위해 만든 클로져 lodingEnd   

```swift
final class HospitalViewModel {
    

    var models: [HospitalModel] = []
    
    var lodingEnd: () -> Void = {}
    
    func fetch() {
        HospitalService.fetchHospital { [weak self] result in
            switch result {
            case .success(let model):
                self?.models = model
                self?.lodingEnd()
            case .failure(_):
                self?.lodingEnd()
            }
        }
    }
}

```

이 viewModel을 이용해 반복문을 통해 마커를 생성하는 코드   
viewModel에서 만든 lodingEnd 클료져가 호출되면 아래 함수가 호출됨   

```swift
private func lodingViewOFF() {
        //네이버 공식문서에서 같은 이미지를 쓰는경우 오버레이 이미지를 하나만 생성해서 사용해야한다고 합니다.
        let image = NMFOverlayImage(name: "마커이미지")
        loadingView.removeFromSuperview()
        DispatchQueue.global(qos: .default).async { [weak self] in
            for models in self!.hospitalViewModel.models {
                let marker = NMFMarker()
                marker.iconImage = image
                marker.position = NMGLatLng(lat: models.x, lng: models.y)
                marker.width = 40
                marker.height = 60
                marker.touchHandler = { [weak self] (ovrlay: NMFOverlay) -> Bool in
                    self?.marker.mapView = nil
                    self?.containerView.viewModel = DetailViewModel(model: models)
                    self?.animatePresentContainer()
                    self?.selectCameraZoom()
                    let camUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: models.x, lng: models.y))
                    self?.naverMapView.moveCamera(camUpdate)
                    return true
                }
                DispatchQueue.main.async { [weak self] in
                    marker.mapView = self?.naverMapView
                }
            }
        }
    }
```

<summary>코드보기</summary>
