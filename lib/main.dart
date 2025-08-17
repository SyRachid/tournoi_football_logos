
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const TournamentApp());
}

class TournamentApp extends StatelessWidget {
  const TournamentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tournoi Football',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const TournamentPage(),
    );
  }
}

enum RoundStage { quarts, demis, finale, champion }

class Team {
  final String name;
  final String asset; // asset path (png)
  final Color color;
  final String short;
  const Team(this.name, this.asset, this.color, this.short);
}

class TournamentPage extends StatefulWidget {
  const TournamentPage({super.key});

  @override
  State<TournamentPage> createState() => _TournamentPageState();
}

class _TournamentPageState extends State<TournamentPage> {
  final Random _rng = Random();

  // Configuration
  int numPlayers = 2;

  // Teams pool (asset filenames located in assets/logos/)
  final List<Team> allTeams = const [
    Team('Real Madrid', 'assets/logos/real_madrid.png', Color(0xFFFEBE10), 'RMA'),
    Team('FC Barcelona', 'assets/logos/barca.png', Color(0xFF004D98), 'BAR'),
    Team('Manchester City', 'assets/logos/man_city.png', Color(0xFF66B2FF), 'MCI'),
    Team('Liverpool', 'assets/logos/liverpool.png', Color(0xFFC8102E), 'LIV'),
    Team('Bayern Munich', 'assets/logos/bayern.png', Color(0xFFDC052D), 'BAY'),
    Team('Paris Saint-Germain', 'assets/logos/psg.png', Color(0xFF002266), 'PSG'),
    Team('Juventus', 'assets/logos/juventus.png', Color(0xFF000000), 'JUV'),
    Team('Chelsea', 'assets/logos/chelsea.png', Color(0xFF034694), 'CHE')
  ];

  // State
  RoundStage stage = RoundStage.quarts;
  int roundSize = 8;
  List<Team?> participants = List<Team?>.filled(8, null);
  List<String> scoreLines = [];

  int playersAssigned = 0;
  Set<int> usedTeamIdx = {};

  String get stageLabel {
    switch (stage) {
      case RoundStage.quarts:
        return 'Quarts de finale';
      case RoundStage.demis:
        return 'Demi-finales';
      case RoundStage.finale:
        return 'Finale';
      case RoundStage.champion:
        return 'Champion';
    }
  }

  void resetAll() {
    setState(() {
      numPlayers = 2;
      stage = RoundStage.quarts;
      roundSize = 8;
      participants = List<Team?>.filled(8, null);
      scoreLines = [];
      playersAssigned = 0;
      usedTeamIdx.clear();
    });
  }

  void assignRandomTeamToPlayerSlot() {
    if (playersAssigned >= numPlayers) return;
    final available = List<int>.generate(allTeams.length, (i) => i)
        .where((i) => !usedTeamIdx.contains(i))
        .toList();
    if (available.isEmpty) return;
    final idx = available[_rng.nextInt(available.length)];
    usedTeamIdx.add(idx);
    participants[playersAssigned] = allTeams[idx];
    playersAssigned++;
    setState(() {});
  }

  void fillAIAndGo() {
    for (int i = playersAssigned; i < 8; i++) {
      final avail = List<int>.generate(allTeams.length, (j) => j)
          .where((j) => !usedTeamIdx.contains(j))
          .toList();
      if (avail.isEmpty) break;
      final idx = avail[_rng.nextInt(avail.length)];
      usedTeamIdx.add(idx);
      participants[i] = allTeams[idx];
    }
    setState(() {});
  }

