// Database service for direct MySQL connection
// This will be replaced with API calls in production

export interface DatabaseConfig {
  host: string;
  user: string;
  password: string;
  database: string;
  port: number;
}

// For now, we'll use API endpoints instead of direct DB connection
// This is safer and follows AWS best practices

const API_BASE = process.env.REACT_APP_API_BASE || 'https://api.calibrr.com/api';

export class DatabaseService {
  private static instance: DatabaseService;
  
  static getInstance(): DatabaseService {
    if (!DatabaseService.instance) {
      DatabaseService.instance = new DatabaseService();
    }
    return DatabaseService.instance;
  }

  // We'll create admin-specific API endpoints on your Laravel backend
  // These will be simple additions that don't affect existing functionality
  
  async getUsers(page: number = 1, search?: string) {
    const params = new URLSearchParams({
      page: page.toString(),
      ...(search && { search })
    });
    
    try {
      console.log(`Fetching users from: ${API_BASE}/admin/users?${params}`);
      const response = await fetch(`${API_BASE}/admin/users?${params}`, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        }
      });
      
      if (!response.ok) {
        console.warn('API call failed, using fallback data');
        throw new Error('Failed to fetch users');
      }
      
      const data = await response.json();
      console.log('Successfully fetched users from API:', data);
      return data;
    } catch (error) {
      console.error('Database service error:', error);
      // Return real API response structure instead of mock data
      throw error;
    }
  }

  async getUserById(id: number) {
    const response = await fetch(`${API_BASE}/admin/users/${id}`);
    if (!response.ok) throw new Error('Failed to fetch user');
    return response.json();
  }

  async moderateUser(userId: number, action: 'ban' | 'suspend' | 'unban' | 'unsuspend', data: {
    reason?: string;
    expiresAt?: string;
    adminEmail: string;
  }) {
    const response = await fetch(`${API_BASE}/admin/users/${userId}/moderate`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        action,
        ...data
      })
    });
    
    if (!response.ok) throw new Error('Failed to moderate user');
    return response.json();
  }

  async getModerationHistory(userId?: number, page: number = 1) {
    const params = new URLSearchParams({
      page: page.toString(),
      ...(userId && { user_id: userId.toString() })
    });
    
    const response = await fetch(`${API_BASE}/admin/moderation-history?${params}`);
    if (!response.ok) throw new Error('Failed to fetch moderation history');
    return response.json();
  }

  async getStats() {
    const response = await fetch(`${API_BASE}/admin/stats`);
    if (!response.ok) throw new Error('Failed to fetch stats');
    return response.json();
  }

  async resetUserPassword(userId: number, data: {
    password: string;
    adminEmail: string;
  }) {
    const response = await fetch(`${API_BASE}/admin/users/${userId}/reset-password`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(data)
    });
    
    if (!response.ok) throw new Error('Failed to reset password');
    return response.json();
  }

  async updateUserEmail(userId: number, data: {
    email: string;
    adminEmail: string;
  }) {
    const response = await fetch(`${API_BASE}/admin/users/${userId}/update-email`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(data)
    });
    
    if (!response.ok) throw new Error('Failed to update email');
    return response.json();
  }

  // Admin self-service methods
  async updateAdminEmail(data: {
    newEmail: string;
    adminEmail: string;
  }) {
    const response = await fetch(`${API_BASE}/admin/update-email`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(data)
    });
    
    if (!response.ok) throw new Error('Failed to update admin email');
    return response.json();
  }
}

export default DatabaseService.getInstance();
