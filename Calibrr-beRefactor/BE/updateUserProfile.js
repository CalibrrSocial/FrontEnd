import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, UpdateCommand } from '@aws-sdk/lib-dynamodb';

const client = new DynamoDBClient({ region: process.env.REGION });
const db = DynamoDBDocumentClient.from(client);

export const handler = async (event) => {
    console.log('updateUserProfile v7.0 - Processing request:', JSON.stringify(event, null, 2));

    try {
        const userId = event.pathParameters.id;
        const user = JSON.parse(event.body);
        
        console.log('Extracted userId:', userId);
        console.log('User data received:', JSON.stringify(user, null, 2));

        // Build update expression dynamically based on what fields are provided
        let updateExpression = 'set ';
        let expressionAttributeValues = {};
        let expressionAttributeNames = {};
        let updateParts = [];

        // Always update personalInfo and socialInfo (core profile data)
        if (user.personalInfo) {
            updateParts.push('personalInfo = :personal');
            expressionAttributeValues[':personal'] = user.personalInfo;
        }

        if (user.socialInfo) {
            updateParts.push('socialInfo = :social');
            expressionAttributeValues[':social'] = user.socialInfo;
        }

        // Update location if provided
        if (user.location) {
            updateParts.push('#location = :location');
            expressionAttributeNames['#location'] = 'location';
            expressionAttributeValues[':location'] = user.location;
        }

        // Update courses if provided
        if (user.myCourses !== undefined) {
            updateParts.push('myCourses = :myCourses');
            expressionAttributeValues[':myCourses'] = user.myCourses;
        }

        // Update friends if provided
        if (user.myFriends !== undefined) {
            updateParts.push('myFriends = :myFriends');
            expressionAttributeValues[':myFriends'] = user.myFriends;
        }

        // Update image URLs if provided
        if (user.pictureProfile !== undefined) {
            updateParts.push('pictureProfile = :pictureProfile');
            expressionAttributeValues[':pictureProfile'] = user.pictureProfile;
        }

        if (user.pictureCover !== undefined) {
            updateParts.push('pictureCover = :pictureCover');
            expressionAttributeValues[':pictureCover'] = user.pictureCover;
        }

        updateExpression += updateParts.join(', ');

        const updateParams = {
            TableName: process.env.DB_TABLE_NAME,
            Key: { id: userId },
            UpdateExpression: updateExpression,
            ExpressionAttributeValues: expressionAttributeValues,
            ReturnValues: 'ALL_NEW'
        };

        // Only add ExpressionAttributeNames if we have any
        if (Object.keys(expressionAttributeNames).length > 0) {
            updateParams.ExpressionAttributeNames = expressionAttributeNames;
        }

        console.log('DynamoDB update params:', JSON.stringify(updateParams, null, 2));
        
        const result = await db.send(new UpdateCommand(updateParams));
        
        console.log('DynamoDB update result:', JSON.stringify(result, null, 2));

        return {
            statusCode: 200,
            headers: {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
            },
            body: JSON.stringify(result.Attributes)
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