  void simulateRound() {
    if (stage == RoundStage.champion) return;
    if (participants.take(roundSize).any((t) => t == null)) return;

    final List<Team?> next = List<Team?>.filled(roundSize ~/ 2, null);
    final List<String> lines = [];

    for (int m = 0; m < roundSize ~/ 2; m++) {
      final a = participants[m * 2]!;
      final b = participants[m * 2 + 1]!;
      int sa = _rng.nextInt(6);
      int sb = _rng.nextInt(6);
      if (sa == sb) {
        if (sb < 5) {
          sb += 1;
        } else {
          sa = (sa > 0) ? sa - 1 : 0;
        }
      }
      final winner = (sa > sb) ? a : b;
      next[m] = winner;
      lines.add('${a.name} $sa - $sb ${b.name}');
    }

    setState(() {
      scoreLines = lines;
      roundSize = roundSize ~/ 2;
      for (int i = 0; i < next.length; i++) {
        participants[i] = next[i];
      }
      for (int i = next.length; i < participants.length; i++) {
        participants[i] = null;
      }

      if (stage == RoundStage.quarts) {
        stage = RoundStage.demis;
      } else if (stage == RoundStage.demis) {
        stage = RoundStage.finale;
      } else if (stage == RoundStage.finale) {
        stage = RoundStage.champion;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournoi Football (8 équipes)'),
        actions: [
          IconButton(
            onPressed: resetAll,
            tooltip: 'Réinitialiser',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                stageLabel,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),

              if (playersAssigned < numPlayers) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Nombre de joueurs : '),
                    DropdownButton<int>(
                      value: numPlayers,
                      items: const [1, 2, 3, 4]
                          .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() {
                          numPlayers = v;
                          playersAssigned = 0;
                          usedTeamIdx.clear();
                          participants = List<Team?>.filled(8, null);
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(numPlayers, (i) {
                    return ElevatedButton.icon(
                      onPressed: assignRandomTeamToPlayerSlot,
                      icon: const Icon(Icons.sports_soccer),
                      label: Text('Joueur ${i + 1}: Tirer équipe'),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: (playersAssigned == numPlayers) ? fillAIAndGo : null,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Remplir IA & Commencer'),
                ),
                const Divider(height: 24),
              ],

              Expanded(
                child: LayoutBuilder(
                  builder: (context, c) {
                    return SingleChildScrollView(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 900),
                          child: Column(
                            children: [
                              if (stage == RoundStage.quarts || stage == RoundStage.demis || stage == RoundStage.finale || stage == RoundStage.champion)
                                _roundGrid(context, 8, 100),
                              const SizedBox(height: 8),
                              if (stage == RoundStage.demis || stage == RoundStage.finale || stage == RoundStage.champion)
                                _roundGrid(context, 4, 110, offset: 0),
                              const SizedBox(height: 8),
                              if (stage == RoundStage.finale || stage == RoundStage.champion)
                                _roundGrid(context, 2, 120, offset: 0),
                              const SizedBox(height: 8),
                              if (stage == RoundStage.champion)
                                Column(
                                  children: [
                                    const Text('Champion ! 🎉', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    _teamBadge(participants[0], size: 90),
                                    const SizedBox(height: 8),
                                    Text(participants[0]?.name ?? '', style: const TextStyle(fontSize: 18)),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              if (scoreLines.isNotEmpty && stage != RoundStage.quarts)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const Text('Scores du dernier tour :', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    ...scoreLines.map((s) => Text('• $s')).toList(),
                  ],
                ),

              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: (playersAssigned == numPlayers && participants.take(8).every((t) => t != null) && stage != RoundStage.champion)
                        ? simulateRound
                        : null,
                    icon: const Icon(Icons.skip_next),
                    label: const Text('Suivant (simuler le tour)'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roundGrid(BuildContext context, int size, double badgeSize, {int offset = 0}) {
    final items = List<Widget>.generate(size, (i) {
      final team = participants[i];
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _teamBadge(team, size: badgeSize),
          const SizedBox(height: 6),
          SizedBox(
            width: badgeSize + 10,
            child: Text(
              team?.name ?? '—',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    });

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: items,
    );
  }

  Widget _teamBadge(Team? team, {double size = 80}) {
    final Color bg = team?.color ?? Colors.grey.shade400;
    final String text = team?.short ?? '?';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg.withOpacity(0.9),
        shape: BoxShape.circle,
        image: team != null ? DecorationImage(
          image: AssetImage(team.asset),
          fit: BoxFit.cover,
        ) : null,
        boxShadow: const [BoxShadow(blurRadius: 6, spreadRadius: 1, offset: Offset(0, 2))],
      ),
      alignment: Alignment.center,
      child: team == null ? Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.26,
          letterSpacing: 1.2,
        ),
      ) : null,
    );
  }
}
