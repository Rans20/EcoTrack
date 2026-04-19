import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import type { Session } from '@supabase/supabase-js';
import React, { useEffect, useState } from 'react';
import { ActivityIndicator, View } from 'react-native';
import { supabase } from '../lib/supabase';
import { BarChart3, Home, Map as MapIcon, Trophy } from 'lucide-react-native';
import AnalyticsScreen from '../screens/AnalyticsScreen';
import HomeScreen from '../screens/HomeScreen';
import LeaderboardScreen from '../screens/LeaderboardScreen';
import MapScreen from '../screens/MapScreen';
import ProfileSetupScreen from '../screens/ProfileSetupScreen';
import WelcomeScreen from '../screens/WelcomeScreen';
import { getCurrentUserProfile } from '../storage';
import type { RootStackParamList } from '../types';

const Stack = createNativeStackNavigator<RootStackParamList>();
const Tab = createBottomTabNavigator();

function TabNavigator() {
  return (
    <Tab.Navigator
      screenOptions={{
        headerShown: false,
        tabBarStyle: {
          backgroundColor: '#fff',
          borderTopWidth: 0,
          elevation: 10,
          shadowColor: '#000',
          shadowOpacity: 0.1,
          shadowRadius: 10,
          height: 60,
          paddingBottom: 10,
        },
        tabBarActiveTintColor: '#344E41',
        tabBarInactiveTintColor: '#A3B18A',
      }}
    >
      <Tab.Screen
        name="Dashboard"
        component={HomeScreen}
        options={{
          tabBarIcon: ({ color, size }) => <Home size={size} color={color} />,
        }}
      />
      <Tab.Screen
        name="Maps"
        component={MapScreen}
        options={{
          tabBarIcon: ({ color, size }) => <MapIcon size={size} color={color} />,
        }}
      />
      <Tab.Screen
        name="Leaderboard"
        component={LeaderboardScreen}
        options={{
          tabBarIcon: ({ color, size }) => <Trophy size={size} color={color} />,
        }}
      />
      <Tab.Screen
        name="Analytics"
        component={AnalyticsScreen}
        options={{
          tabBarIcon: ({ color, size }) => <BarChart3 size={size} color={color} />,
        }}
      />
    </Tab.Navigator>
  );
}

export default function AppNavigator() {
  const [session, setSession] = useState<Session | null>(null);
  const [booted, setBooted] = useState(false);
  const [hasProfile, setHasProfile] = useState<boolean | null>(null);

  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => {
      setSession(data.session);
      setBooted(true);
    });
    const { data: sub } = supabase.auth.onAuthStateChange((_event, s) => {
      setSession(s);
    });
    return () => sub.subscription.unsubscribe();
  }, []);

  useEffect(() => {
    if (!session) {
      setHasProfile(null);
      return;
    }
    getCurrentUserProfile()
      .then((p) => setHasProfile(!!(p && p.fullName && p.country && p.city)))
      .catch(() => setHasProfile(false));
  }, [session]);

  if (!booted || (session && hasProfile === null)) {
    return (
      <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: '#FAF9F6' }}>
        <ActivityIndicator color="#588157" />
      </View>
    );
  }

  const initialRoute: keyof RootStackParamList =
    !session ? 'Welcome' : !hasProfile ? 'ProfileSetup' : 'Home';

  return (
    <NavigationContainer>
      <Stack.Navigator
        key={session?.user.id ?? 'anon'}
        initialRouteName={initialRoute}
      >
        <Stack.Screen
          name="Welcome"
          component={WelcomeScreen}
          options={{ headerShown: false }}
        />
        <Stack.Screen
          name="ProfileSetup"
          component={ProfileSetupScreen}
          options={{ title: 'Create Your Profile' }}
        />
        <Stack.Screen
          name="Home"
          component={TabNavigator}
          options={{ headerShown: false }}
        />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
