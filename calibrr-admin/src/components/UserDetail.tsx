import React, { useState } from 'react';
import { User } from '../types/User';
import DatabaseService from '../services/database';
import './UserDetail.css';

interface UserDetailProps {
  user: User;
  adminEmail: string;
  onBack: () => void;
  onModerated: () => void;
}

const UserDetail: React.FC<UserDetailProps> = ({ user, adminEmail, onBack, onModerated }) => {
  const [showModerationModal, setShowModerationModal] = useState(false);
  const [moderationAction, setModerationAction] = useState<'ban' | 'suspend' | 'unban' | 'unsuspend'>('ban');
  const [reason, setReason] = useState('');
  const [suspensionDuration, setSuspensionDuration] = useState('24h');
  const [customDate, setCustomDate] = useState('');
  const [loading, setLoading] = useState(false);
  


  const handleModerate = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      let expiresAt: string | undefined;
      
      if (moderationAction === 'suspend') {
        if (suspensionDuration === 'custom') {
          expiresAt = customDate;
        } else {
          const now = new Date();
          const duration = parseInt(suspensionDuration);
          const unit = suspensionDuration.slice(-1);
          
          if (unit === 'h') {
            now.setHours(now.getHours() + duration);
          } else if (unit === 'd') {
            now.setDate(now.getDate() + duration);
          }
          
          expiresAt = now.toISOString();
        }
      }

      await DatabaseService.moderateUser(user.id, moderationAction, {
        reason: reason || undefined,
        expiresAt,
        adminEmail
      });

      setShowModerationModal(false);
      onModerated();
    } catch (error) {
      console.error('Moderation failed:', error);
      alert('Moderation action failed. Please try again.');
    } finally {
      setLoading(false);
    }
  };



  const formatDate = (dateString?: string) => {
    if (!dateString) return 'N/A';
    return new Date(dateString).toLocaleString();
  };

  const getStatusColor = (state: string) => {
    switch (state) {
      case 'active': return '#28a745';
      case 'suspended': return '#ffc107';
      case 'banned': return '#dc3545';
      default: return '#6c757d';
    }
  };

  const canModerate = user.moderation_state !== 'banned' || moderationAction === 'unban';

  return (
    <div className="user-detail">
      <div className="user-detail-header">
        <button onClick={onBack} className="back-btn">
          ← Back to Users
        </button>
        <h2>User Details</h2>
      </div>

      <div className="user-info-grid">
        <div className="user-info-card">
          <h3>Basic Information</h3>
          <div className="info-row">
            <span className="label">ID:</span>
            <span className="value">{user.id}</span>
          </div>
          <div className="info-row">
            <span className="label">Name:</span>
            <span className="value">{user.first_name} {user.last_name}</span>
          </div>
          <div className="info-row">
            <span className="label">Email:</span>
            <span className="value">{user.email}</span>
          </div>
          <div className="info-row">
            <span className="label">Phone:</span>
            <span className="value">{user.phone}</span>
          </div>
          <div className="info-row">
            <span className="label">Joined:</span>
            <span className="value">{formatDate(user.created_at)}</span>
          </div>
        </div>

        <div className="user-info-card">
          <h3>Profile Details</h3>
          <div className="info-row">
            <span className="label">City:</span>
            <span className="value">{user.city || 'Not specified'}</span>
          </div>
          <div className="info-row">
            <span className="label">Date of Birth:</span>
            <span className="value">{user.dob || 'Not specified'}</span>
          </div>
          <div className="info-row">
            <span className="label">Gender:</span>
            <span className="value">{user.gender || 'Not specified'}</span>
          </div>
          <div className="info-row">
            <span className="label">Education:</span>
            <span className="value">{user.education || 'Not specified'}</span>
          </div>
          <div className="info-row">
            <span className="label">Occupation:</span>
            <span className="value">{user.occupation || 'Not specified'}</span>
          </div>
        </div>

        <div className="user-info-card moderation-card">
          <h3>Moderation Status</h3>
          <div className="info-row">
            <span className="label">Status:</span>
            <span 
              className="value status-badge"
              style={{ backgroundColor: getStatusColor(user.moderation_state), color: 'white' }}
            >
              {user.moderation_state.toUpperCase()}
            </span>
          </div>
          {user.suspension_ends_at && (
            <div className="info-row">
              <span className="label">Suspension Ends:</span>
              <span className="value">{formatDate(user.suspension_ends_at)}</span>
            </div>
          )}
          {user.moderation_reason && (
            <div className="info-row">
              <span className="label">Reason:</span>
              <span className="value">{user.moderation_reason}</span>
            </div>
          )}
          
          <div className="moderation-actions">
            {user.moderation_state === 'active' && (
              <>
                <button 
                  onClick={() => {
                    setModerationAction('suspend');
                    setShowModerationModal(true);
                  }}
                  className="moderate-btn suspend"
                >
                  ⏸️ Suspend User
                </button>
                <button 
                  onClick={() => {
                    setModerationAction('ban');
                    setShowModerationModal(true);
                  }}
                  className="moderate-btn ban"
                >
                  🚫 Ban User
                </button>
              </>
            )}
            
            {user.moderation_state === 'suspended' && (
              <>
                <button 
                  onClick={() => {
                    setModerationAction('unsuspend');
                    setShowModerationModal(true);
                  }}
                  className="moderate-btn unsuspend"
                >
                  ✅ Unsuspend User
                </button>
                <button 
                  onClick={() => {
                    setModerationAction('ban');
                    setShowModerationModal(true);
                  }}
                  className="moderate-btn ban"
                >
                  🚫 Ban User
                </button>
              </>
            )}
            
            {user.moderation_state === 'banned' && (
              <button 
                onClick={() => {
                  setModerationAction('unban');
                  setShowModerationModal(true);
                }}
                className="moderate-btn unban"
              >
                🔓 Unban User
              </button>
            )}
          </div>
          

        </div>
      </div>

      {showModerationModal && (
        <div className="modal-overlay">
          <div className="modal">
            <h3>
              {moderationAction.charAt(0).toUpperCase() + moderationAction.slice(1)} User
            </h3>
            <form onSubmit={handleModerate}>
              <div className="form-group">
                <label>Reason (optional):</label>
                <textarea
                  value={reason}
                  onChange={(e) => setReason(e.target.value)}
                  placeholder="Enter reason for moderation action..."
                  rows={3}
                />
              </div>
              
              {moderationAction === 'suspend' && (
                <div className="form-group">
                  <label>Suspension Duration:</label>
                  <select
                    value={suspensionDuration}
                    onChange={(e) => setSuspensionDuration(e.target.value)}
                  >
                    <option value="1h">1 Hour</option>
                    <option value="24h">24 Hours</option>
                    <option value="7d">7 Days</option>
                    <option value="30d">30 Days</option>
                    <option value="custom">Custom Date</option>
                  </select>
                  
                  {suspensionDuration === 'custom' && (
                    <input
                      type="datetime-local"
                      value={customDate}
                      onChange={(e) => setCustomDate(e.target.value)}
                      required
                    />
                  )}
                </div>
              )}
              
              <div className="modal-actions">
                <button 
                  type="button" 
                  onClick={() => setShowModerationModal(false)}
                  className="cancel-btn"
                >
                  Cancel
                </button>
                <button 
                  type="submit" 
                  disabled={loading}
                  className={`confirm-btn ${moderationAction}`}
                >
                  {loading ? 'Processing...' : `Confirm ${moderationAction.charAt(0).toUpperCase() + moderationAction.slice(1)}`}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}


    </div>
  );
};

export default UserDetail;
