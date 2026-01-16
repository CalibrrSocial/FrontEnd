import React, { useState, useEffect } from 'react';
import { Amplify } from 'aws-amplify';
import { withAuthenticator, WithAuthenticatorProps } from '@aws-amplify/ui-react';
import '@aws-amplify/ui-react/styles.css';
import Dashboard from './components/Dashboard';
import './App.css';

// AWS Configuration - Updated with your Cognito values
const awsConfig = {
  Auth: {
    Cognito: {
      region: 'us-east-1',
      userPoolId: 'us-east-1_V8r9Bo2BS',
      userPoolClientId: '19uhql4gflvbor8f5hd9hjv0u1'
    }
  }
};

Amplify.configure(awsConfig);

interface AppProps extends WithAuthenticatorProps {}

function App({ signOut, user }: AppProps) {
  const [adminEmail, setAdminEmail] = useState<string>('');

  useEffect(() => {
    // Debug: Log the user object to see its structure
    console.log('Cognito user object:', user);
    
    // Try multiple ways to get the email
    const emailFromAttributes = (user as any)?.attributes?.email;
    const emailFromSignInDetails = (user as any)?.signInDetails?.loginId;
    const fallbackUsername = (user as any)?.username;
    
    // Use the first valid email we find
    const email = emailFromAttributes || emailFromSignInDetails || fallbackUsername || '';
    
    // If it's a UUID (Cognito sub), we need to hardcode the email for now
    if (email && email.includes('-')) {
      // This is a UUID, not an email - use the known admin email
      setAdminEmail('admin@calibrr.com');
    } else {
      setAdminEmail(email);
    }
  }, [user]);

  return (
    <div className="App">
      <Dashboard 
        adminEmail={adminEmail} 
        onSignOut={signOut || (() => {})} 
      />
    </div>
  );
}

// For development without AWS (comment out when deploying)
// export default App;

// For production with AWS authentication (uncomment when deploying)
export default withAuthenticator(App, {
  signUpAttributes: [],
  hideSignUp: true, // Only allow existing admin users to sign in
  components: {
    Header() {
      return (
        <div style={{ padding: '20px', textAlign: 'center' }}>
          <h1>🛡️ Calibrr Admin Panel</h1>
          <p>Secure Administrator Access</p>
        </div>
      );
    }
  }
});
