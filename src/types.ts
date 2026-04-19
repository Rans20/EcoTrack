export type ActivityMode = 'personal' | 'driving' | 'biking' | 'shipping';
export type Industry = 'Transport' | 'Maritime' | 'Aviation' | 'Recycling' | 'Energy' | 'Agriculture' | 'Other';
export type EngineSize = '1.0L' | '1.2L' | '1.4L' | '1.6L' | '2.0L' | '2.5L' | '3.0L+' | 'Electric' | 'Hybrid';

export interface UserProfile {
  id: string;
  fullName: string;
  heightCm: string;
  weightKg: string;
  country: string;
  city: string;
  carEngineSize: EngineSize;
  industry: Industry;
  activityMode: ActivityMode;
  photoUri: string | null;
  createdAt: string;
}

export type RootStackParamList = {
  Welcome: undefined;
  ProfileSetup: { selectedMode?: ActivityMode } | undefined;
  Home: { profile?: UserProfile } | undefined;
  Map: undefined;
  Analytics: undefined;
  Leaderboard: undefined;
};
