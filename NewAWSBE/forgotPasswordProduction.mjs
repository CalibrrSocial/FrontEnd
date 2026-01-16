import { SESClient, SendEmailCommand } from "@aws-sdk/client-ses";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, GetCommand, UpdateCommand, ScanCommand } from "@aws-sdk/lib-dynamodb";
import crypto from 'crypto';

const sesClient = new SESClient({ region: process.env.REGION });
const dynamoClient = new DynamoDBClient({ region: process.env.REGION });
const db = DynamoDBDocumentClient.from(dynamoClient);

export const handler = async (event) => {
    try {
        console.log('🔍 Forgot Password - Received event:', JSON.stringify(event, null, 2));
        
        // Get email from query parameters (to match frontend API call)
        const email = event.queryStringParameters?.email || event.queryStringParameters?.username;
        
        if (!email) {
            return response(400, "Email address is required");
        }
        
        console.log(`🔍 Forgot Password - Looking for user with email: ${email}`);
        
        // Find user by email
        const user = await getUserByEmail(email);
        if (!user) {
            console.log(`🔍 Forgot Password - User not found with email: ${email}`);
            return response(404, "User not found with that email address");
        }
        
        console.log(`🔍 Forgot Password - Found user: ${user.firstName} ${user.lastName} (ID: ${user.id})`);
        
        // Generate a temporary password
        const tempPassword = generateTemporaryPassword();
        console.log(`🔍 Forgot Password - Generated temporary password for user ${user.id}`);
        
        // Update user's password in database
        await updateUserPassword(user.id, tempPassword);
        console.log(`🔍 Forgot Password - Updated password in database for user ${user.id}`);
        
        // Send email with new password
        await sendPasswordResetEmail(email, user.firstName || 'User', tempPassword);
        console.log(`🔍 Forgot Password - Email sent successfully to ${email}`);
        
        return response(200, "Reset message was sent via EMAIL to: " + email);
        
    } catch (error) {
        console.error('🚨 Forgot Password Error:', error);
        return response(500, {
            error: "Failed to reset password",
            details: error.message
        });
    }
};

async function getUserByEmail(email) {
    // Since DynamoDB doesn't support querying by email efficiently without a GSI,
    // we'll need to scan the table. For production, consider adding a GSI on email.
    const params = {
        TableName: process.env.USER_TABLE_NAME,
        FilterExpression: "email = :email",
        ExpressionAttributeValues: {
            ":email": email
        }
    };
    
    console.log(`🔍 Scanning DynamoDB for email: ${email}`);
    const command = new ScanCommand(params);
    const result = await db.send(command);
    
    console.log(`🔍 Scan result: Found ${result.Items?.length || 0} users`);
    return result.Items && result.Items.length > 0 ? result.Items[0] : null;
}

function generateTemporaryPassword() {
    // Generate a secure 12-character temporary password
    const charset = "ABCDEFGHJKMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789";
    let password = "";
    
    for (let i = 0; i < 12; i++) {
        const randomIndex = crypto.randomInt(0, charset.length);
        password += charset[randomIndex];
    }
    
    return password;
}

async function updateUserPassword(userId, newPassword) {
    const params = {
        TableName: process.env.USER_TABLE_NAME,
        Key: {
            id: userId
        },
        UpdateExpression: "SET password = :password, passwordResetAt = :resetAt",
        ExpressionAttributeValues: {
            ":password": newPassword, // In production, this should be hashed
            ":resetAt": new Date().toISOString()
        }
    };
    
    const command = new UpdateCommand(params);
    await db.send(command);
}

async function sendPasswordResetEmail(toEmail, userName, tempPassword) {
    const subject = "Your Calibrr Password Reset";
    
    const htmlBody = `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <h2 style="color: #4A90E2;">Password Reset - Calibrr</h2>
            <p>Hi ${userName},</p>
            <p>You requested a password reset for your Calibrr account. Your temporary password is:</p>
            <div style="background-color: #f8f9fa; padding: 15px; border-radius: 5px; margin: 20px 0;">
                <h3 style="margin: 0; color: #333; text-align: center; font-family: monospace; letter-spacing: 2px;">
                    ${tempPassword}
                </h3>
            </div>
            <p><strong>Important:</strong> Please log in with this temporary password and change it to a new password immediately for security reasons.</p>
            <p>If you didn't request this password reset, please contact support immediately.</p>
            <p>Best regards,<br>The Calibrr Team</p>
        </div>
    `;
    
    const textBody = `
Hi ${userName},

You requested a password reset for your Calibrr account. 

Your temporary password is: ${tempPassword}

Important: Please log in with this temporary password and change it to a new password immediately for security reasons.

If you didn't request this password reset, please contact support immediately.

Best regards,
The Calibrr Team
    `;
    
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
    };
    
    const command = new SendEmailCommand(params);
    return await sesClient.send(command);
}

function response(statusCode, objectBody) {
    const body = typeof objectBody === 'string' ? objectBody : JSON.stringify(objectBody);
    return { 
        statusCode, 
        body,
        headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Allow-Methods': 'POST, GET, OPTIONS'
        }
    };
} 