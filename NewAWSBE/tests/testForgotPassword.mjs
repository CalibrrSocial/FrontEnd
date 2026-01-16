import { handler as forgotPasswordHandler } from './forgotPassword.mjs';

export const handler = async (event) => {
    console.log('🧪 Testing forgot password functionality');
    
    // Test with your actual email
    const testEmail = event.testEmail || "your-email@example.com"; // Replace with your actual email
    
    console.log(`🧪 Testing forgot password for email: ${testEmail}`);
    
    // Create a mock event that matches what the frontend sends
    const mockEvent = {
        queryStringParameters: {
            email: testEmail
        }
    };
    
    console.log('🧪 Mock event:', JSON.stringify(mockEvent, null, 2));
    
    try {
        const result = await forgotPasswordHandler(mockEvent);
        console.log('🧪 Forgot password test result:', JSON.stringify(result, null, 2));
        
        return {
            statusCode: 200,
            body: JSON.stringify({
                message: "Forgot password test completed",
                result: result
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

// Usage instructions:
// 1. Deploy this function to AWS Lambda
// 2. Set environment variables: USER_TABLE_NAME, REGION
// 3. Test with: { "testEmail": "your-actual-email@example.com" }
// 4. Check CloudWatch logs for detailed output
// 5. Check your email for the password reset message 