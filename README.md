# Approov Quickstart: iOS Swift GRPC (Google Remote Procedure Call)

This quickstart is written specifically for native iOS apps that are written in Swift and making API calls using [GRPC-Swift](https://github.com/grpc/grpc-swift) that you wish to protect with Approov. If this is not your situation, then please check if there is a more relevant quickstart guide available.

This quickstart provides the basic steps for integrating Approov into your app. A more detailed step-by-step guide using a [Shapes App Example](https://github.com/approov/quickstart-ios-swift-grpc/blob/master/SHAPES-EXAMPLE.md) is also available.

To follow this guide you should have received an onboarding email for a trial or paid Approov account.

## ADDING APPROOV SERVICE DEPENDENCY
The Approov integration is available via the [`Swift Package Manager`](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app). This allows inclusion into the project by simply specifying a dependency in the `Add Package Dependency` Xcode option. Add the package `https://github.com/approov/approov-service-ios-swift-grpc.git` and then choose the relevant Approov SDK version, in this case 2.9.0, and select the `Exact Version` option:

![Add Package Dependency](readme-images/add-package-repository.png)

The package is actually an open source wrapper layer that allows you to easily use Approov with GRPC-Swift. This has a further dependency to the closed source [Approov SDK](https://github.com/approov/approov-ios-sdk).

## USING APPROOV SERVICE
The `ApproovClientConnection` class mimics the interface and functionality of the `ClientConnection` class provided by GRPC-Swift, but also initializes the Approov SDK and sets up pinning for the GRPC channel created by an `ApproovClientConnection.Builder`.

The `<enter-your-config-string-here>` is a custom string that configures your Approov account access. This will have been provided in your Approov onboarding email (it will be something like `#123456#K/XPlLtfcwnWkzv99Wj5VmAxo4CrU267J1KlQyoz8Qo=`).

The simplest way to use the `ApproovClientConnection` class is to find and replace all the `ClientConnection` with `ApproovClientConnection`.
```swift
let builder = ApproovClientConnection.usingTLSBackedByNIOSSL(approovConfigString: "<enter-your-config-string-here>", on: group!)
```

You can then create secure pinned GRPC channels by using the returned builder instead of the usual `ClientConnection.Builder`:
```swift
let channel = builder.connect(host: hostname, port: port)
```

Approov-enable GRPC clients by adding a `ClientInterceptor` factory. The `ClientInterceptor` factory should return an `ApproovClientInterceptor` for any GRPC call that requires to be protected with Approov. The `ApproovClientInterceptor` adds an `Approov-Token` header to a GRPC request.

```swift
// Provide the channel to the generated client.
client = Your_YourClient(channel: channel, interceptors: ApproovClientInterceptorFactory(hostname: hostname))
```

An `ApproovClientInterceptorFactory` looks similar to this template and must be implemented specifically to match the code generated by the GRPC `protoc` compiler for your protocol definitions (.proto files). In the example below all types starting with`Your_` would have been automatically generated. Note that an ApproovInterceptor needs to be returned only for GRPCs that should be protected with an Approov token.

```swift
import ApproovGRPC
import Foundation
import GRPC

// Example client interceptor factory to show how to create an ApproovClientInterceptorFactory for a specific
// ClientInterceptorFactoryProtocol.
class ApproovClientInterceptorFactory: Your_YourClientInterceptorFactoryProtocol {

    // hostname/domain for which to add an Approov token to protected GRPC requests
    let hostname: String

    init(hostname: String) {
        self.hostname = hostname
    }

    /// - Returns: Interceptors to use when invoking a GRPC that does not require Approov protection.
    func makeUnprotectedInterceptors() -> [ClientInterceptor<Your_UnprotectedRequest, Your_UnprotectedReply>] {
        return []
    }

    /// - Returns: Interceptors to use when invoking a GRPC that requires Approov protection.
    func makeProtectedInterceptors() -> [ClientInterceptor<Your_ProtectedRequest, Your_ProtectedReply>] {
        return [ApproovClientInterceptor<Your_ProtectedRequest, Your_ProtectedReply>(hostname: hostname)]
    }
}
```

## CHECKING IT WORKS
Initially you won't have set which API domains to protect, so the interceptor will not add anything. It will have called Approov though and made contact with the Approov cloud service. You will see logging from Approov saying `UNKNOWN_URL`.

Your Approov onboarding email should contain a link allowing you to access [Live Metrics Graphs](https://approov.io/docs/latest/approov-usage-documentation/#metrics-graphs). After you've run your app with Approov integration you should be able to see the results in the live metrics within a minute or so. At this stage you could even release your app to get details of your app population and the attributes of the devices they are running upon.

However, to actually protect your APIs there are some further steps you can learn about in [Next Steps](https://github.com/approov/quickstart-ios-swift-grpc/blob/master/NEXT-STEPS.md).
