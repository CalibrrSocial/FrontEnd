import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, GetCommand } from '@aws-sdk/lib-dynamodb';

const client = new DynamoDBClient({ region: process.env.REGION });
const db = DynamoDBDocumentClient.from(client);

export const handler = async (event) => {
    console.log('getUser v1.0 - Processing request:', JSON.stringify(event, null, 2));

    try {
        const userId = event.pathParameters.id;
        
        console.log('Fetching user with ID:', userId);

        // Get the user from DynamoDB
        const getParams = {
            TableName: process.env.DB_TABLE_NAME,
            Key: { id: userId }
        };

        console.log('DynamoDB get params:', JSON.stringify(getParams, null, 2));
        
        const result = await db.send(new GetCommand(getParams));
        
        console.log('DynamoDB get result:', JSON.stringify(result, null, 2));

        if (!result.Item) {
            return {
                statusCode: 404,
                headers: {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                    'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
                },
                body: JSON.stringify({
                    error: 'User not found'
                })
            };
        }

        return {
            statusCode: 200,
            headers: {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
            },
            body: JSON.stringify(result.Item)
        };
    } catch (error) {
        console.error('Error:', error);
        return {
            statusCode: 500,
            headers: {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
            },
            body: JSON.stringify({
                error: error.message,
                stack: error.stack
            })
        };
    }
};
