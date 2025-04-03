import React from 'react';
import {
  Text,
  View,
  StyleSheet,
  TouchableOpacity,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
} from 'react-native';
import * as Toadly from 'react-native-toadly';
import { GITHUB_TOKEN, GITHUB_REPO_OWNER, GITHUB_REPO_NAME } from '@env';

Toadly.setup(GITHUB_TOKEN, GITHUB_REPO_OWNER, GITHUB_REPO_NAME);

export default function App() {
  

  const handleReportBug = () => {
    Toadly.show();
  };

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
    >
      <ScrollView contentContainerStyle={styles.scrollContainer}>
        <View style={styles.calculatorContainer}>
          <Text style={styles.title}>Toadly</Text>

          <TouchableOpacity
            style={styles.reportButton}
            onPress={handleReportBug}
          >
            <Text style={styles.buttonText}>Report a Bug</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  scrollContainer: {
    flexGrow: 1,
    justifyContent: 'center',
    padding: 20,
  },
  calculatorContainer: {
    backgroundColor: 'white',
    borderRadius: 10,
    padding: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 20,
    textAlign: 'center',
    color: '#333',
  },
  inputRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 20,
  },
  input: {
    flex: 1,
    height: 50,
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    paddingHorizontal: 10,
    fontSize: 18,
    backgroundColor: '#fafafa',
  },
  operator: {
    fontSize: 24,
    marginHorizontal: 10,
    color: '#666',
  },
  button: {
    backgroundColor: '#007bff',
    borderRadius: 8,
    paddingVertical: 12,
    alignItems: 'center',
    marginBottom: 20,
  },
  buttonText: {
    color: 'white',
    fontSize: 18,
    fontWeight: '600',
  },
  resultContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 10,
  },
  resultLabel: {
    fontSize: 18,
    marginRight: 10,
    color: '#666',
  },
  resultValue: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333',
  },
  divider: {
    height: 1,
    backgroundColor: '#ddd',
    marginVertical: 20,
  },
  reportButton: {
    backgroundColor: '#ff6b6b',
    borderRadius: 8,
    paddingVertical: 12,
    alignItems: 'center',
  },
});
