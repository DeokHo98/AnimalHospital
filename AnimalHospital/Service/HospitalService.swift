//
//  HospitalService.swift
//  AnimalHospital
//
//  Created by 정덕호 on 2022/04/14.
//

import Foundation
import Firebase

public let COLLECTION_HOSPITAL = Firestore.firestore().collection("hospital")

struct HospitalService {
    static func fetchHospital(compltion: @escaping (Result<[HospitalModel],Error>) -> Void) {
        COLLECTION_HOSPITAL.getDocuments() { snapshot, error in
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
