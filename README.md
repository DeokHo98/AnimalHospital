# 24시 동물병원 앱

## 배경
이 앱을 개발하게된 배경은 실제 강아지를 키우면서 꼭두새벽이나 밤에 강아지가 아픈경우가 생깁니다. 그때 당황한 상태로 그 늦은시간에 운영하는 병원을 찾기란 쉽지가 않았습니다. 그래서 앱을통해 내 주변에 어떤병원이 24시간 운영중인지 확인하고 빠르게 병원으로 가 치료를 받을수 있게끔 하는 그런앱을 만들어보고자 했습니다.    

   
## 개발환경
데이터베이스는 Firebase의 FireStore와 CoreData를 이용했습니다.   
지도는 네이버 map Api로 구현했습니다.   
검색기능은 네이버 지역-검색 Api로 구현했습니다.    
네비게이션연동은 현재는 Tmap만 지원하고 Tmap Api로 구현했습니다.   
디자인 패턴은 MVVM 패턴을 사용했습니다.   


## 구현기능
1. 위치 검색기능   
   
2. 주변 동물병원 위치 기능   
   
3. 수정요청, 제보 기능   
   
4. 즐겨찾기 기능   
   
5. 티맵 내비 연동기능
   
6. 전화 기능    
   

## 개발과정



### 위치검색기능

