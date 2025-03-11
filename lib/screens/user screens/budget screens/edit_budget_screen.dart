import 'package:flutter/material.dart';

class EditBudgetScreen extends StatefulWidget {
  const EditBudgetScreen({super.key});

  @override
  State<EditBudgetScreen> createState() => _EditBudgetScreenState();
}

class _EditBudgetScreenState extends State<EditBudgetScreen> {
  bool _receiveAlert = true;
  double _sliderValue = 80.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Center(
          child: Transform.translate(
            offset: Offset(-20, 0), // Adjust this value as needed
            child: Text('Edit Budget', style: TextStyle(color: Colors.white)),
          ),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Column(
                children: [
                  Container(
                    height: constraints.maxHeight * 0.5,
                    width: double.infinity,
                    color: Colors.purple,
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'How much do you want to spend?',
                          style: TextStyle(color: Colors.white, fontSize: 18.0),
                        ),
                        SizedBox(height: 16.0),
                        Text(
                          '\$2000',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 48.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: constraints.maxHeight * 0.5,
                    color: Colors.white,
                  ),
                ],
              ),
              Positioned(
                top: constraints.maxHeight * 0.5 - 30, // Adjust this value
                left: 0,
                right: 0,
                bottom: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                  child: Container(
                    color: Colors.white,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Category',
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Shopping',
                                  child: Text('Shopping'),
                                ),
                                // Add more categories as needed
                              ],
                              onChanged: (value) {
                                // Handle category change
                              },
                            ),
                            const SizedBox(height: 16.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Receive Alert'),
                                Switch(
                                  value: _receiveAlert,
                                  onChanged: (value) {
                                    setState(() {
                                      _receiveAlert = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                            const Text(
                              'Receive alert when it reaches some point.',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 16.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Slider(
                                    value: _sliderValue,
                                    min: 0,
                                    max: 100,
                                    divisions: 100,
                                    activeColor: Colors.purple,
                                    inactiveColor: Colors.grey[300],
                                    onChanged: (value) {
                                      setState(() {
                                        _sliderValue = value;
                                      });
                                    },
                                  ),
                                ),
                                Text('${_sliderValue.toInt()}%'),
                              ],
                            ),
                            const SizedBox(height: 16.0),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              onPressed: () {
                                // Handle continue action
                              },
                              child: const Text(
                                'Continue',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
