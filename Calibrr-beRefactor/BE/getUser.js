let AWS = require('aws-sdk')
AWS.config.update({region: process.env.REGION})
let db = new AWS.DynamoDB.DocumentClient({region: process.env.REGION})

exports.handler = async (event) => {

    let userId = getUserId(event)

    return getUser(userId).then(
        function(data) {
            return processUser(data.Item, userId)
        }
    ).then(
        function(user) {
            if (user) {
                return response(200, user)
            }
            return response(404, "User Id Not Found")
        }
    )
}

function getUserId(request)
{
    return request.pathParameters.id
}

function getUser(id)
{
    let params = {
        TableName: process.env.DB_TABLE_NAME,
        Key: {
          id
        }
    }
    return db.get(params).promise()
}

function processUser(user, userId)
{
    if (user) {
        var processedUser = user

        processedUser.likeCount = processedUser.likes.count
        delete processedUser.likes

        if (!(processedUser.id === userId)){
            delete processedUser.subscription
        }
        return processedUser
    }
    return null
}

function response(statusCode, body)
{
    if (!(typeof body === 'string' || body instanceof String)) {
        return { statusCode, 'body': JSON.stringify(body) }
    }
    return { statusCode, body }
}
