import Foundation

print("Enter zone parameters:")
let input = readLine()
do {
    let zone = try parseZone(input!)
    print("The zone info:")
    print("  The shape of area: \(zone.shape)")
    print("  Phone number: \(zone.phoneNumber)")
    print("  Name: \(zone.name)")
    print("  Emergency dept: \(zone.emergencyDept)")
    print("  Danger level: \(zone.dangerLevel)")
    
    print("Enter an incident coordinates:")
    let incidentCoordinates = readLine()
    
    let ins = try isIncidentInZone(incidentCoordinates!, zone)
    print("The incident info:")
    print("  Description: \(ins.description)")
    print("  Phone number: \(ins.phoneNumber)")
    print("  Type: \(ins.type)")
    print(ins.descriptionFinish)

} catch {
    throw MyError.myException(message: "Input not correct. Please try again!!!")
}

struct Zone {
    let shape: String
    let phoneNumber: String
    let name: String
    let emergencyDept: String
    let dangerLevel: String
    let coordinates: String
}

struct Incident {
    let description: String
    let phoneNumber: String
    let type: String
    let descriptionFinish: String
}


enum Field : String {
    case fire = "fire"
    case gas = "gas leak"
    case cat = "cat on the tree"
    case null = "nil"
}

func parseZone(_ input: String) throws -> Zone {
    let args = input.split(separator: " ").map(String.init)

    guard args.count >= 2 else {
        throw MyError.myException(message: "Input not correct. Please try again!!!")
    }

    let shape = args.count - 1

    guard shape >= 1 && shape <= 4 else {
        throw MyError.myException(message: "Input not correct. Please try again!!!")
    }

    let regex: NSRegularExpression
    let dangerLevel: String

    switch shape {
    case 1:
        regex = try NSRegularExpression(pattern: "^(-?\\d+);(-?\\d+) (-?\\d+)$", options: [])
        dangerLevel = "low"
    case 2:
        regex = try NSRegularExpression(pattern: "^(-?\\d+);(-?\\d+) (-?\\d+);(-?\\d+) (-?\\d+);(-?\\d+)$", options: [])
        dangerLevel = "medium"
    case 3:
        regex = try NSRegularExpression(pattern: "^(-?\\d+);(-?\\d+) (-?\\d+);(-?\\d+) (-?\\d+);(-?\\d+) (-?\\d+);(-?\\d+)$", options: [])
        dangerLevel = "high"
    default:
        fatalError("Unexpected shape \(shape)")
    }

    guard regex.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count)).count > 0 else {
        throw MyError.myException(message: "Input not correct. Please try again!!!")
    }

    return Zone(
        shape: shape == 1 ? "circle" : shape == 2 ? "triangle" : "tetragon",
        phoneNumber: "8800\(dangerLevel)473824",
        name: "Sovetsky district",
        emergencyDept: "49324",
        dangerLevel: dangerLevel,
        coordinates: input
    )
}

func isIncidentInZone(_ input: String, _ zone: Zone) throws -> Incident {
    let incidentPattern = try NSRegularExpression(pattern: "^(-?\\d+);(-?\\d+)", options: [])
    
    guard input.split(separator: " ").count == 1 else {
        throw MyError.myException(message: "Input not correct. Please try again!!!")
    }
    
    guard incidentPattern.firstMatch(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count)) != nil else {
        throw MyError.myException(message: "Input not correct. Please try again!!!")
    }
    
    guard isInZone(input, zone) else {
        return Incident(description: "the woman said her cat can't get off the tree", phoneNumber: "+74832648573", type: Field.cat.rawValue, descriptionFinish: "An incident is not in Sovetsky district\n Switch the applicant to the common number: 88008473824")
    }
    
    return Incident(description: "the woman said her cat can't get off the tree", phoneNumber: "+74832648573", type: Field.cat.rawValue, descriptionFinish: "An incident is in Sovetsky district")
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
