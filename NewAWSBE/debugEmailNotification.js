const { SESClient, SendEmailCommand } = require("@aws-sdk/client-ses");
const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, GetCommand } = require("@aws-sdk/lib-dynamodb");

const sesClient = new SESClient({ region: process.env.REGION });
const dynamoClient = new DynamoDBClient({ region: process.env.REGION });
const db = DynamoDBDocumentClient.from(dynamoClient);

exports.handler = async (event) => {
    try {
        console.log('🔍 DEBUG: Received event:', JSON.stringify(event, null, 2));
        
        let notificationType = event.notificationType
        let recipientUserId = event.recipientUserId
        let senderUserId = event.senderUserId
        let additionalData = event.additionalData || {}
        
        console.log(`🔍 DEBUG: Processing ${notificationType} notification`);
        console.log(`🔍 DEBUG: Recipient ID: ${recipientUserId}, Sender ID: ${senderUserId}`);
        
        // Get recipient user details
        console.log(`🔍 DEBUG: Getting recipient user: ${recipientUserId}`);
        let recipient = await getUser(recipientUserId)
        console.log(`🔍 DEBUG: Recipient found:`, recipient ? 'YES' : 'NO');
        if (!recipient) {
            console.log('🔍 DEBUG: Recipient user not found');
            return response(404, "Recipient user not found")
        }
        
        // Get sender user details (for profile and attribute likes)
        let sender = null
        if (senderUserId) {
            console.log(`🔍 DEBUG: Getting sender user: ${senderUserId}`);
            sender = await getUser(senderUserId)
            console.log(`🔍 DEBUG: Sender found:`, sender ? 'YES' : 'NO');
            if (sender) {
                console.log(`🔍 DEBUG: Sender details: ${sender.firstName} ${sender.lastName}`);
            }
            if (!sender) {
                console.log('🔍 DEBUG: Sender user not found');
                return response(404, "Sender user not found")
            }
        }
        
        // Generate email content based on notification type
        console.log(`🔍 DEBUG: Generating email content for ${notificationType}`);
        let emailContent = generateEmailContent(notificationType, recipient, sender, additionalData)
        console.log(`🔍 DEBUG: Email subject: ${emailContent.subject}`);
        
        // Send email using AWS SES
        console.log(`🔍 DEBUG: Sending email to ${recipient.email}`);
        const result = await sendEmail(recipient.email, emailContent.subject, emailContent.htmlBody, emailContent.textBody)
        console.log(`🔍 DEBUG: Email sent successfully. MessageId: ${result.MessageId}`);
        
        return response(200, {
            message: "Email notification sent successfully",
            messageId: result.MessageId
        })
        
    } catch (error) {
        console.error('🔍 DEBUG: Error sending email notification:', error)
        console.error('🔍 DEBUG: Error stack:', error.stack)
        return response(500, {
            error: "Failed to send email notification",
            details: error.message,
            stack: error.stack
        })
    }
}

