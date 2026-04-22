import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { LinearGradient } from 'expo-linear-gradient';
import { Activity, ArrowRight, BarChart3, Map as MapIcon, Navigation, Wind, CloudRain, Sun, Cloud, LayoutDashboard, MapPinned, Medal, PieChart, TrendingUp, Leaf, Zap } from 'lucide-react-native';
import React, { useEffect, useState } from 'react';
import { Dimensions, Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { COLORS } from '../constants';
import { fetchEmissionSuggestion, getCurrentUserProfile, getTodayCo2Kg } from '../storage';
import type { RootStackParamList, UserProfile } from '../types';

type Props = NativeStackScreenProps<RootStackParamList, 'Home'>;

const { width } = Dimensions.get('window');

type WeatherCondition = 'Sunny' | 'Rainy' | 'Cloudy';

export default function HomeScreen({ navigation, route }: Props) {
  const [profile, setProfile] = useState<UserProfile | null>(route.params?.profile ?? null);
  const [moving, setMoving] = useState(false);
  const [todayCo2, setTodayCo2] = useState<number>(0);
  const [tip, setTip] = useState<string | null>(null);
  const [weather, setWeather] = useState<WeatherCondition>('Sunny');

  useEffect(() => {
    if (!profile) {
      getCurrentUserProfile().then((storedProfile) => {
        if (storedProfile) setProfile(storedProfile);
      });
    }
  }, [profile]);

  useEffect(() => {
    getTodayCo2Kg().then(setTodayCo2).catch(() => setTodayCo2(0));
  }, []);

  useEffect(() => {
    const mode = profile?.activityMode ?? 'personal';
    fetchEmissionSuggestion(mode)
      .then((s) => setTip(s?.suggestion ?? null))
      .catch(() => setTip(null));
  }, [profile?.activityMode]);

  // Simulate movement data collection
  useEffect(() => {
    const interval = setInterval(() => {
      setMoving(prev => !prev);
    }, 5000);

    const weatherConditions: WeatherCondition[] = ['Sunny', 'Rainy', 'Cloudy'];
    setWeather(weatherConditions[Math.floor(Math.random() * weatherConditions.length)]);

    return () => clearInterval(interval);
  }, []);

  const getWeatherIcon = () => {
    switch (weather) {
      case 'Rainy': return <CloudRain size={24} color="#4A90E2" />;
      case 'Cloudy': return <Cloud size={24} color="#9B9B9B" />;
      default: return <Sun size={24} color="#F5A623" />;
    }
  };

  const getWeatherSuggestion = () => {
    switch (weather) {
      case 'Rainy':
        return "It's raining. Consider using public transport instead of driving to reduce emissions safely.";
      case 'Cloudy':
        return "Cooler weather today. Perfect for a brisk walk or hike to your destination!";
      default:
        return "It's a sunny day! Great time to bike or walk and soak up some Vitamin D while saving CO₂.";
    }
  };

  const selectedMode = profile?.activityMode || 'personal';

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <View style={styles.header}>
        <View>
          <Text style={styles.greeting}>Hello, {profile?.fullName?.split(' ')[0] ?? 'EcoTracker'}</Text>
          <Text style={styles.date}>{new Date().toLocaleDateString('en-US', { month: 'long', day: 'numeric' })}</Text>
        </View>
        <View style={styles.avatar}>
           <Text style={styles.avatarText}>{profile?.fullName?.[0] ?? 'E'}</Text>
        </View>
      </View>

      {/* Weather AI Card */}
      <View style={styles.weatherCard}>
        <View style={styles.weatherInfo}>
          {getWeatherIcon()}
          <Text style={styles.weatherTemp}>{weather} • 22°C</Text>
        </View>
        <View style={styles.aiBadge}>
          <Text style={styles.aiBadgeText}>AI Eco-Advisor</Text>
        </View>
        <Text style={styles.weatherAdvice}>{getWeatherSuggestion()}</Text>
      </View>

      {/* 3D-ish Dashboard Card */}
      <LinearGradient
        colors={[COLORS.primary, '#00796B']}
        style={styles.mainDashboard}
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 1 }}
      >
        <View style={styles.dashHeader}>
          <Text style={styles.dashTitle}>Live CO₂ Impact</Text>
          <View style={[styles.statusBadge, moving && styles.statusBadgeActive]}>
            <Activity size={12} color={moving ? '#39FF14' : '#fff'} />
            <Text style={styles.statusText}>{moving ? 'Moving' : 'Stationary'}</Text>
          </View>
        </View>

        <View style={styles.statsContainer}>
          <View>
            <Text style={styles.mainStat}>{todayCo2.toFixed(1)}</Text>
            <Text style={styles.mainStatUnit}>kg CO₂ today</Text>
          </View>
          <View style={styles.verticalDivider} />
          <View>
            <Text style={styles.mainStat}>142</Text>
            <Text style={styles.mainStatUnit}>Points earned</Text>
          </View>
        </View>
      </LinearGradient>

      <View style={styles.sectionHeader}>
        <Text style={styles.sectionTitle}>Eco Actions</Text>
      </View>

      <View style={styles.grid}>
        <Pressable
          style={styles.gridCard}
          onPress={() => navigation.navigate('Map')}
        >
          <View style={[styles.iconCircle, { backgroundColor: COLORS.primaryTransparent }]}>
            <MapPinned size={32} color={COLORS.primary} strokeWidth={2.5} />
          </View>
          <Text style={styles.cardLabel}>Eco Maps</Text>
          <Text style={styles.cardSubLabel}>Smart routes</Text>
        </Pressable>

        <Pressable
          style={styles.gridCard}
          onPress={() => navigation.navigate('Analytics')}
        >
          <View style={[styles.iconCircle, { backgroundColor: 'rgba(128, 185, 24, 0.1)' }]}>
            <PieChart size={32} color={COLORS.secondary} strokeWidth={2.5} />
          </View>
          <Text style={styles.cardLabel}>Analytics</Text>
          <Text style={styles.cardSubLabel}>CO2 Insights</Text>
        </Pressable>

        <Pressable
          style={styles.gridCard}
          onPress={() => navigation.navigate('Leaderboard')}
        >
          <View style={[styles.iconCircle, { backgroundColor: '#FFF3E0' }]}>
            <Medal size={32} color="#EF6C00" strokeWidth={2.5} />
          </View>
          <Text style={styles.cardLabel}>Global Board</Text>
          <Text style={styles.cardSubLabel}>Top Savers</Text>
        </Pressable>

        <View style={styles.gridCard}>
          <View style={[styles.iconCircle, { backgroundColor: '#E3F2FD' }]}>
            <TrendingUp size={32} color="#1565C0" strokeWidth={2.5} />
          </View>
          <Text style={styles.cardLabel}>Milestones</Text>
          <Text style={styles.cardSubLabel}>Achievements</Text>
        </View>
      </View>

      <View style={styles.suggestionCard}>
        <View style={styles.suggestionHeader}>
          <Text style={styles.suggestionTitle}>AI Tip of the Day</Text>
          <ArrowRight size={18} color={COLORS.dark} />
        </View>
        <Text style={styles.suggestionText}>
          {tip ?? 'Loading your personalized tip…'}
        </Text>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
  },
  content: {
    padding: 20,
    paddingTop: 60,
    paddingBottom: 100,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 24,
  },
  greeting: {
    fontSize: 26,
    fontWeight: '800',
    color: COLORS.dark,
  },
  date: {
    fontSize: 14,
    color: COLORS.primary,
    fontWeight: '600',
  },
  avatar: {
    width: 52,
    height: 52,
    borderRadius: 26,
    backgroundColor: COLORS.primaryTransparent,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 2,
    borderColor: COLORS.primary,
    shadowColor: COLORS.dark,
    shadowOpacity: 0.1,
    shadowRadius: 10,
    elevation: 3,
  },
  avatarText: {
    fontSize: 18,
    fontWeight: '700',
    color: COLORS.dark,
  },
  weatherCard: {
    backgroundColor: COLORS.white,
    borderRadius: 28,
    padding: 20,
    marginBottom: 24,
    shadowColor: COLORS.dark,
    shadowOffset: { width: 0, height: 10 },
    shadowOpacity: 0.08,
    shadowRadius: 20,
    elevation: 5,
    position: 'relative',
    overflow: 'hidden',
    borderWidth: 1,
    borderColor: COLORS.lightGray,
  },
  weatherInfo: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    marginBottom: 14,
  },
  weatherTemp: {
    fontSize: 20,
    fontWeight: '800',
    color: COLORS.dark,
  },
  aiBadge: {
    position: 'absolute',
    top: 20,
    right: 20,
    backgroundColor: COLORS.primaryTransparent,
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 10,
  },
  aiBadgeText: {
    fontSize: 10,
    fontWeight: '900',
    color: COLORS.primary,
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  weatherAdvice: {
    fontSize: 15,
    color: COLORS.dark,
    lineHeight: 22,
    fontWeight: '600',
    opacity: 0.8,
  },
  mainDashboard: {
    borderRadius: 32,
    padding: 28,
    marginBottom: 24,
    shadowColor: COLORS.primary,
    shadowOffset: { width: 0, height: 15 },
    shadowOpacity: 0.25,
    shadowRadius: 20,
    elevation: 10,
  },
  dashHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 20,
  },
  dashTitle: {
    color: 'rgba(255,255,255,0.8)',
    fontSize: 16,
    fontWeight: '600',
  },
  statusBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(255,255,255,0.15)',
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 12,
    gap: 6,
  },
  statusBadgeActive: {
    backgroundColor: 'rgba(57, 255, 20, 0.2)',
  },
  statusText: {
    color: '#fff',
    fontSize: 12,
    fontWeight: '700',
  },
  statsContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-around',
  },
  mainStat: {
    fontSize: 36,
    fontWeight: '800',
    color: '#fff',
    textAlign: 'center',
  },
  mainStatUnit: {
    fontSize: 13,
    color: 'rgba(255,255,255,0.7)',
    textAlign: 'center',
    marginTop: -4,
  },
  verticalDivider: {
    width: 1,
    height: 40,
    backgroundColor: 'rgba(255,255,255,0.2)',
  },
  sectionHeader: {
    marginBottom: 16,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '700',
    color: COLORS.dark,
  },
  grid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
    gap: 16,
    marginBottom: 24,
  },
  gridCard: {
    width: (width - 56) / 2,
    backgroundColor: COLORS.white,
    borderRadius: 28,
    padding: 20,
    shadowColor: COLORS.dark,
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.08,
    shadowRadius: 15,
    elevation: 4,
    borderWidth: 1,
    borderColor: COLORS.lightGray,
  },
  iconCircle: {
    width: 56,
    height: 56,
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.1,
    shadowRadius: 5,
    elevation: 2,
  },
  cardLabel: {
    fontSize: 16,
    fontWeight: '800',
    color: COLORS.dark,
  },
  cardSubLabel: {
    fontSize: 13,
    color: COLORS.secondary,
    marginTop: 4,
    fontWeight: '500',
  },
  suggestionCard: {
    backgroundColor: COLORS.primaryTransparent,
    borderRadius: 28,
    padding: 24,
    marginBottom: 20,
    borderWidth: 1,
    borderColor: COLORS.primary,
  },
  suggestionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  suggestionTitle: {
    fontSize: 16,
    fontWeight: '700',
    color: COLORS.dark,
  },
  suggestionText: {
    fontSize: 14,
    color: COLORS.primary,
    lineHeight: 20,
    fontWeight: '500',
  },
});
