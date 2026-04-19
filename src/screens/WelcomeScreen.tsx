import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { Leaf, ShieldCheck, Zap, Globe, Sparkles } from 'lucide-react-native';
import React, { useEffect, useState } from 'react';
import { Pressable, SafeAreaView, StyleSheet, Text, View, Image } from 'react-native';
import { signInWithGoogle } from '../lib/auth';
import { fetchActivityModes } from '../storage';
import type { ActivityMode, RootStackParamList } from '../types';

type Props = NativeStackScreenProps<RootStackParamList, 'Welcome'>;

export default function WelcomeScreen({ navigation }: Props) {
  const [selectedMode, setSelectedMode] = useState<ActivityMode>('personal');

  useEffect(() => {
    fetchActivityModes()
      .then((rows) => {
        if (rows.length > 0) setSelectedMode(rows[0].value);
      })
      .catch((e) => console.warn('Failed to load activity modes', e));
  }, []);

  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.container}>
        <View style={styles.imageContainer}>
           <Image
             source={require('../../assets/splash-icon.png')}
             style={styles.logo}
             resizeMode="contain"
           />
        </View>

        <View style={styles.content}>
          <Text style={styles.title}>Small Steps, Big Impact</Text>
          <Text style={styles.subtitle}>
            Join thousands of eco-conscious users tracking their daily habits to build a greener future.
          </Text>

          <View style={styles.habitTrackingSection}>
            <View style={styles.habitCard}>
              <View style={[styles.iconBox, { backgroundColor: '#E8F5E9' }]}>
                <Zap size={24} color="#2D6A4F" strokeWidth={2.5} />
              </View>
              <View>
                <Text style={styles.habitTitle}>Energy Tracking</Text>
                <Text style={styles.habitText}>Monitor daily carbon output</Text>
              </View>
            </View>
            <View style={styles.habitCard}>
              <View style={[styles.iconBox, { backgroundColor: '#F1F8E9' }]}>
                <Globe size={24} color="#558B2F" strokeWidth={2.5} />
              </View>
              <View>
                <Text style={styles.habitTitle}>Sustainable Routes</Text>
                <Text style={styles.habitText}>AI-powered eco-navigation</Text>
              </View>
            </View>
          </View>
        </View>

        <View style={styles.footer}>
          <Pressable
            style={styles.primaryButton}
            onPress={() => navigation.navigate('ProfileSetup', { selectedMode })}
          >
            <Text style={styles.primaryButtonText}>Get Started</Text>
          </Pressable>

          <Pressable
            style={styles.secondaryButton}
            onPress={async () => {
              try {
                await signInWithGoogle();
              } catch (e) {
                console.warn('Google sign-in failed', e);
              }
            }}
          >
            <Text style={styles.secondaryButtonText}>Sign in with Google</Text>
          </Pressable>
        </View>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: '#F7FBF7',
  },
  container: {
    flex: 1,
    padding: 24,
    justifyContent: 'space-between',
  },
  imageContainer: {
    alignItems: 'center',
    marginTop: 60,
  },
  logo: {
    width: 280,
    height: 180,
  },
  content: {
    marginTop: 0,
  },
  title: {
    fontSize: 34,
    fontWeight: '800',
    color: '#1B4332',
    textAlign: 'center',
    marginBottom: 12,
  },
  subtitle: {
    fontSize: 16,
    color: '#409167',
    textAlign: 'center',
    lineHeight: 24,
    marginBottom: 40,
    fontWeight: '500',
  },
  habitTrackingSection: {
    gap: 16,
  },
  habitCard: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#fff',
    padding: 20,
    borderRadius: 28,
    gap: 16,
    shadowColor: '#1B4332',
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.08,
    shadowRadius: 15,
    elevation: 4,
    borderWidth: 1,
    borderColor: '#F0F7F0',
  },
  iconBox: {
    width: 48,
    height: 48,
    borderRadius: 16,
    justifyContent: 'center',
    alignItems: 'center',
  },
  habitTitle: {
    fontSize: 16,
    fontWeight: '800',
    color: '#1B4332',
  },
  habitText: {
    fontSize: 14,
    color: '#52B788',
    fontWeight: '500',
    marginTop: 2,
  },
  footer: {
    gap: 16,
    marginBottom: 30,
  },
  primaryButton: {
    backgroundColor: '#2D6A4F',
    paddingVertical: 20,
    borderRadius: 24,
    alignItems: 'center',
    shadowColor: '#1B4332',
    shadowOffset: { width: 0, height: 10 },
    shadowOpacity: 0.25,
    shadowRadius: 15,
    elevation: 8,
  },
  primaryButtonText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: '800',
  },
  secondaryButton: {
    paddingVertical: 18,
    borderRadius: 24,
    alignItems: 'center',
    borderWidth: 2,
    borderColor: '#D8F3DC',
    backgroundColor: '#fff',
  },
  secondaryButtonText: {
    color: '#2D6A4F',
    fontSize: 16,
    fontWeight: '700',
  },
});
