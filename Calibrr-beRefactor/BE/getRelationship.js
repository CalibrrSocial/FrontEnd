let AWS = require('aws-sdk')
AWS.config.update({region: process.env.REGION})
let db = new AWS.DynamoDB.DocumentClient({region: process.env.REGION})

exports.handler = async (event) => {

    let userId = getUserId(event)
    let friendId = getFriendId(event)

    return getRelationship(userId, friendId).then(
        function(data){
            if (data.Item){
                return response(200, data.Item)
            }
            return response(204, null)
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

function getRelationship(userId, friendId)
{
    let q1 = db.get(getRelationshipParams(userId, friendId)).promise()

    return q1.then(function(data){ return data || db.get(getRelationshipParams(friendId, userId)).promise()})
}

function getRelationshipParams(userId, friendId)
{
    return {
        TableName: process.env.DB_TABLE_NAME,
        Key: { userId, friendId }
    }
}

function response(statusCode, body)
{
    if (!(typeof body === 'string' || body instanceof String)) {
        return { statusCode, 'body': JSON.stringify(body) }
    }
    return { statusCode, body }
}
