//
//  ViewModel.swift
//  TouchBarLeague
//
//  Created by Marcin Slusarek on 20/05/2019.
//  Copyright © 2019 Marcin Slusarek. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ViewModel {
    
    let pickedChampion: BehaviorRelay<Int> = BehaviorRelay(value : 0)
    fileprivate let disposeBag = DisposeBag()
    
    init() {
        setup()
    }
    
    func setup() {
        
    }
}
