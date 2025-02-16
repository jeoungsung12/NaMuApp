//
//  WatchViewModel.swift
//  NaMuApp
//
//  Created by 정성윤 on 2/9/25.
//

import Foundation

final class WatchViewModel: ViewModelType {
    private var videosData: [AnimateData] = []
    struct Input {
        let dataTrigger: Observable<Int>
    }
    
    struct Output {
        let dataResult: Observable<[AnimateData]?> = Observable(nil)
    }
    
}

extension WatchViewModel {
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.dataTrigger.bind { [weak self] page in
            self?.fetchData(page) { result in
                switch result {
                case let .success(data):
                    self?.videosData.append(contentsOf: data)
                    output.dataResult.value = self?.videosData
                case .failure:
                    output.dataResult.value = nil
                }
            }
        }
        
        return output
    }
    
    private func fetchData(_ page: Int, completion: @escaping (Result<[AnimateData],NetworkError.CustomError>) -> Void) {
        AnimateServices().getRandomAnime(page: page) { result in
            completion(result)
        }
    }
    
}
