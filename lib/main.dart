import 'package:assignment_app/providers.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => BottomNavigationProvider()),
        ChangeNotifierProvider(create: (ctx) => IncrementProvider())
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Widget> _pages = [
    const UserListScreen(),
    const IncrementCounterScreen()
  ];
  @override
  Widget build(BuildContext context) {
    return Consumer<BottomNavigationProvider>(
        builder: (context, bottomNavProvider, child) {
      return Scaffold(
        bottomNavigationBar: CurvedNavigationBar(
          buttonBackgroundColor: Colors.white,
          backgroundColor: const Color.fromARGB(0, 255, 255, 255),
          color: const Color.fromARGB(255, 76, 0, 90),
          animationDuration: const Duration(milliseconds: 300),
          onTap: (index) {
            setState(() {
              bottomNavProvider.setIndex(index);
            });
          },
          items: const [
            Icon(Icons.home_rounded, color: Colors.yellow),
            Icon(Icons.miscellaneous_services, color: Colors.yellow),
          ],
        ),
        body: SafeArea(
          child: _pages[bottomNavProvider.currentIndex],
        ),
      );
    });
  }
}

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List users = [];
  List filteredUsers = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final response = await http
          .get(Uri.parse('https://jsonplaceholder.typicode.com/users'));
      if (response.statusCode == 200) {
        setState(() {
          users = json.decode(response.body);
          filteredUsers = users;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load users';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load users';
        isLoading = false;
      });
    }
  }

  void filterUsers(String query) {
    final filtered = users.where((user) {
      final nameLower = user['name'].toLowerCase();
      final emailLower = user['email'].toLowerCase();
      final searchLower = query.toLowerCase();

      return nameLower.contains(searchLower) ||
          emailLower.contains(searchLower);
    }).toList();

    setState(() {
      filteredUsers = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 76, 0, 90),
        title: const Text(
          'User List',
          style: TextStyle(color: Colors.yellow),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Search',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (query) => filterUsers(query),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          return ListTile(
                            title: Text(user['name']),
                            subtitle: Text(user['email']),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}

class IncrementCounterScreen extends StatefulWidget {
  const IncrementCounterScreen({super.key});

  @override
  State<IncrementCounterScreen> createState() => _IncrementCounterScreenState();
}

class _IncrementCounterScreenState extends State<IncrementCounterScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<IncrementProvider>(builder: (context, provider, child) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Increment Counter",
            style: TextStyle(color: Colors.yellow),
          ),
          backgroundColor: const Color.fromARGB(255, 76, 0, 90),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                provider.increment.toString(),
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton.filled(
                      color: Colors.yellow,
                      onPressed: () {
                        setState(() {
                          provider.increase();
                        });
                      },
                      icon: const Icon(Icons.add)),
                  const SizedBox(
                    width: 20,
                  ),
                  IconButton.filled(
                      color: Colors.yellow,
                      onPressed: () {
                        setState(() {
                          provider.decrease();
                        });
                      },
                      icon: const Icon(Icons.remove)),
                ],
              )
            ],
          ),
        ),
      );
    });
  }
}
