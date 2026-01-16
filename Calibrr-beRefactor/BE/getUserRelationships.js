let AWS = require('aws-sdk')
AWS.config.update({region: process.env.REGION})
let db = new AWS.DynamoDB.DocumentClient({region: process.env.REGION})

exports.handler = async (event) => {

    let userId = getUserId(event)

    return getRelationships(userId).then(
        function(data){
            return response(200, data.Items || [])
        }
    )
}

function getUserId(request)
{
    return request.pathParameters.id
}

function getRelationships(userId, status)
{
    let params1 = {
        TableName: process.env.DB_TABLE_NAME,
        IndexName: process.env.DB_TABLE_INDEX_USER,//'userId-status-index',
        KeyConditionExpression: 'userId = :userId and status = :status',
        ExpressionAttributeValues: {
          ':userId': userId,
          ':status': status
        }
    }
    let q1 = db.query(params).promise()

    let params2 = {
        TableName: process.env.DB_TABLE_NAME,
        IndexName: process.env.DB_TABLE_INDEX_FRIEND,//'friendId-status-index',
        KeyConditionExpression: 'friendId = :friendId and status = :status',
        ExpressionAttributeValues: {
          ':friendId': userId,
          ':status': status
        }
    }
    let q2 = db.query(params).promise()

    return q1.then(function(q1Data){ return q1.then(function(q2Data){ return (q1Data.Items || []).concat(q2Data.Items || [])}) })
}

function response(statusCode, body)
{
    if (!(typeof body === 'string' || body instanceof String)) {
        return { statusCode, 'body': JSON.stringify(body) }
    }
    return { statusCode, body }
}
