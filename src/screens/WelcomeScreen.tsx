import { NativeStackScreenProps } from '@react-navigation/native-stack';
import React, { useState } from 'react';
import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { activityModes } from '../constants';
import type { RootStackParamList } from '../types';

type Props = NativeStackScreenProps<RootStackParamList, 'Welcome'>;

export default function WelcomeScreen({ navigation }: Props) {
  const [selectedMode, setSelectedMode] = useState(activityModes[0].value);

  return (
    <ScrollView contentContainerStyle={styles.container}>
      <Text style={styles.title}>Welcome to EcoTrack</Text>
      <Text style={styles.subtitle}>
        Choose how you want to track carbon emissions and build a profile for smarter sustainability.
      </Text>

      <View style={styles.optionList}>
        {activityModes.map((mode, index) => (
          <Pressable
            key={mode.value}
            onPress={() => setSelectedMode(mode.value)}
            style={[styles.optionCard, index < activityModes.length - 1 && styles.optionCardSpacer, selectedMode === mode.value && styles.optionCardSelected]}
          >
            <Text style={[styles.optionLabel, selectedMode === mode.value && styles.optionLabelSelected]}>
              {mode.label}
            </Text>
          </Pressable>
        ))}
      </View>

      <Pressable
        style={styles.button}
        onPress={() => navigation.navigate('ProfileSetup', { selectedMode })}
      >
        <Text style={styles.buttonText}>Create Profile</Text>
      </Pressable>

      <Text style={styles.note}>
        EcoTrack helps you track CO2 emissions for humans, cars, shipping, and more. Use the map to find shorter routes and stay ahead of traffic.
      </Text>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    padding: 24,
    backgroundColor: '#f3f9f2',
    minHeight: '100%',
  },
  title: {
    fontSize: 28,
    fontWeight: '700',
    marginBottom: 12,
  },
  subtitle: {
    fontSize: 16,
    marginBottom: 20,
    color: '#3c5a4d',
  },
  optionList: {
    flexDirection: 'column',
    marginBottom: 24,
  },
  optionCardSpacer: {
    marginBottom: 12,
  },
  optionCard: {
    backgroundColor: '#ffffff',
    borderRadius: 14,
    padding: 18,
    borderWidth: 1,
    borderColor: '#d0e4d0',
  },
  optionCardSelected: {
    backgroundColor: '#c8ebd0',
    borderColor: '#6aa96b',
  },
  optionLabel: {
    fontSize: 17,
    fontWeight: '600',
  },
  optionLabelSelected: {
    color: '#1f4f2f',
  },
  button: {
    backgroundColor: '#286c47',
    padding: 16,
    borderRadius: 14,
    alignItems: 'center',
    marginBottom: 16,
  },
  buttonText: {
    color: '#fff',
    fontWeight: '700',
    fontSize: 16,
  },
  note: {
    fontSize: 15,
    color: '#2b4b33',
    marginTop: 16,
    lineHeight: 22,
  },
});