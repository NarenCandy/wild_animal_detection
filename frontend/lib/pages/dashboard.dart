import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../api/api_service.dart';
import '../models/alerts.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Alert> _alerts = [];
  bool _isLoading = true;
  Map<String, int> _animalCounts = {};

  // Chatbot setup
  final ChatUser user = ChatUser(id: '1', firstName: 'User');
  final ChatUser bot = ChatUser(id: '2', firstName: 'WildBot');
  List<ChatMessage> messages = [];

  @override
  void initState() {
    super.initState();
    _fetchAlerts();
  }

  Future<void> _fetchAlerts() async {
    try {
      final data = await ApiService.getAlerts();
      setState(() {
        _alerts = data;
        _isLoading = false;
        _calculateStats();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching alerts: $e');
    }
  }

  void _calculateStats() {
    Map<String, int> counts = {};
    for (var a in _alerts) {
      counts[a.animal] = (counts[a.animal] ?? 0) + 1;
    }
    _animalCounts = counts;
  }

  String getMostFrequentAnimal() {
    if (_animalCounts.isEmpty) return "N/A";
    return _animalCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  void _openChatbot() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.85,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: DashChat(
            currentUser: user,
            messages: messages,
            onSend: (ChatMessage m) {
              setState(() => messages.add(m));
              _handleChatResponse(m.text);
            },

            // SET THIS:
            messageOptions: MessageOptions(
              messageTextBuilder:
                  (ChatMessage msg, ChatMessage? prev, ChatMessage? next) {
                return MarkdownBody(
                  data: msg.text,
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(fontSize: 16, color: Colors.black),
                    strong: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _handleChatResponse(String query) {
    String reply =
        "I'm not sure about that. Could you please specify the animal you're asking about?";
    if (query.contains("hi") || query.contains("hello")) {
      reply =
          "👋 **Hello there!** How can I help you today? You can ask about **elephants**, **tigers**, **boars**, or **bears**.";
    } else if (query.contains("thank") || query.contains("thanks")) {
      reply =
          "🤝 **You're welcome!** Stay safe and alert around wildlife. Would you like me to share **safety tips**?";
    } else if (query.contains("bye") || query.contains("goodbye")) {
      reply = "👋 **Goodbye!** Take care and have a great day ahead!";
    } else if (query.contains("good night")) {
      reply =
          "🌙 **Good night!** Stay safe and rest well — nature never sleeps!";
    } else if (query.contains("good morning")) {
      reply =
          "🌞 **Good morning!** Perfect time to stay alert and start your day safely!";
    } else if (query.contains("good evening")) {
      reply =
          "🌇 **Good evening!** It’s getting dark — remember, most wildlife activity increases now!";
    }

    // Detect intent
    bool wantsPrevention = query.contains("prevent") ||
        query.contains("avoid") ||
        query.contains("stop");
    bool wantsHelp = query.contains("help") ||
        query.contains("emergency") ||
        query.contains("contact");
    bool wantsEncounter = query.contains("see") ||
        query.contains("attack") ||
        query.contains("spotted") ||
        query.contains("near") ||
        query.contains("approach") ||
        query.contains("what to do");

    // Base contact info
    const contactInfo = """
📞 **Wildlife Emergency Contacts**
- Toll-Free Helpline: **1800 425 4409**
- Direct Line (Chennai): **044 24323783**
""";

    // ELEPHANT
    if (query.contains("elephant")) {
      if (wantsPrevention) {
        reply = """
🌿 **Preventing Elephant Encounters**

✅ Use chili rope or solar electric fencing.
✅ Store food grains, fruits & alcohol securely indoors.
✅ Maintain a clean farm boundary — avoid banana or palm near forest edges.
✅ Use motion lights or hanging cloth strips to signal movement.

$contactInfo
""";
      } else if (wantsEncounter) {
        reply = """
🚨 **If You Encounter an Elephant**

1️⃣ Stay calm and quiet — do **not** shout or run.  
2️⃣ Move **away diagonally**, not directly back.  
3️⃣ Keep at least **100 meters distance**.  
4️⃣ Never block their trail or throw objects.  
5️⃣ If it starts trumpeting or flapping ears, move behind cover immediately.

$contactInfo
""";
      } else {
        reply = """
🐘 Elephants can be dangerous if threatened.
Would you like to know **how to prevent** or **what to do during** an encounter?

$contactInfo
""";
      }
    }

    // TIGER
    else if (query.contains("tiger")) {
      if (wantsPrevention) {
        reply = """
🌿 **Preventing Tiger Incidents**

✅ Avoid going alone near forest edges at dawn or dusk.  
✅ Keep livestock in enclosed sheds at night.  
✅ Set up **solar lights or sirens** triggered by motion.  
✅ Inform forest rangers if you spot pugmarks nearby.

$contactInfo
""";
      } else if (wantsEncounter) {
        reply = """
⚠️ **If You See a Tiger**

1️⃣ **Do not run** — it may trigger a chase.  
2️⃣ Maintain eye contact and **slowly back away**.  
3️⃣ Try to appear larger (raise hands or open your jacket).  
4️⃣ Move calmly toward shelter while facing the tiger.  
5️⃣ If attacked, fight back with sticks or stones targeting its face.

$contactInfo
""";
      } else {
        reply = """
🐅 Tigers are territorial and active during early morning or late evening.  
Would you like tips on **how to avoid tigers** or **what to do if you see one**?

$contactInfo
""";
      }
    }

    // BOAR
    else if (query.contains("boar")) {
      if (wantsPrevention) {
        reply = """
🌿 **Preventing Wild Boar Damage**

✅ Install solar fencing or use LED deterrent lights.  
✅ Harvest ripe crops promptly.  
✅ Avoid leaving feed or leftovers near open areas.  
✅ Inform local wildlife officials if herds are seen nearby.

$contactInfo
""";
      } else if (wantsEncounter) {
        reply = """
🚨 **If You Encounter a Wild Boar**

1️⃣ Stay calm and **don't corner it**.  
2️⃣ Move behind a strong barrier or climb up quickly.  
3️⃣ Make loud noises (metal banging, shouting) from afar.  
4️⃣ Avoid direct confrontation — they can charge suddenly.  

$contactInfo
""";
      } else {
        reply = """
🐗 Wild boars are aggressive if provoked.  
Would you like to know **how to avoid them** or **what to do during an encounter**?

$contactInfo
""";
      }
    }

    // BEAR
    else if (query.contains("bear")) {
      if (wantsPrevention) {
        reply = """
🌿 **Preventing Bear Encounters**

✅ Store food and waste securely — bears are drawn to strong smells.  
✅ Avoid walking alone early morning or late evening.  
✅ Keep livestock areas well-lit.  
✅ Make noise while moving through forest paths.

$contactInfo
""";
      } else if (wantsEncounter) {
        reply = """
⚠️ **If You See a Bear**

1️⃣ **Do not run** — stay calm and talk softly.  
2️⃣ Slowly back away, keeping the bear in view.  
3️⃣ Avoid eye contact but watch its movements.  
4️⃣ If it charges, stand your ground — many charges are bluff.  
5️⃣ If attacked, **play dead**, covering your head and neck.

$contactInfo
""";
      } else {
        reply = """
🐻 Bears are curious but can be dangerous when startled.  
Would you like to know **how to prevent bear visits** or **how to stay safe if one appears**?

$contactInfo
""";
      }
    }

    // HUMAN or OTHER
    else if (query.contains("human")) {
      reply = """
👤 The system identifies human presence to detect intrusions near restricted or farm zones.  
If this seems like a false alert, please report it through the dashboard.

$contactInfo
""";
    }

    // UNKNOWN
    else if (wantsHelp) {
      reply = """
🆘 **Wildlife Emergency Contacts**

- Toll-Free Helpline: **1800 425 4409**  
- Direct Line (Chennai): **044 24323783**

Stay safe and alert. You can tell me the animal name to get quick safety and prevention tips.
""";
    }

    // Fallback
    final botReply = ChatMessage(
      user: bot,
      createdAt: DateTime.now(),
      text: reply.trim(),
    );

    setState(() => messages.add(botReply));
  }

  @override
  Widget build(BuildContext context) {
    final mostFrequent = getMostFrequentAnimal();
    final totalAlerts = _alerts.length;
    final recentAlerts = _alerts.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("📊 Dashboard"),
        backgroundColor: Colors.teal,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: _openChatbot,
        child: const Icon(Icons.chat, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Summary Cards ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard(
                          "Total Alerts", "$totalAlerts", Icons.notifications),
                      _buildStatCard("Frequent", mostFrequent, Icons.pets),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- Pie Chart ---
                  if (_animalCounts.isNotEmpty)
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: _animalCounts.entries.map((e) {
                            final color = Colors.primaries[
                                _animalCounts.keys.toList().indexOf(e.key) %
                                    Colors.primaries.length];
                            return PieChartSectionData(
                              value: e.value.toDouble(),
                              title: e.key,
                              color: color,
                              radius: 60,
                              titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            );
                          }).toList(),
                        ),
                      ),
                    )
                  else
                    const Center(child: Text("No alerts data to show yet")),
                  const SizedBox(height: 20),

                  const Text("🕒 Latest Alerts",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  ...recentAlerts.map((alert) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: Image.network(
                            alert.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.error),
                              );
                            },
                          ),
                          title: Text(alert.animal.toUpperCase()),
                          subtitle: Text(alert.timestamp),
                        ),
                      )),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.teal, size: 30),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, color: Colors.teal)),
        ],
      ),
    );
  }
}
