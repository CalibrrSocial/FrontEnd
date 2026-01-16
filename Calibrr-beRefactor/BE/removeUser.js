let AWS = require('aws-sdk')
AWS.config.update({region: process.env.REGION})
let db = new AWS.DynamoDB.DocumentClient({region: process.env.REGION})

exports.handler = async (event) => {

    let userId = event.pathParameters.id

    return removeUser(userId).then(
        function(data){
            return response(200, "OK")
        }
    )
}
//TODO: REMOVE FROM COGNITO TOO!
function removeUser(id)
{
    let params = {
        TableName: process.env.DB_TABLE_NAME,
        Key: {
            id
        }
    }
    return db.delete(params).promise()
}

function response(statusCode, body)
{
    if (!(typeof body === 'string' || body instanceof String)) {
        return { statusCode, 'body': JSON.stringify(body) }
    }
    return { statusCode, body }
}