function generateEmailContent(notificationType, recipient, sender, additionalData) {
    console.log(`🔍 DEBUG: generateEmailContent called with type: ${notificationType}`);
    
    let subject = ""
    let htmlBody = ""
    let textBody = ""
    
    // Base HTML template styling
    let htmlTemplate = `
        <html>
        <head>
            <style>
                body { font-family: Arial, sans-serif; color: #333; line-height: 1.6; }
                .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                .header { text-align: center; margin-bottom: 30px; }
                .content { margin-bottom: 30px; }
                .footer { text-align: center; margin-top: 30px; }
                .app-link { color: #007bff; text-decoration: none; font-weight: bold; }
                .logo { text-align: center; margin-top: 40px; }
                ul { margin: 15px 0; padding-left: 20px; }
                li { margin: 5px 0; }
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h2>Calibrr Social App</h2>
                </div>
                <div class="content">
                    {{CONTENT}}
                </div>
                <div class="footer">
                    <p>Open the Calibrr Social <a href="https://apps.apple.com/us/app/calibrr-social/id1377015871" class="app-link">HERE</a></p>
                </div>
                <div class="logo">
                    <img src="https://calibrr-email-logo-1753077694.s3.amazonaws.com/calibrr-logo.png" alt="Calibrr Social App" style="max-width: 200px; height: auto;">
                </div>
            </div>
        </body>
        </html>
    `
    
    switch (notificationType) {
        case 'profile_liked':
            console.log(`🔍 DEBUG: Processing profile_liked case`);
            if (!sender) {
                console.log(`🔍 DEBUG: Error - no sender for profile_liked`);
                throw new Error("Sender required for profile like notification")
            }
            console.log(`🔍 DEBUG: Sender object:`, JSON.stringify(sender, null, 2));
            let senderName = `${sender.firstName} ${sender.lastName}`
            console.log(`🔍 DEBUG: Sender name: ${senderName}`);
            subject = `${senderName} just liked you!`
            let profileContent = `
                <h3>${senderName} just liked you!</h3>
                <p>${senderName} just liked your profile on the Calibrr Social App-- go like their profile back to return the favor!</p>
            `
            htmlBody = htmlTemplate.replace('{{CONTENT}}', profileContent)
            textBody = `${senderName} just liked your profile on the Calibrr Social App-- go like their profile back to return the favor!`
            console.log(`🔍 DEBUG: Profile liked content generated successfully`);
            break
            
        case 'attribute_liked':
            console.log(`🔍 DEBUG: Processing attribute_liked case`);
            if (!sender) throw new Error("Sender required for attribute like notification")
            if (!additionalData.category || !additionalData.attribute) {
                throw new Error("Category and attribute required for attribute like notification")
            }
            let attributeSenderName = `${sender.firstName} ${sender.lastName}`
            subject = `${attributeSenderName} just liked your '${additionalData.category}/${additionalData.attribute}'`
            let attributeContent = `
                <h3>${attributeSenderName} just liked your '${additionalData.category}/${additionalData.attribute}'</h3>
                <p>${attributeSenderName} just liked your '${additionalData.category}/${additionalData.attribute}' on the Calibrr Social App...looks like you caught their attention, or maybe have something in common? Go hit them back on the Calibrr Social App to return the favor!</p>
            `
            htmlBody = htmlTemplate.replace('{{CONTENT}}', attributeContent)
            textBody = `${attributeSenderName} just liked your '${additionalData.category}/${additionalData.attribute}' on the Calibrr Social App...looks like you caught their attention, or maybe have something in common? Go hit them back on the Calibrr Social App to return the favor!`
            break
            
        case 'dead_link_reported':
            console.log(`🔍 DEBUG: Processing dead_link_reported case`);
            if (!additionalData.platforms || !Array.isArray(additionalData.platforms)) {
                throw new Error("Platforms array required for dead link notification")
            }
            subject = "Fix your broken links!"
            let platformsList = additionalData.platforms.map(platform => `<li>${platform}</li>`).join('')
            let deadLinkContent = `
                <h3>Fix your broken links!</h3>
                <p>Someone on the Calibrr Social app reported the social media link on your profile seems to be broken for the following platform(s):</p>
                <ul>
                    ${platformsList}
                </ul>
                <p>This means that no one can check you out, or hit you up on the platforms listed above, until you fix the links(s)!</p>
                <p>Try relinking these platforms to your Calibrr account by editing your profile.</p>
                <p>Make sure your username is correct, and/or that you copy and paste a good, functioning, and current link for that platform.</p>
                <p>Also test it yourself to make sure it is working!</p>
            `
            // Use different template for dead link
            let deadLinkTemplate = `
                <html>
                <head>
                    <style>
                        body { font-family: Arial, sans-serif; color: #333; line-height: 1.6; }
                        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                        .header { text-align: center; margin-bottom: 30px; }
                        .content { margin-bottom: 30px; }
                        .footer { font-size: 12px; color: #666; text-align: center; margin-top: 30px; }
                        .app-link { color: #007bff; text-decoration: none; font-weight: bold; }
                        .logo { text-align: center; margin-top: 40px; }
                        ul { margin: 15px 0; padding-left: 20px; }
                        li { margin: 5px 0; }
                    </style>
                </head>
                <body>
                    <div class="container">
                        <div class="header">
                            <h2>Calibrr Social</h2>
                        </div>
                        <div class="content">
                            {{CONTENT}}
                        </div>
                        <div class="footer">
                            <p>Open the Calibrr Social <a href="https://apps.apple.com/us/app/calibrr-social/id1377015871" class="app-link">HERE</a></p>
                            <p>This email was sent from the Calibrr Social app.</p>
                        </div>
                        <div class="logo">
                            <img src="https://calibrr-email-logo-1753077694.s3.amazonaws.com/calibrr-logo.png" alt="Calibrr Social App" style="max-width: 200px; height: auto;">
                        </div>
                    </div>
                </body>
                </html>
            `
            htmlBody = deadLinkTemplate.replace('{{CONTENT}}', deadLinkContent)
            textBody = `Someone on the Calibrr Social app reported the social media link on your profile seems to be broken for the following platform(s): ${additionalData.platforms.join(', ')}. This means that no one can check you out, or hit you up on the platforms listed above, until you fix the links(s)! Try relinking these platforms to your Calibrr account by editing your profile. Make sure your username is correct, and/or that you copy and paste a good, functioning, and current link for that platform. Also test it yourself to make sure it is working!`
            break
            
        default:
            console.log(`🔍 DEBUG: Unknown notification type: ${notificationType}`);
            throw new Error(`Unknown notification type: ${notificationType}`)
    }
    
    console.log(`🔍 DEBUG: Email content generated. Subject: ${subject}`);
    return { subject, htmlBody, textBody }
}

async function sendEmail(toEmail, subject, htmlBody, textBody) {
    console.log(`🔍 DEBUG: sendEmail called with toEmail: ${toEmail}, subject: ${subject}`);
    
    const params = {
        Source: 'contact@calibrr.com',
        Destination: {
            ToAddresses: [toEmail]
        },
        Message: {
            Subject: {
                Data: subject,
                Charset: 'UTF-8'
            },
            Body: {
                Html: {
                    Data: htmlBody,
                    Charset: 'UTF-8'
                },
                Text: {
                    Data: textBody,
                    Charset: 'UTF-8'
                }
            }
        }
    }
    
    console.log(`🔍 DEBUG: SES params prepared, sending email...`);
    const command = new SendEmailCommand(params);
    const result = await sesClient.send(command);
    console.log(`🔍 DEBUG: SES send result:`, result);
    return result;
}

async function getUser(userId) {
    console.log(`🔍 DEBUG: getUser called with userId: ${userId}`);
    const params = {
        TableName: process.env.USER_TABLE_NAME,
        Key: {
            id: userId
        }
    }
    
    console.log(`🔍 DEBUG: DynamoDB params:`, params);
    const command = new GetCommand(params);
    const result = await db.send(command);
    console.log(`🔍 DEBUG: DynamoDB result:`, result);
    return result.Item;
}

function response(statusCode, objectBody) {
    var body = objectBody
    if (!(typeof objectBody === 'string' || objectBody instanceof String)) {
        body = JSON.stringify(objectBody)
    }
    return { statusCode, body }
} 