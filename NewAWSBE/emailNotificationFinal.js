const { SESClient, SendEmailCommand } = require("@aws-sdk/client-ses");

const REGION = process.env.REGION || process.env.AWS_REGION || "us-east-1";
const EMAIL_FROM = process.env.SYSTEM_EMAIL_FROM || "contact@calibrr.com";

const sesClient = new SESClient({ region: REGION });

exports.handler = async (event) => {
  try {
    const payload = typeof event === "string" ? JSON.parse(event) : event;
    console.log("🔍 Received event:", JSON.stringify(payload, null, 2));

    const notificationType = payload?.notificationType;
    const ad = payload?.additionalData || {};

    if (notificationType === "profile_liked") {
      const recipientEmail = ad.recipientEmail;
      const senderFirstName = ad.senderFirstName || "";
      const senderLastName = ad.senderLastName || "";
      if (!recipientEmail) {
        console.error("Missing recipientEmail in additionalData");
        return response(400, { error: "recipientEmail missing" });
      }

      const senderName = [senderFirstName, senderLastName].filter(Boolean).join(" ") || "Someone";
      const subject = `${senderName} just liked you!`;
      const htmlBody = baseHtml().replace(
        "{{CONTENT}}",
        `
          <h3>${senderName} just liked you!</h3>
          <p>${senderName} just liked your profile on Calibrr Social-- go like their profile back to return the favor!</p>
        `.trim()
      );
      const textBody = `${senderName} just liked your profile on Calibrr Social -- go like their profile back to return the favor!`;

      const res = await sendEmail(recipientEmail, subject, htmlBody, textBody);
      return response(200, { ok: true, messageId: res.MessageId });
    }

    if (notificationType === "dead_link_reported") {
      const platforms = Array.isArray(ad.platforms) ? ad.platforms : [];
      const recipientEmail = ad.recipientEmail;
      if (!recipientEmail) return response(400, { error: "recipientEmail missing" });
      const subject = "Fix your broken links!";
      const list = platforms.map((p) => `<li>${p}</li>`).join("");
      const htmlBody = deadLinkHtml().replace(
        "{{CONTENT}}",
        `
          <h3>Fix your broken links!</h3>
          <p>Someone on the Calibrr Social app reported the social media link on your profile seems to be broken for the following platform(s):</p>
          <ul>${list}</ul>
          <p>Please relink these platforms in your profile settings.</p>
        `.trim()
      );
      const textBody = `Broken links reported for: ${platforms.join(", ")}. Please relink in your profile.`;
      const res = await sendEmail(recipientEmail, subject, htmlBody, textBody);
      return response(200, { ok: true, messageId: res.MessageId });
    }

    console.log(`ℹ️ Unknown or unsupported notificationType: ${notificationType}`);
    return response(200, { ok: true, skipped: true });
  } catch (e) {
    console.error("emailNotificationFinal error", e);
    return response(500, { error: "Failed to send email", details: e.message });
  }
};

function baseHtml() {
  return `
    <html><head><style>
      body { font-family: Arial, sans-serif; color: #333; line-height: 1.6; }
      .container { max-width: 600px; margin: 0 auto; padding: 20px; }
      .header { text-align: center; margin-bottom: 30px; }
      .content { margin-bottom: 30px; }
      .footer { text-align: center; margin-top: 30px; }
      .app-link { color: #007bff; text-decoration: none; font-weight: bold; }
      .logo { text-align: center; margin-top: 40px; }
    </style></head><body>
      <div class="container">
        <div class="header"><h2>Calibrr Social App</h2></div>
        <div class="content">{{CONTENT}}</div>
        <div class="footer">
          <p>Open Calibrr Social <a href="https://apps.apple.com/us/app/calibrr-social/id1377015871" class="app-link">HERE</a></p>
        </div>
        <div class="logo">
          <img src="https://calibrr-email-logo-1753077694.s3.amazonaws.com/calibrr-logo.png" alt="Calibrr Social App" style="max-width:200px;height:auto;">
        </div>
      </div>
    </body></html>
  `;
}

function deadLinkHtml() {
  return `
    <html><head><style>
      body { font-family: Arial, sans-serif; color: #333; line-height: 1.6; }
      .container { max-width: 600px; margin: 0 auto; padding: 20px; }
      .header { text-align: center; margin-bottom: 30px; }
      .content { margin-bottom: 30px; }
      .footer { font-size: 12px; color: #666; text-align: center; margin-top: 30px; }
      .app-link { color: #007bff; text-decoration: none; font-weight: bold; }
      .logo { text-align: center; margin-top: 40px; }
    </style></head><body>
      <div class="container">
        <div class="header"><h2>Calibrr Social</h2></div>
        <div class="content">{{CONTENT}}</div>
        <div class="footer">
          <p>Open the Calibrr Social <a href="https://apps.apple.com/us/app/calibrr-social/id1377015871" class="app-link">HERE</a></p>
          <p>This email was sent from the Calibrr Social app.</p>
        </div>
        <div class="logo">
          <img src="https://calibrr-email-logo-1753077694.s3.amazonaws.com/calibrr-logo.png" alt="Calibrr Social App" style="max-width:200px;height:auto;">
        </div>
      </div>
    </body></html>
  `;
}

async function sendEmail(toEmail, subject, htmlBody, textBody) {
  const params = {
    Source: EMAIL_FROM,
    Destination: { ToAddresses: [toEmail] },
    Message: {
      Subject: { Data: subject, Charset: "UTF-8" },
      Body: {
        Html: { Data: htmlBody, Charset: "UTF-8" },
        Text: { Data: textBody || subject, Charset: "UTF-8" },
      },
    },
  };
  const command = new SendEmailCommand(params);
  return await sesClient.send(command);
}

function response(statusCode, objectBody) {
  return { statusCode, body: typeof objectBody === "string" ? objectBody : JSON.stringify(objectBody) };
}