let AWS = require('aws-sdk')
AWS.config.update({region: process.env.REGION})
let db = new AWS.DynamoDB.DocumentClient({region: process.env.REGION})

exports.handler = async (event) => {

    let userId = getUserId(event)
    let position = getPosition(event)

    return updateUser(userId, location).then(
        function(data) {
            if (data.Item) {
                return response(200, data.Item)
            }
            return response(404, "User Id Not Found")
        }
    )
}

function getUserId(request)
{
    return request.pathParameters.id
}

function getPosition(request)
{
    return JSON.parse(request.body)
}

function updateUser(id, position)
{
    let params = {
        TableName: process.env.DB_TABLE_NAME,
        Key: { id },
        UpdateExpression: 'set #l = :l, #t = :t',
        ExpressionAttributeNames: {
          '#l' : 'location',
          '#t' : 'locationTimestamp'
        },
        ExpressionAttributeValues: {
          ':l' : position,
          ':t' : now()
        },
        ReturnValues: 'ALL_NEW'
    }
    return db.update(params).promise()
}

function now()
{
    return new Date().toISOString()
}

function response(statusCode, body)
{
    if (!(typeof body === 'string' || body instanceof String)) {
        return { statusCode, 'body': JSON.stringify(body) }
    }
    return { statusCode, body }
}
