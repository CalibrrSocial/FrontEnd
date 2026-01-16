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

    if (notificationType === "attribute_liked") {
      const recipientEmail = ad.recipientEmail;
      const senderFirstName = ad.senderFirstName || "";
      const senderLastName = ad.senderLastName || "";
      const category = ad.category || "";
      const attribute = ad.attribute || "";
      
      if (!recipientEmail) {
        console.error("Missing recipientEmail in additionalData");
        return response(400, { error: "recipientEmail missing" });
      }

      if (!category || !attribute) {
        console.error("Missing category or attribute in additionalData");
        return response(400, { error: "category and attribute required" });
      }

      const senderName = [senderFirstName, senderLastName].filter(Boolean).join(" ") || "Someone";
      const displayLabel = deriveAttributeLabel(category, attribute);
      const subject = `${senderName} just liked your ${displayLabel}, "${attribute}"!`;
      const htmlBody = baseHtml().replace(
        "{{CONTENT}}",
        `
          <h3>${senderName} just liked your ${displayLabel}, "${attribute}"!</h3>
          <p>${senderName} just liked your ${displayLabel}, "${attribute}" on Calibrr Social-- go like their profile back to return the favor!</p>
        `.trim()
      );
      const textBody = `${senderName} just liked your ${displayLabel}, "${attribute}" on Calibrr Social -- go like their profile back to return the favor!`;

      const res = await sendEmail(recipientEmail, subject, htmlBody, textBody);
      return response(200, { ok: true, messageId: res.MessageId });
    }

    if (notificationType === "dead_link_reported") {
      const platforms = Array.isArray(ad.platforms) ? ad.platforms : [];
      const recipientEmail = ad.recipientEmail;
      const reporterName = ad.reporterName || "Someone";
      
      if (!recipientEmail) return response(400, { error: "recipientEmail missing" });
      if (!platforms.length) return response(400, { error: "platforms array missing or empty" });
      
      const subject = "Fix your broken links!";
      const platformsList = platforms.map((p) => `<li style="margin: 5px 0;">${p}</li>`).join("");
      
      const htmlBody = deadLinkHtml().replace(
        "{{CONTENT}}",
        `
          <h3 style="color: #d9534f;">⚠️ Fix your broken links!</h3>
          <p><strong>${reporterName} on the Calibrr Social app reported that the social media link(s) on your profile seem to be broken for the following platform(s):</strong></p>
          <ul style="margin: 15px 0; padding-left: 20px; background-color: #f8f9fa; padding: 15px 20px; border-radius: 5px;">
            ${platformsList}
          </ul>
          <div style="background-color: #fff3cd; padding: 15px; border-radius: 5px; margin: 20px 0; border-left: 4px solid #ffc107;">
            <p style="margin: 0;"><strong>This means that no one can check you out, or hit you up on the platforms listed above, until you fix the link(s)!</strong></p>
          </div>
          <h4>How to fix this:</h4>
          <ol style="line-height: 1.8;">
            <li>Open the Calibrr Social app</li>
            <li>Go to your profile settings</li>
            <li>Try relinking these platforms to your Calibrr account by editing your profile</li>
            <li>Make sure your username is correct, and/or that you copy and paste a good, functioning, and current link for that platform</li>
            <li><strong>Test it yourself to make sure it is working!</strong></li>
          </ol>
        `.trim()
      );
      
      const textBody = `${reporterName} on the Calibrr Social app reported the social media link on your profile seems to be broken for the following platform(s): ${platforms.join(', ')}. 

This means that no one can check you out, or hit you up on the platforms listed above, until you fix the link(s)!

Try relinking these platforms to your Calibrr account by editing your profile. Make sure your username is correct, and/or that you copy and paste a good, functioning, and current link for that platform. Also test it yourself to make sure it is working!`;
      
      const res = await sendEmail(recipientEmail, subject, htmlBody, textBody);
      return response(200, { ok: true, messageId: res.MessageId });
    }

    if (notificationType === "user_reported") {
      const reportData = payload.reportData || {};
      const adminEmails = reportData.adminEmails || [];
      
      if (!adminEmails.length) {
        console.error("Missing adminEmails in reportData");
        return response(400, { error: "adminEmails missing" });
      }

      const subject = `🚨 User Report: ${reportData.reportedUserName || 'Unknown User'}`;
      const htmlBody = baseHtml().replace(
        "{{CONTENT}}",
        `
          <h3>🚨 User Report Notification</h3>
          <div style="background-color: #f8f9fa; padding: 20px; border-radius: 5px; margin: 20px 0;">
            <h4>Report Details:</h4>
            <p><strong>Report ID:</strong> ${reportData.reportId || 'N/A'}</p>
            <p><strong>Reported At:</strong> ${reportData.reportedAt || 'N/A'}</p>
            <p><strong>Reason:</strong> ${reportData.reasonCategory || 'No reason provided'}</p>
            ${reportData.description ? `<p><strong>Additional Info:</strong> ${reportData.description}</p>` : ''}
          </div>
          <div style="background-color: #fff3cd; padding: 20px; border-radius: 5px; margin: 20px 0;">
            <h4>👤 Reporter Information:</h4>
            <p><strong>Name:</strong> ${reportData.reporterName || 'Unknown'}</p>
            <p><strong>Email:</strong> ${reportData.reporterEmail || 'Unknown'}</p>
          </div>
          <div style="background-color: #f8d7da; padding: 20px; border-radius: 5px; margin: 20px 0;">
            <h4>⚠️ Reported User Information:</h4>
            <p><strong>Name:</strong> ${reportData.reportedUserName || 'Unknown'}</p>
            <p><strong>Email:</strong> ${reportData.reportedUserEmail || 'Unknown'}</p>
          </div>
          <p><em>This user has been automatically blocked from the reporter's view.</em></p>
        `.trim()
      );
      
      const textBody = `
USER REPORT NOTIFICATION

Report ID: ${reportData.reportId || 'N/A'}
Reported At: ${reportData.reportedAt || 'N/A'}
Reason: ${reportData.reasonCategory || 'No reason provided'}
${reportData.description ? `Additional Info: ${reportData.description}` : ''}

Reporter: ${reportData.reporterName || 'Unknown'} (${reportData.reporterEmail || 'Unknown'})
Reported User: ${reportData.reportedUserName || 'Unknown'} (${reportData.reportedUserEmail || 'Unknown'})

The reported user has been automatically blocked from the reporter's view.
      `.trim();

      // Send email to all admin addresses
      const results = [];
      for (const adminEmail of adminEmails) {
        try {
          const res = await sendEmail(adminEmail, subject, htmlBody, textBody);
          results.push({ email: adminEmail, messageId: res.MessageId, success: true });
        } catch (error) {
          console.error(`Failed to send report email to ${adminEmail}:`, error);
          results.push({ email: adminEmail, error: error.message, success: false });
        }
      }
      
      return response(200, { ok: true, results });
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

function deriveAttributeLabel(category, attribute) {
  const group = (category || '').trim();
  const value = (attribute || '').trim();
  const groupLower = group.toLowerCase();
  const valueLower = value.toLowerCase();

  const genderValues = new Set(['male', 'female', 'non-binary', 'nonbinary', 'other', 'prefer not to say']);
  const relationshipValues = new Set(['single', 'in a relationship', 'married', 'engaged', "it's complicated", 'divorced', 'separated']);
  const sexualityValues = new Set(['straight', 'heterosexual', 'gay', 'lesbian', 'bisexual', 'asexual', 'pansexual', 'queer', 'questioning', 'demisexual', 'prefer not to say']);
  const monthNames = ['january','february','march','april','may','june','july','august','september','october','november','december'];

  const looksLikeDate = monthNames.some((m) => valueLower.includes(m)) || /\b(19|20)\d{2}\b/.test(valueLower) || /years? old\b/.test(valueLower);
  const looksLikeCourse = /\b[A-Za-z]{2,4}\s?\d{3,4}[A-Za-z]?\b/.test(value);
  const looksLikeClassYear = /\b(freshman|sophomore|junior|senior)\b/.test(valueLower) || /\b\d(?:st|nd|rd|th) year\b/.test(valueLower);
  const looksLikeCollege = /\b(university|college|institute|state)\b/.test(valueLower);
  const looksLikeCampus = /\bcampus\b/.test(valueLower);
  const looksLikeFriendList = /friend\b/i.test(value) || /,/ .test(value);

  const tvShows = new Set(['breaking bad','game of thrones','the office','friends','stranger things','succession','the boys','walking dead','dexter','risk','chess']);
  const games = new Set(['minecraft','call of duty','fortnite','league of legends','valorant','overwatch','apex legends','grand theft auto','gta','genshin impact','cod zombies','squid game','metal']);
  const musicExamples = new Set(['daft punk','rammstein','ramnstein','taylor swift','drake','ariana grande','metallica']);

  switch (groupLower) {
    case 'personal': {
      if (genderValues.has(valueLower)) return 'Gender';
      if (relationshipValues.has(valueLower)) return 'Relationship';
      if (sexualityValues.has(valueLower)) return 'Sexuality';
      if (looksLikeDate) return 'Born';
      return 'Bio';
    }
    case 'education': {
      if (looksLikeCourse) return 'Courses';
      if (looksLikeClassYear) return 'Class Year';
      if (looksLikeCampus) return 'Campus';
      if (looksLikeCollege) return 'College';
      return 'Major/Studying';
    }
    case 'career': {
      if (valueLower === 'yes' || valueLower === 'no') return 'Postgraduate Plans';
      const occupationHints = ['founder','ceo','cto','engineer','developer','designer','teacher','nurse','pca','manager','doctor','attorney','lawyer','analyst','technician'];
      if (occupationHints.some((h) => valueLower.includes(h))) return 'Occupation';
      return 'Career Aspirations';
    }
    case 'social': {
      if (looksLikeFriendList) return 'Best Friends';
      if (valueLower === 'none') return 'Greek life';
      return 'Team/Club';
    }
    case 'entertainment': {
      if (games.has(valueLower)) return 'Favorite Games';
      if (tvShows.has(valueLower)) return 'Favorite TV';
      // Check for game-like patterns
      if (/\b(game|gaming|play|cod|zombies|minecraft|fortnite)\b/i.test(value)) return 'Favorite Games';
      // Check for TV-like patterns  
      if (/\b(show|series|tv|episode|season|bad|dead|dexter)\b/i.test(value)) return 'Favorite TV';
      // Default to TV for entertainment category
      return 'Favorite TV';
    }
    case 'music': {
      return 'Favorite Music';
    }
    case 'politics': {
      return 'Politics';
    }
    case 'religion': {
      return 'Religion';
    }
    case 'location': {
      return 'Location';
    }
    case 'other': {
      if (looksLikeCourse) return 'Courses';
      if (games.has(valueLower)) return 'Favorite Games';
      if (tvShows.has(valueLower)) return 'Favorite TV';
      if (musicExamples.has(valueLower)) return 'Favorite Music';
      // Check for game-like patterns in Other category
      if (/\b(game|gaming|play|cod|zombies|minecraft|fortnite|metal|chess)\b/i.test(value)) return 'Favorite Games';
      // Check for TV-like patterns in Other category
      if (/\b(show|series|tv|episode|season|bad|dead|dexter|walking|squid)\b/i.test(value)) return 'Favorite TV';
      // Check for music-like patterns in Other category
      if (/\b(music|band|artist|song|album|metal)\b/i.test(value)) return 'Favorite Music';
      return 'Other';
    }
    default:
      return group || 'Attribute';
  }
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