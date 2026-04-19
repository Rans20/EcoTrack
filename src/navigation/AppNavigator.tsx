import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import type { Session } from '@supabase/supabase-js';
import React, { useEffect, useState } from 'react';
import { ActivityIndicator, View, Image } from 'react-native';
import { supabase } from '../lib/supabase';
import { BarChart3, Home, Map as MapIcon, Trophy, LayoutDashboard, MapPinned, Medal, PieChart } from 'lucide-react-native';
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

function Icon3D({ children, color, focused }: { children: React.ReactNode, color: string, focused: boolean }) {
  return (
    <View style={{
      alignItems: 'center',
      justifyContent: 'center',
      top: focused ? -5 : 0,
    }}>
      <View style={{
        padding: 8,
        borderRadius: 12,
        backgroundColor: focused ? '#E8F5E9' : 'transparent',
        shadowColor: color,
        shadowOffset: { width: 0, height: focused ? 4 : 0 },
        shadowOpacity: focused ? 0.3 : 0,
        shadowRadius: 4,
        elevation: focused ? 5 : 0,
      }}>
        {children}
      </View>
      {focused && (
        <View style={{
          width: 4,
          height: 4,
          borderRadius: 2,
          backgroundColor: color,
          marginTop: 4
        }} />
      )}
    </View>
  );
}

function TabNavigator() {
  return (
    <Tab.Navigator
      screenOptions={{
        headerShown: false,
        tabBarStyle: {
          backgroundColor: '#fff',
          borderTopWidth: 0,
          elevation: 20,
          shadowColor: '#2D6A4F',
          shadowOpacity: 0.1,
          shadowRadius: 20,
          height: 85,
          paddingBottom: 25,
          paddingTop: 10,
          borderTopLeftRadius: 30,
          borderTopRightRadius: 30,
          position: 'absolute',
        },
        tabBarActiveTintColor: '#2D6A4F',
        tabBarInactiveTintColor: '#A3B18A',
        tabBarShowLabel: true,
        tabBarLabelStyle: {
          fontSize: 11,
          fontWeight: '600',
        }
      }}
    >
      <Tab.Screen
        name="Dashboard"
        component={HomeScreen}
        options={{
          tabBarIcon: ({ color, size, focused }) => (
            <Icon3D color={color} focused={focused}>
              <LayoutDashboard size={24} color={color} strokeWidth={focused ? 2.5 : 2} />
            </Icon3D>
          ),
        }}
      />
      <Tab.Screen
        name="Maps"
        component={MapScreen}
        options={{
          tabBarIcon: ({ color, size, focused }) => (
            <Icon3D color={color} focused={focused}>
              <MapPinned size={24} color={color} strokeWidth={focused ? 2.5 : 2} />
            </Icon3D>
          ),
        }}
      />
      <Tab.Screen
        name="Leaderboard"
        component={LeaderboardScreen}
        options={{
          tabBarIcon: ({ color, size, focused }) => (
            <Icon3D color={color} focused={focused}>
              <Medal size={24} color={color} strokeWidth={focused ? 2.5 : 2} />
            </Icon3D>
          ),
        }}
      />
      <Tab.Screen
        name="Analytics"
        component={AnalyticsScreen}
        options={{
          tabBarIcon: ({ color, size, focused }) => (
            <Icon3D color={color} focused={focused}>
              <PieChart size={24} color={color} strokeWidth={focused ? 2.5 : 2} />
            </Icon3D>
          ),
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
      <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: '#FFFFFF' }}>
        <View style={{ alignItems: 'center' }}>
          <Image
            source={require('../../assets/splash-icon.png')}
            style={{ width: 280, height: 180, marginBottom: 40 }}
            resizeMode="contain"
          />
          <ActivityIndicator size="large" color="#2D6A4F" />
        </View>
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
