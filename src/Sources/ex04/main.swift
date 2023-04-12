import Foundation

extension String {
    func applyPhoneMask() -> String {
        let phone = self.replacingOccurrences(of: "[^0-9]+", with: "", options: .regularExpression)
        
        guard [11, 12].contains(phone.count) else {
            return self
        }
        
        if phone.count == 11 {
            switch phone.prefix(4).suffix(3) {
            case "800":
                return "8 (800) \(phone.prefix(7).suffix(3)) \(phone.prefix(9).suffix(2)) \(phone.suffix(2))"
            default:
                return "+7 \(phone.prefix(4).suffix(3)) \(phone.prefix(7).suffix(3))-\(phone.prefix(9).suffix(2))-\(phone.suffix(2))"
            }
        } else {
            return "+7 \(phone.prefix(6).suffix(3)) \(phone.prefix(9).suffix(3))-\(phone.prefix(11).suffix(2))-\(phone.suffix(2))"
        }
    }
}

print("Enter an incident coordinates:")
let incidentCoordinates = readLine()
do {
    let sovetskyDistrict = "7;7 1"
    let kaliniskyDistrict = "11;11 12;12 12;11"
    let kirovskyDistrict = "0;0 0;-2 -2;0 -1;1"
    var zone = try parseZone(sovetskyDistrict)
    var ins = try isIncidentInZone(incidentCoordinates!, zone)
    print("The city info:")
    print("  Name: Novosibirsk")
    print("  The common number: 8 (800) 847 38 24")
    print("")
    print("The incident info:")
    print("  Description: \(ins.description)")
    print("  Phone number: \(ins.phoneNumber)")
    print("  Type: \(ins.type)")
    print("")
    if (ins.inDistrict) {
        print(ins.descriptionFinish)
    } else {
        zone = try parseZone(kaliniskyDistrict)
        ins = try isIncidentInZone(incidentCoordinates!, zone)
        if (ins.inDistrict) {
            print(ins.descriptionFinish)
        } else {
            zone = try parseZone(kirovskyDistrict)
            ins = try isIncidentInZone(incidentCoordinates!, zone)
            if (ins.inDistrict) {
                print(ins.descriptionFinish)
            } else {
                zone = try parseZone(sovetskyDistrict)
                ins = try isIncidentInZone(incidentCoordinates!, zone)
                print(ins.descriptionFinish)
            }
        }
    }
    print("The zone info:")
    print("  The shape of area: \(zone.shape)")
    print("  Phone number: \(zone.phoneNumber)")
    print("  Name: \(zone.name)")
    print("  Emergency dept: \(zone.emergencyDept)")
    print("  Danger level: \(zone.dangerLevel)")
}catch {
    throw MyError.myException(message: "Input not correct. Please try again!!!")
}

struct Zone {
    var shape: String
    var phoneNumber: String
    var name: String
    var emergencyDept: String
    var dangerLevel: String
    var coordinates: String
}

struct Incident {
    var description: String
    var phoneNumber: String
    var type: String
    var descriptionFinish: String
    var inDistrict: Bool
}


enum Field : String {
    case fire = "fire"
    case gas = "gas leak"
    case cat = "cat on the tree"
    case null = "nil"
}

func parseZone(_ input: String) throws -> Zone {
    let circlePattern = try! NSRegularExpression(pattern: "^(-?\\d+);(-?\\d+) (-?\\d+)$", options: [])
    let trianglePattern = try! NSRegularExpression(pattern: "^(-?\\d+);(-?\\d+) (-?\\d+);(-?\\d+) (-?\\d+);(-?\\d+)$", options: [])
    let tetragonPattern = try! NSRegularExpression(pattern: "^(-?\\d+);(-?\\d+) (-?\\d+);(-?\\d+) (-?\\d+);(-?\\d+) (-?\\d+);(-?\\d+)$", options: [])

    func isCircle(input: String) -> Bool {
        return circlePattern.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count)).count > 0
    }

    func isTriangle(input: String) -> Bool {
        return trianglePattern.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count)).count > 0
    }

    func isTetragon(input: String) -> Bool {
        return tetragonPattern.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count)).count > 0
    }

    let args = input.split(separator: " ").map(String.init)
    
    let phone2 = "89152342343"
    let maskedPhone2 = phone2.applyPhoneMask()

    
    switch args.count {
    case 2:
        if isCircle(input: input) {
            return Zone(shape: "circle", phoneNumber: maskedPhone2, name: "Sovetsky district", emergencyDept: "49324", dangerLevel: "low", coordinates: input)
        } else {
            throw MyError.myException(message: "Input not correct. Please try again!!!")
        }

    case 3:
        if isTriangle(input: input) {
            return Zone(shape: "triangle", phoneNumber: maskedPhone2, name: "Kalinisky district", emergencyDept: "49324", dangerLevel: "medium", coordinates: input)
        } else {
            throw MyError.myException(message: "Input not correct. Please try again!!!")
        }

    case 4:
        if isTetragon(input: input) {
            return Zone(shape: "tetragon", phoneNumber: maskedPhone2, name: "Kirovsky district", emergencyDept: "49324", dangerLevel: "high", coordinates: input)
        } else {
            throw MyError.myException(message: "Input not correct. Please try again!!!")
        }

    default:
        throw MyError.myException(message: "Input not correct. Please try again!!!")
    }
}

