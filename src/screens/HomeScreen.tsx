import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { LinearGradient } from 'expo-linear-gradient';
import { Activity, ArrowRight, BarChart3, Map as MapIcon, Navigation, Wind, CloudRain, Sun, Cloud } from 'lucide-react-native';
import React, { useEffect, useState } from 'react';
import { Dimensions, Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
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
        colors={['#588157', '#3A5A40']}
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
          <View style={[styles.iconCircle, { backgroundColor: '#E9EDC9' }]}>
            <Navigation size={24} color="#588157" />
          </View>
          <Text style={styles.cardLabel}>Route Map</Text>
          <Text style={styles.cardSubLabel}>Smarter travel</Text>
        </Pressable>

        <Pressable
          style={styles.gridCard}
          onPress={() => navigation.navigate('Analytics')}
        >
          <View style={[styles.iconCircle, { backgroundColor: '#D8F3DC' }]}>
            <BarChart3 size={24} color="#2D6A4F" />
          </View>
          <Text style={styles.cardLabel}>Analytics</Text>
          <Text style={styles.cardSubLabel}>Trend insights</Text>
        </Pressable>

        <Pressable
          style={styles.gridCard}
          onPress={() => navigation.navigate('Leaderboard')}
        >
          <View style={[styles.iconCircle, { backgroundColor: '#FFE8D6' }]}>
            <Wind size={24} color="#A68A64" />
          </View>
          <Text style={styles.cardLabel}>Community</Text>
          <Text style={styles.cardSubLabel}>Compare stats</Text>
        </Pressable>

        <View style={styles.gridCard}>
          <View style={[styles.iconCircle, { backgroundColor: '#E0E1DD' }]}>
            <MapIcon size={24} color="#415A77" />
          </View>
          <Text style={styles.cardLabel}>History</Text>
          <Text style={styles.cardSubLabel}>Past routes</Text>
        </View>
      </View>

      <View style={styles.suggestionCard}>
        <View style={styles.suggestionHeader}>
          <Text style={styles.suggestionTitle}>AI Tip of the Day</Text>
          <ArrowRight size={18} color="#344E41" />
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
    backgroundColor: '#FAF9F6',
  },
  content: {
    padding: 20,
    paddingTop: 60,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 24,
  },
  greeting: {
    fontSize: 24,
    fontWeight: '700',
    color: '#344E41',
  },
  date: {
    fontSize: 14,
    color: '#A3B18A',
    fontWeight: '500',
  },
  avatar: {
    width: 48,
    height: 48,
    borderRadius: 24,
    backgroundColor: '#E9EDC9',
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 2,
    borderColor: '#CCD5AE',
  },
  avatarText: {
    fontSize: 18,
    fontWeight: '700',
    color: '#344E41',
  },
  weatherCard: {
    backgroundColor: '#fff',
    borderRadius: 24,
    padding: 16,
    marginBottom: 24,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 10,
    elevation: 2,
    position: 'relative',
    overflow: 'hidden',
  },
  weatherInfo: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
    marginBottom: 12,
  },
  weatherTemp: {
    fontSize: 18,
    fontWeight: '700',
    color: '#344E41',
  },
  aiBadge: {
    position: 'absolute',
    top: 16,
    right: 16,
    backgroundColor: '#E9EDC9',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 8,
  },
  aiBadgeText: {
    fontSize: 10,
    fontWeight: '800',
    color: '#588157',
    textTransform: 'uppercase',
  },
  weatherAdvice: {
    fontSize: 14,
    color: '#588157',
    lineHeight: 20,
    fontWeight: '500',
  },
  mainDashboard: {
    borderRadius: 28,
    padding: 24,
    marginBottom: 24,
    shadowColor: '#3A5A40',
    shadowOffset: { width: 0, height: 10 },
    shadowOpacity: 0.2,
    shadowRadius: 15,
    elevation: 8,
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
    color: '#344E41',
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
    backgroundColor: '#fff',
    borderRadius: 24,
    padding: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 10,
    elevation: 2,
  },
  iconCircle: {
    width: 44,
    height: 44,
    borderRadius: 14,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 12,
  },
  cardLabel: {
    fontSize: 15,
    fontWeight: '700',
    color: '#344E41',
  },
  cardSubLabel: {
    fontSize: 12,
    color: '#A3B18A',
    marginTop: 2,
  },
  suggestionCard: {
    backgroundColor: '#E9EDC9',
    borderRadius: 24,
    padding: 20,
    marginBottom: 20,
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
    color: '#344E41',
  },
  suggestionText: {
    fontSize: 14,
    color: '#588157',
    lineHeight: 20,
    fontWeight: '500',
  },
});
