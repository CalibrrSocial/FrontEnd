let AWS = require('aws-sdk')
AWS.config.update({region: process.env.REGION})
let db = new AWS.DynamoDB.DocumentClient({region: process.env.REGION})

exports.handler = async (event) => {

    let userId = getUserId(event)
    let friendId = getFriendId(event)
    let status = getStatus(event)

    return updateRelationship(userId, friendId, status).then(
        function(data){
            return response(200, 'OK')
        }
    )
}

function getUserId(request)
{
    return request.pathParameters.id
}

function getFriendId(request)
{
    return request.pathParameters.friendId
}

function getStatus(request)
{
    return request.queryStringParameters.status
}

function updateRelationship(userId, friendId, status)
{
    let params = {
        TableName: process.env.DB_TABLE_NAME,
        Key: { 'userId' : friendId, 'friendId' : userId },
        UpdateExpression: 'set #s = :s, #d = :d',
        ExpressionAttributeNames: {
          '#s' : 'status',
          '#d' : (status === 'accepted' ? 'dateAccepted' : (status == 'rejected' ? 'dateRejected' : 'dateBlocked'))
        },
        ExpressionAttributeValues: {
          ':s' : status,
          ':d' : now()
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
