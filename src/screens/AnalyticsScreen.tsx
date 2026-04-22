import { PieChart as PieChartIcon, TrendingUp, Leaf, BarChart3, Calendar } from 'lucide-react-native';
import React, { useEffect, useMemo, useState } from 'react';
import { Dimensions, ScrollView, StyleSheet, Text, View, ActivityIndicator } from 'react-native';
import { LineChart, BarChart } from 'react-native-chart-kit';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { COLORS } from '../constants';
import { supabase } from '../lib/supabase';
import type { RootStackParamList } from '../types';

type Props = NativeStackScreenProps<RootStackParamList, 'Analytics'>;

const screenWidth = Dimensions.get('window').width;

type Bucket = { label: string; co2: number };
type ActivityRow = { started_at: string; co2_kg: number; mode: string };

function bucketByMonth(rows: ActivityRow[]): Bucket[] {
  const now = new Date();
  const buckets: Bucket[] = [];
  for (let i = 5; i >= 0; i--) {
    const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
    buckets.push({
      label: d.toLocaleString('en-US', { month: 'short' }),
      co2: 0,
    });
  }
  const earliest = new Date(now.getFullYear(), now.getMonth() - 5, 1);
  for (const row of rows) {
    const when = new Date(row.started_at);
    if (when < earliest) continue;
    const idx = (when.getFullYear() - earliest.getFullYear()) * 12 +
      (when.getMonth() - earliest.getMonth());
    if (idx >= 0 && idx < buckets.length) {
      buckets[idx].co2 += Number(row.co2_kg);
    }
  }
  return buckets;
}

function bucketByMode(rows: ActivityRow[]) {
  const totals: Record<string, number> = {
    driving: 0, biking: 0, personal: 0, shipping: 0,
  };
  for (const r of rows) {
    if (r.mode in totals) totals[r.mode] += Number(r.co2_kg);
  }
  return totals;
}

