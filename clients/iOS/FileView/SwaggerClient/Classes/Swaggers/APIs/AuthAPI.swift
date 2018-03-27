//
// AuthAPI.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation
import Alamofire



open class AuthAPI {
    /**
     Delete an authorization (pending or allowed)
     
     - parameter key: (query) delete a key from access (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    open class func authDelete(key: String? = nil, completion: @escaping ((_ error: Error?) -> Void)) {
        authDeleteWithRequestBuilder(key: key).execute { (response, error) -> Void in
            completion(error);
        }
    }


    /**
     Delete an authorization (pending or allowed)
     - DELETE /auth
     
     - parameter key: (query) delete a key from access (optional)

     - returns: RequestBuilder<Void> 
     */
    open class func authDeleteWithRequestBuilder(key: String? = nil) -> RequestBuilder<Void> {
        let path = "/auth"
        let URLString = SwaggerClientAPI.basePath + path
        let parameters: [String:Any]? = nil

        let url = NSURLComponents(string: URLString)
        url?.queryItems = APIHelper.mapValuesToQueryItems(values:[
            "key": key
        ])
        

        let requestBuilder: RequestBuilder<Void>.Type = SwaggerClientAPI.requestBuilderFactory.getNonDecodableBuilder()

        return requestBuilder.init(method: "DELETE", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false)
    }

    /**
     List all pending authorizations
     
     - parameter completion: completion handler to receive the data and the error objects
     */
    open class func authGet(completion: @escaping ((_ data: Data?,_ error: Error?) -> Void)) {
        authGetWithRequestBuilder().execute { (response, error) -> Void in
            completion(response?.body, error);
        }
    }


    /**
     List all pending authorizations
     - GET /auth
     - examples: [{contentType=application/json, example=""}]

     - returns: RequestBuilder<HashMap> 
     */
    open class func authGetWithRequestBuilder() -> RequestBuilder<Data> {
        let path = "/auth"
        let URLString = SwaggerClientAPI.basePath + path
        let parameters: [String:Any]? = nil

        let url = NSURLComponents(string: URLString)


        let requestBuilder: RequestBuilder<Data>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false)
    }

    /**
     Requests authorization
     
     - parameter key: (body) key to stage for access (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    open class func authPost(key: Key? = nil, completion: @escaping ((_ error: Error?) -> Void)) {
        authPostWithRequestBuilder(key: key).execute { (response, error) -> Void in
            completion(error);
        }
    }


    /**
     Requests authorization
     - POST /auth
     
     - parameter key: (body) key to stage for access (optional)

     - returns: RequestBuilder<Void> 
     */
    open class func authPostWithRequestBuilder(key: Key? = nil) -> RequestBuilder<Void> {
        let path = "/auth"
        let URLString = SwaggerClientAPI.basePath + path
        let parameters = JSONEncodingHelper.encodingParameters(forEncodableObject: key)

        let url = NSURLComponents(string: URLString)


        let requestBuilder: RequestBuilder<Void>.Type = SwaggerClientAPI.requestBuilderFactory.getNonDecodableBuilder()

        return requestBuilder.init(method: "POST", URLString: (url?.string ?? URLString), parameters: parameters, isBody: true)
    }

    /**
     Activiate a pending authorization
     
     - parameter key: (body) key to add for access (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    open class func authPut(key: HashSet? = nil, completion: @escaping ((_ data: HashMap?,_ error: Error?) -> Void)) {
        authPutWithRequestBuilder(key: key).execute { (response, error) -> Void in
            completion(response?.body, error);
        }
    }


    /**
     Activiate a pending authorization
     - PUT /auth
     - examples: [{contentType=application/json, example=""}]
     
     - parameter key: (body) key to add for access (optional)

     - returns: RequestBuilder<HashMap> 
     */
    open class func authPutWithRequestBuilder(key: HashSet? = nil) -> RequestBuilder<HashMap> {
        let path = "/auth"
        let URLString = SwaggerClientAPI.basePath + path
        let parameters = JSONEncodingHelper.encodingParameters(forEncodableObject: key)

        let url = NSURLComponents(string: URLString)


        let requestBuilder: RequestBuilder<HashMap>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "PUT", URLString: (url?.string ?? URLString), parameters: parameters, isBody: true)
    }

}
