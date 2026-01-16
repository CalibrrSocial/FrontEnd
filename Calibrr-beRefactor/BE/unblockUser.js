let AWS = require('aws-sdk')
AWS.config.update({region: process.env.REGION})
let db = new AWS.DynamoDB.DocumentClient({region: process.env.REGION})

exports.handler = async (event) => {

    let userId = getUserId(event)
    let friendId = getFriendId(event)

    return deleteRelationship(userId, friendId).then(
        function(data){ return data },
        function(error){
            return deleteRelationship(friendId, userId)
        }
    ).then(
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

function deleteRelationship(userId, friendId)
{
    let params = {
        TableName: process.env.DB_TABLE_NAME,
        Key: {
            userId,
            friendId
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
