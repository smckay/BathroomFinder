
import UIKit
import SwiftyJSON

class BathroomsDataModel {
    
    var bathrooms : [BathroomDataModel]
    
    init(){
        bathrooms = []
    }
    
    func populateParks(json: JSON) -> Void{
        print("POPULATING PARKS")
        for bathroom in json{
            let b: JSON = bathroom.1
            if b["type"].stringValue == "Bathrooms"{
                let room : BathroomDataModel = BathroomDataModel()
                room.location = b["location"].stringValue
                room.name = b["name"].stringValue
                room.type = b["type"].stringValue
                bathrooms.append(room)
            }
        }
        print("PARKS POPULATED")
    }
    
    func populateLatLongs(json: JSON) -> Void{
        let j : JSON = json["results"].arrayValue[0]
        print(j["geometry"]["lat"])
    }
    
    func getBathrooms() -> [BathroomDataModel]{
        return self.bathrooms
    }
    
    func closestBathroom() -> BathroomDataModel{
        var closest : BathroomDataModel = BathroomDataModel()
        for b in bathrooms{
            if let distance = closest.distance {
                if let bDistance = b.distance {
                    if bDistance < distance{
                        closest = b
                    }
                }
            }
            else{
                if b.distance != nil{
                    closest = b
                }
            }
        }
        return closest
    }
    
}
