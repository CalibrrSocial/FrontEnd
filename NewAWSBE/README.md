# Calibrr AWS Lambda Functions

AWS Lambda functions for the Calibrr backend services.

## Structure

```
├── lambdas/                # Production Lambda functions
│   ├── emailNotificationFinal.js
│   ├── forgotPassword.mjs
│   ├── forgotPasswordProduction.mjs
│   ├── getUser.mjs
│   └── updateUserProfile.mjs
├── tests/                  # Test scripts
│   ├── testEmailNotificaiton.js
│   ├── testForgotPassword.mjs
│   └── testForgotPasswordStandalone.mjs
└── debug/                  # Debug utilities
    ├── debugDatabaseUsers.mjs
    ├── debugEmailNotification.js
    ├── debugTestEmail-esm.js
    ├── debugTestEmail.js
    ├── debugUserProfile.mjs
    └── fixMissingNames.mjs
```

## Deployment

Lambda functions are deployed via AWS Console or AWS CLI.

## Environment Variables

Required environment variables for Lambda functions:
- `REGION` - AWS region (us-east-1)
- `DYNAMODB_TABLE` - DynamoDB table name
- `SES_FROM_EMAIL` - SES verified sender email

