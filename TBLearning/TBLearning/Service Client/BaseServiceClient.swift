import Foundation

typealias ServiceCallCompletion = (_ result: ServiceCallResult) -> ()

struct ServiceCallError {
    let message: String
    let code: Int?
}

enum ServiceCallResult {
    case success(result: Any)
    case error(error: ServiceCallError)
}

enum RequestBodyContentType: String {
    case json = "application/json; charset=utf-8"
}

enum ServiceCallMethod: String {
    case get = "GET"
    case post = "POST"
}

class BaseServiceClient {
    
    func get(from endpoint: URL,
             httpHeaders: [String:String],
             queryParams:[String:String]?,
             serviceType: String,
             completion: @escaping ServiceCallCompletion) {
        
        // Create URL with query parameters, if present
        var completeUrlPath = endpoint.absoluteString
        
        if let params = queryParams {
            let parameterString = params.map { "\($0.key)=\($0.value)" } .joined(separator: "&")
            completeUrlPath.append("?\(parameterString)")
        }
        
        guard let completeUrl = URL(string: completeUrlPath) else {
            let serviceCallError = ServiceCallError(message: "Error constructing URL for service call", code: nil)
            Log.error(serviceCallError.message)
            completion(ServiceCallResult.error(error: serviceCallError))
            return
        }
        
        // Create the URL Request
        var request = URLRequest(url: completeUrl)
        request.httpMethod = ServiceCallMethod.get.rawValue
        request.timeoutInterval = 10.0
        
        // Set headers on the URL Request
        for (key, value) in httpHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        Log.info("🌎 Making GET request to: \(completeUrl.absoluteString)")
        
        // Create the URL Session and the task we want it to perform
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        let task = session.dataTask(with: request) { [weak self] (data, response, error) in
            self?.responseHandler(completion: completion, data: data, response: response, error: error, serviceType: serviceType)
        }
        
        // Actually start the task
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    func post(to endpoint: URL,
              httpHeaders: [String:String],
              httpBody:Data?,
              serviceType: String,
              completion: @escaping ServiceCallCompletion) {
        
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = ServiceCallMethod.post.rawValue
        request.timeoutInterval = 10.0
        
        // Set headers on the URL Request
        for (key, value) in httpHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        // Add the body to the request
        if let body = httpBody {
            request.httpBody = body
        }
        // Create the URL Session and the task we want it to perform
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        let task = session.dataTask(with: request) { [weak self] (data, response, error) in
            //output the response data value:::::::::
            let _ = String(data: data!, encoding: String.Encoding.utf8)
            self?.responseHandler(completion: completion, data: data, response: response, error: error, serviceType: serviceType)
        }
        
        // Actually start the task
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    private func responseHandler(completion: @escaping ServiceCallCompletion, data: Data?, response: URLResponse?, error: Error?, serviceType: String) {
        
        // Check for errors
        if let responseError = error {
            let serviceCallError = ServiceCallError(message: responseError.localizedDescription, code: nil)
            completion(ServiceCallResult.error(error: serviceCallError))
            return
        }
        
        // Check if we can parse response
        guard let httpResponse = response as? HTTPURLResponse else {
            let serviceCallError = ServiceCallError(message: "Could not parse HTTP response", code: nil)
            completion(ServiceCallResult.error(error: serviceCallError))
            return
        }
        // Check for response codes outside of 200s (success range)
        if !(200 ... 299 ~= httpResponse.statusCode) {
            let serviceCallError = ServiceCallError(message: "Unsuccessful service call", code: httpResponse.statusCode)
            completion(ServiceCallResult.error(error: serviceCallError))
            return
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
            if let date = formatter.date(from: dateStr) {
                return date
            }
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSXXXXX"
            if let date = formatter.date(from: dateStr) {
                return date
            }
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
            if let date = formatter.date(from: dateStr) {
                return date
            }
            throw DateError.invalidDate
        })
        switch serviceType {
        case "getCourses":
            if let responseData = data, let json = try? decoder.decode([CourseInfo].self, from: responseData) {
                completion(ServiceCallResult.success(result: json))
                return
            }
        case "getQuizes":
            if let responseData = data, let json = try? decoder.decode(GetQuizWithToken.self, from: responseData) {
                completion(ServiceCallResult.success(result: json))
                return
            }
        case "postAnswers": 
            if let responseData = data, let json = try? decoder.decode(QuizResult.self, from: responseData) {
                completion(ServiceCallResult.success(result: json))
                return
            }
        case "getGroupInfo":
            if let responseData = data, let json = try? decoder.decode(Group.self, from: responseData) {
                completion(ServiceCallResult.success(result: json))
                return
            }
        case "getGroupStatus":
            if let responseData = data, let json = try? decoder.decode(GroupStatus.self, from: responseData){
                completion(ServiceCallResult.success(result: json))
                return
            }
        case "postGroupAnswer":
            if let responseData = data, let json = try? decoder.decode(GroupQuizAnswerResult.self, from: responseData) {
                Log.info(json)
                completion(ServiceCallResult.success(result: json))
                return
            }
        case "groupQuizProgress":
            if let responseData = data, let json = try? decoder.decode(GroupQuizProgress.self, from: responseData) {
                Log.info("response \(json)")
                completion(ServiceCallResult.success(result: json))
                return
            }

        default:
            print("Other services")
        }
        completion(ServiceCallResult.success(result: []))
    }
    
}


