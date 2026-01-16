let AWS = require('aws-sdk')
AWS.config.update({region: process.env.REGION})
let cognito = new AWS.CognitoIdentityServiceProvider({region: process.env.REGION})

exports.handler = async (event) => {

    let refreshToken = event.refreshToken

    return authenticate(refreshToken).then(
        function(data){
            return {
                token: data.AuthenticationResult.IdToken
            }
        }
    )
}

function authenticate(token)
{
    let params = {
        AuthFlow: 'REFRESH_TOKEN_AUTH',
        ClientId: process.env.COGNITO_CLIENT_ID,
        AuthParameters: {
            'REFRESH_TOKEN': token
        }
    }
    return cognito.initiateAuth(params).promise()
}
