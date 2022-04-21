# 24시 동물병원 앱 개발 과정

## 배경
이 앱을 개발하게된 배경은 실제 강아지를 키우면서 꼭두새벽이나 밤에 강아지가 아픈경우가 생깁니다. 그때 당황한 상태로 그 늦은시간에   
운영하는 병원을 찾기란 쉽지가 않았습니다. 그래서 앱을통해 내 주변에 어떤병원이 24시간 운영중인지 확인하고 빠르게 병원으로 가 치료   
를 받을수 있게끔 하는 그런앱을 만들어보고자 했습니다.
   
## Setting
데이터베이스는 Firebase의 FireStore와 CoreData를 이용했습니다.   
지도는 네이버 map Api로 구현했습니다.   
검색기능은 네이버 지역-검색 Api로 구현했습니다.    
네비게이션연동은 현재는 Tmap만 지원하고 Tmap Api로 구현했습니다.   
디자인 패턴은 MVVM 패턴을 사용했습니다.   