![Simulator Screen Recording - iPhone 13 Pro - 2022-04-22 at 16 50 13](https://user-images.githubusercontent.com/93653997/164642882-f7b2a238-42f7-4bfe-afe1-63faf7a6966f.gif)


원하는 지역을 검색하고 그 위치로 이동한뒤   
그위치 주변의 병원정보를 알기위해 네이버 검색 API를 활용했습니다.   
검색 결과를 테이블뷰로 보여주고 셀을 클릭하면 클릭한 셀의 해당지역 좌표값을 가지고   
네이버맵의 카메라를 이동시킵니다.   
<details>
<summary>코드보기</summary>

네이버 검색 결과를 URL세션을 이용해 JSON형태로 받아와 모델로 만드는 코드  

```swift
static func fetchSearchService(queryValue: String, compltion: @escaping (Result<[SearchModel], Error>) -> Void) {
        DispatchQueue.global(qos: .default).async {
            let clientID = "AZNe9xs00tGIlUvyHPXj"
            let secretID = "XbdL_MZyWc"
            
            let query = "https://openapi.naver.com/v1/search/local.json?query=\(queryValue)&display=10&start=1&sort=random"
            
            guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) else {return}
            
            guard let url = URL(string: encodedQuery) else {return}
            
            var requestURL = URLRequest(url: url)
            
            requestURL.addValue(clientID, forHTTPHeaderField: "X-Naver-Client-Id")
            requestURL.addValue(secretID, forHTTPHeaderField: "X-Naver-Client-Secret")
            
            URLSession.shared.dataTask(with: requestURL) { data, respones, error in
                if error != nil {
                    compltion(.failure(error!))
                    return
                }
                
                guard let data = data else {
                    return
                }
                
                do {
                    let decodeData = try JSONDecoder().decode(SearchModelList.self, from: data)
                    let searhModels = decodeData.items.map {
                        SearchModel(name: $0.title, address: $0.roadAddress, x: $0.mapx, y: $0.mapy)
                    }
                    compltion(.success(searhModels))
                } catch {
                }
            }.resume()
        }
        
    }
}

```

받아온 모델을 통해 뷰에 보여줄 Viewmodel 코드   
데이터를 받기 시작한 시점과 끝난시점을 알기위해    
loddingStart와 lodingEnd 를만들었고    
이로인해 받아오는중의 로딩뷰를 표시했음    
델리게이트 패턴으로 HomeViewController에 lating값을 전달하고   
그 값을 이용해 카메라를 이동시켰음

```swift
final class SearchViewModel {
    
    var models : [SearchModel] = []
    
    var loddingStart: () -> Void = {}
    
    var lodingEnd: () -> Void = {}
    
    func count() -> Int {
        return models.count
    }
    
    func name(index: Int) -> String {
        return models[index].name.components(separatedBy: ["b","/","<",">"]).joined()
    }
    
    func address(index: Int) -> String {
        return models[index].address
    }
    
    func lating(index: Int) -> NMGLatLng {
        guard let xInt = Int(models[index].x) else {return NMGLatLng()}
        guard let yInt = Int(models[index].y) else {return NMGLatLng()}
        let xDouble = Double(xInt)
        let yDouble = Double(yInt)
        let tm = NMGTm128(x: xDouble, y: yDouble)
        let lating = tm.toLatLng()
        return lating
    }
    
    func fetch(searhText: String) {
        loddingStart()
        SearchService.fetchSearchService(queryValue: searhText) { [weak self] result in
             switch result {
             case .success(let models):
                 self?.models = models
                 self?.lodingEnd()
             case .failure(_):
                 self?.lodingEnd()
             }
        }
    }
}





```

델리게이트 패턴

```swift
protocol SearchViewDelegate: AnyObject {
    func locationData(lating: NMGLatLng)
}

func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let lating = searchViewModel?.lating(index: indexPath.row) else {return}
        delegate?.locationData(lating: lating)
        navigationController?.popViewController(animated: true)
        
        
    }
```
</details>




   
### 주변 동물병원 위치 기능    
![Simulator Screen Recording - iPhone 13 Pro - 2022-04-22 at 16 29 26](https://user-images.githubusercontent.com/93653997/164627998-dbfbf64c-405d-46d4-a186-9052abed6be2.gif)


동물병원의 위치를 나타낼 지도는 네이버 맵 Api를 활용했습니다.    
네이버맵 API같은경우 여러가지 기능을 제공하는데       
그중 병원의 위치를 알수있는 마커를 활용했습니다.
앱을 켠후 데이터 로딩화면이 표시되고   
데이터 로딩이 완료되면 로딩화면이 사라진후에 받아온 데이터를 반복문을 활용해 마커로 표시합니다.   
그럼 결과적으로 화면에 모든 동물병원의 위치가 마커로 표시됩니다.
<details>
<summary>코드보기</summary>

파이어베이스에서 데이터를 받아와 모델로 만드는 Service 코드

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
  
ViewModel 코드   
데이터를 받은게 끝나는 시점을 알기위해 만든 lodingEnd   
이 클로져를 이용해 로딩이 끝난 시점에 뷰를 보여줌   

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
</details>



### 수정요청, 제보기능

![Simulator Screen Recording - iPhone 13 Pro - 2022-04-22 at 17 03 38](https://user-images.githubusercontent.com/93653997/164645152-cef8e7a0-2c26-49fc-ab2a-729c620fc962.gif)


병원의 정보가 잘못되었거나 수정할정보가 있으면 수정사항을 사용자가 요청할수 있는 기능입니다.   
또한 제보를 통해 새로운 병원을 알릴 수 있습니다.     
수정요청이나 제보을 하면 파이어스토어에 항목에 정보가 올라옵니다.   

<img width="779" alt="스크린샷 2022-04-22 오후 5 04 56" src="https://user-images.githubusercontent.com/93653997/164645445-aaefcce1-3dae-4baa-87c7-5142670c9d74.png">

   
<details>
<summary>코드보기</summary>


제보, 수정요청 서비스 코드
```swift
struct EditService {
    static func uploadEditData(type: String, name: String, text: String,compliton: @escaping (Error?) -> Void) {
        let db = Firestore.firestore().collection(type)
        db.document().setData(["병원이름": name,"수정내용" : text]) { error in
            compliton(error)
        }
    }
    
    static func report(name: String, address: String, compltion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore().collection("새로운 병원 제보")
        db.document().setData(["병원이름": name,"위치" : address]) { error in
            compltion(error)
        }
    }
}
```

