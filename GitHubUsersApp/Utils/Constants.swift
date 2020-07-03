import Foundation

struct Constants {
    static let usersEndpoint = "https://api.github.com/search/users"
    static let usersDetailsEndpoint = "https://api.github.com/users/"
    static let apiDateFormat = "yyyy-MM-dd hh:mm:ss"
    static let usersPerRequestAmount = 30
    static let preferredPrimaryColumnWidthFraction = 0.5
    
    static func getUsersEndpoint() -> String {
        return usersEndpoint
    }
    
    static func getUsersDetailsEndpoint(userName: String) -> String {
        var currentEndpoint = usersDetailsEndpoint
        currentEndpoint += userName
        return currentEndpoint
    }
    
    static func getUsersRequestParametes(query:String, page:Int) -> [String:String]{
        return [Strings.queryParameter : query,
                Strings.perPageString: String(usersPerRequestAmount),
                Strings.pageString:String(page)]
    }
}

struct Strings {
    // MARK: Controllers titles
    static let detailsViewTitle = "gitHub User Details"
    static let mainViewTitle = "gitHub User Lookup"
    
    // MARK: Users request parameters titles
    static let queryParameter = "q"
    static let perPageString = "per_page"
    static let pageString = "page"
    
    // MARK: misc Strings
    static let noInternet = "not connected to internet"
    static let noInternetAndCache = "not connected to internet and user is not cached"
    static let noAlphanumeric = "please insert valid userName or part of it"
    static let noUsers = "No users found for criteria"
    static let notProvided = "<Not Provided>"
    static let loading = "Loading"
    static let welcomeMessage = "Search for gitHub Users from left panel"
}
