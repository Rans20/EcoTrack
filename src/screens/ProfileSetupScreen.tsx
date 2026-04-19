import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { Picker } from '@react-native-picker/picker';
import * as ImagePicker from 'expo-image-picker';
import { Camera, ChevronRight, User } from 'lucide-react-native';
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
import { engineSizes, industries } from '../constants';
import { saveUserProfile } from '../storage';
import type { EngineSize, Industry, UserProfile, RootStackParamList } from '../types';

type Props = NativeStackScreenProps<RootStackParamList, 'ProfileSetup'>;

function generateUniqueId(): string {
  return `eco-${Math.random().toString(36).substr(2, 9)}`;
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
    if (!fullName || !country || !city) return;

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
      <ScrollView style={styles.container} contentContainerStyle={styles.content}>
        <Text style={styles.header}>Personalize Your Journey</Text>
        <Text style={styles.description}>
          We use this data to calculate your precise carbon impact and suggest the best habits for you.
        </Text>

        <View style={styles.avatarSection}>
          <Pressable style={styles.photoUpload} onPress={pickImage}>
            {photoUri ? (
              <Image source={{ uri: photoUri }} style={styles.photo} />
            ) : (
              <View style={styles.photoPlaceholder}>
                <User size={40} color="#A3B18A" />
              </View>
            )}
            <View style={styles.cameraIcon}>
              <Camera size={16} color="#fff" />
            </View>
          </Pressable>
        </View>

        <View style={styles.form}>
          <View style={styles.inputWrapper}>
            <Text style={styles.label}>Full Name</Text>
            <TextInput
              style={styles.input}
              value={fullName}
              onChangeText={setFullName}
              placeholder="Enter your name"
              placeholderTextColor="#A3B18A"
            />
          </View>

          <View style={styles.row}>
            <View style={[styles.inputWrapper, { flex: 1, marginRight: 12 }]}>
              <Text style={styles.label}>Height (cm)</Text>
              <TextInput
                keyboardType="numeric"
                style={styles.input}
                value={heightCm}
                onChangeText={setHeightCm}
                placeholder="175"
                placeholderTextColor="#A3B18A"
              />
            </View>
            <View style={[styles.inputWrapper, { flex: 1 }]}>
              <Text style={styles.label}>Weight (kg)</Text>
              <TextInput
                keyboardType="numeric"
                style={styles.input}
                value={weightKg}
                onChangeText={setWeightKg}
                placeholder="70"
                placeholderTextColor="#A3B18A"
              />
            </View>
          </View>

          <View style={styles.row}>
            <View style={[styles.inputWrapper, { flex: 1, marginRight: 12 }]}>
              <Text style={styles.label}>Country</Text>
              <TextInput
                style={styles.input}
                value={country}
                onChangeText={setCountry}
                placeholder="e.g. USA"
                placeholderTextColor="#A3B18A"
              />
            </View>
            <View style={[styles.inputWrapper, { flex: 1 }]}>
              <Text style={styles.label}>City</Text>
              <TextInput
                style={styles.input}
                value={city}
                onChangeText={setCity}
                placeholder="e.g. NY"
                placeholderTextColor="#A3B18A"
              />
            </View>
          </View>

          <View style={styles.pickerWrapper}>
            <Text style={styles.label}>Vehicle Engine</Text>
            <View style={styles.pickerBox}>
              <Picker
                selectedValue={carEngineSize}
                onValueChange={(v) => setCarEngineSize(v as EngineSize)}
                style={styles.picker}
              >
                {engineSizes.map((size) => (
                  <Picker.Item key={size} label={size} value={size} color="#344E41" />
                ))}
              </Picker>
            </View>
          </View>

          <View style={styles.pickerWrapper}>
            <Text style={styles.label}>Industry</Text>
            <View style={styles.pickerBox}>
              <Picker
                selectedValue={industry}
                onValueChange={(v) => setIndustry(v as Industry)}
                style={styles.picker}
              >
                {industries.map((opt) => (
                  <Picker.Item key={opt} label={opt} value={opt} color="#344E41" />
                ))}
              </Picker>
            </View>
          </View>
        </View>

        <Pressable style={styles.submitButton} onPress={handleSubmit}>
          <Text style={styles.submitButtonText}>Create My Profile</Text>
          <ChevronRight size={20} color="#fff" />
        </Pressable>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FAF9F6',
  },
  content: {
    padding: 24,
    paddingBottom: 60,
  },
  header: {
    fontSize: 28,
    fontWeight: '700',
    color: '#344E41',
    marginBottom: 8,
  },
  description: {
    fontSize: 15,
    color: '#588157',
    lineHeight: 22,
    marginBottom: 32,
  },
  avatarSection: {
    alignItems: 'center',
    marginBottom: 32,
  },
  photoUpload: {
    width: 100,
    height: 100,
    borderRadius: 50,
    backgroundColor: '#E9EDC9',
    justifyContent: 'center',
    alignItems: 'center',
    position: 'relative',
    shadowColor: '#000',
    shadowOpacity: 0.05,
    shadowRadius: 10,
    elevation: 2,
  },
  photo: {
    width: 100,
    height: 100,
    borderRadius: 50,
  },
  photoPlaceholder: {
    width: 100,
    height: 100,
    borderRadius: 50,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 2,
    borderColor: '#CCD5AE',
    borderStyle: 'dashed',
  },
  cameraIcon: {
    position: 'absolute',
    bottom: 0,
    right: 0,
    backgroundColor: '#344E41',
    width: 32,
    height: 32,
    borderRadius: 16,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 3,
    borderColor: '#FAF9F6',
  },
  form: {
    gap: 20,
    marginBottom: 40,
  },
  inputWrapper: {
    gap: 8,
  },
  label: {
    fontSize: 14,
    fontWeight: '700',
    color: '#344E41',
    textTransform: 'uppercase',
    letterSpacing: 1,
  },
  input: {
    backgroundColor: '#fff',
    borderRadius: 16,
    paddingHorizontal: 16,
    paddingVertical: 14,
    fontSize: 16,
    color: '#344E41',
    borderWidth: 1,
    borderColor: '#DAD7CD',
  },
  row: {
    flexDirection: 'row',
  },
  pickerWrapper: {
    gap: 8,
  },
  pickerBox: {
    backgroundColor: '#fff',
    borderRadius: 16,
    borderWidth: 1,
    borderColor: '#DAD7CD',
    overflow: 'hidden',
  },
  picker: {
    height: 50,
    width: '100%',
  },
  submitButton: {
    backgroundColor: '#588157',
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 18,
    borderRadius: 24,
    gap: 12,
    shadowColor: '#588157',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 4,
  },
  submitButtonText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: '700',
  },
});
