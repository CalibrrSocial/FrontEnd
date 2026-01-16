let AWS = require('aws-sdk')
AWS.config.update({region: process.env.REGION})
let db = new AWS.DynamoDB.DocumentClient({region: process.env.REGION})

exports.handler = async (event) => {

    let names = getNames(event)

    return findUsers(names).then(
      //TODO: process users
        function(data){
            return response(200, processUsers(data.Items || []))
        }
    )
}

function getNames(request)
{
    return request.queryStringParameters.name.toLowerCase().split(' ')
}

function findUsers(names)
{
    let params = {
        TableName: process.env.DB_TABLE_NAME,
        FilterExpression : 'ghostMode = :ghostMode AND contains(firstName = :names) or contains(lastName = :names)',
        ExpressionAttributeValues : {
          ':ghostMode' : false,
          ':names' : names
        }
    }
    return db.scan(params).promise()
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
