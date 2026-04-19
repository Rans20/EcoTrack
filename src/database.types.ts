// Stub of the Supabase Database type, shaped to match supabase/migrations/0001_init.sql.
// Replace this file by running `npm run gen:types` once the schema is applied and
// you have logged in via `npx supabase login`.

export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[];

export interface Database {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string;
          full_name: string;
          height_cm: string | null;
          weight_kg: string | null;
          country: string | null;
          city: string | null;
          car_engine_size: string | null;
          industry: string | null;
          activity_mode: string | null;
          photo_uri: string | null;
          created_at: string;
        };
        Insert: {
          id: string;
          full_name?: string;
          height_cm?: string | null;
          weight_kg?: string | null;
          country?: string | null;
          city?: string | null;
          car_engine_size?: string | null;
          industry?: string | null;
          activity_mode?: string | null;
          photo_uri?: string | null;
          created_at?: string;
        };
        Update: Partial<Database['public']['Tables']['profiles']['Insert']>;
        Relationships: [];
      };
      activities: {
        Row: {
          id: string;
          user_id: string;
          mode: string;
          distance_km: number;
          duration_minutes: number;
          co2_kg: number;
          started_at: string;
          created_at: string;
        };
        Insert: {
          id?: string;
          user_id: string;
          mode: string;
          distance_km?: number;
          duration_minutes?: number;
          co2_kg?: number;
          started_at?: string;
          created_at?: string;
        };
        Update: Partial<Database['public']['Tables']['activities']['Insert']>;
        Relationships: [];
      };
      activity_modes: {
        Row: { value: string; label: string; sort_order: number };
        Insert: { value: string; label: string; sort_order?: number };
        Update: Partial<Database['public']['Tables']['activity_modes']['Insert']>;
        Relationships: [];
      };
      engine_sizes: {
        Row: { value: string; sort_order: number };
        Insert: { value: string; sort_order?: number };
        Update: Partial<Database['public']['Tables']['engine_sizes']['Insert']>;
        Relationships: [];
      };
      industries: {
        Row: { value: string; sort_order: number };
        Insert: { value: string; sort_order?: number };
        Update: Partial<Database['public']['Tables']['industries']['Insert']>;
        Relationships: [];
      };
      emission_suggestions: {
        Row: { id: string; mode: string; suggestion: string; sort_order: number };
        Insert: { id?: string; mode: string; suggestion: string; sort_order?: number };
        Update: Partial<Database['public']['Tables']['emission_suggestions']['Insert']>;
        Relationships: [];
      };
      route_suggestions: {
        Row: { id: string; name: string; benefit: string; sort_order: number };
        Insert: { id?: string; name: string; benefit: string; sort_order?: number };
        Update: Partial<Database['public']['Tables']['route_suggestions']['Insert']>;
        Relationships: [];
      };
    };
    Views: {
      leaderboard: {
        Row: {
          id: string | null;
          full_name: string | null;
          photo_uri: string | null;
          city: string | null;
          country: string | null;
          activity_mode: string | null;
          total_co2_kg: number | null;
          activity_count: number | null;
        };
        Relationships: [];
      };
      daily_co2: {
        Row: {
          user_id: string | null;
          day: string | null;
          co2_kg: number | null;
        };
        Relationships: [];
      };
    };
    Functions: Record<string, never>;
    Enums: Record<string, never>;
    CompositeTypes: Record<string, never>;
  };
}
