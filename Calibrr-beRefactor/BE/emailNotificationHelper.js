let AWS = require('aws-sdk')
AWS.config.update({region: process.env.REGION})
let lambda = new AWS.Lambda({region: process.env.REGION})

/**
 * Email Notification Helper
 * 
 * This utility provides simple functions to trigger email notifications
 * for different events in the Calibrr app. Use these functions when
 * implementing features in future milestones.
 */

/**
 * Send a profile liked notification email
 * @param {string} recipientUserId - ID of the user who received the like
 * @param {string} senderUserId - ID of the user who liked the profile
 */
async function sendProfileLikedNotification(recipientUserId, senderUserId) {
    return invokeEmailNotification({
        notificationType: 'profile_liked',
        recipientUserId: recipientUserId,
        senderUserId: senderUserId
    })
}

/**
 * Send an attribute liked notification email
 * @param {string} recipientUserId - ID of the user who received the like
 * @param {string} senderUserId - ID of the user who liked the attribute
 * @param {string} category - Category of the liked attribute (e.g., "Education", "Music")
 * @param {string} attribute - Specific attribute that was liked
 */
async function sendAttributeLikedNotification(recipientUserId, senderUserId, category, attribute) {
    return invokeEmailNotification({
        notificationType: 'attribute_liked',
        recipientUserId: recipientUserId,
        senderUserId: senderUserId,
        additionalData: {
            category: category,
            attribute: attribute
        }
    })
}

/**
 * Send a dead link reported notification email
 * @param {string} recipientUserId - ID of the user whose links were reported
 * @param {Array<string>} platforms - Array of platform names with broken links
 */
async function sendDeadLinkReportedNotification(recipientUserId, platforms) {
    return invokeEmailNotification({
        notificationType: 'dead_link_reported',
        recipientUserId: recipientUserId,
        additionalData: {
            platforms: platforms
        }
    })
}

/**
 * Internal function to invoke the email notification Lambda
 * @param {Object} payload - The notification payload
 */
async function invokeEmailNotification(payload) {
    let params = {
        FunctionName: process.env.EMAIL_NOTIFICATION_FUNCTION_NAME || 'sendEmailNotification',
        InvocationType: 'Event', // Asynchronous invocation
        Payload: JSON.stringify(payload)
    }
    
    try {
        let result = await lambda.invoke(params).promise()
        console.log('Email notification triggered:', result)
        return { success: true, result: result }
    } catch (error) {
        console.error('Error triggering email notification:', error)
        return { success: false, error: error.message }
    }
}

/**
 * Synchronous version - waits for email to be sent
 * Use this when you need to ensure the email was sent successfully
 * @param {Object} payload - The notification payload
 */
async function invokeEmailNotificationSync(payload) {
    let params = {
        FunctionName: process.env.EMAIL_NOTIFICATION_FUNCTION_NAME || 'sendEmailNotification',
        InvocationType: 'RequestResponse', // Synchronous invocation
        Payload: JSON.stringify(payload)
    }
    
    try {
        let result = await lambda.invoke(params).promise()
        let response = JSON.parse(result.Payload)
        console.log('Email notification sent:', response)
        return { success: true, response: response }
    } catch (error) {
        console.error('Error sending email notification:', error)
        return { success: false, error: error.message }
    }
}

module.exports = {
    sendProfileLikedNotification,
    sendAttributeLikedNotification,
    sendDeadLinkReportedNotification,
    invokeEmailNotification,
    invokeEmailNotificationSync
}

/**
 * USAGE EXAMPLES:
 * 
 * // In your profile liking Lambda function:
 * const emailHelper = require('./emailNotificationHelper')
 * await emailHelper.sendProfileLikedNotification(recipientUserId, senderUserId)
 * 
 * // In your attribute liking Lambda function:
 * await emailHelper.sendAttributeLikedNotification(
 *     recipientUserId, 
 *     senderUserId, 
 *     "Music", 
 *     "Hip Hop"
 * )
 * 
 * // In your dead link reporting Lambda function:
 * await emailHelper.sendDeadLinkReportedNotification(
 *     reportedUserId, 
 *     ["Instagram", "Snapchat"]
 * )
 */ 