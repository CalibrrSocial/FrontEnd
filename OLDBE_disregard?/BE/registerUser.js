let AWS = require('aws-sdk')
AWS.config.update({region: process.env.REGION})
let cognito = new AWS.CognitoIdentityServiceProvider({region: process.env.REGION})
let db = new AWS.DynamoDB.DocumentClient({region: process.env.REGION})

exports.handler = async (event) => {

    let email = event.email
    let phone = event.phone
    let password = event.password
    let firstName = event.firstName
    let lastName = event.lastName

    return createCognitoUser(email, phone, password).then(
        function(data){
            return createDBUser(data.User.Username, email, phone, firstName, lastName)
        }
    ).then(
        function(data){
            return authenticate(data)
        }
    ).then(
        function(data){
            return confirmUser(data.session, data.user, password)
        }
    ).then(
        function(data){
            return response(200, {
              token: data.data.AuthenticationResult.IdToken,
              refreshToken: data.data.AuthenticationResult.RefreshToken,
              user: data.user
            })
        }
    )
}

function getPayload(request)
{
    return JSON.parse(request.body)
}

function createCognitoUser(email, phone, password)
{
    let params = {
        UserPoolId: process.env.COGNITO_USER_POOL_ID,
        Username: email,
        UserAttributes: [
          {Name: 'email', Value: email},
          {Name: 'email_verified', Value: 'True'},
          {Name: 'phone_number', Value: phone},
          {Name: 'phone_number_verified', Value: 'True'}
        ],
        TemporaryPassword: process.env.COGNITO_TEMP_PASSWORD,
        MessageAction: 'SUPPRESS'
    }
    return cognito.adminCreateUser(params).promise()
}

function createDBUser(id, email, phone, firstName, lastName)
{
    let params = {
        TableName: process.env.DB_TABLE_NAME,
        Item: {
            id,
            email,
            phone,
            firstName,
            lastName,
            ghostMode: false,
            subscription: "free",
            dateRegistered: now()
        }
    }
    return db.put(params).promise().then(function(data){ return params.Item })
}

function now()
{
    return new Date().toISOString()
}

function authenticate(user)
{
      let params = {
          AuthFlow: 'ADMIN_NO_SRP_AUTH',
          ClientId: process.env.COGNITO_CLIENT_ID,
          UserPoolId: process.env.COGNITO_USER_POOL_ID,
          AuthParameters: {
            'USERNAME': user.id,
            'PASSWORD': process.env.COGNITO_TEMP_PASSWORD
          }
      }
    return cognito.adminInitiateAuth(params).promise().then(function(data){return {session: data.Session, user}})
}

function confirmUser(session, user, password)
{
      let params = {
          ChallengeName: 'NEW_PASSWORD_REQUIRED',
          ClientId: process.env.COGNITO_CLIENT_ID,
          UserPoolId: process.env.COGNITO_USER_POOL_ID,
          ChallengeResponses: {
            'USERNAME': user.email,
            'NEW_PASSWORD': password
          },
          Session: session
      }
      return cognito.adminRespondToAuthChallenge(params).promise().then(function(data){ return {data, user} })
}

function response(statusCode, body)
{
    if (!(typeof body === 'string' || body instanceof String)) {
        return { statusCode, 'body': JSON.stringify(body) }
    }
    return { statusCode, body }
}
