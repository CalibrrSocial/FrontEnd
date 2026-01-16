# Calibrr
Calibrr iOS app


## Workspace
To setup the workspace, pull the latest dev and run `pod install` in the project folder. Now open `Calibrr.xcworkspace` - you're ready to go.

## Swagger Codegen
To generate the BE related code (APIs and Models), make sure to get the OpenAPI Generator:
https://github.com/OpenAPITools/openapi-generator

Simply clone the master branch.

Then in the terminal, go to the top folder where you cloned the OpenAPI Generator and run the below command where you specify the location of the swagger.yaml and the output folder (assuming it's all in the Calibrr iOS Project directory):

`
java -jar modules/openapi-generator-cli/target/openapi-generator-cli.jar generate \
  -i pathToCalibrriOS/swagger.yaml \
  -c pathToCalibrriOS/swagger_gen_config.json \
  -g swift4 \
  -o pathToCalibrriOS/Calibrr/Generated
`

Assuming that pathToCalibrriOS should be something like `/Users/username/Calibrr-iOS`

## Deploying to Testflight
We're using fastlane to speed up the deployment process:

https://docs.fastlane.tools/getting-started/ios/setup/

Follow the above link's `Installing fastlane` to install it on your machine.

After that,  to deploy to TestFlight you have to go to the project folder in the terminal, and run `fastlane pushTestflight`

That's it.

There will be some prompts - asking for credentials to iTunesConnect - just follow the instructions on screen and fastlane will guide you through it.
