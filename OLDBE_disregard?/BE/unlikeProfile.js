let AWS = require('aws-sdk')
AWS.config.update({region: process.env.REGION})
let db = new AWS.DynamoDB.DocumentClient({region: process.env.REGION})

exports.handler = async (event) => {

    let userId = getUserId(event)
    let profileLikedId = getProfileLikedId(event)

    return getUser(profileLikedId).then(
        function(data){
            return removeLike(profileLikedId, data.Item.likes, userId)
        }
    ).then(
        function(data){
            return response(200, "OK")
        }
    )
}

function getUserId(request)
{
    return request.pathParameters.id
}

function getProfileLikedId(request)
{
    return request.queryStringParameters.profileLikedId
}

function getUser(id)
{
    let params = {
        TableName: process.env.DB_TABLE_NAME,
        Key: { id }
    }
    return db.get(params).promise()
}

function removeLike(profileLikedId, likes, userId)
{
    if (likes){
        var newLikes = likes
        let index = newLikes.indexOf(userId)
        if (index < 0) {
            return null
        }
        newLikes.splice(index, 1)
        return updateLikes(profileLikedId, newLikes)
    }
    return updateLikes(profileLikedId, [])
}

function updateLikes(id, likes)
{
    let params = {
        TableName: process.env.DB_TABLE_NAME,
        Key: { id },
        UpdateExpression: 'set #likes = :likes',
        ExpressionAttributeNames: {'#likes' : 'likes'},
        ExpressionAttributeValues: {
          ':likes' : likes
        }
    }
    return db.update(params).promise()
}

function response(statusCode, body)
{
    if (!(typeof body === 'string' || body instanceof String)) {
        return { statusCode, 'body': JSON.stringify(body) }
    }
    return { statusCode, body }
}
