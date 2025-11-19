import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/glucose_reading.dart';
import '../models/medication.dart';

class AiAssistantScreen extends StatefulWidget {
  final List<BloodSugarReading> bloodSugarReadings;
  final List<Medication> medications;

  const AiAssistantScreen({
    super.key,
    required this.bloodSugarReadings,
    required this.medications,
  });

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Add user's message to chat
    setState(() {
      _messages.add({"text": text, "isUser": true});
      _controller.clear();
      _isSending = true;
    });

    try {
      // SEND READINGS + MEDICATIONS TO BACKEND
      final reply = await ApiService.sendChatMessage(
        text,
        readings: widget.bloodSugarReadings,
        medications: widget.medications,
      );

      setState(() {
        _messages.add({"text": reply, "isUser": false});
      });
    } catch (e) {
      setState(() {
        _messages.add({"text": "⚠️ Error contacting AI", "isUser": false});
      });
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Assistant")),
      body: Column(
        children: [
          // Chat UI
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment:
                      msg["isUser"] ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: msg["isUser"] ? Colors.blue : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg["text"],
                      style: TextStyle(
                        color: msg["isUser"] ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Input field
          SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Ask the AI...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: _isSending
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.send),
                  onPressed: _isSending ? null : _sendMessage,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
