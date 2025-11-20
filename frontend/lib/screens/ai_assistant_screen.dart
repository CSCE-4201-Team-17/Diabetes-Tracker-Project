import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/glucose_reading.dart';
import '../models/medication.dart';
import '../widgets/glucose_trend_chart.dart';

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

  Future<void> _callBackend(String message) async {
    setState(() {
      _isSending = true;
    });

    try {
      // SEND READINGS + MEDICATIONS TO BACKEND
      final reply = await ApiService.sendChatMessage(
        message,
        readings: widget.bloodSugarReadings,
        medications: widget.medications,
      );

      setState(() {
        _messages.add({
          "type": "text",
          "text": reply,
          "isUser": false,
        });
      });
    } catch (e) {
      setState(() {
        _messages.add({
          "type": "text",
          "text": "Error contacting AI. Please try again.",
          "isUser": false,
        });
      });
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        "type": "text",
        "text": text,
        "isUser": true,
      });
      _controller.clear();
    });

    await _callBackend(text);
  }

  Future<void> _askFutureTrend() async {
    if (widget.bloodSugarReadings.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Not enough readings yet to show a trend. "
            "Log a few more blood sugar values first.",
          ),
        ),
      );
      return;
    }

    const prompt =
        "Based on my recent blood sugar readings and medications, "
        "what could happen over the next ~3 weeks if this pattern continues? "
        "Explain the trend using the data and rough forecast, but remind me "
        "it is only an estimate and not medical advice.";

    setState(() {
      // user message
      _messages.add({
        "type": "text",
        "text": prompt,
        "isUser": true,
      });
      // chart bubble right after
      _messages.add({
        "type": "chart",
        "isUser": false,
      });
    });

    await _callBackend(prompt);
  }

  /// Small helper: colored square + label, e.g. orange "Low", green "In range"
  Widget _zoneLabel(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Assistant"),
      ),
      body: Column(
        children: [
          //  CHAT (text + chart) 
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final String type = msg["type"] ?? "text";

                if (type == "chart") {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        // slightly smaller vertical padding to reduce height
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ---- HEADER ROW: Trend + 3-week trend ----
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Trend",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // keep label on a single line, no wrapping
                                Flexible(
                                  child: Text(
                                    "3-week trend",
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 4),

                            Wrap(
                              spacing: 12,
                              runSpacing: 4,
                              children: [
                                // These should match your zone colors in the chart:
                                // low = orange tinted, normal = green, high = red
                                _zoneLabel(
                                  Colors.orange.withOpacity(0.8),
                                  "Low",
                                ),
                                _zoneLabel(
                                  Colors.green.withOpacity(0.8),
                                  "In range",
                                ),
                                _zoneLabel(
                                  Colors.red.withOpacity(0.8),
                                  "High",
                                ),
                              ],
                            ),

                            const SizedBox(height: 4),

                            // Short line explaining dots/lines
                            const Text(
                              "Blue dots = your readings. "
                              "Red solid/dashed line = trend and ~3-week forecast.",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // ---- CHART (slightly shorter vertically) ----
                            SizedBox(
                              height: 190, // was 230 before
                              width:
                                  MediaQuery.of(context).size.width * 0.75,
                              child: GlucoseTrendChart(
                                readings: widget.bloodSugarReadings,
                              ),
                            ),

                            const SizedBox(height: 4),

                            const Text(
                              "This forecast is only an estimate from your recent data "
                              "and is NOT medical advice. Always talk to your doctor "
                              "before changing anything.",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final bool isUser = msg["isUser"] as bool? ?? false;

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.teal : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg["text"] as String,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          //  INPUT + SMALL GREEN TREND BUTTON 
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 6.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Ask questions over glucose numbers...",
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      minLines: 1,
                      maxLines: 4,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 32,
                        child: ElevatedButton.icon(
                          onPressed:
                              _isSending ? null : _askFutureTrend,
                          icon: const Icon(
                            Icons.trending_up,
                            size: 18,
                          ),
                          label: const Text(
                            "Trend",
                            style: TextStyle(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      _isSending
                          ? const SizedBox(
                              width: 26,
                              height: 26,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.send),
                              color: Colors.teal,
                              onPressed: _sendMessage,
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
