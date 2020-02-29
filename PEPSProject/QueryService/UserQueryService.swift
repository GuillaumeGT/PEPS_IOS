//
//  UserQueryService.swift
//  PEPSProject
//
//  Created by user164567 on 2/27/20.
//  Copyright © 2020 user164567. All rights reserved.
//

import Foundation


struct createUserJSON: Codable{
    var pseudo: String
    var password : String
}

struct credentialsJSON: Codable{
    var user: User
    var token: String
}

class UserQueryService{
    
    
    var fileLocation : URL? = Bundle.main.url(forResource: "credentials", withExtension: "json")
    
    
    //
    //Make a request to API and get the User corresponding to the ID given in parameter
    //Create a User with the data received and return the User
    func getUserById(idUser: Int) -> User{
        
        var newU : User = User()
        
        var responseDataOpt : [String: Any]?
        
        responseDataOpt = QueryService().request(url: "https://web-ios-api.herokuapp.com/users/"+String(idUser), httpMethod: "GET", httpBody: nil)
        
        if let responseData = responseDataOpt{
            if let dataUser = responseData["data"] as? [Any]{
                for user in dataUser{
                    if let newUser = user as? [String:Any]{
                        //print(newUser)
                        newU.idUser = (newUser["idUser"] as! Int)
                        newU.role = (newUser["role"] as! String)
                        newU.pseudo = (newUser["pseudo"] as! String)
                    }
                }
            }
        }
        
        return newU
    }
    
    
    
    
    //
    // Send a request to API for create a new User in database
    //
    func createUser(pseudo: String, password: String) -> Bool{
        
        var requestDone : Bool = false
        
        var jsonData : Data?
        do {
            let newUser = createUserJSON(pseudo: pseudo, password: password)
            jsonData = try JSONEncoder().encode(newUser)
        } catch {
            print(error)
        }
        
        var responseDataOpt : [String: Any]?
        
        responseDataOpt = QueryService().request(url: "https://web-ios-api.herokuapp.com/users", httpMethod: "POST", httpBody: jsonData)
        
        if let responseData = responseDataOpt{
            if let message = responseData["message"] as? String{
                //print(message)
                
                if message == "Success"{
                    requestDone = true
                }
            }
        }
        return requestDone
    }
    
    
    
    //Log the User in the API
    //Store the token in a json file (AppDelegate)
    func login(pseudo: String, password: String) -> Bool{
        
        var requestDone : Bool = false
        var userToken : String = ""
        
        var jsonData : Data?
        do {
            let newUser = createUserJSON(pseudo: pseudo, password: password)
            jsonData = try JSONEncoder().encode(newUser)
        } catch {
            print(error)
        }
        
        var responseDataOpt : [String: Any]?
        
        responseDataOpt = QueryService().request(url: "https://web-ios-api.herokuapp.com/users/login", httpMethod: "POST", httpBody: jsonData)
        
        if let responseData = responseDataOpt{
            
            if let dataT = responseData["data"] as? [String:Any]{
                userToken = dataT["token"] as! String
                requestDone = true
            }
        }
        storeUser(token: userToken)
        return requestDone
        
    }
    
    
    //Clear the token stored in the JSON file
    /*func logout(){
        
    }*/
    
    //Store the token given by the API in a JSON file
    func storeUser(token: String){
        
        if !(isLogged()){
            
            if let url = self.fileLocation{
                do{
                    
                    let user : User = getUserById(idUser: 45)
                    let credentialJson = credentialsJSON(user: user, token: token)
                    
                    let jsonEncoder = JSONEncoder()
                    jsonEncoder.outputFormatting = .prettyPrinted
                    let data = try jsonEncoder.encode(credentialJson)
                    try data.write(to: url)
                }catch{
                    print(error)
                }
            }
        }
        
    }
    
    //Return True if a token is stored in the JSON file
    func isLogged() -> Bool{
        print(getToken() != nil)
        return (getToken() != nil)
    }
    
    
    //Return the Token stored in JSON file
    //Return nil if no token stored
    func getToken() -> String?{
        var token : String?
        
        if let url = self.fileLocation{
            do{
                let data = try Data(contentsOf: url)
                let jsonDecoder = JSONDecoder()
                let dataFromJson = try jsonDecoder.decode(credentialsJSON.self, from: data)
                token = dataFromJson.token
            }catch{
                print(error)
            }
        }
        return token
    }
    
    //Return the User stored in the JSON file
    func getUserLogged() -> User?{
        var user : User?
        
        if let url = self.fileLocation{
            do{
                let data = try Data(contentsOf: url)
                let jsonDecoder = JSONDecoder()
                let dataFromJson = try jsonDecoder.decode(credentialsJSON.self, from: data)
                user = dataFromJson.user
            }catch{
                print(error)
            }
        }
        return user
    }
    
    
}