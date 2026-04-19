import React, { useEffect, useMemo, useState } from 'react';
import { Dimensions, ScrollView, StyleSheet, Text, View } from 'react-native';
import { LineChart, BarChart, PieChart } from 'react-native-chart-kit';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
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

  useEffect(() => {
    (async () => {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) return;
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
        return;
      }
      setRows((data ?? []).map(r => ({
        started_at: r.started_at,
        co2_kg: Number(r.co2_kg),
        mode: r.mode,
      })));
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
        color: (opacity = 1) => `rgba(57, 255, 20, ${opacity})`,
        strokeWidth: 2,
      },
    ],
    legend: ['CO2 Trends (kg)'],
  };

  const chartConfig = {
    backgroundColor: '#0a1a0a',
    backgroundGradientFrom: '#122612',
    backgroundGradientTo: '#0a1a0a',
    decimalPlaces: 1,
    color: (opacity = 1) => `rgba(0, 255, 255, ${opacity})`, // Cyan/Blue highlight
    labelColor: (opacity = 1) => `rgba(255, 255, 255, ${opacity})`,
    style: {
      borderRadius: 16,
    },
    propsForDots: {
      r: '6',
      strokeWidth: '2',
      stroke: '#39FF14',
    },
  };

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Carbon Analytics</Text>
        <Text style={styles.subtitle}>Real-time emission tracking & trends</Text>
      </View>

      <View style={styles.chartCard}>
        <Text style={styles.chartTitle}>Emissions Over Time</Text>
        <LineChart
          data={lineData}
          width={screenWidth - 48}
          height={220}
          chartConfig={chartConfig}
          bezier
          style={styles.chart}
        />
      </View>

      <View style={styles.statsRow}>
        <View style={[styles.statBox, { borderColor: '#39FF14' }]}>
          <Text style={styles.statValue}>{avgPerDay.toFixed(1)}</Text>
          <Text style={styles.statLabel}>Avg kg/day</Text>
        </View>
        <View style={[styles.statBox, { borderColor: '#00FFFF' }]}>
          <Text style={styles.statValue}>{totalCo2.toFixed(1)}</Text>
          <Text style={styles.statLabel}>Total kg (6mo)</Text>
        </View>
      </View>

      <View style={styles.chartCard}>
        <Text style={styles.chartTitle}>CO₂ by Mode</Text>
        <BarChart
          data={{
            labels: ['Driving', 'Biking', 'Personal', 'Shipping'],
            datasets: [{
              data: [
                modeTotals.driving,
                modeTotals.biking,
                modeTotals.personal,
                modeTotals.shipping,
              ],
            }],
          }}
          width={screenWidth - 48}
          height={220}
          yAxisLabel=""
          yAxisSuffix="kg"
          chartConfig={{
            ...chartConfig,
            backgroundGradientFrom: '#001a33',
          }}
          style={styles.chart}
        />
      </View>

      <View style={styles.comparisonPanel}>
        <Text style={styles.comparisonTitle}>Global Comparison</Text>
        <Text style={styles.comparisonText}>
          You are performing better than <Text style={styles.highlight}>68%</Text> of users in your city.
        </Text>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#050a05',
  },
  header: {
    padding: 24,
    paddingTop: 40,
  },
  title: {
    fontSize: 28,
    fontWeight: '800',
    color: '#fff',
    letterSpacing: 1,
  },
  subtitle: {
    fontSize: 14,
    color: '#39FF14',
    marginTop: 4,
    textTransform: 'uppercase',
  },
  chartCard: {
    backgroundColor: '#111',
    marginHorizontal: 20,
    marginBottom: 24,
    borderRadius: 20,
    padding: 16,
    borderWidth: 1,
    borderColor: '#222',
  },
  chartTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#fff',
    marginBottom: 16,
  },
  chart: {
    borderRadius: 16,
  },
  statsRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingHorizontal: 20,
    marginBottom: 24,
  },
  statBox: {
    width: '47%',
    backgroundColor: '#111',
    borderRadius: 16,
    padding: 16,
    alignItems: 'center',
    borderLeftWidth: 4,
  },
  statValue: {
    fontSize: 24,
    fontWeight: '800',
    color: '#fff',
  },
  statLabel: {
    fontSize: 12,
    color: '#888',
    marginTop: 4,
  },
  comparisonPanel: {
    marginHorizontal: 20,
    padding: 20,
    backgroundColor: '#112211',
    borderRadius: 16,
    marginBottom: 40,
  },
  comparisonTitle: {
    color: '#fff',
    fontSize: 18,
    fontWeight: '700',
    marginBottom: 8,
  },
  comparisonText: {
    color: '#ccc',
    lineHeight: 22,
  },
  highlight: {
    color: '#39FF14',
    fontWeight: 'bold',
  },
});
