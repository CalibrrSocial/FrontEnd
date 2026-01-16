import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, ScanCommand } from "@aws-sdk/lib-dynamodb";

const dynamoClient = new DynamoDBClient({ region: process.env.REGION });
const db = DynamoDBDocumentClient.from(dynamoClient);

export const handler = async (event) => {
    try {
        console.log('🔍 DEBUG: Scanning Users table to see what emails exist...');
        
        const params = {
            TableName: process.env.USER_TABLE_NAME,
            Limit: 10  // Just get first 10 users
        };
        
        const command = new ScanCommand(params);
        const result = await db.send(command);
        
        console.log(`🔍 Found ${result.Items?.length || 0} users`);
        
        if (result.Items) {
            result.Items.forEach((user, index) => {
                console.log(`🔍 User ${index + 1}:`);
                console.log(`  - ID: ${user.id}`);
                console.log(`  - Email: ${user.email || 'NO EMAIL FIELD'}`);
                console.log(`  - First Name: ${user.firstName || 'NO FIRST NAME'}`);
                console.log(`  - Last Name: ${user.lastName || 'NO LAST NAME'}`);
                console.log(`  - All fields:`, Object.keys(user));
                console.log('---');
            });
        }
        
        return {
            statusCode: 200,
            body: JSON.stringify({
                message: "Database scan completed",
                userCount: result.Items?.length || 0,
                users: result.Items?.map(user => ({
                    id: user.id,
                    email: user.email,
                    firstName: user.firstName,
                    lastName: user.lastName,
                    hasEmail: !!user.email
                }))
            })
        };
        
    } catch (error) {
        console.error('🚨 Database scan error:', error);
        return {
            statusCode: 500,
            body: JSON.stringify({
                error: "Database scan failed",
                details: error.message
            })
        };
    }
};

// Usage: Deploy this as a Lambda function and run it to see what users exist 