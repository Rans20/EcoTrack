import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { Picker } from '@react-native-picker/picker';
import * as ImagePicker from 'expo-image-picker';
import React, { useEffect, useState } from 'react';
import {
  Image,
  KeyboardAvoidingView,
  Platform,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  TextInput,
  View,
} from 'react-native';
import { activityModes, engineSizes, industries } from '../constants';
import { saveUserProfile } from '../storage';
import type { ActivityMode, EngineSize, Industry, UserProfile, RootStackParamList } from '../types';

type Props = NativeStackScreenProps<RootStackParamList, 'ProfileSetup'>;

function generateUniqueId(): string {
  return `ecotrack-${Date.now()}-${Math.floor(Math.random() * 100000)}`;
}

export default function ProfileSetupScreen({ route, navigation }: Props) {
  const { selectedMode } = route.params;
  const [fullName, setFullName] = useState('');
  const [heightCm, setHeightCm] = useState('');
  const [weightKg, setWeightKg] = useState('');
  const [country, setCountry] = useState('');
  const [city, setCity] = useState('');
  const [carEngineSize, setCarEngineSize] = useState<EngineSize>(engineSizes[0]);
  const [industry, setIndustry] = useState<Industry>(industries[0]);
  const [photoUri, setPhotoUri] = useState<string | null>(null);

  useEffect(() => {
    ImagePicker.requestMediaLibraryPermissionsAsync();
  }, []);

  async function pickImage() {
    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: 'images',
      allowsEditing: true,
      aspect: [1, 1],
      quality: 0.7,
    });

    if (!result.canceled && result.assets.length > 0) {
      setPhotoUri(result.assets[0].uri);
    }
  }

  async function handleSubmit() {
    if (!fullName || !country || !city || !heightCm || !weightKg) {
      return;
    }

    const profile: UserProfile = {
      id: generateUniqueId(),
      fullName,
      heightCm,
      weightKg,
      country,
      city,
      carEngineSize,
      industry,
      activityMode: selectedMode,
      photoUri,
      createdAt: new Date().toISOString(),
    };

    await saveUserProfile(profile);
    navigation.reset({ index: 0, routes: [{ name: 'Home', params: { profile } }] });
  }

  return (
    <KeyboardAvoidingView style={{ flex: 1 }} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
      <ScrollView contentContainerStyle={styles.container}>
        <Text style={styles.header}>Create your EcoTrack profile</Text>
        <Text style={styles.description}>
          Complete the profile below to receive tailored CO₂ recommendations for your selected mode: {selectedMode}.
        </Text>

        <Pressable style={styles.photoUpload} onPress={pickImage}>
          {photoUri ? (
            <Image source={{ uri: photoUri }} style={styles.photo} />
          ) : (
            <Text style={styles.photoText}>Upload Profile Picture</Text>
          )}
        </Pressable>

        <View style={styles.fieldGroup}>
          <Text style={styles.label}>Full Name</Text>
          <TextInput style={styles.input} value={fullName} onChangeText={setFullName} placeholder="Jane Doe" />
        </View>

        <View style={styles.fieldRow}>
          <View style={[styles.fieldHalf, styles.fieldRightPadding]}>
            <Text style={styles.label}>Height (cm)</Text>
            <TextInput
              keyboardType="numeric"
              style={styles.input}
              value={heightCm}
              onChangeText={setHeightCm}
              placeholder="170"
            />
          </View>
          <View style={styles.fieldHalf}>
            <Text style={styles.label}>Weight (kg)</Text>
            <TextInput
              keyboardType="numeric"
              style={styles.input}
              value={weightKg}
              onChangeText={setWeightKg}
              placeholder="65"
            />
          </View>
        </View>

        <View style={styles.fieldRow}>
          <View style={styles.fieldHalf}>
            <Text style={styles.label}>Country</Text>
            <TextInput style={styles.input} value={country} onChangeText={setCountry} placeholder="Spain" />
          </View>
          <View style={styles.fieldHalf}>
            <Text style={styles.label}>City</Text>
            <TextInput style={styles.input} value={city} onChangeText={setCity} placeholder="Barcelona" />
          </View>
        </View>

        <View style={styles.pickerGroup}>
          <Text style={styles.label}>Car Engine Size</Text>
          <View style={styles.pickerBox}>
            <Picker selectedValue={carEngineSize} onValueChange={(value) => setCarEngineSize(value as EngineSize)}>
              {engineSizes.map((size) => (
                <Picker.Item key={size} label={size} value={size} />
              ))}
            </Picker>
          </View>
        </View>

        <View style={styles.pickerGroup}>
          <Text style={styles.label}>Industry</Text>
          <View style={styles.pickerBox}>
            <Picker selectedValue={industry} onValueChange={(value) => setIndustry(value as Industry)}>
              {industries.map((option) => (
                <Picker.Item key={option} label={option} value={option} />
              ))}
            </Picker>
          </View>
        </View>

        <Pressable style={styles.button} onPress={handleSubmit}>
          <Text style={styles.buttonText}>Save Profile & Continue</Text>
        </Pressable>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: {
    padding: 22,
    backgroundColor: '#eef7ee',
    minHeight: '100%',
  },
  header: {
    fontSize: 24,
    fontWeight: '700',
    marginBottom: 12,
  },
  description: {
    lineHeight: 22,
    color: '#3b4f3d',
    marginBottom: 24,
  },
  photoUpload: {
    backgroundColor: '#dcead7',
    borderRadius: 16,
    height: 140,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 22,
  },
  photoText: {
    color: '#3c5a47',
    fontWeight: '600',
  },
  photo: {
    width: 120,
    height: 120,
    borderRadius: 60,
  },
  fieldGroup: {
    marginBottom: 18,
  },
  fieldRow: {
    flexDirection: 'row',
    marginBottom: 18,
  },
  fieldRightPadding: {
    marginRight: 14,
  },
  fieldHalf: {
    flex: 1,
  },
  label: {
    fontWeight: '700',
    marginBottom: 8,
  },
  input: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
    paddingVertical: 12,
    paddingHorizontal: 14,
    borderWidth: 1,
    borderColor: '#c8d7c5',
  },
  pickerGroup: {
    marginBottom: 18,
  },
  pickerBox: {
    backgroundColor: '#ffffff',
    borderRadius: 12,
    borderWidth: 1,
    borderColor: '#c8d7c5',
  },
  button: {
    backgroundColor: '#2f6d47',
    paddingVertical: 16,
    borderRadius: 14,
    alignItems: 'center',
    marginTop: 12,
  },
  buttonText: {
    color: '#fff',
    fontWeight: '700',
  },
});