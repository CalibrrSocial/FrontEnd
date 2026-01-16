let AWS = require('aws-sdk')
AWS.config.update({region: process.env.REGION})
let cognito = new AWS.CognitoIdentityServiceProvider({region: process.env.REGION})
let db = new AWS.DynamoDB.DocumentClient({region: process.env.REGION})

exports.handler = async (event) => {

    let username = event.username
    let password = event.password

    return authenticate(username, password).then(
        function(data){
            return getUser(data.id, data.token, data.refreshToken)
        }
    )
}

function authenticate(username, password, method)
{
    let params = {
        AuthFlow: 'USER_PASSWORD_AUTH',
        ClientId: process.env.COGNITO_CLIENT_ID,
        AuthParameters: {
            'USERNAME': username,
            'PASSWORD': password
        }
    }
    return cognito.initiateAuth(params).promise().then(
        function(authData){
            return cognito.getUser({AccessToken: authData.AuthenticationResult.AccessToken}).promise().then(
                function(data){
                    return {
                        id: data.Username,
                        token: authData.AuthenticationResult.IdToken,
                        refreshToken: authData.AuthenticationResult.RefreshToken
                    }
                }
            )
        }
    )
}

function getUser(id, token, refreshToken)
{
    let params = {
        TableName: process.env.DB_TABLE_NAME,
        Key: {
            id
        }
    }
    return db.get(params).promise().then(function(data){return {user: data.Item, token, refreshToken}})
}

function response(statusCode, objectBody)
{
    var body = objectBody
    if (!(typeof objectBody === 'string' || objectBody instanceof String)) {
        body = JSON.stringify(objectBody)
    }
    return { statusCode, body }
}
