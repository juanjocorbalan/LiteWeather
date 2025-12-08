import Foundation

public struct WeatherDTO: Decodable, Sendable {
    
    public struct CoordDTO: Decodable, Sendable {
        public let lon: Double
        public let lat: Double
        
        public init(lon: Double, lat: Double) {
            self.lon = lon
            self.lat = lat
        }
    }
    
    public struct WeatherConditionDTO: Decodable, Sendable {
        public let id: Int
        public let main: String
        public let description: String
        public let icon: String
        
        public init(id: Int, main: String, description: String, icon: String) {
            self.id = id
            self.main = main
            self.description = description
            self.icon = icon
        }
    }
    
    public struct MainDTO: Decodable, Sendable {
        public let temp: Double
        public let feelsLike: Double
        public let tempMin: Double
        public let tempMax: Double
        public let pressure: Int
        public let humidity: Int
        
        public init(temp: Double, feelsLike: Double, tempMin: Double, tempMax: Double, pressure: Int, humidity: Int) {
            self.temp = temp
            self.feelsLike = feelsLike
            self.tempMin = tempMin
            self.tempMax = tempMax
            self.pressure = pressure
            self.humidity = humidity
        }
    }
    
    public struct WindDTO: Decodable, Sendable {
        public let speed: Double
        public let deg: Int
        public let gust: Double?
        
        public init(speed: Double, deg: Int, gust: Double?) {
            self.speed = speed
            self.deg = deg
            self.gust = gust
        }
    }
    
    public struct CloudsDTO: Decodable, Sendable {
        public let all: Int
        
        public init(all: Int) {
            self.all = all
        }
    }
    
    public struct SysDTO: Decodable, Sendable {
        public let type: Int?
        public let id: Int?
        public let country: String?
        public let sunrise: Int
        public let sunset: Int

        public init(type: Int?, id: Int?, country: String?, sunrise: Int, sunset: Int) {
            self.type = type
            self.id = id
            self.country = country
            self.sunrise = sunrise
            self.sunset = sunset
        }
    }
    
    public let coord: CoordDTO
    public let weather: [WeatherConditionDTO]
    public let base: String?
    public let main: MainDTO
    public let visibility: Int?
    public let wind: WindDTO
    public let clouds: CloudsDTO
    public let dt: Int
    public let sys: SysDTO
    public let timezone: Int?
    public let id: Int?
    public let name: String
    public let cod: Int?
    
    public init(
        coord: CoordDTO,
        weather: [WeatherConditionDTO],
        base: String?,
        main: MainDTO,
        visibility: Int?,
        wind: WindDTO,
        clouds: CloudsDTO,
        dt: Int,
        sys: SysDTO,
        timezone: Int?,
        id: Int?,
        name: String,
        cod: Int?
    ) {
        self.coord = coord
        self.weather = weather
        self.base = base
        self.main = main
        self.visibility = visibility
        self.wind = wind
        self.clouds = clouds
        self.dt = dt
        self.sys = sys
        self.timezone = timezone
        self.id = id
        self.name = name
        self.cod = cod
    }
    
    enum CodingKeys: String, CodingKey {
        case coord, weather, base, main, visibility, wind, clouds, dt, sys, timezone, id, name, cod
    }
    
    enum MainKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure
        case humidity
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        coord = try container.decode(CoordDTO.self, forKey: .coord)
        weather = try container.decode([WeatherConditionDTO].self, forKey: .weather)
        base = try container.decodeIfPresent(String.self, forKey: .base)
        visibility = try container.decodeIfPresent(Int.self, forKey: .visibility)
        wind = try container.decode(WindDTO.self, forKey: .wind)
        clouds = try container.decode(CloudsDTO.self, forKey: .clouds)
        dt = try container.decode(Int.self, forKey: .dt)
        sys = try container.decode(SysDTO.self, forKey: .sys)
        timezone = try container.decodeIfPresent(Int.self, forKey: .timezone)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        cod = try container.decodeIfPresent(Int.self, forKey: .cod)
        
        let mainContainer = try container.nestedContainer(keyedBy: MainKeys.self, forKey: .main)
        main = MainDTO(
            temp: try mainContainer.decode(Double.self, forKey: .temp),
            feelsLike: try mainContainer.decode(Double.self, forKey: .feelsLike),
            tempMin: try mainContainer.decode(Double.self, forKey: .tempMin),
            tempMax: try mainContainer.decode(Double.self, forKey: .tempMax),
            pressure: try mainContainer.decode(Int.self, forKey: .pressure),
            humidity: try mainContainer.decode(Int.self, forKey: .humidity)
        )
    }
}
