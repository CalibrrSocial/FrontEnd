let AWS = require('aws-sdk')
AWS.config.update({region: process.env.REGION})
let db = new AWS.DynamoDB.DocumentClient({region: process.env.REGION})

exports.handler = async (event) => {

    let userId = getUserId(event)
    let userReport = getUserReport(event)

    return createReport(userId, userReport).then(
        function(data){
            return response(200, "OK")
        }
    )
}

function getUserId(request)
{
    return request.pathParameters.id
}

function getUserReport(request)
{
    return JSON.parse(request.body)
}

function createReport(byId, userReport)
{
    let params = {
        TableName: process.env.DB_TABLE_NAME,
        Item: {
            id: generateReportId(),
            byId,
            userId: userReport.userId,
            info: userReport.info,
            dateCreated: now()
        }
    }
    return db.put(params).promise()
}

function generateReportId()
{
    return "" + Date.now()
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
