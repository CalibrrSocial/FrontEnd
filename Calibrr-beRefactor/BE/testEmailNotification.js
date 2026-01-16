let AWS = require('aws-sdk')
AWS.config.update({region: process.env.REGION})
let lambda = new AWS.Lambda({region: process.env.REGION})

exports.handler = async (event) => {
    try {
        console.log('Testing email notification system...')
        
        // You can modify these test parameters
        let testRecipientUserId = event.testRecipientUserId || "test-recipient-123"
        let testSenderUserId = event.testSenderUserId || "test-sender-456"
        let testEmail = event.testEmail || "test@example.com" // Change this to your email for testing
        
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
    let params = {
        FunctionName: process.env.EMAIL_NOTIFICATION_FUNCTION_NAME || 'sendEmailNotification',
        InvocationType: 'RequestResponse',
        Payload: JSON.stringify(payload)
    }
    
    try {
        let result = await lambda.invoke(params).promise()
        let response = JSON.parse(result.Payload)
        console.log(`Notification test result:`, response)
        return { success: true, response: response }
    } catch (error) {
        console.error(`Notification test failed:`, error)
        return { success: false, error: error.message }
    }
}

async function createTestUsers(recipientUserId, senderUserId, testEmail) {
    let db = new AWS.DynamoDB.DocumentClient({region: process.env.REGION})
    
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
    await db.put({
        TableName: process.env.USER_TABLE_NAME,
        Item: recipientUser
    }).promise()
    
    await db.put({
        TableName: process.env.USER_TABLE_NAME,
        Item: senderUser
    }).promise()
    
    console.log('Test users created successfully')
}

async function cleanupTestUsers(recipientUserId, senderUserId) {
    let db = new AWS.DynamoDB.DocumentClient({region: process.env.REGION})
    
    // Delete test users
    await db.delete({
        TableName: process.env.USER_TABLE_NAME,
        Key: { id: recipientUserId }
    }).promise()
    
    await db.delete({
        TableName: process.env.USER_TABLE_NAME,
        Key: { id: senderUserId }
    }).promise()
    
    console.log('Test users cleaned up successfully')
}

function response(statusCode, objectBody) {
    var body = objectBody
    if (!(typeof objectBody === 'string' || objectBody instanceof String)) {
        body = JSON.stringify(objectBody)
    }
    return { statusCode, body }
}

/**
 * HOW TO USE THIS TEST FUNCTION:
 * 
 * 1. Deploy this function to AWS Lambda
 * 2. Set up the same environment variables as the main email function
 * 3. Run the function with this payload:
 * {
 *   "testEmail": "your-email@example.com"
 * }
 * 
 * 4. Check your email for three test emails:
 *    - "Test Sender liked you!"
 *    - "Test Sender likes your 'Music/Hip Hop'"
 *    - "Fix your broken links!"
 * 
 * 5. Verify the emails look professional and match Nolan's specifications
 * 
 * TROUBLESHOOTING:
 * - If emails don't arrive, check AWS SES sending limits and verification status
 * - Check CloudWatch logs for detailed error messages
 * - Ensure contact@calibrr.com is verified in AWS SES
 * - Make sure the DynamoDB table name is correct in environment variables
 */ 