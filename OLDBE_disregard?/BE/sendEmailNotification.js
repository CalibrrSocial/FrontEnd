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
                    <img src="cid:calibrr-logo" alt="Calibrr Social App" style="max-width: 200px; height: auto;">
                </div>
            </div>
        </body>
        </html>
    `
    
    switch (notificationType) {
        case 'profile_liked':
            if (!sender) throw new Error("Sender required for profile like notification")
            let senderName = `${sender.firstName} ${sender.lastName}`
            subject = `${senderName} just liked you!`
            let profileContent = `
                <h3>${senderName} just liked you!</h3>
                <p>${senderName} just liked your profile on the Calibrr Social App-- go like their profile back to return the favor!</p>
            `
            htmlBody = htmlTemplate.replace('{{CONTENT}}', profileContent)
            textBody = `${senderName} just liked your profile on the Calibrr Social App-- go like their profile back to return the favor!`
            break
            
        case 'attribute_liked':
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
            // Use different template for dead link (keeps original footer)
            let deadLinkTemplate = `
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
            htmlBody = deadLinkTemplate.replace('{{CONTENT}}', deadLinkContent)
            textBody = `Someone on the Calibrr Social app reported the social media link on your profile seems to be broken for the following platform(s): ${additionalData.platforms.join(', ')}. This means that no one can check you out, or hit you up on the platforms listed above, until you fix the links(s)! Try relinking these platforms to your Calibrr account by editing your profile. Make sure your username is correct, and/or that you copy and paste a good, functioning, and current link for that platform. Also test it yourself to make sure it is working!`
            break
            
        default:
            throw new Error(`Unknown notification type: ${notificationType}`)
    }
    
    return { subject, htmlBody, textBody }
}

