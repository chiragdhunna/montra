import 'package:flutter/material.dart';
import 'package:montra/screens/on_boarding/set_up_account_screen.dart';

class SetUpPinScreen extends StatefulWidget {
  const SetUpPinScreen({super.key});

  @override
  State<SetUpPinScreen> createState() => _SetUpPinScreenState();
}

class _SetUpPinScreenState extends State<SetUpPinScreen> {
  String _enteredPin = "";
  final int _pinLength = 4;

  void _onNumberTap(String number) {
    if (_enteredPin.length < _pinLength) {
      setState(() {
        _enteredPin += number;
      });

      if (_enteredPin.length == _pinLength) {
        // TODO: Implement PIN confirmation or saving logic
      }
    }
  }

  void _onDelete() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  Widget _buildPinIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pinLength,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                index < _enteredPin.length
                    ? Colors.white
                    : Colors.white.withOpacity(0.4),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return GestureDetector(
      onTap: () => _onNumberTap(number),
      child: Container(
        width: 80,
        height: 80,
        alignment: Alignment.center,
        child: Text(
          number,
          style: const TextStyle(
            fontSize: 28,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return GestureDetector(
      onTap: _onDelete,
      child: const Icon(Icons.backspace, color: Colors.white, size: 30),
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: () {
        // TODO: Handle PIN submission
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (builder) => SetUpAccountScreen()));
      },
      child: const Icon(Icons.arrow_forward, color: Colors.white, size: 36),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Let’s setup your PIN",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          _buildPinIndicators(),
          const SizedBox(height: 40),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            padding: const EdgeInsets.symmetric(horizontal: 50),
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            children: [
              for (var i = 1; i <= 9; i++) _buildNumberButton(i.toString()),
              _buildBackspaceButton(),
              _buildNumberButton("0"),
              _buildSubmitButton(),
            ],
          ),
        ],
      ),
    );
  }
}
