let AWS = require('aws-sdk')
AWS.config.update({region: process.env.REGION})
let cognito = new AWS.CognitoIdentityServiceProvider({region: process.env.REGION})

exports.handler = async (event) => {

    let username = getUsername(event)

    return requestPassword(username).then(
        function(data) {
            let info = data.CodeDeliveryDetails
            return response(200, "Reset message was sent via " + info.DeliveryMedium + " to: " + info.Destination)
        }
    )
}

function getUsername(request)
{
    return request.queryParameters.username
}

function requestPassword(username)
{
    let params = {
        ClientId: process.env.COGNITO_CLIENT_ID,
        Username: username
    }
    return cognito.forgotPassword(params).promise()
}

function response(statusCode, objectBody)
{
    var body = objectBody
    if (!(typeof objectBody === 'string' || objectBody instanceof String)) {
        body = JSON.stringify(objectBody)
    }
    return { statusCode, body }
}
