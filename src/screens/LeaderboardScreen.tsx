import { Medal, Trophy, Users, Award } from 'lucide-react-native';
import React, { useEffect, useState } from 'react';
import { FlatList, Pressable, StyleSheet, Text, View, ActivityIndicator } from 'react-native';
import { COLORS } from '../constants';
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
      <View style={styles.header}>
        <View style={styles.headerIcon}>
           <Medal size={40} color="#fff" strokeWidth={2.5} />
        </View>
        <View>
          <Text style={styles.title}>Impact Leaders</Text>
          <Text style={styles.subtitle}>Top eco-warriors globally</Text>
        </View>
      </View>

      <View style={styles.statsOverview}>
        <View style={styles.miniStat}>
          <Users size={20} color={COLORS.primary} />
          <Text style={styles.miniStatValue}>1.2k</Text>
          <Text style={styles.miniStatLabel}>Active</Text>
        </View>
        <View style={styles.miniStat}>
          <Trophy size={20} color="#EF6C00" />
          <Text style={styles.miniStatValue}>#42</Text>
          <Text style={styles.miniStatLabel}>Your Rank</Text>
        </View>
        <View style={styles.miniStat}>
          <Award size={20} color="#1565C0" />
          <Text style={styles.miniStatValue}>8</Text>
          <Text style={styles.miniStatLabel}>Badges</Text>
        </View>
      </View>

      <View style={styles.section}>
        <View style={styles.sectionHeader}>
          <Text style={styles.sectionTitle}>Global Rankings</Text>
          <Text style={styles.seeAll}>This Week</Text>
        </View>
        {loading ? (
          <ActivityIndicator color={COLORS.primary} style={{ marginVertical: 40 }} />
        ) : entries.length === 0 ? (
          <Text style={styles.empty}>No activity yet. Log a journey to appear here.</Text>
        ) : (
          <FlatList
            data={entries}
            keyExtractor={(item) => item.id ?? String(Math.random())}
            contentContainerStyle={{ paddingBottom: 20 }}
            renderItem={({ item, index }) => (
              <View style={[styles.row, index === 0 && styles.topRow]}>
                <View style={[styles.rankBadge, index < 3 && styles[`rankBadge${index + 1}`]]}>
                  <Text style={[styles.rankText, index < 3 && styles.rankTextTop]}>{index + 1}</Text>
                </View>
                <View style={styles.rowContent}>
                  <Text style={styles.name}>{item.full_name || 'Anonymous'}</Text>
                  <Text style={styles.detail}>{formatEntry(item)}</Text>
                </View>
                <View style={styles.co2Badge}>
                  <Text style={styles.co2Value}>{Number(item.total_co2_kg ?? 0).toFixed(1)}</Text>
                  <Text style={styles.co2Unit}>kg</Text>
                </View>
              </View>
            )}
          />
        )}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
    padding: 20,
    paddingTop: 60,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 16,
    marginBottom: 24,
  },
  headerIcon: {
    width: 64,
    height: 64,
    borderRadius: 20,
    backgroundColor: COLORS.primary,
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: COLORS.primary,
    shadowOpacity: 0.3,
    shadowRadius: 10,
    elevation: 8,
  },
  title: {
    fontSize: 26,
    fontWeight: '800',
    color: COLORS.dark,
  },
  subtitle: {
    fontSize: 14,
    color: COLORS.primary,
    fontWeight: '600',
  },
  statsOverview: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 24,
  },
  miniStat: {
    width: '31%',
    backgroundColor: COLORS.white,
    borderRadius: 20,
    padding: 12,
    alignItems: 'center',
    shadowColor: COLORS.dark,
    shadowOpacity: 0.05,
    shadowRadius: 10,
    elevation: 2,
    borderWidth: 1,
    borderColor: COLORS.lightGray,
  },
  miniStatValue: {
    fontSize: 16,
    fontWeight: '800',
    color: COLORS.dark,
    marginTop: 4,
  },
  miniStatLabel: {
    fontSize: 10,
    color: COLORS.gray,
    textTransform: 'uppercase',
    fontWeight: '700',
  },
  section: {
    flex: 1,
    backgroundColor: COLORS.white,
    borderRadius: 32,
    padding: 24,
    shadowColor: COLORS.dark,
    shadowOpacity: 0.1,
    shadowRadius: 20,
    elevation: 5,
    borderWidth: 1,
    borderColor: COLORS.lightGray,
  },
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 20,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '800',
    color: COLORS.dark,
  },
  seeAll: {
    fontSize: 12,
    fontWeight: '700',
    color: COLORS.primary,
    backgroundColor: COLORS.primaryTransparent,
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 10,
  },
  empty: {
    color: COLORS.gray,
    textAlign: 'center',
    marginTop: 40,
    fontSize: 16,
    fontWeight: '500',
  },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 16,
    borderBottomWidth: 1,
    borderBottomColor: COLORS.lightGray,
  },
  topRow: {
    backgroundColor: COLORS.background,
    borderRadius: 16,
    marginHorizontal: -8,
    paddingHorizontal: 8,
  },
  rankBadge: {
    width: 32,
    height: 32,
    borderRadius: 10,
    backgroundColor: COLORS.lightGray,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 16,
  },
  rankBadge1: { backgroundColor: '#FFD700' },
  rankBadge2: { backgroundColor: '#C0C0C0' },
  rankBadge3: { backgroundColor: '#CD7F32' },
  rankText: {
    fontSize: 14,
    fontWeight: '800',
    color: COLORS.primary,
  },
  rankTextTop: {
    color: '#fff',
  },
  rowContent: {
    flex: 1,
  },
  name: {
    fontSize: 16,
    fontWeight: '700',
    color: COLORS.dark,
  },
  detail: {
    color: COLORS.secondary,
    fontSize: 12,
    marginTop: 2,
    fontWeight: '500',
  },
  co2Badge: {
    alignItems: 'flex-end',
  },
  co2Value: {
    fontSize: 16,
    fontWeight: '800',
    color: COLORS.primary,
  },
  co2Unit: {
    fontSize: 10,
    color: COLORS.gray,
    fontWeight: '700',
    textTransform: 'uppercase',
  },
});
