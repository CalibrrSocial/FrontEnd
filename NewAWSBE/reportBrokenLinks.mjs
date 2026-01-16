import { LambdaClient, InvokeCommand } from "@aws-sdk/client-lambda";

const REGION = process.env.REGION || process.env.AWS_REGION || "us-east-1";
const EMAIL_LAMBDA_NAME = process.env.EMAIL_LAMBDA_NAME || "emailNotificationFinal";

const lambdaClient = new LambdaClient({ region: REGION });

export const handler = async (event) => {
  try {
    console.log("🔍 Received broken link report event:", JSON.stringify(event, null, 2));
    
    // Parse the event body if it's a string (API Gateway format)
    let body;
    if (typeof event.body === "string") {
      body = JSON.parse(event.body);
    } else {
      body = event.body || event;
    }
    
    const { platforms, recipientEmail, reporterName } = body;
    
    // Validate required fields
    if (!platforms || !Array.isArray(platforms) || platforms.length === 0) {
      console.error("Missing or invalid platforms array");
      return {
        statusCode: 400,
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Headers": "Content-Type,Authorization",
          "Access-Control-Allow-Methods": "POST,OPTIONS"
        },
        body: JSON.stringify({ error: "platforms array is required" })
      };
    }
    
    if (!recipientEmail) {
      console.error("Missing recipientEmail");
      return {
        statusCode: 400,
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Headers": "Content-Type,Authorization",
          "Access-Control-Allow-Methods": "POST,OPTIONS"
        },
        body: JSON.stringify({ error: "recipientEmail is required" })
      };
    }
    
    if (!reporterName) {
      console.error("Missing reporterName");
      return {
        statusCode: 400,
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Headers": "Content-Type,Authorization",
          "Access-Control-Allow-Methods": "POST,OPTIONS"
        },
        body: JSON.stringify({ error: "reporterName is required" })
      };
    }
    
    // Prepare payload for emailNotificationFinal Lambda
    const emailPayload = {
      notificationType: "dead_link_reported",
      additionalData: {
        recipientEmail: recipientEmail,
        platforms: platforms,
        reporterName: reporterName
      }
    };
    
    console.log("📧 Invoking emailNotificationFinal Lambda with payload:", JSON.stringify(emailPayload, null, 2));
    
    // Invoke the emailNotificationFinal Lambda function
    const invokeCommand = new InvokeCommand({
      FunctionName: EMAIL_LAMBDA_NAME,
      InvocationType: "Event", // Async invocation
      Payload: JSON.stringify(emailPayload)
    });
    
    const response = await lambdaClient.send(invokeCommand);
    console.log("✅ Email Lambda invoked successfully:", response);
    
    return {
      statusCode: 200,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "Content-Type,Authorization",
        "Access-Control-Allow-Methods": "POST,OPTIONS"
      },
      body: JSON.stringify({ 
        success: true, 
        message: "Broken link report submitted successfully",
        platforms: platforms,
        recipientEmail: recipientEmail
      })
    };
    
  } catch (error) {
    console.error("❌ Error in reportBrokenLinks Lambda:", error);
    
    return {
      statusCode: 500,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "Content-Type,Authorization",
        "Access-Control-Allow-Methods": "POST,OPTIONS"
      },
      body: JSON.stringify({ 
        error: "Failed to process broken link report",
        details: error.message 
      })
    };
  }
};
