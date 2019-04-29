//
//  BathroomDataModel.swift
//  Clima
//
//  Created by McKay, Samuel on 3/27/19.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import UIKit

class BathroomDataModel{
    
    var location: String
    var name: String
    var type : String
    var lat : Double?
    var long : Double?
    var distance : Double?
    
    
    init(){
        location = ""
        name = ""
        type = ""
    }
}
