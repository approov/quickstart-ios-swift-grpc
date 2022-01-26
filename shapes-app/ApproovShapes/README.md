How to generate protobuf implementation and how to build:

In a shell:
protoc shapes.proto --proto_path=. --plugin=/Users/johanness/bin/protoc-gen-swift --swift_opt=Visibility=Public --swift_out=.

protoc shapes.proto --proto_path=. --plugin=/Users/johanness/bin/protoc-gen-grpc-swift --grpc-swift_opt=Visibility=Public --grpc-swift_out=.


From Xcode 11 it is possible to add Swift Package dependencies to Xcode projects (https://help.apple.com/xcode/mac/current/#/devb83d64851) and link targets to products of those packages; this is the easiest way to integrate gRPC Swift with an existing xcodeproj.

Add
  
  https://github.com/approov/approov-service-urlsession