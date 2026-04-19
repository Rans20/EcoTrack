import { NativeStackScreenProps } from '@react-navigation/native-stack';
import * as Location from 'expo-location';
import { Navigation, Compass, Info, Leaf } from 'lucide-react-native';
import React, { useEffect, useState } from 'react';
import { Pressable, StyleSheet, Text, View, Dimensions, ActivityIndicator } from 'react-native';
import MapView, { Marker, Polyline, PROVIDER_GOOGLE } from 'react-native-maps';
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
  const [routeType, setRouteType] = useState<'walking' | 'driving' | 'biking'>('biking');

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

  const routeColors = {
    walking: '#A3B18A',
    driving: '#344E41',
    biking: '#588157',
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
              strokeColor={routeColors[routeType]}
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
              {(['walking', 'biking', 'driving'] as const).map((t) => (
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
              <Text style={styles.suggestionMain}>Save 0.8kg CO₂ via Park Lane</Text>
              <Text style={styles.suggestionSub}>12 mins • 2.4 km • Shorter & Greener</Text>

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
    "stylers": [{ "color": "#617454" }]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{ "color": "#CDE3D2" }]
  },
  {
    "featureType": "landscape",
    "elementType": "geometry",
    "stylers": [{ "color": "#F5F5F0" }]
  }
];

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#FAF9F6' },
  loader: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  loaderText: { marginTop: 16, color: '#588157', fontWeight: '600' },
  map: { width, height },
  userMarker: {
    width: 24,
    height: 24,
    borderRadius: 12,
    backgroundColor: 'rgba(88, 129, 87, 0.2)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  userMarkerInner: {
    width: 12,
    height: 12,
    borderRadius: 6,
    backgroundColor: '#588157',
    borderWidth: 2,
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
    padding: 14,
    borderRadius: 16,
    gap: 12,
    shadowColor: '#000',
    shadowOpacity: 0.1,
    shadowRadius: 10,
    elevation: 5,
  },
  searchText: { color: '#888', fontSize: 14 },
  bottomPanel: {
    position: 'absolute',
    bottom: 40,
    left: 20,
    right: 20,
  },
  typeSelector: {
    flexDirection: 'row',
    backgroundColor: 'rgba(255,255,255,0.9)',
    borderRadius: 20,
    padding: 6,
    marginBottom: 16,
    gap: 6,
  },
  typeBtn: {
    flex: 1,
    paddingVertical: 10,
    alignItems: 'center',
    borderRadius: 16,
  },
  typeBtnActive: {
    backgroundColor: '#588157',
  },
  typeBtnText: {
    fontSize: 13,
    fontWeight: '600',
    color: '#588157',
  },
  typeBtnTextActive: {
    color: '#fff',
  },
  suggestionBox: {
    backgroundColor: '#fff',
    borderRadius: 24,
    padding: 20,
    shadowColor: '#000',
    shadowOpacity: 0.1,
    shadowRadius: 15,
    elevation: 10,
  },
  suggestionHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    marginBottom: 8,
  },
  suggestionTitle: {
    fontSize: 14,
    fontWeight: '700',
    color: '#588157',
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  suggestionMain: {
    fontSize: 20,
    fontWeight: '800',
    color: '#344E41',
    marginBottom: 4,
  },
  suggestionSub: {
    fontSize: 14,
    color: '#A3B18A',
    marginBottom: 16,
  },
  goButton: {
    backgroundColor: '#344E41',
    paddingVertical: 14,
    borderRadius: 16,
    alignItems: 'center',
  },
  goButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '700',
  },
});
