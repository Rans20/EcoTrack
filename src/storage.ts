import { supabase } from './lib/supabase';
import type { Database } from './database.types';
import type { ActivityMode, EngineSize, Industry, UserProfile } from './types';

export type ActivityModeOption = { value: ActivityMode; label: string };
export type EmissionSuggestion = { id: string; mode: ActivityMode; suggestion: string };
export type RouteSuggestion = { id: string; name: string; benefit: string };

type ProfileRow = Database['public']['Tables']['profiles']['Row'];
type ProfileInsert = Database['public']['Tables']['profiles']['Insert'];
type LeaderboardRow = Database['public']['Views']['leaderboard']['Row'];

function fromRow(row: ProfileRow): UserProfile {
  return {
    id: row.id,
    fullName: row.full_name ?? '',
    heightCm: row.height_cm ?? '',
    weightKg: row.weight_kg ?? '',
    nationality: row.nationality ?? '',
    country: row.country ?? '',
    city: row.city ?? '',
    carEngineSize: (row.car_engine_size ?? '1.0L') as EngineSize,
    industry: (row.industry ?? 'Other') as Industry,
    activityMode: (row.activity_mode ?? 'personal') as ActivityMode,
    photoUri: row.photo_uri,
    createdAt: row.created_at,
  };
}

function toRow(p: Partial<UserProfile>, userId: string): ProfileInsert {
  return {
    id: userId,
    full_name: p.fullName,
    height_cm: p.heightCm,
    weight_kg: p.weightKg,
    nationality: p.nationality,
    country: p.country,
    city: p.city,
    car_engine_size: p.carEngineSize,
    industry: p.industry,
    activity_mode: p.activityMode,
    photo_uri: p.photoUri ?? null,
  };
}

export async function getCurrentUserProfile(): Promise<UserProfile | null> {
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return null;
  const { data, error } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', user.id)
    .maybeSingle();
  if (error) throw error;
  return data ? fromRow(data) : null;
}

export async function upsertUserProfile(
  profile: Partial<UserProfile>,
): Promise<UserProfile> {
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) throw new Error('Not authenticated');

  let photoUrl = profile.photoUri;
  if (photoUrl && photoUrl.startsWith('file://')) {
    try {
      const fileName = `${user.id}/avatar_${Date.now()}.jpg`;
      const formData = new FormData();
      // @ts-ignore
      formData.append('file', {
        uri: photoUrl,
        name: fileName,
        type: 'image/jpeg',
      });

      const { data: uploadData, error: uploadError } = await supabase.storage
        .from('avatars')
        .upload(fileName, formData, {
          contentType: 'image/jpeg',
          upsert: true,
        });

      if (uploadError) throw uploadError;

      const { data: { publicUrl } } = supabase.storage
        .from('avatars')
        .getPublicUrl(fileName);

      photoUrl = publicUrl;
    } catch (e) {
      console.warn('Avatar upload failed, continuing with local URI', e);
    }
  }

  const { data, error } = await supabase
    .from('profiles')
    .upsert(toRow({ ...profile, photoUri: photoUrl }, user.id))
    .select('*')
    .single();
  if (error) throw error;
  return fromRow(data);
}

export async function clearUserSession(): Promise<void> {
  await supabase.auth.signOut();
}

export async function getTodayCo2Kg(): Promise<number> {
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return 0;
  const since = new Date();
  since.setHours(0, 0, 0, 0);
  const { data, error } = await supabase
    .from('activities')
    .select('co2_kg')
    .eq('user_id', user.id)
    .gte('started_at', since.toISOString());
  if (error) throw error;
  return (data ?? []).reduce((sum, row) => sum + Number(row.co2_kg), 0);
}

export type LeaderboardEntry = LeaderboardRow;

export async function fetchLeaderboard(limit = 20): Promise<LeaderboardEntry[]> {
  const { data, error } = await supabase
    .from('leaderboard')
    .select('*')
    .limit(limit);
  if (error) throw error;
  return data ?? [];
}

export async function fetchActivityModes(): Promise<ActivityModeOption[]> {
  const { data, error } = await supabase
    .from('activity_modes')
    .select('value, label, sort_order')
    .order('sort_order');
  if (error) throw error;
  return (data ?? []).map((r) => ({
    value: r.value as ActivityMode,
    label: r.label,
  }));
}

export async function fetchEngineSizes(): Promise<EngineSize[]> {
  const { data, error } = await supabase
    .from('engine_sizes')
    .select('value, sort_order')
    .order('sort_order');
  if (error) throw error;
  return (data ?? []).map((r) => r.value as EngineSize);
}

export async function fetchIndustries(): Promise<Industry[]> {
  const { data, error } = await supabase
    .from('industries')
    .select('value, sort_order')
    .order('sort_order');
  if (error) throw error;
  return (data ?? []).map((r) => r.value as Industry);
}

export async function fetchEmissionSuggestion(
  mode: ActivityMode,
): Promise<EmissionSuggestion | null> {
  const { data, error } = await supabase
    .from('emission_suggestions')
    .select('id, mode, suggestion')
    .eq('mode', mode);
  if (error) throw error;
  if (!data || data.length === 0) return null;
  const pick = data[Math.floor(Math.random() * data.length)];
  return {
    id: pick.id,
    mode: pick.mode as ActivityMode,
    suggestion: pick.suggestion,
  };
}

export async function fetchRouteSuggestions(): Promise<RouteSuggestion[]> {
  const { data, error } = await supabase
    .from('route_suggestions')
    .select('id, name, benefit, sort_order')
    .order('sort_order');
  if (error) throw error;
  return (data ?? []).map((r) => ({ id: r.id, name: r.name, benefit: r.benefit }));
}