func isIncidentInZone(_ input: String, _ zone: Zone) throws -> Incident {
    let incidentPattern = try! NSRegularExpression(pattern: "^(-?\\d+);(-?\\d+)", options: [])
    
    func isIncidentInZonePattern(input: String) -> Bool {
        return incidentPattern.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count)).count > 0
    }
    
    let args = input.split(separator: " ").map(String.init)
    
    let phone3 = "88005553535"
    let maskedPhone3 = phone3.applyPhoneMask()
    

    if args.count == 1 {
        if isIncidentInZonePattern(input: input) {
            if(isInZone(input, zone)) {
                return Incident(description: "the woman said her cat can't get off the tree", phoneNumber: maskedPhone3, type: Field.cat.rawValue, descriptionFinish: "An incident is in \(zone.name)", inDistrict: true)
                
            } else {
                return Incident(description: "the woman said her cat can't get off the tree", phoneNumber: maskedPhone3, type: Field.cat.rawValue, descriptionFinish: "The incident didn't match with any zone. The nearest zone: \(zone.name)", inDistrict: false)
            }
        } else {
            throw MyError.myException(message: "Input not correct. Please try again!!!")
        }
    } else {
        throw MyError.myException(message: "Input not correct. Please try again!!!")
    }
    
}

func isInZone(_ input: String, _ zone: Zone) -> Bool {
    let coordinates = input.split(separator: ";")
    guard coordinates.count == 2,
          let xInZone = Int(coordinates[0]),
          let yInZone = Int(coordinates[1]) else {
        return false
    }
    
    switch zone.shape {
    case "circle":
        guard let (x, y, radius) = parseCircle(zone.coordinates) else {
            return false
        }
        let distance = sqrt(Double((xInZone - x) * (xInZone - x) + (yInZone - y) * (yInZone - y)))
        return distance <= Double(radius)
        
    case "triangle":
        return isInTriangle(x: xInZone, y: yInZone, triangle: zone.coordinates)
        
    case "tetragon":
        return isInTetragon(x: xInZone, y: yInZone, tetragon: zone.coordinates)
        
    default:
        return false
    }
}

func parseCircle(_ input: String) -> (x: Int, y: Int, radius: Int)? {
    let components = input.split(separator: " ")
    guard components.count == 2 else {
        return nil
    }
    let xyComponents = components[0].split(separator: ";")
    guard xyComponents.count == 2,
          let x = Int(xyComponents[0]),
          let y = Int(xyComponents[1]),
          let radius = Int(components[1]) else {
        return nil
    }
    return (x, y, radius)
}

func isInTriangle(x: Int, y: Int, triangle: String) -> Bool {
    guard let points = parsePoints(triangle) else {
        return false
    }
    let triangleArea = areaOfTriangle(points)
    let area1 = areaOfTriangle([(x, y), points[1], points[2]])
    let area2 = areaOfTriangle([points[0], (x, y), points[2]])
    let area3 = areaOfTriangle([points[0], points[1], (x, y)])
    let sumOfAreas = area1 + area2 + area3
    return abs(triangleArea - sumOfAreas) < 1e-9
}

private func parsePoints(_ input: String) -> [(Int, Int)]? {
    let components = input.split(separator: " ")
    guard components.count == 3 else {
        return nil
    }
    let points = components.compactMap { (component) -> (Int, Int)? in
        let xy = component.split(separator: ";").compactMap { Int($0) }
        guard xy.count == 2 else {
            return nil
        }
        return (xy[0], xy[1])
    }
    guard points.count == 3 else {
        return nil
    }
    return points
}

private func areaOfTriangle(_ points: [(Int, Int)]) -> Double {
    let x1 = Double(points[0].0), y1 = Double(points[0].1)
    let x2 = Double(points[1].0), y2 = Double(points[1].1)
    let x3 = Double(points[2].0), y3 = Double(points[2].1)
    return abs(0.5 * ((x1 * y2 + x2 * y3 + x3 * y1) - (x2 * y1 + x3 * y2 + x1 * y3)))
}

func isInTetragon(x: Int, y: Int, tetragon: String) -> Bool {
    let points = tetragon.split(separator: " ").map { $0.split(separator: ";").compactMap { Int($0) } }
    let p1 = points[0], p2 = points[1], p3 = points[2], p4 = points[3]
    
    // Check if the point is inside the quadrilateral ABCD by checking if it's on the same side of
    // all four line segments as the remaining point on each line segment
    let side1 = getSide(x: x, y: y, x1: p1[0], y1: p1[1], x2: p2[0], y2: p2[1])
    let side2 = getSide(x: x, y: y, x1: p2[0], y1: p2[1], x2: p3[0], y2: p3[1])
    let side3 = getSide(x: x, y: y, x1: p3[0], y1: p3[1], x2: p4[0], y2: p4[1])
    let side4 = getSide(x: x, y: y, x1: p4[0], y1: p4[1], x2: p1[0], y2: p1[1])
    
    return side1 >= 0 && side2 >= 0 && side3 >= 0 && side4 >= 0 || side1 <= 0 && side2 <= 0 && side3 <= 0 && side4 <= 0
}

private func getSide(x: Int, y: Int, x1: Int, y1: Int, x2: Int, y2: Int) -> Int {
    return (x - x1) * (y2 - y1) - (y - y1) * (x2 - x1)
}

enum MyError: Error {
    case myException(message: String)
}
