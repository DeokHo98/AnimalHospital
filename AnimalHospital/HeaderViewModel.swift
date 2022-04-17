//
//  headerViewModel.swift
//  AnimalHospital
//
//  Created by 정덕호 on 2022/04/17.
//

import Foundation

final class HeaderViewModel {
    
    deinit {
        print("헤더뷰 모델 메모리 해제")
    }
    
    var model: HospitalModel
    
    var phoneNumber: String {
        return model.phoneNumber.replacingOccurrences(of: "-", with: "")
    }
    
    init(model: HospitalModel) {
        self.model = model
    }
}
