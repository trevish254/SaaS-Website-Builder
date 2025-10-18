export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export interface Database {
  public: {
    Tables: {
      actions: {
        Row: {
          id: string
          name: string
          type: Database['public']['Enums']['action_type_enum']
          created_at: string
          updated_at: string
          automation_id: string
          order: number
          lane_id: string
        }
        Insert: {
          id?: string
          name: string
          type: Database['public']['Enums']['action_type_enum']
          created_at?: string
          updated_at?: string
          automation_id: string
          order: number
          lane_id?: string
        }
        Update: {
          id?: string
          name?: string
          type?: Database['public']['Enums']['action_type_enum']
          created_at?: string
          updated_at?: string
          automation_id?: string
          order?: number
          lane_id?: string
        }
      }
      add_ons: {
        Row: {
          id: string
          created_at: string
          updated_at: string
          name: string
          active: boolean
          price_id: string
          agency_id: string | null
        }
        Insert: {
          id?: string
          created_at?: string
          updated_at?: string
          name: string
          active?: boolean
          price_id: string
          agency_id?: string | null
        }
        Update: {
          id?: string
          created_at?: string
          updated_at?: string
          name?: string
          active?: boolean
          price_id?: string
          agency_id?: string | null
        }
      }
      agencies: {
        Row: {
          id: string
          connect_account_id: string
          customer_id: string
          name: string
          agency_logo: string
          company_email: string
          company_phone: string
          white_label: boolean
          address: string
          city: string
          zip_code: string
          state: string
          country: string
          goal: number
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          connect_account_id?: string
          customer_id?: string
          name: string
          agency_logo: string
          company_email: string
          company_phone: string
          white_label?: boolean
          address: string
          city: string
          zip_code: string
          state: string
          country: string
          goal?: number
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          connect_account_id?: string
          customer_id?: string
          name?: string
          agency_logo?: string
          company_email?: string
          company_phone?: string
          white_label?: boolean
          address?: string
          city?: string
          zip_code?: string
          state?: string
          country?: string
          goal?: number
          created_at?: string
          updated_at?: string
        }
      }
      agency_sidebar_options: {
        Row: {
          id: string
          name: string
          link: string
          icon: Database['public']['Enums']['icon_enum']
          agency_id: string
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          name?: string
          link?: string
          icon?: Database['public']['Enums']['icon_enum']
          agency_id: string
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          name?: string
          link?: string
          icon?: Database['public']['Enums']['icon_enum']
          agency_id?: string
          created_at?: string
          updated_at?: string
        }
      }
      automation_instances: {
        Row: {
          id: string
          created_at: string
          updated_at: string
          automation_id: string
          active: boolean
        }
        Insert: {
          id?: string
          created_at?: string
          updated_at?: string
          automation_id: string
          active?: boolean
        }
        Update: {
          id?: string
          created_at?: string
          updated_at?: string
          automation_id?: string
          active?: boolean
        }
      }
      automations: {
        Row: {
          id: string
          name: string
          created_at: string
          updated_at: string
          trigger_id: string | null
          published: boolean
          sub_account_id: string
        }
        Insert: {
          id?: string
          name: string
          created_at?: string
          updated_at?: string
          trigger_id?: string | null
          published?: boolean
          sub_account_id: string
        }
        Update: {
          id?: string
          name?: string
          created_at?: string
          updated_at?: string
          trigger_id?: string | null
          published?: boolean
          sub_account_id?: string
        }
      }
      class_names: {
        Row: {
          id: string
          name: string
          color: string
          created_at: string
          updated_at: string
          funnel_id: string
          custom_data: string | null
        }
        Insert: {
          id?: string
          name: string
          color: string
          created_at?: string
          updated_at?: string
          funnel_id: string
          custom_data?: string | null
        }
        Update: {
          id?: string
          name?: string
          color?: string
          created_at?: string
          updated_at?: string
          funnel_id?: string
          custom_data?: string | null
        }
      }
      contacts: {
        Row: {
          id: string
          name: string
          email: string
          created_at: string
          updated_at: string
          sub_account_id: string
        }
        Insert: {
          id?: string
          name: string
          email: string
          created_at?: string
          updated_at?: string
          sub_account_id: string
        }
        Update: {
          id?: string
          name?: string
          email?: string
          created_at?: string
          updated_at?: string
          sub_account_id?: string
        }
      }
      funnel_pages: {
        Row: {
          id: string
          name: string
          path_name: string
          created_at: string
          updated_at: string
          visits: number
          content: string | null
          order: number
          preview_image: string | null
          funnel_id: string
        }
        Insert: {
          id?: string
          name: string
          path_name?: string
          created_at?: string
          updated_at?: string
          visits?: number
          content?: string | null
          order: number
          preview_image?: string | null
          funnel_id: string
        }
        Update: {
          id?: string
          name?: string
          path_name?: string
          created_at?: string
          updated_at?: string
          visits?: number
          content?: string | null
          order?: number
          preview_image?: string | null
          funnel_id?: string
        }
      }
      funnels: {
        Row: {
          id: string
          name: string
          created_at: string
          updated_at: string
          description: string | null
          published: boolean
          sub_domain_name: string | null
          favicon: string | null
          sub_account_id: string
          live_products: string
        }
        Insert: {
          id?: string
          name: string
          created_at?: string
          updated_at?: string
          description?: string | null
          published?: boolean
          sub_domain_name?: string | null
          favicon?: string | null
          sub_account_id: string
          live_products?: string
        }
        Update: {
          id?: string
          name?: string
          created_at?: string
          updated_at?: string
          description?: string | null
          published?: boolean
          sub_domain_name?: string | null
          favicon?: string | null
          sub_account_id?: string
          live_products?: string
        }
      }
      invitations: {
        Row: {
          id: string
          email: string
          agency_id: string
          status: Database['public']['Enums']['invitation_status_enum']
          role: Database['public']['Enums']['role_enum']
        }
        Insert: {
          id?: string
          email: string
          agency_id: string
          status?: Database['public']['Enums']['invitation_status_enum']
          role?: Database['public']['Enums']['role_enum']
        }
        Update: {
          id?: string
          email?: string
          agency_id?: string
          status?: Database['public']['Enums']['invitation_status_enum']
          role?: Database['public']['Enums']['role_enum']
        }
      }
      lanes: {
        Row: {
          id: string
          name: string
          created_at: string
          updated_at: string
          pipeline_id: string
          order: number
        }
        Insert: {
          id?: string
          name: string
          created_at?: string
          updated_at?: string
          pipeline_id: string
          order?: number
        }
        Update: {
          id?: string
          name?: string
          created_at?: string
          updated_at?: string
          pipeline_id?: string
          order?: number
        }
      }
      media: {
        Row: {
          id: string
          type: string | null
          name: string
          link: string
          sub_account_id: string
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          type?: string | null
          name: string
          link: string
          sub_account_id: string
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          type?: string | null
          name?: string
          link?: string
          sub_account_id?: string
          created_at?: string
          updated_at?: string
        }
      }
      notifications: {
        Row: {
          id: string
          notification: string
          agency_id: string
          sub_account_id: string | null
          user_id: string
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          notification: string
          agency_id: string
          sub_account_id?: string | null
          user_id: string
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          notification?: string
          agency_id?: string
          sub_account_id?: string | null
          user_id?: string
          created_at?: string
          updated_at?: string
        }
      }
      permissions: {
        Row: {
          id: string
          email: string
          sub_account_id: string
          access: boolean
        }
        Insert: {
          id?: string
          email: string
          sub_account_id: string
          access: boolean
        }
        Update: {
          id?: string
          email?: string
          sub_account_id?: string
          access?: boolean
        }
      }
      pipelines: {
        Row: {
          id: string
          name: string
          created_at: string
          updated_at: string
          sub_account_id: string
        }
        Insert: {
          id?: string
          name: string
          created_at?: string
          updated_at?: string
          sub_account_id: string
        }
        Update: {
          id?: string
          name?: string
          created_at?: string
          updated_at?: string
          sub_account_id?: string
        }
      }
      sub_account_sidebar_options: {
        Row: {
          id: string
          name: string
          link: string
          icon: Database['public']['Enums']['icon_enum']
          created_at: string
          updated_at: string
          sub_account_id: string | null
        }
        Insert: {
          id?: string
          name?: string
          link?: string
          icon?: Database['public']['Enums']['icon_enum']
          created_at?: string
          updated_at?: string
          sub_account_id?: string | null
        }
        Update: {
          id?: string
          name?: string
          link?: string
          icon?: Database['public']['Enums']['icon_enum']
          created_at?: string
          updated_at?: string
          sub_account_id?: string | null
        }
      }
      sub_accounts: {
        Row: {
          id: string
          connect_account_id: string
          name: string
          sub_account_logo: string
          created_at: string
          updated_at: string
          company_email: string
          company_phone: string
          goal: number
          address: string
          city: string
          zip_code: string
          state: string
          country: string
          agency_id: string
        }
        Insert: {
          id?: string
          connect_account_id?: string
          name: string
          sub_account_logo: string
          created_at?: string
          updated_at?: string
          company_email: string
          company_phone: string
          goal?: number
          address: string
          city: string
          zip_code: string
          state: string
          country: string
          agency_id: string
        }
        Update: {
          id?: string
          connect_account_id?: string
          name?: string
          sub_account_logo?: string
          created_at?: string
          updated_at?: string
          company_email?: string
          company_phone?: string
          goal?: number
          address?: string
          city?: string
          zip_code?: string
          state?: string
          country?: string
          agency_id?: string
        }
      }
      subscriptions: {
        Row: {
          id: string
          created_at: string
          updated_at: string
          plan: Database['public']['Enums']['plan_enum'] | null
          price: string | null
          active: boolean
          price_id: string
          customer_id: string
          current_period_end_date: string
          subscription_id: string
          agency_id: string | null
        }
        Insert: {
          id?: string
          created_at?: string
          updated_at?: string
          plan?: Database['public']['Enums']['plan_enum'] | null
          price?: string | null
          active?: boolean
          price_id: string
          customer_id: string
          current_period_end_date: string
          subscription_id: string
          agency_id?: string | null
        }
        Update: {
          id?: string
          created_at?: string
          updated_at?: string
          plan?: Database['public']['Enums']['plan_enum'] | null
          price?: string | null
          active?: boolean
          price_id?: string
          customer_id?: string
          current_period_end_date?: string
          subscription_id?: string
          agency_id?: string | null
        }
      }
      tags: {
        Row: {
          id: string
          name: string
          color: string
          created_at: string
          updated_at: string
          sub_account_id: string
        }
        Insert: {
          id?: string
          name: string
          color: string
          created_at?: string
          updated_at?: string
          sub_account_id: string
        }
        Update: {
          id?: string
          name?: string
          color?: string
          created_at?: string
          updated_at?: string
          sub_account_id?: string
        }
      }
      ticket_tags: {
        Row: {
          ticket_id: string
          tag_id: string
        }
        Insert: {
          ticket_id: string
          tag_id: string
        }
        Update: {
          ticket_id?: string
          tag_id?: string
        }
      }
      tickets: {
        Row: {
          id: string
          name: string
          created_at: string
          updated_at: string
          lane_id: string
          order: number
          value: string | null
          description: string | null
          customer_id: string | null
          assigned_user_id: string | null
        }
        Insert: {
          id?: string
          name: string
          created_at?: string
          updated_at?: string
          lane_id: string
          order?: number
          value?: string | null
          description?: string | null
          customer_id?: string | null
          assigned_user_id?: string | null
        }
        Update: {
          id?: string
          name?: string
          created_at?: string
          updated_at?: string
          lane_id?: string
          order?: number
          value?: string | null
          description?: string | null
          customer_id?: string | null
          assigned_user_id?: string | null
        }
      }
      triggers: {
        Row: {
          id: string
          name: string
          type: Database['public']['Enums']['trigger_types_enum']
          created_at: string
          updated_at: string
          sub_account_id: string
        }
        Insert: {
          id?: string
          name: string
          type: Database['public']['Enums']['trigger_types_enum']
          created_at?: string
          updated_at?: string
          sub_account_id: string
        }
        Update: {
          id?: string
          name?: string
          type?: Database['public']['Enums']['trigger_types_enum']
          created_at?: string
          updated_at?: string
          sub_account_id?: string
        }
      }
      users: {
        Row: {
          id: string
          name: string
          avatar_url: string
          email: string
          created_at: string
          updated_at: string
          role: Database['public']['Enums']['role_enum']
          agency_id: string | null
        }
        Insert: {
          id?: string
          name: string
          avatar_url: string
          email: string
          created_at?: string
          updated_at?: string
          role?: Database['public']['Enums']['role_enum']
          agency_id?: string | null
        }
        Update: {
          id?: string
          name?: string
          avatar_url?: string
          email?: string
          created_at?: string
          updated_at?: string
          role?: Database['public']['Enums']['role_enum']
          agency_id?: string | null
        }
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      action_type_enum: 'CREATE_CONTACT'
      icon_enum:
        | 'settings'
        | 'chart'
        | 'calendar'
        | 'check'
        | 'chip'
        | 'compass'
        | 'database'
        | 'flag'
        | 'home'
        | 'info'
        | 'link'
        | 'lock'
        | 'messages'
        | 'notification'
        | 'payment'
        | 'power'
        | 'receipt'
        | 'shield'
        | 'star'
        | 'tune'
        | 'videorecorder'
        | 'wallet'
        | 'warning'
        | 'headphone'
        | 'send'
        | 'pipelines'
        | 'person'
        | 'category'
        | 'contact'
        | 'clipboardIcon'
      invitation_status_enum: 'ACCEPTED' | 'REVOKED' | 'PENDING'
      plan_enum: 'price_1OYxkqFj9oKEERu1NbKUxXxN' | 'price_1OYxkqFj9oKEERu1KfJGWxgN'
      role_enum: 'AGENCY_OWNER' | 'AGENCY_ADMIN' | 'SUBACCOUNT_USER' | 'SUBACCOUNT_GUEST'
      trigger_types_enum: 'CONTACT_FORM'
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}
