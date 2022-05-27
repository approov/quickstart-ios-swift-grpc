// MIT License
//
// Copyright (c) 2016-present, Critical Blue Ltd.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
// documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
// Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

// *** UNCOMMENT THE LINE BELOW FOR APPROOV ***
// import ApproovGRPC
import GRPC
import NIO
import UIKit


class ViewController: UIViewController {
    
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var statusTextView: UILabel!

    var shapes: Shapes_ShapeClient?
    var group: EventLoopGroup?

    // API key for grpc.shapes.approov.io:50051
    let apiKeyHeaderName = "Api-Key"
    let apiSecretKey = "yXClypapWNHIifHUWmBIyPFAm"
    // *** UNCOMMENT THE LINE BELOW FOR APPROOV SECRETS PROTECTION (and comment the line above) ***
    // let apiSecretKey = "shapes_api_key_placeholder"

    deinit {
        // Make sure the group is shutdown when we're done with it.
        try! group?.syncShutdownGracefully()
    }

    override func viewDidLoad() {
        // *** UNCOMMENT THE LINE BELOW FOR APPROOV ***
        // try! ApproovService.initialize(config: "<enter-your-config-string-here>")

        // Set up an EventLoopGroup for the connection to run on
        // See: https://github.com/apple/swift-nio#eventloops-and-eventloopgroups
        group = MultiThreadedEventLoopGroup(numberOfThreads: 1)

        // Open GRPC channel
        let hostname = "grpc.shapes.approov.io"
        let port = 50051
        let builder = ClientConnection.usingTLSBackedByNIOSSL(on: group!)
        // *** UNCOMMENT THE LINE BELOW FOR APPROOV (and comment the line above) ***
        // let builder = ApproovClientConnection.usingTLSBackedByNIOSSL(on: group!)
        let channel = builder.connect(host: hostname, port: port)

        // Provide the channel to the generated client.
        shapes = Shapes_ShapeClient(
            channel: channel,
            interceptors: ClientInterceptorFactory(
                hostname: hostname, apiKeyHeaderName: apiKeyHeaderName, apiKey: apiSecretKey)
        )
        // *** UNCOMMENT THE LINE BELOW FOR APPROOV SECRETS PROTECTION ***
        // ApproovService.addSubstitutionHeader(header: apiKeyHeaderName, prefix: nil)

        super.viewDidLoad()
    }

    // Check unprotected hello endpoint
    @IBAction func checkHello() {
        // Display busy screen
        DispatchQueue.main.async {
            self.statusImageView.image = UIImage(named: "approov")
            self.statusTextView.text = "Checking connectivity..."
        }

        // Run RPC asynchronously
        let callbackQueue = DispatchQueue(label: "io.approov.helloCallbackQueue")
        callbackQueue.async {
            // Create the request
            let helloRequest = Shapes_HelloRequest()

            // Make the RPC call to the server.
            let helloRPC = self.shapes!.hello(helloRequest)

            // wait() on the response
            let message: String
            let image: UIImage?
            do {
                _ = try helloRPC.response.wait()
                // Successful response
                message = "OK"
                image = UIImage(named: "hello")
            } catch {
                // Error response
                message = "Error: \(error)"
                image = UIImage(named: "confused")
            }
            NSLog("Hello: \(message)")
            // Display the image on screen using the main queue
            DispatchQueue.main.async {
                self.statusImageView.image = image
                self.statusTextView.text = message
            }
        }
    }
    
    // Check Approov-protected shapes endpoint
    @IBAction func checkShape() {
        // Display busy screen
        DispatchQueue.main.async {
            self.statusImageView.image = UIImage(named: "approov")
            self.statusTextView.text = "Checking app authenticity..."
        }

        // Run RPC asynchronously
        let callbackQueue = DispatchQueue(label: "io.approov.shapeCallbackQueue")
        callbackQueue.async {
            // Make the remote procedure call to the server.
            let shapeRPC = self.shapes!.shape(Shapes_ShapeRequest())
            // *** UNCOMMENT THE LINE BELOW FOR APPROOV API PROTECTION (and comment the line above) ***
            // let shapeRPC = self.shapes!.approovShape(Shapes_ApproovShapeRequest())

            // wait() on the response
            var message: String
            let image: UIImage?
            do {
                let shapeResponse = try shapeRPC.response.wait()
                // Successful response
                message = "Approoved!"
                switch shapeResponse.message {
                case "circle", "Circle":
                    image = UIImage(named: "Circle")
                case "rectangle", "Rectangle":
                    image = UIImage(named: "Rectangle")
                case "square", "Square":
                    image = UIImage(named: "Square")
                case "triangle", "Triangle":
                    image = UIImage(named: "Triangle")
                default:
                    message = "Approoved: unknown shape '\(shapeResponse.message)'"
                    image = UIImage(named: "confused")
                }
            } catch {
                // Error response
                message = "Error: \(error)"
                image = UIImage(named: "confused")
            }
            NSLog("Shape: \(message)")

            // Display the image on screen using the main queue
            DispatchQueue.main.async {
                self.statusImageView.image = image
                self.statusTextView.text = message
            }
        }
    }

}
