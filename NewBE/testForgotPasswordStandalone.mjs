import { SESClient, SendEmailCommand } from "@aws-sdk/client-ses";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, GetCommand, UpdateCommand, ScanCommand } from "@aws-sdk/lib-dynamodb";
import crypto from 'crypto';

const sesClient = new SESClient({ region: process.env.REGION });
const dynamoClient = new DynamoDBClient({ region: process.env.REGION });
const db = DynamoDBDocumentClient.from(dynamoClient);

export const handler = async (event) => {
    console.log('🧪 Testing forgot password functionality - STANDALONE VERSION');
    
    // Test with the provided email
    const testEmail = event.testEmail || event.queryStringParameters?.email;
    
    if (!testEmail) {
        return {
            statusCode: 400,
            body: JSON.stringify({
                error: "Please provide testEmail in the event",
                example: { "testEmail": "your-email@example.com" }
            })
        };
    }
    
    console.log(`🧪 Testing forgot password for email: ${testEmail}`);
    
    try {
        // Run the actual forgot password logic
        const result = await forgotPasswordLogic(testEmail);
        
        console.log('🧪 Forgot password test result:', JSON.stringify(result, null, 2));
        
        return {
            statusCode: 200,
            body: JSON.stringify({
                message: "Forgot password test completed successfully!",
                result: result,
                instructions: "Check your email for the password reset message"
            })
        };
    } catch (error) {
        console.error('🧪 Forgot password test failed:', error);
        return {
            statusCode: 500,
            body: JSON.stringify({
                error: "Forgot password test failed",
                details: error.message
            })
        };
    }
};

// Forgot password logic (copied from forgotPassword.mjs)
async function forgotPasswordLogic(email) {
    console.log(`🔍 Forgot Password - Looking for user with email: ${email}`);
    
    // Find user by email
    const user = await getUserByEmail(email);
    if (!user) {
        console.log(`🔍 Forgot Password - User not found with email: ${email}`);
        throw new Error("User not found with that email address");
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
    
    return {
        statusCode: 200,
        message: "Reset message was sent via EMAIL to: " + email,
        tempPassword: tempPassword // Include for testing purposes
    };
}

async function getUserByEmail(email) {
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
            ":password": newPassword,
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