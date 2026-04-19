import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { Leaf, ShieldCheck, Zap } from 'lucide-react-native';
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
             source={require('../../assets/ecotrack_logo_new.png')}
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
              <Zap size={24} color="#D4A373" />
              <Text style={styles.habitText}>Track energy & transport</Text>
            </View>
            <View style={styles.habitCard}>
              <ShieldCheck size={24} color="#A3B18A" />
              <Text style={styles.habitText}>Build sustainable habits</Text>
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
    backgroundColor: '#FAF9F6', // Off-white/Cream
  },
  container: {
    flex: 1,
    padding: 24,
    justifyContent: 'space-between',
  },
  imageContainer: {
    alignItems: 'center',
    marginTop: 40,
  },
  logo: {
    width: 250,
    height: 150,
  },
  content: {
    marginTop: 20,
  },
  title: {
    fontSize: 32,
    fontWeight: '700',
    color: '#344E41', // Darker forest green
    textAlign: 'center',
    marginBottom: 16,
  },
  subtitle: {
    fontSize: 16,
    color: '#588157',
    textAlign: 'center',
    lineHeight: 24,
    marginBottom: 32,
  },
  habitTrackingSection: {
    gap: 12,
  },
  habitCard: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#fff',
    padding: 16,
    borderRadius: 20,
    gap: 12,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 10,
    elevation: 2,
  },
  habitText: {
    fontSize: 16,
    color: '#3A5A40',
    fontWeight: '500',
  },
  footer: {
    gap: 12,
    marginBottom: 20,
  },
  primaryButton: {
    backgroundColor: '#588157',
    paddingVertical: 18,
    borderRadius: 24,
    alignItems: 'center',
    shadowColor: '#588157',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 4,
  },
  primaryButtonText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: '700',
  },
  secondaryButton: {
    paddingVertical: 18,
    borderRadius: 24,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#DAD7CD',
  },
  secondaryButtonText: {
    color: '#3A5A40',
    fontSize: 16,
    fontWeight: '600',
  },
});
