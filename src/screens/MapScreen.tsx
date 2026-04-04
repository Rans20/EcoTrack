import { NativeStackScreenProps } from '@react-navigation/native-stack';
import * as Location from 'expo-location';
import React, { useEffect, useState } from 'react';
import { FlatList, Pressable, StyleSheet, Text, View } from 'react-native';
import MapView, { Marker, PROVIDER_GOOGLE } from 'react-native-maps';
import { routeSuggestions } from '../constants';
import type { RootStackParamList } from '../types';

type Props = NativeStackScreenProps<RootStackParamList, 'Map'>;

export default function MapScreen({ navigation }: Props) {
  const [region, setRegion] = useState({
    latitude: 37.78825,
    longitude: -122.4324,
    latitudeDelta: 0.06,
    longitudeDelta: 0.05,
  });
  const [permissionStatus, setPermissionStatus] = useState<string>('pending');

  useEffect(() => {
    (async () => {
      const { status } = await Location.requestForegroundPermissionsAsync();
      setPermissionStatus(status);
      if (status === 'granted') {
        const location = await Location.getCurrentPositionAsync({ accuracy: Location.Accuracy.Highest });
        setRegion((current) => ({
          ...current,
          latitude: location.coords.latitude,
          longitude: location.coords.longitude,
        }));
      }
    })();
  }, []);

  return (
    <View style={styles.container}>
      <MapView
        provider={PROVIDER_GOOGLE}
        style={styles.map}
        region={region}
        showsUserLocation
        showsTraffic
      >
        <Marker coordinate={{ latitude: region.latitude, longitude: region.longitude }} title="You are here" />
      </MapView>

      <View style={styles.panel}>
        <Text style={styles.panelTitle}>Route suggestions</Text>
        <Text style={styles.panelSubtitle}>The map recommends shorter, lower-emission routes and detects traffic ahead.</Text>
        <FlatList
          data={routeSuggestions}
          keyExtractor={(item) => item.name}
          renderItem={({ item }) => (
            <View style={styles.routeCard}>
              <Text style={styles.routeName}>{item.name}</Text>
              <Text style={styles.routeBenefit}>{item.benefit}</Text>
            </View>
          )}
          ItemSeparatorComponent={() => <View style={styles.separator} />}
        />

        <Pressable style={styles.button} onPress={() => navigation.navigate('Home')}>
          <Text style={styles.buttonText}>Return to Dashboard</Text>
        </Pressable>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#eef7ed',
  },
  map: {
    flex: 1,
  },
  panel: {
    backgroundColor: '#ffffff',
    padding: 18,
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    elevation: 6,
    shadowColor: '#000',
    shadowOpacity: 0.08,
    shadowOffset: { width: 0, height: -4 },
    shadowRadius: 10,
  },
  panelTitle: {
    fontSize: 20,
    fontWeight: '700',
    marginBottom: 6,
  },
  panelSubtitle: {
    fontSize: 14,
    color: '#4c5b47',
    marginBottom: 16,
  },
  routeCard: {
    padding: 14,
    backgroundColor: '#f3faf1',
    borderRadius: 14,
  },
  routeName: {
    fontWeight: '700',
    fontSize: 15,
    marginBottom: 4,
  },
  routeBenefit: {
    color: '#556b52',
    lineHeight: 20,
  },
  separator: {
    height: 12,
  },
  button: {
    backgroundColor: '#2f6d47',
    padding: 14,
    borderRadius: 14,
    alignItems: 'center',
    marginTop: 16,
  },
  buttonText: {
    color: '#fff',
    fontWeight: '700',
  },
});