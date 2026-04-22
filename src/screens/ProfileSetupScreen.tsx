import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { Picker } from '@react-native-picker/picker';
import * as ImagePicker from 'expo-image-picker';
import { Camera, ChevronRight, User, UserCircle } from 'lucide-react-native';
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
import { COLORS } from '../constants';
import { fetchEngineSizes, fetchIndustries, upsertUserProfile } from '../storage';
import type { EngineSize, Industry, RootStackParamList } from '../types';

type Props = NativeStackScreenProps<RootStackParamList, 'ProfileSetup'>;

export default function ProfileSetupScreen({ route, navigation }: Props) {
  const selectedMode = route.params?.selectedMode ?? 'personal';
  const [fullName, setFullName] = useState('');
  const [heightCm, setHeightCm] = useState('');
  const [weightKg, setWeightKg] = useState('');
  const [country, setCountry] = useState('');
  const [city, setCity] = useState('');
  const [engineSizes, setEngineSizes] = useState<EngineSize[]>([]);
  const [industries, setIndustries] = useState<Industry[]>([]);
  const [carEngineSize, setCarEngineSize] = useState<EngineSize>('Electric');
  const [industry, setIndustry] = useState<Industry>('Other');
  const [photoUri, setPhotoUri] = useState<string | null>(null);

  useEffect(() => {
    ImagePicker.requestMediaLibraryPermissionsAsync();
  }, []);

  useEffect(() => {
    fetchEngineSizes()
      .then((rows) => {
        setEngineSizes(rows);
        if (rows.length > 0) setCarEngineSize(rows[0]);
      })
      .catch((e) => console.warn('Failed to load engine sizes', e));
    fetchIndustries()
      .then((rows) => {
        setIndustries(rows);
        if (rows.length > 0) setIndustry(rows[0]);
      })
      .catch((e) => console.warn('Failed to load industries', e));
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

    try {
      const profile = await upsertUserProfile({
        fullName,
        heightCm,
        weightKg,
        country,
        city,
        carEngineSize,
        industry,
        activityMode: selectedMode,
        photoUri,
      });
      navigation.reset({ index: 0, routes: [{ name: 'Home', params: { profile } }] });
    } catch (e) {
      console.warn('Failed to save profile', e);
    }
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
                <User size={40} color={COLORS.gray} />
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
              placeholderTextColor={COLORS.gray}
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
                placeholderTextColor={COLORS.gray}
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
                placeholderTextColor={COLORS.gray}
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
                placeholderTextColor={COLORS.gray}
              />
            </View>
            <View style={[styles.inputWrapper, { flex: 1 }]}>
              <Text style={styles.label}>City</Text>
              <TextInput
                style={styles.input}
                value={city}
                onChangeText={setCity}
                placeholder="e.g. NY"
                placeholderTextColor={COLORS.gray}
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
                  <Picker.Item key={size} label={size} value={size} color={COLORS.dark} />
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
    backgroundColor: COLORS.background,
  },
  content: {
    padding: 24,
    paddingTop: 40,
    paddingBottom: 100,
  },
  header: {
    fontSize: 28,
    fontWeight: '800',
    color: COLORS.dark,
    marginBottom: 8,
  },
  description: {
    fontSize: 15,
    color: COLORS.secondary,
    lineHeight: 22,
    marginBottom: 32,
    fontWeight: '500',
  },
  avatarSection: {
    alignItems: 'center',
    marginBottom: 32,
  },
  photoUpload: {
    width: 120,
    height: 120,
    borderRadius: 40,
    backgroundColor: COLORS.white,
    justifyContent: 'center',
    alignItems: 'center',
    position: 'relative',
    shadowColor: COLORS.dark,
    shadowOpacity: 0.1,
    shadowRadius: 15,
    elevation: 5,
    borderWidth: 1,
    borderColor: COLORS.lightGray,
  },
  photo: {
    width: 120,
    height: 120,
    borderRadius: 40,
  },
  photoPlaceholder: {
    width: 120,
    height: 120,
    borderRadius: 40,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 2,
    borderColor: COLORS.primaryTransparent,
    borderStyle: 'dashed',
    backgroundColor: COLORS.background,
  },
  cameraIcon: {
    position: 'absolute',
    bottom: -5,
    right: -5,
    backgroundColor: COLORS.primary,
    width: 40,
    height: 40,
    borderRadius: 14,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 4,
    borderColor: COLORS.background,
    shadowColor: '#000',
    shadowOpacity: 0.2,
    shadowRadius: 5,
    elevation: 3,
  },
  form: {
    gap: 20,
    marginBottom: 40,
  },
  inputWrapper: {
    gap: 8,
  },
  label: {
    fontSize: 13,
    fontWeight: '800',
    color: COLORS.primary,
    textTransform: 'uppercase',
    letterSpacing: 1.2,
  },
  input: {
    backgroundColor: COLORS.white,
    borderRadius: 20,
    paddingHorizontal: 20,
    paddingVertical: 16,
    fontSize: 16,
    color: COLORS.dark,
    borderWidth: 1,
    borderColor: COLORS.lightGray,
    shadowColor: COLORS.dark,
    shadowOpacity: 0.03,
    shadowRadius: 10,
    elevation: 1,
    fontWeight: '600',
  },
  row: {
    flexDirection: 'row',
  },
  pickerWrapper: {
    gap: 8,
  },
  pickerBox: {
    backgroundColor: COLORS.white,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: COLORS.lightGray,
    overflow: 'hidden',
    shadowColor: COLORS.dark,
    shadowOpacity: 0.03,
    shadowRadius: 10,
    elevation: 1,
  },
  picker: {
    height: 55,
    width: '100%',
  },
  submitButton: {
    backgroundColor: COLORS.primary,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 20,
    borderRadius: 24,
    gap: 12,
    shadowColor: COLORS.primary,
    shadowOffset: { width: 0, height: 10 },
    shadowOpacity: 0.25,
    shadowRadius: 15,
    elevation: 8,
  },
  submitButtonText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: '800',
  },
});
