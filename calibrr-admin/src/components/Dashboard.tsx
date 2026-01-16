import React, { useState, useEffect } from 'react';
import { User, AdminStats } from '../types/User';
import DatabaseService from '../services/database';
import UserList from './UserList';
import UserDetail from './UserDetail';
import ModerationHistory from './ModerationHistory';
import AdminReset from './AdminReset';
import './Dashboard.css';

interface DashboardProps {
  adminEmail: string;
  onSignOut: () => void;
}

const Dashboard: React.FC<DashboardProps> = ({ adminEmail, onSignOut }) => {
  const [activeTab, setActiveTab] = useState<'users' | 'history' | 'stats' | 'admin-reset'>('users');
  const [selectedUser, setSelectedUser] = useState<User | null>(null);
  const [stats, setStats] = useState<AdminStats | null>(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    loadStats();
  }, []);

  const loadStats = async () => {
    try {
      setLoading(true);
      const statsData = await DatabaseService.getStats();
      setStats(statsData);
    } catch (error) {
      console.error('Failed to load stats:', error);
      // Show error state instead of mock data
      setStats(null);
    } finally {
      setLoading(false);
    }
  };

  const handleUserSelect = (user: User) => {
    setSelectedUser(user);
  };

  const handleUserModerated = () => {
    setSelectedUser(null);
    loadStats(); // Refresh stats after moderation
  };

  const renderTabContent = () => {
    if (selectedUser) {
      return (
        <UserDetail 
          user={selectedUser} 
          adminEmail={adminEmail}
          onBack={() => setSelectedUser(null)}
          onModerated={handleUserModerated}
        />
      );
    }

    switch (activeTab) {
      case 'users':
        return <UserList onUserSelect={handleUserSelect} />;
      case 'history':
        return <ModerationHistory />;
      case 'stats':
        return (
          <div className="stats-container">
            <h2>User Statistics</h2>
            {loading ? (
              <div>Loading stats...</div>
            ) : stats ? (
              <div className="stats-grid">
                <div className="stat-card">
                  <h3>{stats.totalUsers}</h3>
                  <p>Total Users</p>
                </div>
                <div className="stat-card active">
                  <h3>{stats.activeUsers}</h3>
                  <p>Active Users</p>
                </div>
                <div className="stat-card suspended">
                  <h3>{stats.suspendedUsers}</h3>
                  <p>Suspended Users</p>
                </div>
                <div className="stat-card banned">
                  <h3>{stats.bannedUsers}</h3>
                  <p>Banned Users</p>
                </div>
              </div>
            ) : (
              <div>Failed to load stats</div>
            )}
          </div>
        );
      case 'admin-reset':
        return <AdminReset adminEmail={adminEmail} />;
      default:
        return null;
    }
  };

  return (
    <div className="dashboard">
      <header className="dashboard-header">
        <h1>🛡️ Calibrr Admin Panel</h1>
        <div className="header-actions">
          <span>Logged in as: {adminEmail}</span>
          <button onClick={onSignOut} className="sign-out-btn">
            Sign Out
          </button>
        </div>
      </header>

      <nav className="dashboard-nav">
        <button 
          className={activeTab === 'users' ? 'active' : ''}
          onClick={() => setActiveTab('users')}
        >
          👥 Users
        </button>
        <button 
          className={activeTab === 'history' ? 'active' : ''}
          onClick={() => setActiveTab('history')}
        >
          📋 History
        </button>
        <button 
          className={activeTab === 'stats' ? 'active' : ''}
          onClick={() => setActiveTab('stats')}
        >
          📊 Statistics
        </button>
        <button 
          className={activeTab === 'admin-reset' ? 'active' : ''}
          onClick={() => setActiveTab('admin-reset')}
        >
          🔧 Admin Reset
        </button>
      </nav>

      <main className="dashboard-content">
        {renderTabContent()}
      </main>
    </div>
  );
};

export default Dashboard;
