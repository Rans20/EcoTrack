import { NativeStackScreenProps } from '@react-navigation/native-stack';
import React, { useEffect, useState } from 'react';
import { Linking, Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { loadUserProfile } from '../storage';
import { emissionSuggestions } from '../constants';
import type { RootStackParamList, UserProfile } from '../types';

type Props = NativeStackScreenProps<RootStackParamList, 'Home'>;

export default function HomeScreen({ navigation, route }: Props) {
  const [profile, setProfile] = useState<UserProfile | null>(route.params?.profile ?? null);

  useEffect(() => {
    if (!profile) {
      loadUserProfile().then((storedProfile) => {
        if (storedProfile) {
          setProfile(storedProfile);
        }
      });
    }
  }, [profile]);

  const selectedMode = profile?.activityMode || 'personal';
  const suggestions = emissionSuggestions[selectedMode];

  function openMap() {
    navigation.navigate('Map');
  }

  function openLeaderboard() {
    navigation.navigate('Leaderboard');
  }

  return (
    <ScrollView contentContainerStyle={styles.container}>
      <Text style={styles.welcome}>Hello, {profile?.fullName ?? 'EcoTracker'}!</Text>
      <Text style={styles.subtitle}>Your unique EcoTrack ID: {profile?.id ?? 'Not available yet'}</Text>

      <View style={styles.card}>
        <Text style={styles.cardTitle}>Profile Summary</Text>
        <Text style={styles.cardText}>Mode: {selectedMode}</Text>
        <Text style={styles.cardText}>Industry: {profile?.industry ?? 'N/A'}</Text>
        <Text style={styles.cardText}>Location: {profile?.city}, {profile?.country}</Text>
        <Text style={styles.cardText}>Car Engine: {profile?.carEngineSize}</Text>
      </View>

      <View style={styles.card}>
        <Text style={styles.cardTitle}>Recommended Actions</Text>
        {suggestions.map((item) => (
          <Text key={item} style={styles.cardText}>• {item}</Text>
        ))}
      </View>

      <View style={styles.card}>
        <Text style={styles.cardTitle}>CO₂ Tracker</Text>
        <Text style={styles.cardText}>Based on your profile, the app will estimate emissions for daily travel and suggest reductions.</Text>
        <Pressable style={styles.linkButton} onPress={() => Linking.openURL('https://www.epa.gov/energy/greenhouse-gas-equivalencies-calculator')}> 
          <Text style={styles.linkText}>Learn more about CO₂ emissions</Text>
        </Pressable>
      </View>

      <Pressable style={styles.button} onPress={openMap}>
        <Text style={styles.buttonText}>Open Route Map</Text>
      </Pressable>
      <Pressable style={styles.secondaryButton} onPress={openLeaderboard}>
        <Text style={styles.secondaryButtonText}>View City / Country Leaderboard</Text>
      </Pressable>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    padding: 22,
    backgroundColor: '#f4faf2',
    minHeight: '100%',
  },
  welcome: {
    fontSize: 26,
    fontWeight: '700',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 14,
    color: '#4b5a48',
    marginBottom: 18,
  },
  card: {
    backgroundColor: '#ffffff',
    borderRadius: 16,
    padding: 18,
    marginBottom: 16,
    borderWidth: 1,
    borderColor: '#d6e6d4',
  },
  cardTitle: {
    fontSize: 18,
    fontWeight: '700',
    marginBottom: 12,
  },
  cardText: {
    fontSize: 15,
    lineHeight: 22,
    color: '#3a4b3a',
  },
  linkButton: {
    marginTop: 12,
  },
  linkText: {
    color: '#1f6e45',
    fontWeight: '700',
  },
  button: {
    backgroundColor: '#2d724d',
    padding: 16,
    borderRadius: 14,
    alignItems: 'center',
    marginBottom: 12,
  },
  buttonText: {
    color: '#fff',
    fontWeight: '700',
  },
  secondaryButton: {
    borderColor: '#2d724d',
    borderWidth: 1,
    padding: 16,
    borderRadius: 14,
    alignItems: 'center',
  },
  secondaryButtonText: {
    color: '#2d724d',
    fontWeight: '700',
  },
});