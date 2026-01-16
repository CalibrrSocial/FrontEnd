import React, { useState } from 'react';
import DatabaseService from '../services/database';
import './AdminReset.css';

interface AdminResetProps {
  adminEmail: string;
}

const AdminReset: React.FC<AdminResetProps> = ({ adminEmail }) => {
  // Password reset states
  const [currentPassword, setCurrentPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [passwordLoading, setPasswordLoading] = useState(false);
  
  // Email update states
  const [newEmail, setNewEmail] = useState('');
  const [emailLoading, setEmailLoading] = useState(false);

  const handlePasswordReset = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (newPassword !== confirmPassword) {
      alert('New passwords do not match');
      return;
    }
    
    if (newPassword.length < 8) {
      alert('New password must be at least 8 characters long');
      return;
    }
    
    if (!currentPassword) {
      alert('Please enter your current password');
      return;
    }
    
    setPasswordLoading(true);

    try {
      // This would need a different endpoint for admin self-service
      await DatabaseService.resetAdminPassword({
        currentPassword,
        newPassword,
        adminEmail
      });

      setCurrentPassword('');
      setNewPassword('');
      setConfirmPassword('');
      alert('Password updated successfully! Please log in again with your new password.');
    } catch (error) {
      console.error('Password reset failed:', error);
      alert('Password reset failed. Please check your current password and try again.');
    } finally {
      setPasswordLoading(false);
    }
  };

  const handleEmailUpdate = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!newEmail || !newEmail.includes('@')) {
      alert('Please enter a valid email address');
      return;
    }
    
    if (newEmail === adminEmail) {
      alert('New email must be different from current email');
      return;
    }
    
    setEmailLoading(true);

    try {
      // This would need a different endpoint for admin self-service
      await DatabaseService.updateAdminEmail({
        newEmail,
        adminEmail
      });

      setNewEmail('');
      alert('Email updated successfully! Please log in again with your new email.');
    } catch (error) {
      console.error('Email update failed:', error);
      alert('Email update failed. Please try again.');
    } finally {
      setEmailLoading(false);
    }
  };

  return (
    <div className="admin-reset">
      <div className="admin-reset-header">
        <h2>🔧 Admin Account Management</h2>
        <p>Manage your own admin account credentials securely.</p>
      </div>

      <div className="admin-reset-content">
        <div className="reset-section">
          <div className="reset-card">
            <h3>🔑 Change Your Password</h3>
            <p className="card-description">
              Update your admin password. You'll need to log in again after changing it.
            </p>
            
            <form onSubmit={handlePasswordReset} className="reset-form">
              <div className="form-group">
                <label>Current Password:</label>
                <input
                  type="password"
                  value={currentPassword}
                  onChange={(e) => setCurrentPassword(e.target.value)}
                  placeholder="Enter your current password"
                  required
                />
              </div>
              
              <div className="form-group">
                <label>New Password:</label>
                <input
                  type="password"
                  value={newPassword}
                  onChange={(e) => setNewPassword(e.target.value)}
                  placeholder="Enter new password (min 8 characters)"
                  required
                  minLength={8}
                />
              </div>
              
              <div className="form-group">
                <label>Confirm New Password:</label>
                <input
                  type="password"
                  value={confirmPassword}
                  onChange={(e) => setConfirmPassword(e.target.value)}
                  placeholder="Confirm new password"
                  required
                  minLength={8}
                />
              </div>
              
              <button 
                type="submit" 
                disabled={passwordLoading}
                className="reset-btn password-btn"
              >
                {passwordLoading ? 'Updating Password...' : '🔑 Update Password'}
              </button>
            </form>
          </div>

          <div className="reset-card">
            <h3>✉️ Change Your Email</h3>
            <p className="card-description">
              Current email: <strong>{adminEmail}</strong><br/>
              Update your admin email address. You'll need to log in again after changing it.
            </p>
            
            <form onSubmit={handleEmailUpdate} className="reset-form">
              <div className="form-group">
                <label>New Email Address:</label>
                <input
                  type="email"
                  value={newEmail}
                  onChange={(e) => setNewEmail(e.target.value)}
                  placeholder="Enter new email address"
                  required
                />
              </div>
              
              <button 
                type="submit" 
                disabled={emailLoading}
                className="reset-btn email-btn"
              >
                {emailLoading ? 'Updating Email...' : '✉️ Update Email'}
              </button>
            </form>
          </div>
        </div>

        <div className="security-notice">
          <h4>🛡️ Security Notice</h4>
          <ul>
            <li>These changes affect only your admin account</li>
            <li>You will be logged out after making changes</li>
            <li>All changes are logged in the audit trail</li>
            <li>Use strong passwords with at least 8 characters</li>
            <li>Keep your admin credentials secure and private</li>
          </ul>
        </div>
      </div>
    </div>
  );
};

export default AdminReset;
