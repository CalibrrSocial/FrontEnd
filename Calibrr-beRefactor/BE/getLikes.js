let AWS = require('aws-sdk')
AWS.config.update({region: process.env.REGION})
let db = new AWS.DynamoDB.DocumentClient({region: process.env.REGION})

exports.handler = async (event) => {

    let userId = getUserId(event)

    return getLikes(userId).then(
        function(data){
            return response(200, data.Item.likes.count || 0)
        }
    )
}

function getUserId(request)
{
    return request.pathParameters.id
}

function getLikes(id)
{
    let params = {
        TableName: process.env.DB_TABLE_NAME,
        Key: { id }
    }
    return db.get(params).promise()
}

function response(statusCode, body)
{
    if (!(typeof body === 'string' || body instanceof String)) {
        return { statusCode, 'body': JSON.stringify(body) }
    }
    return { statusCode, body }
}
