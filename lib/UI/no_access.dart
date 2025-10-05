import 'package:flutter/material.dart';

class NoAccessPage extends StatelessWidget {
  final String resourceName;

  const NoAccessPage({super.key, required this.resourceName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Access Denied')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('You do not have access to $resourceName.', style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              Text('Please contact your admin to request access.', style: TextStyle(color: Colors.grey)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                child: Text('Return Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


