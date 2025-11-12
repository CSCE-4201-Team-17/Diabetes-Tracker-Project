import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Diabetes Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

// Login Screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _isLoading = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  void _toggleFormMode() {
    setState(() {
      _isLogin = !_isLogin;
      _formKey.currentState?.reset();
      _emailController.clear();
      _passwordController.clear();
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.medical_services,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isLogin ? 'Welcome Back' : 'Create an Account',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isLogin 
                            ? 'Sign in to continue tracking your diabetes'
                            : 'Create an account to get started',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      
                      TextFormField(
                        controller: _emailController,
                        key: const ValueKey('email'),
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: _emailValidator,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _passwordController,
                        key: const ValueKey('password'),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword 
                                  ? Icons.visibility_off 
                                  : Icons.visibility,
                            ),
                            onPressed: _togglePasswordVisibility,
                          ),
                        ),
                        obscureText: _obscurePassword,
                        validator: _passwordValidator,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submitForm(),
                      ),
                      const SizedBox(height: 8),
                      
                      if (_isLogin)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Forgot password feature coming soon!'),
                                ),
                              );
                            },
                            child: const Text('Forgot Password?'),
                          ),
                        ),
                      const SizedBox(height: 16),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(_isLogin ? 'Login' : 'Sign Up'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isLogin
                                ? "Don't have an account?"
                                : "Already have an account?",
                            style: const TextStyle(color: Colors.grey),
                          ),
                          TextButton(
                            onPressed: _toggleFormMode,
                            child: Text(
                              _isLogin ? 'Sign Up' : 'Login',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Data Models
class BloodSugarReading {
  final double value;
  final DateTime timestamp;
  final String type; // fasting, after meal, before meal, etc.
  final String? notes;

  BloodSugarReading({
    required this.value,
    required this.timestamp,
    required this.type,
    this.notes,
  });
}

class Medication {
  final String name;
  final String dosage;
  final TimeOfDay time;
  final bool taken;

  Medication({
    required this.name,
    required this.dosage,
    required this.time,
    this.taken = false,
  });
}

// Home Screen with Diabetes Tracking Features
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<BloodSugarReading> _bloodSugarReadings = [];
  final List<Medication> _medications = [
    Medication(name: 'Metformin', dosage: '500mg', time: TimeOfDay(hour: 8, minute: 0)),
    Medication(name: 'Insulin', dosage: '10 units', time: TimeOfDay(hour: 20, minute: 0)),
  ];

  // Sample initial data 
  @override
  void initState() {
    super.initState();
    _bloodSugarReadings.addAll([
      BloodSugarReading(value: 120, timestamp: DateTime.now().subtract(const Duration(hours: 2)), type: 'After Meal'),
      BloodSugarReading(value: 95, timestamp: DateTime.now().subtract(const Duration(days: 1)), type: 'Fasting'),
      BloodSugarReading(value: 140, timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 4)), type: 'After Meal'),
    ]);
  }

  // Dashboard Screen
  Widget _buildDashboard() {
    final latestReading = _bloodSugarReadings.isNotEmpty ? _bloodSugarReadings.first : null;
    final todayReadings = _bloodSugarReadings.where((reading) => 
      reading.timestamp.day == DateTime.now().day).toList();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good ${_getGreeting()}!',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Track your diabetes management',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Quick Stats
          const Text(
            'Today\'s Overview',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Blood Sugar',
                  latestReading?.value.toString() ?? '--',
                  'mg/dL',
                  latestReading != null ? _getBloodSugarColor(latestReading.value) : Colors.grey,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Readings Today',
                  todayReadings.length.toString(),
                  'times',
                  Colors.blue,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildActionCard('Log Blood Sugar', Icons.monitor_heart, Colors.red, () {
                _showAddBloodSugarDialog();
              }),
              _buildActionCard('Medications', Icons.medication, Colors.green, () {
                setState(() {
                  _currentIndex = 1;
                });
              }),
              _buildActionCard('History', Icons.history, Colors.orange, () {
                setState(() {
                  _currentIndex = 2;
                });
              }),
              _buildActionCard('Settings', Icons.settings, Colors.purple, () {
                setState(() {
                  _currentIndex = 3;
                });
              }),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Recent Readings
          const Text(
            'Recent Readings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          if (_bloodSugarReadings.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No readings yet. Add your first reading!'),
              ),
            )
          else
            ..._bloodSugarReadings.take(3).map((reading) => 
              _buildReadingCard(reading)
            ).toList(),
        ],
      ),
    );
  }

  // Medications Screen
  Widget _buildMedications() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your Medications',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _showAddMedicationDialog,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _medications.length,
            itemBuilder: (context, index) {
              final medication = _medications[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: const Icon(Icons.medication, color: Colors.green),
                  title: Text(medication.name),
                  subtitle: Text('${medication.dosage} • ${_formatTimeOfDay(medication.time)}'),
                  trailing: Checkbox(
                    value: medication.taken,
                    onChanged: (value) {
                      setState(() {
                        _medications[index] = Medication(
                          name: medication.name,
                          dosage: medication.dosage,
                          time: medication.time,
                          taken: value ?? false,
                        );
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // History Screen
  Widget _buildHistory() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Blood Sugar History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: _showAddBloodSugarDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Reading'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _bloodSugarReadings.isEmpty
              ? const Center(
                  child: Text('No readings yet. Add your first reading!'),
                )
              : ListView.builder(
                  itemCount: _bloodSugarReadings.length,
                  itemBuilder: (context, index) {
                    return _buildReadingCard(_bloodSugarReadings[index]);
                  },
                ),
        ),
      ],
    );
  }

  // Settings Screen
  Widget _buildSettings() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Settings',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        _buildSettingsCard(
          'Profile',
          Icons.person,
          [
            const ListTile(
              leading: Icon(Icons.email),
              title: Text('Email'),
              subtitle: Text('user@example.com'),
            ),
            const ListTile(
              leading: Icon(Icons.phone),
              title: Text('Phone'),
              subtitle: Text('+1 234 567 8900'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSettingsCard(
          'Preferences',
          Icons.settings,
          [
            SwitchListTile(
              title: const Text('Enable Reminders'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: false,
              onChanged: (value) {},
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              const ListTile(
                leading: Icon(Icons.medical_information),
                title: Text('Medical Information'),
                subtitle: Text('Manage your health data'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper Widgets
  Widget _buildStatCard(String title, String value, String unit, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
                const SizedBox(width: 4),
                Text(unit, style: TextStyle(color: color)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadingCard(BloodSugarReading reading) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getBloodSugarColor(reading.value).withOpacity(0.2),
          child: Icon(Icons.monitor_heart, color: _getBloodSugarColor(reading.value)),
        ),
        title: Text('${reading.value} mg/dL'),
        subtitle: Text('${reading.type} • ${_formatDateTime(reading.timestamp)}'),
        trailing: Text(
          _getBloodSugarStatus(reading.value),
          style: TextStyle(
            color: _getBloodSugarColor(reading.value),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(String title, IconData icon, List<Widget> children) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  // Helper Methods
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  Color _getBloodSugarColor(double value) {
    if (value < 70) return Colors.orange; // Low
    if (value <= 140) return Colors.green; // Normal
    if (value <= 180) return Colors.orange; // High
    return Colors.red; // Very High
  }

  String _getBloodSugarStatus(double value) {
    if (value < 70) return 'Low';
    if (value <= 140) return 'Normal';
    if (value <= 180) return 'High';
    return 'Very High';
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, h:mm a').format(dateTime);
  }

  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    return DateFormat('h:mm a').format(dateTime);
  }

  // Dialog Methods
  void _showAddBloodSugarDialog() {
    final TextEditingController valueController = TextEditingController();
    String selectedType = 'Fasting';
    final List<String> types = ['Fasting', 'Before Meal', 'After Meal', 'Bedtime'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Blood Sugar Reading'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: valueController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Blood Sugar (mg/dL)',
                prefixIcon: Icon(Icons.monitor_heart),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedType,
              items: types.map((type) => 
                DropdownMenuItem(value: type, child: Text(type))
              ).toList(),
              onChanged: (value) => selectedType = value!,
              decoration: const InputDecoration(labelText: 'Reading Type'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(valueController.text);
              if (value != null) {
                setState(() {
                  _bloodSugarReadings.insert(0, BloodSugarReading(
                    value: value,
                    timestamp: DateTime.now(),
                    type: selectedType,
                  ));
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added reading: $value mg/dL')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddMedicationDialog() {
    // Implementation for adding medication
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add medication feature coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diabetes Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboard(),
          _buildMedications(),
          _buildHistory(),
          _buildSettings(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.medication), label: 'Medications'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
      floatingActionButton: _currentIndex == 0 ? FloatingActionButton(
        onPressed: _showAddBloodSugarDialog,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
    );
  }
}