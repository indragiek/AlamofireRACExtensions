## AlamofireRACExtensions
#### Extensions for using ReactiveCocoa (Swift) with Alamofire

This is a small set of extensions for using [Alamofire](https://github.com/Alamofire/Alamofire) with the [`swift-development` branch of ReactiveCocoa](https://github.com/reactivecocoa/reactivecocoa/tree/swift-development).

### Installation

#### [Carthage](https://github.com/Carthage/Carthage)

Add the following line to your Cartfile:

```
github "indragiek/AlamofireRACExtensions" >= 1.0
```

Note that `AlamofireRACExtensions.framework` doesn't copy its dependencies (Alamofire, ReactiveCocoa, LlamaKit) into the bundle, so you have to link and copy them in your own targets. This is so that you can use those dependencies in your own apps/libraries without them being duplicated. However, the versions of the dependencies that you link in your project must be ABI-compatible with the versions that `AlamofireRACExtensions.framework` links against.

#### Manual

Add `AlamofireRACExtensions.swift` to your project.

### API

The main method is `Alamofire.Manager.rac_request(request:serializer:)`:

```
public func rac_request(request: URLRequestConvertible, serializer: Request.Serializer) -> SignalProducer<(AnyObject, NSHTTPURLResponse), NSError>
```

There are convenience methods built on this one for getting responses as data, JSON, or property list. All methods return a `SignalProducer`, which means that:

* The HTTP request isn't started until `start()` has been called on the `SignalProducer`
* Each invocation of `start()` on the same `SignalProducer` causes a new HTTP request to be started

### Example

```
let manager = Manager(configuration: NSURLSessionConfiguration.defaultConfiguration())
let request = NSURLRequest(URL: NSURL(string: "http://httpbin.org/get")!)
manager.rac_JSONWithRequest(request)
    .start(next: { (object, _) in
        if let JSONDictionary = object as? [String: AnyObject] {
            println(JSONDictionary)
        } else {
            fatalError("JSON object is not a dictionary")
        }
    }, error: { error in
        println("Request failed with error \(error)")
    })
```        

The unit tests contain more usage examples.

### Contact

* Indragie Karunaratne
* [@indragie](http://twitter.com/indragie)
* [http://indragie.com](http://indragie.com)

### License

`AlamofireRACExtensions` is licensed under the MIT License. See `LICENSE` for more information.
