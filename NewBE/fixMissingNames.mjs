import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, UpdateCommand } from '@aws-sdk/lib-dynamodb';

const client = new DynamoDBClient({ region: process.env.REGION || 'us-east-1' });
const db = DynamoDBDocumentClient.from(client);

export const handler = async (event) => {
    console.log('fixMissingNames - Processing request:', JSON.stringify(event, null, 2));

    try {
        const { userId, firstName, lastName } = JSON.parse(event.body || '{}');
        
        if (!userId) {
            return {
                statusCode: 400,
                headers: {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                    'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
                },
                body: JSON.stringify({ error: 'userId is required' })
            };
        }

        if (!firstName || !lastName) {
            return {
                statusCode: 400,
                headers: {
                    'Access-Control-Allow-Origin': '*'
                },
                body: JSON.stringify({ error: 'Both firstName and lastName are required' })
            };
        }

        console.log('Fixing names for userId:', userId);
        console.log('Setting firstName:', firstName);
        console.log('Setting lastName:', lastName);

        const updateParams = {
            TableName: process.env.DB_TABLE_NAME || 'calibrr-users',
            Key: { id: userId },
            UpdateExpression: 'set firstName = :firstName, lastName = :lastName',
            ExpressionAttributeValues: {
                ':firstName': firstName,
                ':lastName': lastName
            },
            ReturnValues: 'ALL_NEW'
        };

        const result = await db.send(new UpdateCommand(updateParams));
        
        console.log('Successfully updated user names');
        console.log('New firstName:', result.Attributes.firstName);
        console.log('New lastName:', result.Attributes.lastName);

        return {
            statusCode: 200,
            headers: {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
            },
            body: JSON.stringify({
                success: true,
                message: 'Names updated successfully',
                userId: userId,
                firstName: result.Attributes.firstName,
                lastName: result.Attributes.lastName,
                updatedProfile: result.Attributes
            })
        };
        
    } catch (error) {
        console.error('Error updating names:', error);
        return {
            statusCode: 500,
            headers: {
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({
                error: error.message,
                stack: error.stack
            })
        };
    }
};

// Example usage:
// POST request body:
// {
//   "userId": "user-id-here",
//   "firstName": "John",
//   "lastName": "Doe"
// } 