let AWS = require('aws-sdk')
AWS.config.update({region: process.env.REGION})
let ses = new AWS.SES({region: process.env.REGION})
let db = new AWS.DynamoDB.DocumentClient({region: process.env.REGION})

exports.handler = async (event) => {
    try {
        let notificationType = event.notificationType
        let recipientUserId = event.recipientUserId
        let senderUserId = event.senderUserId
        let additionalData = event.additionalData || {}
        
        // Get recipient user details
        let recipient = await getUser(recipientUserId)
        if (!recipient) {
            return response(404, "Recipient user not found")
        }
        
        // Get sender user details (for profile and attribute likes)
        let sender = null
        if (senderUserId) {
            sender = await getUser(senderUserId)
            if (!sender) {
                return response(404, "Sender user not found")
            }
        }
        
        // Generate email content based on notification type
        let emailContent = generateEmailContent(notificationType, recipient, sender, additionalData)
        
        // Send email using AWS SES
        return sendEmail(recipient.email, emailContent.subject, emailContent.htmlBody, emailContent.textBody).then(
            function(data) {
                return response(200, {
                    message: "Email notification sent successfully",
                    messageId: data.MessageId
                })
            }
        )
        
    } catch (error) {
        console.error('Error sending email notification:', error)
        return response(500, {
            error: "Failed to send email notification",
            details: error.message
        })
    }
}

function generateEmailContent(notificationType, recipient, sender, additionalData) {
    let subject = ""
    let htmlBody = ""
    let textBody = ""
    
    // Base HTML template styling (similar to password reset emails)
    let htmlTemplate = `
        <html>
        <head>
            <style>
                body { font-family: Arial, sans-serif; color: #333; line-height: 1.6; }
                .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                .header { text-align: center; margin-bottom: 30px; }
                .content { margin-bottom: 30px; }
                .footer { font-size: 12px; color: #666; text-align: center; margin-top: 30px; }
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
                    <p>This email was sent from the Calibrr Social app.</p>
                </div>
            </div>
        </body>
        </html>
    `
    
    switch (notificationType) {
        case 'profile_liked':
            if (!sender) throw new Error("Sender required for profile like notification")
            let senderName = `${sender.firstName} ${sender.lastName}`
            subject = `${senderName} liked you!`
            let profileContent = `
                <h3>${senderName} liked you!</h3>
                <p>${senderName} just liked your profile on the Calibrr Social app-- go like their profile back!</p>
            `
            htmlBody = htmlTemplate.replace('{{CONTENT}}', profileContent)
            textBody = `${senderName} just liked your profile on the Calibrr Social app-- go like their profile back!`
            break
            
        case 'attribute_liked':
            if (!sender) throw new Error("Sender required for attribute like notification")
            if (!additionalData.category || !additionalData.attribute) {
                throw new Error("Category and attribute required for attribute like notification")
            }
            let attributeSenderName = `${sender.firstName} ${sender.lastName}`
            subject = `${attributeSenderName} likes your '${additionalData.category}/${additionalData.attribute}'`
            let attributeContent = `
                <h3>${attributeSenderName} likes your '${additionalData.category}/${additionalData.attribute}'</h3>
                <p>${attributeSenderName} just liked your '${additionalData.category}/${additionalData.attribute}' on the Calibrr Social app...looks like you caught their attention, or maybe have something in common? Go hit them back on the Calibrr Social app!</p>
            `
            htmlBody = htmlTemplate.replace('{{CONTENT}}', attributeContent)
            textBody = `${attributeSenderName} just liked your '${additionalData.category}/${additionalData.attribute}' on the Calibrr Social app...looks like you caught their attention, or maybe have something in common? Go hit them back on the Calibrr Social app!`
            break
            
        case 'dead_link_reported':
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
            htmlBody = htmlTemplate.replace('{{CONTENT}}', deadLinkContent)
            textBody = `Someone on the Calibrr Social app reported the social media link on your profile seems to be broken for the following platform(s): ${additionalData.platforms.join(', ')}. This means that no one can check you out, or hit you up on the platforms listed above, until you fix the links(s)! Try relinking these platforms to your Calibrr account by editing your profile. Make sure your username is correct, and/or that you copy and paste a good, functioning, and current link for that platform. Also test it yourself to make sure it is working!`
            break
            
        default:
            throw new Error(`Unknown notification type: ${notificationType}`)
    }
    
    return { subject, htmlBody, textBody }
}

function sendEmail(toEmail, subject, htmlBody, textBody) {
    let params = {
        Source: 'contact@calibrr.com', // This will need to be verified in AWS SES
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
    
    return ses.sendEmail(params).promise()
}

function getUser(userId) {
    let params = {
        TableName: process.env.USER_TABLE_NAME,
        Key: {
            id: userId
        }
    }
    
    return db.get(params).promise().then(
        function(data) {
            return data.Item
        }
    )
}

function response(statusCode, objectBody) {
    var body = objectBody
    if (!(typeof objectBody === 'string' || objectBody instanceof String)) {
        body = JSON.stringify(objectBody)
    }
    return { statusCode, body }
} 