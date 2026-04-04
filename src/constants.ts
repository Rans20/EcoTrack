import { ActivityMode, EngineSize, Industry, UserProfile } from './types';

export const activityModes: { label: string; value: ActivityMode }[] = [
  { label: 'Personal', value: 'personal' },
  { label: 'Driving', value: 'driving' },
  { label: 'Biking', value: 'biking' },
  { label: 'Shipping / Marine', value: 'shipping' },
];

export const engineSizes: EngineSize[] = ['Electric', 'Hybrid', '1.0L', '1.2L', '1.4L', '1.6L', '2.0L', '2.5L', '3.0L+'];

export const industries: Industry[] = ['Transport', 'Maritime', 'Aviation', 'Recycling', 'Energy', 'Agriculture', 'Other'];

export const emissionSuggestions = {
  personal: [
    'Replace one car trip per week with biking or walking.',
    'Choose public transportation for short errands.',
    'Reduce air travel and choose train routes when possible.',
  ],
  driving: [
    'Maintain proper tire pressure to improve fuel economy.',
    'Use route planning to avoid traffic and minimize idle time.',
    'Switch to electric or hybrid options for your next vehicle.',
  ],
  biking: [
    'Plan bike-friendly routes to avoid busy streets.',
    'Combine errands into one ride to reduce repeat trips.',
    'Use cargo bikes for short deliveries instead of cars.',
  ],
  shipping: [
    'Optimize cargo load and choose cleaner fuels or hybrids.',
    'Reduce idle time in ports and use digital route planning.',
    'Monitor vessel speed to minimize fuel consumption.',
  ],
};

export const leaderboardSamples: UserProfile[] = [
  {
    id: 'leader-1',
    fullName: 'Maya Chen',
    heightCm: '168',
    weightKg: '60',
    country: 'Spain',
    city: 'Barcelona',
    carEngineSize: 'Electric',
    industry: 'Transport',
    activityMode: 'biking',
    photoUri: null,
    createdAt: '2026-04-01T08:30:00Z',
  },
  {
    id: 'leader-2',
    fullName: 'Luca Rossi',
    heightCm: '175',
    weightKg: '72',
    country: 'Italy',
    city: 'Milan',
    carEngineSize: 'Hybrid',
    industry: 'Recycling',
    activityMode: 'personal',
    photoUri: null,
    createdAt: '2026-04-02T10:20:00Z',
  },
  {
    id: 'leader-3',
    fullName: 'Aisha Ndlovu',
    heightCm: '162',
    weightKg: '58',
    country: 'South Africa',
    city: 'Cape Town',
    carEngineSize: '1.0L',
    industry: 'Maritime',
    activityMode: 'shipping',
    photoUri: null,
    createdAt: '2026-04-03T09:45:00Z',
  },
];

export const routeSuggestions = [
  { name: 'Shorter route via Oak Avenue', benefit: '2.4 km shorter, 8 min faster' },
  { name: 'Low-traffic Green Boulevard', benefit: 'Avoids congestion and lowers CO2 by 12%' },
  { name: 'Eco-friendly highway route', benefit: 'Better speed consistency for fewer emissions' },
];
