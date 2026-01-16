let AWS = require('aws-sdk')
AWS.config.update({region: process.env.REGION})
let db = new AWS.DynamoDB.DocumentClient({region: process.env.REGION})

exports.handler = async (event) => {

    let userId = getUserId(event)
    let status = getRelationshipStatus(event)

    return getRelationships(userId, status).then(
        function(data){
            console.log('LELELELE: relationships: ' + JSON.stringify(data))
            return getUsers(data, userId)
        }
    ).then(
        function(data){
            console.log('LELELELE: users: ' + JSON.stringify(data))
            return response(200, data.Items || [])
        }
    )
}

function getUserId(request)
{
    return request.pathParameters.id
}

function getRelationshipStatus(request)
{
    return request.queryStringParameters.status
}

function getRelationships(userId, status)
{
    let params1 = {
        TableName: process.env.DB_TABLE_NAME_RELATIONSHIPS,
        IndexName: process.env.DB_TABLE_INDEX_RELATIONSHIPS_USER,
        KeyConditionExpression: 'userId = :userId and status = :status',
        ExpressionAttributeValues: {
          ':userId': userId,
          ':status': status
        }
    }
    let q1 = db.query(params1).promise()

    let params2 = {
        TableName: process.env.DB_TABLE_NAME_RELATIONSHIPS,
        IndexName: process.env.DB_TABLE_INDEX_RELATIONSHIPS_FRIEND,
        KeyConditionExpression: 'friendId = :friendId and status = :status',
        ExpressionAttributeValues: {
          ':friendId': userId,
          ':status': status
        }
    }
    let q2 = db.query(params2).promise()

    return q1.then(function(q1Data){ return q1.then(function(q2Data){ return (q1Data.Items || []).concat(q2Data.Items || [])}) })
}

function getUsers(relationships, userId)
{
      let userIds = getUserIds(relationships, userId)
      let params = {
          TableName: process.env.DB_TABLE_NAME_USERS,
          KeyConditionExpression: 'id = :id',
          ExpressionAttributeValues: {
              ':id' : userIds
          }
      }
      return db.query(params).promise()
    // let userIds = getUserIds(relationships, userId)
    // if (userIds.count == 0) {
    //     return null
    // }
    // let params = {
    //     RequestItems: {
    //         process.env.DB_TABLE_NAME_USERS : {
    //             Keys: userIds
    //         }
    //     }
    // }
    // return db.batchGet(params).promise()
}

function getUserIds(relationships, userId)
{
    var ids = []
    if (relationships) {
        for (let r of relationships) {
            if (r.userId === userId) {
                ids.append(r.friendId)
                // ids.append({'id' : r.friendId})
            }else{
                ids.append(r.userId)
                // ids.append({'id' : r.userId})
            }
        }
    }
    return ids
}

function response(statusCode, body)
{
    if (!(typeof body === 'string' || body instanceof String)) {
        return { statusCode, 'body': JSON.stringify(body) }
    }
    return { statusCode, body }
}
