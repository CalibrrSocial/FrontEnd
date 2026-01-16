let AWS = require('aws-sdk')
AWS.config.update({region: process.env.REGION})
let db = new AWS.DynamoDB.DocumentClient({region: process.env.REGION})

exports.handler = async (event) => {

    let userId = getUserId(event)
    let user = getUser(event)

    return updateUser(userId, user).then(
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

function getUser(request)
{
    return JSON.parse(request.body)
}

function updateUser(id, user)
{
    let params = {
        TableName: process.env.DB_TABLE_NAME,
        Key: { id },
        UpdateExpression: 'set #personal = :personal, #social = :social',
        ExpressionAttributeNames: {
          '#personal' : 'personalInfo',
          '#social' : 'socialInfo'
        },
        ExpressionAttributeValues: {
          ':personal' : user.personalInfo,
          ':social' : user.socialInfo
        },
        ReturnValues: 'ALL_NEW'
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
