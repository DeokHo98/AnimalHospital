//
//  DetailViewModel.swift
//  AnimalHospital
//
//  Created by 정덕호 on 2022/04/16.
//

import Foundation

final class DetailViewModel {
    let model: HospitalModel

    var name: String {
        return model.name
    }
    
    var address: String {
        return model.address
    }
    
    var phoneNumber: String {
        return model.phoneNumber
    }
    
    var runtime: String {
        return model.runtime
    }
    
    var tax: String {
        return model.tax
    }
    
    var imageURL: String {
        return model.imageURL
    }
    
    
    
    init(model: HospitalModel) {
        self.model = model
    }
    
    
    
}
