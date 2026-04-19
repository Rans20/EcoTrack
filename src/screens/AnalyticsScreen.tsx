import React from 'react';
import { Dimensions, ScrollView, StyleSheet, Text, View } from 'react-native';
import { LineChart, BarChart, PieChart } from 'react-native-chart-kit';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../types';

type Props = NativeStackScreenProps<RootStackParamList, 'Analytics'>;

const screenWidth = Dimensions.get('window').width;

export default function AnalyticsScreen({ navigation }: Props) {
  const lineData = {
    labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
    datasets: [
      {
        data: [20, 45, 28, 80, 99, 43],
        color: (opacity = 1) => `rgba(57, 255, 20, ${opacity})`, // Neon Green
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
          <Text style={styles.statValue}>12.4</Text>
          <Text style={styles.statLabel}>Avg kg/day</Text>
        </View>
        <View style={[styles.statBox, { borderColor: '#00FFFF' }]}>
          <Text style={styles.statValue}>-15%</Text>
          <Text style={styles.statLabel}>vs Last Month</Text>
        </View>
      </View>

      <View style={styles.chartCard}>
        <Text style={styles.chartTitle}>Vehicle vs. Personal</Text>
        <BarChart
          data={{
            labels: ['Transport', 'Home', 'Food'],
            datasets: [{ data: [40, 20, 35] }],
          }}
          width={screenWidth - 48}
          height={220}
          yAxisLabel=""
          yAxisSuffix="kg"
          chartConfig={{
            ...chartConfig,
            backgroundGradientFrom: '#001a33', // Blueish tint
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
