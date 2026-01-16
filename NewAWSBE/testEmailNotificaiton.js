const { LambdaClient, InvokeCommand } = require("@aws-sdk/client-lambda");
const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, PutCommand, DeleteCommand } = require("@aws-sdk/lib-dynamodb");

const lambdaClient = new LambdaClient({ region: process.env.REGION });
const dynamoClient = new DynamoDBClient({ region: process.env.REGION });
const db = DynamoDBDocumentClient.from(dynamoClient);

exports.handler = async (event) => {
    try {
        console.log('Testing email notification system...')
        
        // You can modify these test parameters
        let testRecipientUserId = event.testRecipientUserId || "test-recipient-123"
        let testSenderUserId = event.testSenderUserId || "test-sender-456"
        let testEmail = event.testEmail || "test@example.com"
        
        console.log(`Testing with recipient: ${testRecipientUserId}, sender: ${testSenderUserId}, email: ${testEmail}`)
        
        // Create test users in the expected format
        await createTestUsers(testRecipientUserId, testSenderUserId, testEmail)
        
        // Test 1: Profile Liked Notification
        console.log('Testing profile liked notification...')
        let profileLikedResult = await testNotification({
            notificationType: 'profile_liked',
            recipientUserId: testRecipientUserId,
            senderUserId: testSenderUserId
        })
        
        // Test 2: Attribute Liked Notification
        console.log('Testing attribute liked notification...')
        let attributeLikedResult = await testNotification({
            notificationType: 'attribute_liked',
            recipientUserId: testRecipientUserId,
            senderUserId: testSenderUserId,
            additionalData: {
                category: "Music",
                attribute: "Hip Hop"
            }
        })
        
        // Test 3: Dead Link Reported Notification
        console.log('Testing dead link reported notification...')
        let deadLinkResult = await testNotification({
            notificationType: 'dead_link_reported',
            recipientUserId: testRecipientUserId,
            additionalData: {
                platforms: ["Instagram", "Snapchat", "TikTok"]
            }
        })
        
        // Cleanup test users
        await cleanupTestUsers(testRecipientUserId, testSenderUserId)
        
        return response(200, {
            message: "Email notification tests completed",
            results: {
                profileLiked: profileLikedResult,
                attributeLiked: attributeLikedResult,
                deadLinkReported: deadLinkResult
            },
            instructions: `Check the email address ${testEmail} for three test emails`
        })
        
    } catch (error) {
        console.error('Error testing email notifications:', error)
        return response(500, {
            error: "Failed to test email notifications",
            details: error.message
        })
    }
}

async function testNotification(payload) {
    const params = {
        FunctionName: process.env.EMAIL_NOTIFICATION_FUNCTION_NAME || 'sendEmailNotification',
        InvocationType: 'RequestResponse',
        Payload: JSON.stringify(payload)
    }
    
    try {
        const command = new InvokeCommand(params);
        const result = await lambdaClient.send(command);
        const response = JSON.parse(new TextDecoder().decode(result.Payload));
        console.log(`Notification test result:`, response)
        return { success: true, response: response }
    } catch (error) {
        console.error(`Notification test failed:`, error)
        return { success: false, error: error.message }
    }
}

async function createTestUsers(recipientUserId, senderUserId, testEmail) {
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
    
    // Put test users in database
    console.log('Creating recipient user with table:', process.env.USER_TABLE_NAME);
    await db.send(new PutCommand({
        TableName: process.env.USER_TABLE_NAME,
        Item: recipientUser
    }));
    
    console.log('Creating sender user with table:', process.env.USER_TABLE_NAME);
    await db.send(new PutCommand({
        TableName: process.env.USER_TABLE_NAME,
        Item: senderUser
    }));
    
    console.log('Test users created successfully')
}

async function cleanupTestUsers(recipientUserId, senderUserId) {
    // Delete test users
    await db.send(new DeleteCommand({
        TableName: process.env.USER_TABLE_NAME,
        Key: { id: recipientUserId }
    }));
    
    await db.send(new DeleteCommand({
        TableName: process.env.USER_TABLE_NAME,
        Key: { id: senderUserId }
    }));
    
    console.log('Test users cleaned up successfully')
}

function response(statusCode, objectBody) {
    var body = objectBody
    if (!(typeof objectBody === 'string' || objectBody instanceof String)) {
        body = JSON.stringify(objectBody)
    }
    return { statusCode, body }
}