import React, { useState, useEffect } from 'react';
import { User } from '../types/User';
import DatabaseService from '../services/database';
import './UserList.css';

interface UserListProps {
  onUserSelect: (user: User) => void;
}

const UserList: React.FC<UserListProps> = ({ onUserSelect }) => {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);

  useEffect(() => {
    loadUsers();
  }, [currentPage, searchTerm]);

  const loadUsers = async () => {
    try {
      setLoading(true);
      const response = await DatabaseService.getUsers(currentPage, searchTerm);
      setUsers(response.data || []);
      setTotalPages(response.totalPages || 1);
    } catch (error) {
      console.error('Failed to load users:', error);
      // Show error state instead of mock data
      setUsers([]);
    } finally {
      setLoading(false);
    }
  };

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    setCurrentPage(1);
    loadUsers();
  };

  const getStatusBadge = (state: string) => {
    const className = `status-badge ${state}`;
    const text = state.charAt(0).toUpperCase() + state.slice(1);
    return <span className={className}>{text}</span>;
  };

  const formatDate = (dateString?: string) => {
    if (!dateString) return 'N/A';
    return new Date(dateString).toLocaleDateString();
  };

  return (
    <div className="user-list">
      <div className="user-list-header">
        <h2>👥 User Management</h2>
        <form onSubmit={handleSearch} className="search-form">
          <input
            type="text"
            placeholder="Search by name, email, or ID..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="search-input"
          />
          <button type="submit" className="search-btn">
            🔍 Search
          </button>
        </form>
      </div>

      {loading ? (
        <div className="loading">Loading users...</div>
      ) : (
        <>
          <div className="user-table-container">
            <table className="user-table">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Name</th>
                  <th>Email</th>
                  <th>Phone</th>
                  <th>Status</th>
                  <th>Joined</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {users.map((user) => (
                  <tr key={user.id}>
                    <td>{user.id}</td>
                    <td>{user.first_name} {user.last_name}</td>
                    <td>{user.email}</td>
                    <td>{user.phone}</td>
                    <td>{getStatusBadge(user.moderation_state)}</td>
                    <td>{formatDate(user.created_at)}</td>
                    <td>
                      <button 
                        onClick={() => onUserSelect(user)}
                        className="view-btn"
                      >
                        👁️ View
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

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

export default UserList;
