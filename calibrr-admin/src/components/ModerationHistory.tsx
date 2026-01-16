import React, { useState, useEffect } from 'react';
import { ModerationAction } from '../types/User';
import DatabaseService from '../services/database';
import './ModerationHistory.css';

const ModerationHistory: React.FC = () => {
  const [history, setHistory] = useState<ModerationAction[]>([]);
  const [loading, setLoading] = useState(false);
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [filterUserId, setFilterUserId] = useState('');

  useEffect(() => {
    loadHistory();
  }, [currentPage, filterUserId]);

  const loadHistory = async () => {
    try {
      setLoading(true);
      const userId = filterUserId ? parseInt(filterUserId) : undefined;
      const response = await DatabaseService.getModerationHistory(userId, currentPage);
      setHistory(response.data || []);
      setTotalPages(response.totalPages || 1);
    } catch (error) {
      console.error('Failed to load moderation history:', error);
      // Show empty state instead of mock data
      setHistory([]);
    } finally {
      setLoading(false);
    }
  };

  const handleFilter = (e: React.FormEvent) => {
    e.preventDefault();
    setCurrentPage(1);
    loadHistory();
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleString();
  };

  const getActionBadge = (action: string) => {
    const className = `action-badge ${action}`;
    return <span className={className}>{action.toUpperCase()}</span>;
  };

  const exportToCsv = () => {
    const headers = ['ID', 'User ID', 'Action', 'Reason', 'Expires At', 'Admin Email', 'Created At'];
    const csvContent = [
      headers.join(','),
      ...history.map(item => [
        item.id,
        item.user_id,
        item.action,
        `"${item.reason || ''}"`,
        item.expires_at || '',
        item.admin_email,
        item.created_at
      ].join(','))
    ].join('\n');

    const blob = new Blob([csvContent], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `moderation-history-${new Date().toISOString().split('T')[0]}.csv`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    window.URL.revokeObjectURL(url);
  };

  return (
    <div className="moderation-history">
      <div className="history-header">
        <h2>📋 Moderation History</h2>
        <div className="header-actions">
          <form onSubmit={handleFilter} className="filter-form">
            <input
              type="number"
              placeholder="Filter by User ID..."
              value={filterUserId}
              onChange={(e) => setFilterUserId(e.target.value)}
              className="filter-input"
            />
            <button type="submit" className="filter-btn">
              🔍 Filter
            </button>
            {filterUserId && (
              <button 
                type="button" 
                onClick={() => {
                  setFilterUserId('');
                  setCurrentPage(1);
                }}
                className="clear-btn"
              >
                ✕ Clear
              </button>
            )}
          </form>
          <button onClick={exportToCsv} className="export-btn">
            📁 Export CSV
          </button>
        </div>
      </div>

      {loading ? (
        <div className="loading">Loading moderation history...</div>
      ) : (
        <>
          <div className="history-table-container">
            <table className="history-table">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>User ID</th>
                  <th>Action</th>
                  <th>Reason</th>
                  <th>Expires At</th>
                  <th>Admin</th>
                  <th>Date</th>
                </tr>
              </thead>
              <tbody>
                {history.map((action) => (
                  <tr key={action.id}>
                    <td>{action.id}</td>
                    <td>{action.user_id}</td>
                    <td>{getActionBadge(action.action)}</td>
                    <td className="reason-cell">
                      {action.reason || <em>No reason provided</em>}
                    </td>
                    <td>
                      {action.expires_at ? formatDate(action.expires_at) : '—'}
                    </td>
                    <td>{action.admin_email}</td>
                    <td>{formatDate(action.created_at)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          {history.length === 0 && (
            <div className="no-data">
              <p>No moderation actions found.</p>
            </div>
          )}

          {totalPages > 1 && (
            <div className="pagination">
              <button 
                onClick={() => setCurrentPage(Math.max(1, currentPage - 1))}
                disabled={currentPage === 1}
                className="page-btn"
              >
                ← Previous
              </button>
              <span className="page-info">
                Page {currentPage} of {totalPages}
              </span>
              <button 
                onClick={() => setCurrentPage(Math.min(totalPages, currentPage + 1))}
                disabled={currentPage === totalPages}
                className="page-btn"
              >
                Next →
              </button>
            </div>
          )}
        </>
      )}
    </div>
  );
};

export default ModerationHistory;
