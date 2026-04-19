import { NativeStackScreenProps } from '@react-navigation/native-stack';
import React, { useEffect, useState } from 'react';
import { FlatList, Pressable, StyleSheet, Text, View } from 'react-native';
import { fetchLeaderboard, type LeaderboardEntry } from '../storage';
import type { RootStackParamList } from '../types';

type Props = NativeStackScreenProps<RootStackParamList, 'Leaderboard'>;

function formatEntry(entry: LeaderboardEntry) {
  const parts = [entry.city, entry.country].filter(Boolean);
  const location = parts.length ? parts.join(', ') : 'Unknown';
  const mode = entry.activity_mode ?? 'personal';
  return `${location} — ${mode}`;
}

export default function LeaderboardScreen({ navigation }: Props) {
  const [entries, setEntries] = useState<LeaderboardEntry[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchLeaderboard()
      .then((rows) => setEntries(rows))
      .catch((e) => console.warn('Failed to fetch leaderboard', e))
      .finally(() => setLoading(false));
  }, []);

  return (
    <View style={styles.container}>
      <Text style={styles.title}>City & Country Leaderboard</Text>
      <Text style={styles.subtitle}>
        Track the top sustainable users in your area and see how your city and country are performing.
      </Text>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Top local contributors</Text>
        {loading ? (
          <Text style={styles.empty}>Loading…</Text>
        ) : entries.length === 0 ? (
          <Text style={styles.empty}>No activity yet. Log a journey to appear here.</Text>
        ) : (
          <FlatList
            data={entries}
            keyExtractor={(item) => item.id ?? String(Math.random())}
            renderItem={({ item, index }) => (
              <View style={styles.row}>
                <Text style={styles.rank}>{index + 1}</Text>
                <View style={styles.rowContent}>
                  <Text style={styles.name}>{item.full_name || 'Anonymous'}</Text>
                  <Text style={styles.detail}>{formatEntry(item)}</Text>
                </View>
                <Text style={styles.co2}>{Number(item.total_co2_kg ?? 0).toFixed(1)} kg</Text>
              </View>
            )}
          />
        )}
      </View>

      <Pressable style={styles.button} onPress={() => navigation.navigate('Home')}>
        <Text style={styles.buttonText}>Back to Dashboard</Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f3faf2',
    padding: 22,
  },
  title: {
    fontSize: 24,
    fontWeight: '700',
    marginBottom: 8,
  },
  subtitle: {
    color: '#4a5e48',
    marginBottom: 18,
    lineHeight: 20,
  },
  section: {
    backgroundColor: '#ffffff',
    borderRadius: 18,
    padding: 18,
    marginBottom: 18,
    borderWidth: 1,
    borderColor: '#d7ead5',
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '700',
    marginBottom: 12,
  },
  empty: {
    color: '#6a7a68',
    fontStyle: 'italic',
    paddingVertical: 12,
  },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 14,
    borderBottomWidth: 1,
    borderBottomColor: '#eef5ee',
  },
  rank: {
    width: 28,
    fontSize: 17,
    fontWeight: '700',
    color: '#2f6d47',
  },
  rowContent: {
    flex: 1,
  },
  name: {
    fontSize: 16,
    fontWeight: '700',
  },
  detail: {
    color: '#5e715d',
    marginTop: 2,
  },
  co2: {
    fontSize: 14,
    fontWeight: '700',
    color: '#2f6d47',
  },
  button: {
    backgroundColor: '#2d724d',
    padding: 14,
    borderRadius: 14,
    alignItems: 'center',
  },
  buttonText: {
    color: '#fff',
    fontWeight: '700',
  },
});
