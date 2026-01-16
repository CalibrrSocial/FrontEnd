import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, GetCommand } from '@aws-sdk/lib-dynamodb';

const client = new DynamoDBClient({ region: process.env.REGION || 'us-east-1' });
const db = DynamoDBDocumentClient.from(client);

export const handler = async (event) => {
    console.log('debugUserProfile - Processing request:', JSON.stringify(event, null, 2));

    try {
        const userId = event.pathParameters?.id || event.queryStringParameters?.userId;
        
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

        console.log('Fetching profile for userId:', userId);

        const getParams = {
            TableName: process.env.DB_TABLE_NAME || 'calibrr-users',
            Key: { id: userId }
        };

        const result = await db.send(new GetCommand(getParams));
        
        if (!result.Item) {
            return {
                statusCode: 404,
                headers: {
                    'Access-Control-Allow-Origin': '*'
                },
                body: JSON.stringify({ error: 'User not found' })
            };
        }

        const user = result.Item;
        
        console.log('=== USER PROFILE DEBUG INFO ===');
        console.log('User ID:', user.id);
        console.log('First Name:', user.firstName || 'EMPTY/NULL');
        console.log('Last Name:', user.lastName || 'EMPTY/NULL');
        console.log('Email:', user.email || 'EMPTY/NULL');
        console.log('Phone:', user.phone || 'EMPTY/NULL');
        console.log('Picture Profile:', user.pictureProfile || 'EMPTY/NULL');
        console.log('Picture Cover:', user.pictureCover || 'EMPTY/NULL');
        console.log('Personal Info Bio:', user.personalInfo?.bio || 'EMPTY/NULL');
        console.log('Personal Info City:', user.personalInfo?.city || 'EMPTY/NULL');
        console.log('================================');

        return {
            statusCode: 200,
            headers: {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
            },
            body: JSON.stringify({
                userId: user.id,
                firstName: user.firstName || null,
                lastName: user.lastName || null,
                email: user.email || null,
                phone: user.phone || null,
                hasFirstName: !!(user.firstName && user.firstName.length > 0),
                hasLastName: !!(user.lastName && user.lastName.length > 0),
                fullProfile: user
            })
        };
        
    } catch (error) {
        console.error('Error:', error);
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