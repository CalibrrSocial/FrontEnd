let AWS = require('aws-sdk')
AWS.config.update({region: process.env.REGION})
let db = new AWS.DynamoDB.DocumentClient({region: process.env.REGION})

exports.handler = async (event) => {

    let userId = getUserId(event)

    return getReports(userId).then(
        function(data){
            return response(200, data.Items || [])
        }
    )
}

function getUserId(request)
{
    return request.pathParameters.id
}

function getReports(userId)
{
    let params = {
        TableName: process.env.DB_TABLE_NAME,
        KeyConditionExpression: 'byId = :byId',
        ExpressionAttributeValues: {
            ':byId' : userId
        }
    }
    return db.query(params).promise()
}

function response(statusCode, body)
{
    if (!(typeof body === 'string' || body instanceof String)) {
        return { statusCode, 'body': JSON.stringify(body) }
    }
    return { statusCode, body }
}
