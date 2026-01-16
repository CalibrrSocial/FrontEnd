export interface User {
  id: number;
  email: string;
  first_name: string;
  last_name: string;
  phone: string;
  profile_pic?: string;
  cover_image?: string;
  city?: string;
  dob?: string;
  politics?: string;
  religion?: string;
  education?: string;
  occupation?: string;
  gender?: string;
  bio?: string;
  moderation_state: 'active' | 'suspended' | 'banned';
  suspension_ends_at?: string;
  moderation_reason?: string;
  created_at?: string;
  updated_at?: string;
}

export interface ModerationAction {
  id: number;
  user_id: number;
  action: 'ban' | 'suspend' | 'unban' | 'unsuspend';
  reason?: string;
  expires_at?: string;
  admin_email: string;
  created_at: string;
}

export interface AdminStats {
  totalUsers: number;
  activeUsers: number;
  suspendedUsers: number;
  bannedUsers: number;
}
