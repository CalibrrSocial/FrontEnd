# Calibrr

A social networking iOS application with a Laravel backend and AWS Lambda services.

## Project Structure

```
├── Calibrr-beRefactor/     # iOS App (Swift/Xcode)
├── EC2BACKENDGIT/          # Laravel Backend (PHP)
├── NewAWSBE/               # AWS Lambda Functions (Node.js)
├── calibrr-admin/          # Admin Dashboard (React)
├── docs/                   # Documentation
└── assets/                 # Brand assets
```

## iOS App Setup

1. Navigate to the iOS project folder:
   ```bash
   cd Calibrr-beRefactor
   ```

2. Install dependencies:
   ```bash
   pod install
   ```

3. Open `Calibrr.xcworkspace` in Xcode

## Backend Setup

See `EC2BACKENDGIT/README.md` for Laravel backend setup instructions.

## Lambda Functions

AWS Lambda functions are located in `NewAWSBE/`:
- `lambdas/` - Production Lambda function code
- `tests/` - Test scripts
- `debug/` - Debug utilities

## Admin Dashboard

React-based admin panel in `calibrr-admin/`:
```bash
cd calibrr-admin
npm install
npm start
```

## Documentation

All documentation is located in the `docs/` folder.

## Swagger Codegen

To generate the BE related code (APIs and Models):

1. Get OpenAPI Generator: https://github.com/OpenAPITools/openapi-generator

2. Run:
   ```bash
   java -jar modules/openapi-generator-cli/target/openapi-generator-cli.jar generate \
     -i pathToCalibrriOS/swagger.yaml \
     -c pathToCalibrriOS/swagger_gen_config.json \
     -g swift4 \
     -o pathToCalibrriOS/Calibrr/Generated
   ```

## Deploying to TestFlight

Using fastlane for deployment:

1. Install fastlane: https://docs.fastlane.tools/getting-started/ios/setup/

2. Deploy:
   ```bash
   cd Calibrr-beRefactor
   fastlane pushTestflight
   ```
