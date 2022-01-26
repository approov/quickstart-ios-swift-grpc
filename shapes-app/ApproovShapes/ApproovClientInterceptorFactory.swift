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
import Foundation
import GRPC


// Client interceptor factory for the Shapes app. This serves as an example of how to create an
// ApproovClientInterceptorFactory for the ClientInterceptorFactoryProtocols of other apps.
class ApproovClientInterceptorFactory: Shapes_ShapeClientInterceptorFactoryProtocol {

    // hostname/domain for which to add an Approov token to every GRPC request
    let hostname: String

    init(hostname: String) {
        self.hostname = hostname
    }

    /// - Returns: Interceptors to use when invoking 'hello' - a GRPC that does not require Approov protection.
    func makeHelloInterceptors() -> [ClientInterceptor<Shapes_HelloRequest, Shapes_HelloReply>] {
        return []
    }

    /// - Returns: Interceptors to use when invoking 'shape' - a GRPC that requires Approov protection.
    func makeShapeInterceptors() -> [ClientInterceptor<Shapes_ShapeRequest, Shapes_ShapeReply>] {
        return []
        // *** UNCOMMENT THE LINE BELOW FOR APPROOV (and comment the line above) ***
        // return [ApproovClientInterceptor<Shapes_ShapeRequest, Shapes_ShapeReply>(hostname: hostname)]
    }

}