function sendEmail(toEmail, subject, htmlBody, textBody) {
    // For profile and attribute emails with embedded logo
    if (htmlBody.includes('cid:calibrr-logo')) {
        return sendEmailWithAttachment(toEmail, subject, htmlBody, textBody)
    }
    
    // For simple emails without attachments (like dead link reports)
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

function sendEmailWithAttachment(toEmail, subject, htmlBody, textBody) {
    // Base64 encoded PNG logo
    let logoBase64 = 'iVBORw0KGgoAAAANSUhEUgAABzoAAAMhCAYAAACQebduAAAACXBIWXMAAC4jAAAuIwF4pT92AAAgAElEQVR4nOzdfYxe930f+HNF0pSG5MyQIilSsjxD6oWkLGmGpJ24qWWOHIhqXgqOCiTdtUbLMWoFTXY3ojcFmmZfNEq7TRZdRKN0sUnXbTWq5P2jBWoKKPoHCVRDtOhig6Ymt3mxncQmbcVJDSch7cSNbSl3cUZn5NFoSM7L89x77r2fj/BA8ov43OecM/M8z/2e3+8UZVkGAAAAAAAAgCa5xWwBAAAAAAAATSPoBAAAAAAAABpH0AkAAAAAAAA0jqATAAAAAAAAaBxBJwAAAAAAANA4gk4AAAAAAACgcQSdAAAAAAAAQOMIOgEAAAAAAIDGEXQCAAAAAAAAjSPoBAAAAAAAABpH0AkAAAAAAAA0jqATAAAAAAAAaBxBJwAAAAAAANA4gk4AAAAAAACgcQSdAAAAAAAAQOMIOgEAAAAAAIDGEXQCAAAAAAAAjSPoBAAAAAAAABpH0AkAAAAAAAA0jqATAAAAAAAAaBxBJwAAAAAAANA4gk4AAAAAAACgcQSdAAAAAAAAQOMIOgEAAAAAAIDGEXQCAAAAAAAAjSPoBAAAAAAAABpH0AkAAAAAAAA0jqATAAAAAAAAaBxBJwAAAAAAANA4gk4AAAAAAACgcQSdAAAAAAAAQOMIOgEAAAAAAIDGEXQCAAAAAAAAjSPoBAAAAAAAABpH0AkAAAAAAAA0jqATAAAAAAAAaBxBJwAAAAAAANA4gk4AAAAAAACgcQSdAAAAAAAAQOMIOgEAAAAAAIDGEXQCAAAAAAAAjSPoBAAAAAAAABpH0AkAAAAAAAA0jqATAAAAAAAAaBxBJwAAAAAAANA4gk4AAAAAAACgcQSdAAAAAAAAQOMIOgEAAAAAAIDGEXQCAAAAAAAAjSPoBAAAAAAAABpH0AkAAAAAAAA0jqATAAAAAAAAaBxBJwAAAAAAANA4gk4AAAAAAACgcQSdAAAAAAAAQOMIOgEAAAAAAIDGEXQCAAAAAAAAjSPoBAAAAAAAABpH0AkAAAAAAAA0jqATAAAAAAAAaBxBJwAAAAAAANA4gk4AAAAAAACgcQSdAAAAAAAAQOMIOgEAAAAAAIDGEXQCAAAAAAAAjSPoBAAAAAAAABpH0AkAAAAAAAA0jqATAAAAAAAAaBxBJwAAAAAAANA4gk4AAAAAAACgcQSdAAAAAAAAQOMIOgEAAAAAAIDGEXQCAAAAAAAAjSPoBAAAAAAAABpH0AkAAAAAAAA0jqATAAAAAAAAaBxBJwAAAAAAANA4gk4AAAAAAACgcQSdAAAAAAAAQOMIOgEAAAAAAIDGEXQCAAAAAAAAjSPoBAAAAAAAABpH0AkAAAAAAAA0jqATAAAAAAAAaBxBJwAAAAAAANA4gk4AAAAAAACgcQSdAAAAAAAAQOMIOgEAAAAAAIDGEXQCAAAAAAAAjSPoBAAAAAAAABpH0AkAAAAAAAA0jqATAAAAAAAAaBxBJwAAAAAAANA4gk4AAAAAAACgcQSdAAAAAAAAQOMIOgEAAAAAAIDGEXQCAAAAAAAAjSPoBAAAAAAAABpH0AkAAAAAAAA0jqATAAAAAAAAaBxBJwAAAAAAANA4gk4AAAAAAACgcQSdAAAAAAAAQOMIOgEAAAAAAIDGEXQCAAAAAAAAjSPoBAAAAAAAABpH0AkAAAAAAAA0jqATAAAAAAAAaBxBJwAAAAAAANA4gk4AAAAAAACgcQSdAAAAAAAAQOMIOgEAAAAAAIDGEXQCAAAAAAAAjSPoBAAAAAAAABpH0AkAAAAAAAA0jqATAAAAAAAAaBxBJwAAAAAAANA4gk4AAAAAAACgcQSdAAAAAAAAQOMIOgEAAAAAAIDGEXQCAAAAAAAAjSPoBAAAAAAAABpH0AkAAAAAAAA0jqATAAAAAAAAaBxBJwAAAAAAANA4gk4AAAAAAACgcQSdAAAAAAAAQOMIOgEAAAAAAIDGEXQCAAAAAAAAjSPoBAAAAAAAABpH0AkAAAAAAAA0jqATAAAAAAAAaBxBJwAAAAAAANA4gk4AAAAAAACgcQSdAAAAAAAAQOMIOgEAAAAAAIDGEXQCAAAAAAAAjSPoBAAAAAAAABpH0AkAAAAAAAA0jqATAAAAAAAAaBxBJwAAAAAAANA4gk4AAAAAAACgcQSdAAAAAAAAQOMIOgEAAAAAAIDGEXQCAAAAAAAAjSPoBAAAAAAAABpH0AkAAAAAAAA0jqATAAAAAAAAaBxBJwAAAAAAANA4gk4AAAAAAACgcQSdAAAAAAAAQOMIOgEAAAAAAIDGEXQCAAAAAAAAjSPoBAAAAAAAABpH0AkAAAAAAAA0jqATAAAAAAAAaBxB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'; // Actual PNG of Calibrr logo
    
    let rawMessage = `From: contact@calibrr.com
To: ${toEmail}
Subject: ${subject}
MIME-Version: 1.0
Content-Type: multipart/related; boundary="boundary123"

--boundary123
Content-Type: multipart/alternative; boundary="boundary456"

--boundary456
Content-Type: text/plain; charset=UTF-8

${textBody}

--boundary456
Content-Type: text/html; charset=UTF-8

${htmlBody}

--boundary456--

--boundary123
Content-Type: image/png; name="calibrr-logo.png"
Content-Transfer-Encoding: base64
Content-ID: <calibrr-logo>
Content-Disposition: inline; filename="calibrr-logo.png"

${logoBase64}

--boundary123--`

    let params = {
        Source: 'contact@calibrr.com',
        Destinations: [toEmail],
        RawMessage: {
            Data: rawMessage
        }
    }
    
    return ses.sendRawEmail(params).promise()
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