import { NativeStackScreenProps } from '@react-navigation/native-stack';
import * as Location from 'expo-location';
import { Navigation, Compass, Info, Leaf } from 'lucide-react-native';
import React, { useEffect, useState } from 'react';
import { Pressable, StyleSheet, Text, View, Dimensions, ActivityIndicator } from 'react-native';
import MapView, { Marker, Polyline, PROVIDER_GOOGLE } from 'react-native-maps';
import { fetchRouteSuggestions, type RouteSuggestion } from '../storage';
import type { RootStackParamList } from '../types';

type Props = NativeStackScreenProps<RootStackParamList, 'Map'>;

const { width, height } = Dimensions.get('window');

export default function MapScreen({ navigation }: Props) {
  const [region, setRegion] = useState({
    latitude: 37.78825,
    longitude: -122.4324,
    latitudeDelta: 0.01,
    longitudeDelta: 0.01,
  });
  const [loading, setLoading] = useState(true);
  const [routeType, setRouteType] = useState<'walking' | 'driving' | 'hiking'>('hiking');
  const [routeSuggestion, setRouteSuggestion] = useState<RouteSuggestion | null>(null);

  useEffect(() => {
    (async () => {
      let { status } = await Location.requestForegroundPermissionsAsync();
      if (status !== 'granted') return;

      let location = await Location.getCurrentPositionAsync({});
      setRegion({
        ...region,
        latitude: location.coords.latitude,
        longitude: location.coords.longitude,
      });
      setLoading(false);
    })();
  }, []);

  useEffect(() => {
    fetchRouteSuggestions()
      .then((rows) => setRouteSuggestion(rows[0] ?? null))
      .catch((e) => console.warn('Failed to load route suggestions', e));
  }, []);

  const routeColors = {
    walking: '#95D5B2',
    driving: '#1B4332',
    hiking: '#2D6A4F',
  };

  return (
    <View style={styles.container}>
      {loading ? (
        <View style={styles.loader}>
          <ActivityIndicator size="large" color="#588157" />
          <Text style={styles.loaderText}>Calibrating Eco-Routes...</Text>
        </View>
      ) : (
        <>
          <MapView
            provider={PROVIDER_GOOGLE}
            style={styles.map}
            region={region}
            showsUserLocation
            showsMyLocationButton
            customMapStyle={mapStyle}
          >
            <Marker coordinate={{ latitude: region.latitude, longitude: region.longitude }}>
              <View style={styles.userMarker}>
                <View style={styles.userMarkerInner} />
              </View>
            </Marker>

            {/* Simulated route to destination */}
            <Polyline
              coordinates={[
                { latitude: region.latitude, longitude: region.longitude },
                { latitude: region.latitude + 0.002, longitude: region.longitude + 0.002 },
                { latitude: region.latitude + 0.004, longitude: region.longitude + 0.001 },
              ]}
              strokeColor={routeColors[routeType] || '#588157'}
              strokeWidth={4}
            />
          </MapView>

          <View style={styles.topOverlay}>
            <View style={styles.searchBar}>
              <Navigation size={20} color="#588157" />
              <Text style={styles.searchText}>Searching for low-emission paths...</Text>
            </View>
          </View>

          <View style={styles.bottomPanel}>
            <View style={styles.typeSelector}>
              {(['driving', 'hiking', 'walking'] as const).map((t) => (
                <Pressable
                  key={t}
                  onPress={() => setRouteType(t)}
                  style={[styles.typeBtn, routeType === t && styles.typeBtnActive]}
                >
                  <Text style={[styles.typeBtnText, routeType === t && styles.typeBtnTextActive]}>
                    {t.charAt(0).toUpperCase() + t.slice(1)}
                  </Text>
                </Pressable>
              ))}
            </View>

            <View style={styles.suggestionBox}>
              <View style={styles.suggestionHeader}>
                <Leaf size={20} color="#588157" />
                <Text style={styles.suggestionTitle}>Optimal Route Found</Text>
              </View>
              <Text style={styles.suggestionMain}>
                {routeSuggestion?.name ?? 'Loading suggestion…'}
              </Text>
              <Text style={styles.suggestionSub}>
                {routeSuggestion?.benefit ?? ''}
              </Text>

              <Pressable style={styles.goButton}>
                <Text style={styles.goButtonText}>Start Journey</Text>
              </Pressable>
            </View>
          </View>
        </>
      )}
    </View>
  );
}

const mapStyle = [
  {
    "featureType": "all",
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#1B4332" }]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{ "color": "#D8F3DC" }]
  },
  {
    "featureType": "landscape",
    "elementType": "geometry",
    "stylers": [{ "color": "#F7FBF7" }]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [{ "color": "#B7E4C7" }]
  }
];

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#F7FBF7' },
  loader: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  loaderText: { marginTop: 16, color: '#2D6A4F', fontWeight: '800' },
  map: { width, height },
  userMarker: {
    width: 28,
    height: 28,
    borderRadius: 14,
    backgroundColor: 'rgba(45, 106, 79, 0.2)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  userMarkerInner: {
    width: 14,
    height: 14,
    borderRadius: 7,
    backgroundColor: '#2D6A4F',
    borderWidth: 3,
    borderColor: '#fff',
  },
  topOverlay: {
    position: 'absolute',
    top: 60,
    left: 20,
    right: 20,
  },
  searchBar: {
    backgroundColor: '#fff',
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
    borderRadius: 20,
    gap: 12,
    shadowColor: '#1B4332',
    shadowOpacity: 0.1,
    shadowRadius: 15,
    elevation: 8,
    borderWidth: 1,
    borderColor: '#F0F7F0',
  },
  searchText: { color: '#95D5B2', fontSize: 15, fontWeight: '500' },
  bottomPanel: {
    position: 'absolute',
    bottom: 100, // Adjusted for new tab bar height
    left: 20,
    right: 20,
  },
  typeSelector: {
    flexDirection: 'row',
    backgroundColor: 'rgba(255,255,255,0.95)',
    borderRadius: 24,
    padding: 8,
    marginBottom: 16,
    gap: 8,
    shadowColor: '#1B4332',
    shadowOpacity: 0.1,
    shadowRadius: 10,
    elevation: 5,
  },
  typeBtn: {
    flex: 1,
    paddingVertical: 12,
    alignItems: 'center',
    borderRadius: 18,
  },
  typeBtnActive: {
    backgroundColor: '#2D6A4F',
  },
  typeBtnText: {
    fontSize: 14,
    fontWeight: '700',
    color: '#2D6A4F',
  },
  typeBtnTextActive: {
    color: '#fff',
  },
  suggestionBox: {
    backgroundColor: '#fff',
    borderRadius: 32,
    padding: 24,
    shadowColor: '#1B4332',
    shadowOpacity: 0.15,
    shadowRadius: 20,
    elevation: 12,
    borderWidth: 1,
    borderColor: '#F0F7F0',
  },
  suggestionHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
    marginBottom: 10,
  },
  suggestionTitle: {
    fontSize: 12,
    fontWeight: '900',
    color: '#409167',
    textTransform: 'uppercase',
    letterSpacing: 1,
  },
  suggestionMain: {
    fontSize: 22,
    fontWeight: '800',
    color: '#1B4332',
    marginBottom: 6,
  },
  suggestionSub: {
    fontSize: 15,
    color: '#52B788',
    marginBottom: 20,
    fontWeight: '500',
  },
  goButton: {
    backgroundColor: '#1B4332',
    paddingVertical: 18,
    borderRadius: 20,
    alignItems: 'center',
    shadowColor: '#1B4332',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 5,
  },
  goButtonText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: '800',
  },
});
