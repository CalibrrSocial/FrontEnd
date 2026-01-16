import { LambdaClient, InvokeCommand } from "@aws-sdk/client-lambda";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, PutCommand, DeleteCommand } from "@aws-sdk/lib-dynamodb";

const lambdaClient = new LambdaClient({ region: process.env.REGION });
const dynamoClient = new DynamoDBClient({ region: process.env.REGION });
const db = DynamoDBDocumentClient.from(dynamoClient);

export const handler = async (event) => {
    try {
        console.log('🔍 DEBUG TEST: Testing email notification system...')
        
        // You can modify these test parameters
        let testRecipientUserId = event.testRecipientUserId || "test-recipient-123"
        let testSenderUserId = event.testSenderUserId || "test-sender-456"
        let testEmail = event.testEmail || "test@example.com"
        
        console.log(`🔍 DEBUG TEST: Testing with recipient: ${testRecipientUserId}, sender: ${testSenderUserId}, email: ${testEmail}`)
        
        // Create test users in the expected format
        await createTestUsers(testRecipientUserId, testSenderUserId, testEmail)
        
        // Test ONLY the Profile Liked Notification to debug the issue
        console.log('🔍 DEBUG TEST: Testing ONLY profile liked notification...')
        let profileLikedResult = await testNotification({
            notificationType: 'profile_liked',
            recipientUserId: testRecipientUserId,
            senderUserId: testSenderUserId
        })
        
        // Cleanup test users
        await cleanupTestUsers(testRecipientUserId, testSenderUserId)
        
        return response(200, {
            message: "Profile liked notification test completed",
            result: profileLikedResult,
            instructions: `Check the email address ${testEmail} for the profile liked test email. Also check CloudWatch logs for detailed debug info.`
        })
        
    } catch (error) {
        console.error('🔍 DEBUG TEST: Error testing email notifications:', error)
        return response(500, {
            error: "Failed to test email notifications",
            details: error.message,
            stack: error.stack
        })
    }
}

async function testNotification(payload) {
    console.log('🔍 DEBUG TEST: Calling email notification function with payload:', JSON.stringify(payload, null, 2));
    
    const params = {
        FunctionName: 'debugEmailNotification', // Point to our debug function
        InvocationType: 'RequestResponse',
        Payload: JSON.stringify(payload)
    }
    
    try {
        const command = new InvokeCommand(params);
        const result = await lambdaClient.send(command);
        const response = JSON.parse(new TextDecoder().decode(result.Payload));
        console.log(`🔍 DEBUG TEST: Notification test result:`, JSON.stringify(response, null, 2))
        return { success: true, response: response }
    } catch (error) {
        console.error(`🔍 DEBUG TEST: Notification test failed:`, error)
        return { success: false, error: error.message, stack: error.stack }
    }
}

async function createTestUsers(recipientUserId, senderUserId, testEmail) {
    console.log('🔍 DEBUG TEST: Creating test users...');
    
    // Create test recipient user
    let recipientUser = {
        id: recipientUserId,
        firstName: "Test",
        lastName: "Recipient",
        email: testEmail
    }
    
    // Create test sender user
    let senderUser = {
        id: senderUserId,
        firstName: "Test",
        lastName: "Sender",
        email: "testsender@example.com"
    }
    
    console.log('🔍 DEBUG TEST: Recipient user:', JSON.stringify(recipientUser, null, 2));
    console.log('🔍 DEBUG TEST: Sender user:', JSON.stringify(senderUser, null, 2));
    
    // Put test users in database
    await db.send(new PutCommand({
        TableName: process.env.USER_TABLE_NAME,
        Item: recipientUser
    }));
    
    await db.send(new PutCommand({
        TableName: process.env.USER_TABLE_NAME,
        Item: senderUser
    }));
    
    console.log('🔍 DEBUG TEST: Test users created successfully')
}

async function cleanupTestUsers(recipientUserId, senderUserId) {
    console.log('🔍 DEBUG TEST: Cleaning up test users...');
    
    // Delete test users
    await db.send(new DeleteCommand({
        TableName: process.env.USER_TABLE_NAME,
        Key: { id: recipientUserId }
    }));
    
    await db.send(new DeleteCommand({
        TableName: process.env.USER_TABLE_NAME,
        Key: { id: senderUserId }
    }));
    
    console.log('🔍 DEBUG TEST: Test users cleaned up successfully')
}

function response(statusCode, objectBody) {
    var body = objectBody
    if (!(typeof objectBody === 'string' || objectBody instanceof String)) {
        body = JSON.stringify(objectBody)
    }
    return { statusCode, body }
} 