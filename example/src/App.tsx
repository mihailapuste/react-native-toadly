import React, { useState } from 'react';
import {
  Text,
  View,
  StyleSheet,
  TextInput,
  TouchableOpacity,
  KeyboardAvoidingView,
  Platform,
} from 'react-native';
import { multiply } from 'react-native-toadly';

export default function App() {
  const [firstNumber, setFirstNumber] = useState('3');
  const [secondNumber, setSecondNumber] = useState('7');
  const [result, setResult] = useState(multiply(3, 7).toString());

  const calculateResult = () => {
    const num1 = parseFloat(firstNumber) || 0;
    const num2 = parseFloat(secondNumber) || 0;
    setResult(multiply(num1, num2).toString());
  };

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
    >
      <View style={styles.calculatorContainer}>
        <Text style={styles.title}>Multiply Calculator</Text>

        <View style={styles.inputRow}>
          <TextInput
            style={styles.input}
            value={firstNumber}
            onChangeText={setFirstNumber}
            keyboardType="numeric"
            placeholder="Enter first number"
          />

          <Text style={styles.operator}>×</Text>

          <TextInput
            style={styles.input}
            value={secondNumber}
            onChangeText={setSecondNumber}
            keyboardType="numeric"
            placeholder="Enter second number"
          />
        </View>

        <TouchableOpacity style={styles.button} onPress={calculateResult}>
          <Text style={styles.buttonText}>Calculate</Text>
        </TouchableOpacity>

        <View style={styles.resultContainer}>
          <Text style={styles.resultLabel}>Result:</Text>
          <Text style={styles.resultValue}>{result}</Text>
        </View>
      </View>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  calculatorContainer: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 20,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 30,
    color: '#333',
  },
  inputRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 20,
    width: '100%',
    justifyContent: 'center',
  },
  input: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    padding: 12,
    width: '40%',
    fontSize: 18,
    backgroundColor: 'white',
  },
  operator: {
    fontSize: 24,
    marginHorizontal: 10,
    color: '#333',
  },
  button: {
    backgroundColor: '#007AFF',
    paddingVertical: 12,
    paddingHorizontal: 30,
    borderRadius: 8,
    marginVertical: 20,
  },
  buttonText: {
    color: 'white',
    fontSize: 18,
    fontWeight: '600',
  },
  resultContainer: {
    marginTop: 20,
    alignItems: 'center',
  },
  resultLabel: {
    fontSize: 18,
    color: '#555',
    marginBottom: 5,
  },
  resultValue: {
    fontSize: 36,
    fontWeight: 'bold',
    color: '#007AFF',
  },
});
