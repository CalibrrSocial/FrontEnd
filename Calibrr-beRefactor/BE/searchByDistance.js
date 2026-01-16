let AWS = require('aws-sdk')
AWS.config.update({region: process.env.REGION})
let db = new AWS.DynamoDB.DocumentClient({region: process.env.REGION})

exports.handler = async (event) => {

    let position = getPosition(event)
    let minDistance = getMinDistance(event)
    let maxDistance = getMaxDistance(event)

    return findUsers(position, minDistance, maxDistance).then(
      //TODO: process users
        function(data){
            return response(200, processUsers(data.Items || []))
        }
    )
}

function getPosition(request)
{
    return request.queryStringParameters.position
}

function getMinDistance(request)
{
    return request.queryStringParameters.minDistance
}

function getMaxDistance(request)
{
    return request.queryStringParameters.maxDistance
}

function findUsers(position, minDistance, maxDistance)
{
    let minLat = getMinPosition(position.latitude)
    let maxLat = getMaxPosition(position.latitude)
    let minLon = getMinPosition(position.longitude)
    let maxLon = getMaxPosition(position.longitude)

    let params = {
        TableName: process.env.DB_TABLE_NAME,
        FilterExpression : 'ghostMode = :ghostMode AND (location.latitude BETWEEN :minLat AND :maxLat) AND (location.longitude BETWEEN :minLon AND :maxLon)',
        ExpressionAttributeValues : {
            ':ghostMode' : false,
            ':minLat' : minLat,
            ':maxLat' : maxLat,
            ':minLon' : minLon,
            ':maxLon' : maxLon
        }
    }
    return db.scan(params).promise()
}

function getMinPosition(pos)
{
    // 1lat degree is approx 69 miles
    return Math.floor(pos * 10) / 10.0 - 0.1
}

function getMaxPosition(pos)
{
    // 1lat degree is approx 69 miles
    return Math.ceil(pos * 10) / 10.0 + 0.1
}

function processUsers(users)
{
    var processedUsers = []

    for (let user of users){
        processedUsers.append(processUser(user))
    }
    return processedUsers
}

function processUser(user)
{
    var processedUser = user

    processedUser.likeCount = processedUser.likes.count
    delete processedUser.likes

    delete processedUser.subscription

    return processedUser
}

function response(statusCode, body)
{
    if (!(typeof body === 'string' || body instanceof String)) {
        return { statusCode, 'body': JSON.stringify(body) }
    }
    return { statusCode, body }
}
