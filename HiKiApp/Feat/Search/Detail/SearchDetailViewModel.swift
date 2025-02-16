//
//  SearchDetailViewModel.swift
//  HiKiApp
//
//  Created by 정성윤 on 2/12/25.
//

import Foundation

struct AnimateDetailData {
    var synopsis: AnimateData?
    var teaser: [VideoPromo]?
    var characters: [CharacterData]?
}

final class SearchDetailViewModel: ViewModelType {
    private let db = DataBase.shared
    
    enum DetailType: CaseIterable {
        case poster
        case synopsis
        case teaser
        case characters
    }
    
    struct Input {
        let detailTrigger: Observable<Int>
        let heartBtnTrigger: Observable<Void>
    }
    
    struct Output {
        let animeData: Observable<AnimateDetailData?> = Observable(nil)
    }
    
    init() {
        print(#function, self)
    }
    
    deinit {
        print(#function, self)
    }
    
}

extension SearchDetailViewModel {
    
    func transform(input: Input) -> Output {
        let output = Output()
        //TODO: Swift Concurency
        input.detailTrigger.bind { id in
            let group = DispatchGroup()
            var resultData = AnimateDetailData(synopsis: nil, teaser: nil, characters: nil)
            group.enter()
            AnimateServices().getDetailAnime(id: id) { response in
                switch response {
                case let .success(data):
                    resultData.synopsis = data
                case .failure:
                    resultData.synopsis = nil
                }
                group.leave()
            }
            group.enter()
            AnimateServices().getVideo(id: id) { response in
                switch response {
                case let .success(data):
                    resultData.teaser = data.promo
                case .failure:
                    resultData.teaser = nil
                }
                group.leave()
            }
            group.enter()
            AnimateServices().getCharacters(id: id) { response in
                switch response {
                case let .success(data):
                    resultData.characters = data
                case .failure:
                    resultData.characters = nil
                }
                group.leave()
            }
            group.notify(queue: .global()) {
                output.animeData.value = resultData
            }
        }
        
        return output
    }
    
}