export default function AnalyticsScreen({ navigation }: Props) {
  const [rows, setRows] = useState<ActivityRow[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    (async () => {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) {
        setLoading(false);
        return;
      }
      const since = new Date();
      since.setMonth(since.getMonth() - 6);
      const { data, error } = await supabase
        .from('activities')
        .select('started_at, co2_kg, mode')
        .eq('user_id', user.id)
        .gte('started_at', since.toISOString())
        .order('started_at');
      if (error) {
        console.warn('Failed to load activities', error);
        setLoading(false);
        return;
      }
      setRows((data ?? []).map(r => ({
        started_at: r.started_at,
        co2_kg: Number(r.co2_kg),
        mode: r.mode,
      })));
      setLoading(false);
    })();
  }, []);

  const monthly = useMemo(() => bucketByMonth(rows), [rows]);
  const modeTotals = useMemo(() => bucketByMode(rows), [rows]);

  const totalCo2 = rows.reduce((s, r) => s + r.co2_kg, 0);
  const avgPerDay = totalCo2 / Math.max(1, 30);

  const lineData = {
    labels: monthly.map(b => b.label),
    datasets: [
      {
        data: monthly.map(b => b.co2 || 0),
        color: (opacity = 1) => `rgba(0, 168, 150, ${opacity})`,
        strokeWidth: 3,
      },
    ],
  };

  const chartConfig = {
    backgroundColor: COLORS.white,
    backgroundGradientFrom: COLORS.white,
    backgroundGradientTo: COLORS.white,
    decimalPlaces: 1,
    color: (opacity = 1) => `rgba(0, 168, 150, ${opacity})`,
    labelColor: (opacity = 1) => `rgba(26, 33, 48, ${opacity})`,
    style: {
      borderRadius: 16,
    },
    propsForDots: {
      r: '6',
      strokeWidth: '3',
      stroke: COLORS.primary,
    },
    propsForBackgroundLines: {
      strokeDasharray: '',
      stroke: COLORS.lightGray,
    }
  };

  if (loading) {
    return (
      <View style={[styles.container, { justifyContent: 'center', alignItems: 'center' }]}>
        <ActivityIndicator size="large" color={COLORS.primary} />
      </View>
    );
  }

  return (
    <ScrollView style={styles.container} contentContainerStyle={{ paddingBottom: 120 }}>
      <View style={styles.header}>
        <View style={styles.headerTop}>
          <View style={styles.headerIcon}>
            <PieChartIcon size={32} color="#fff" strokeWidth={2.5} />
          </View>
          <View>
            <Text style={styles.title}>Analytics</Text>
            <Text style={styles.subtitle}>Environmental footprint</Text>
          </View>
        </View>
      </View>

      <View style={styles.statsRow}>
        <View style={styles.statBox}>
          <View style={[styles.miniIcon, { backgroundColor: COLORS.primaryTransparent }]}>
            <TrendingUp size={18} color={COLORS.primary} />
          </View>
          <Text style={styles.statValue}>{avgPerDay.toFixed(1)}</Text>
          <Text style={styles.statLabel}>Avg kg/day</Text>
        </View>
        <View style={styles.statBox}>
          <View style={[styles.miniIcon, { backgroundColor: 'rgba(128, 185, 24, 0.1)' }]}>
            <Leaf size={18} color={COLORS.secondary} />
          </View>
          <Text style={styles.statValue}>{totalCo2.toFixed(1)}</Text>
          <Text style={styles.statLabel}>Total kg (6mo)</Text>
        </View>
      </View>

      <View style={styles.chartCard}>
        <View style={styles.chartHeader}>
          <BarChart3 size={20} color="#2D6A4F" />
          <Text style={styles.chartTitle}>Emission Trends</Text>
        </View>
        <LineChart
          data={lineData}
          width={screenWidth - 72}
          height={200}
          chartConfig={chartConfig}
          bezier
          style={styles.chart}
          withInnerLines={true}
          withOuterLines={false}
        />
      </View>

      <View style={styles.chartCard}>
        <View style={styles.chartHeader}>
          <Calendar size={20} color="#558B2F" />
          <Text style={styles.chartTitle}>Impact by Activity</Text>
        </View>
        <BarChart
          data={{
            labels: ['Drive', 'Bike', 'Walk', 'Ship'],
            datasets: [{
              data: [
                modeTotals.driving || 0,
                modeTotals.biking || 0,
                modeTotals.personal || 0,
                modeTotals.shipping || 0,
              ],
            }],
          }}
          width={screenWidth - 72}
          height={200}
          yAxisLabel=""
          yAxisSuffix="kg"
          chartConfig={{
            ...chartConfig,
            backgroundGradientFrom: '#ffffff',
            color: (opacity = 1) => `rgba(82, 183, 136, ${opacity})`,
          }}
          style={styles.chart}
          fromZero
          showValuesOnTopOfBars
        />
      </View>

      <View style={styles.comparisonPanel}>
        <View style={styles.badge}>
          <Text style={styles.badgeText}>Performance</Text>
        </View>
        <Text style={styles.comparisonTitle}>Above Average</Text>
        <Text style={styles.comparisonText}>
          You are performing better than <Text style={styles.highlight}>68%</Text> of users in your city. Keep using eco-friendly transport!
        </Text>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
  },
  header: {
    padding: 24,
    paddingTop: 60,
    marginBottom: 8,
  },
  headerTop: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 16,
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
  chartCard: {
    backgroundColor: COLORS.white,
    marginHorizontal: 20,
    marginBottom: 24,
    borderRadius: 32,
    padding: 20,
    shadowColor: COLORS.dark,
    shadowOpacity: 0.1,
    shadowRadius: 20,
    elevation: 5,
    borderWidth: 1,
    borderColor: COLORS.lightGray,
  },
  chartHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    marginBottom: 20,
  },
  chartTitle: {
    fontSize: 16,
    fontWeight: '800',
    color: COLORS.dark,
  },
  chart: {
    borderRadius: 16,
    marginLeft: -12,
  },
  statsRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingHorizontal: 20,
    marginBottom: 24,
    gap: 16,
  },
  statBox: {
    flex: 1,
    backgroundColor: COLORS.white,
    borderRadius: 28,
    padding: 20,
    alignItems: 'center',
    shadowColor: COLORS.dark,
    shadowOpacity: 0.08,
    shadowRadius: 15,
    elevation: 3,
    borderWidth: 1,
    borderColor: COLORS.lightGray,
  },
  miniIcon: {
    width: 36,
    height: 36,
    borderRadius: 12,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 12,
  },
  statValue: {
    fontSize: 24,
    fontWeight: '900',
    color: COLORS.dark,
  },
  statLabel: {
    fontSize: 12,
    color: COLORS.primary,
    marginTop: 2,
    fontWeight: '700',
    textTransform: 'uppercase',
  },
  comparisonPanel: {
    marginHorizontal: 20,
    padding: 24,
    backgroundColor: COLORS.primaryTransparent,
    borderRadius: 32,
    marginBottom: 40,
    borderWidth: 1,
    borderColor: COLORS.primary,
  },
  badge: {
    backgroundColor: COLORS.primary,
    alignSelf: 'flex-start',
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 8,
    marginBottom: 12,
  },
  badgeText: {
    color: '#fff',
    fontSize: 10,
    fontWeight: '900',
    textTransform: 'uppercase',
  },
  comparisonTitle: {
    color: COLORS.dark,
    fontSize: 20,
    fontWeight: '800',
    marginBottom: 8,
  },
  comparisonText: {
    color: COLORS.secondary,
    lineHeight: 22,
    fontSize: 15,
    fontWeight: '500',
  },
  highlight: {
    color: COLORS.primary,
    fontWeight: '900',
  },
});
