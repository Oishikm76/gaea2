import 'package:flutter/material.dart';

void main() => runApp(const GaeaApp());

class GaeaApp extends StatelessWidget {
  const GaeaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gaea: The Soil Classification App',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: const Color(0xFFF3EFEF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.brown,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.brown.shade400,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gaea: The Soil Classification App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Instructions:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose one of the classification systems below to classify your soil sample according to USDA, AASHTO, or USCS standards.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const UsdaClassificationPage()),
                      );
                    },
                    child: const Text('USDA Classification'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AashtoClassificationPage()),
                      );
                    },
                    child: const Text('AASHTO Classification'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const UscsClassificationPage()),
                      );
                    },
                    child: const Text('USCS Classification'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UsdaClassificationPage extends StatefulWidget {
  const UsdaClassificationPage({super.key});

  @override
  State<UsdaClassificationPage> createState() => _UsdaClassificationPageState();
}

class _UsdaClassificationPageState extends State<UsdaClassificationPage> {
  final _sandController = TextEditingController();
  final _clayController = TextEditingController();
  final _gravelController = TextEditingController();

  String _result = '';

  void classifySoil() {
    double sand = double.tryParse(_sandController.text) ?? 0.0;
    double clay = double.tryParse(_clayController.text) ?? 0.0;
    double gravel = double.tryParse(_gravelController.text) ?? 0.0;

    double silt = 100 - sand - clay - gravel;

    if (gravel < 0 || sand < 0 || clay < 0 || silt < 0) {
      setState(() {
        _result = "⚠️ Invalid percentages! They must be non-negative and sum to 100% (including gravel).";
      });
      return;
    }

    if (gravel >= 100) {
      setState(() {
        _result = "⚠️ The soil cannot be composed entirely of gravel.";
      });
      return;
    }

    double adjustedFactor = gravel > 0 ? 100 / (100 - gravel) : 1;
    sand = sand * adjustedFactor;
    clay = clay * adjustedFactor;
    silt = silt * adjustedFactor;

    String soilType = classifySoilUsda(sand, silt, clay);

    if (gravel > 0) {
      setState(() {
        _result = "✅ The soil type is: Gravelly $soilType";
      });
    } else {
      setState(() {
        _result = "✅ The soil type is: $soilType";
      });
    }
  }

  String classifySoilUsda(double sand, double silt, double clay) {
    if ((sand + silt + clay).round() != 100) {
      return "Invalid percentages: they should add up to 100";
    }

    if (sand > 85 && (silt + 1.5 * clay) < 15) return "Sand";
    if (70 <= sand && sand <= 91 && (silt + 1.5 * clay) >= 15 && (silt + 2 * clay) < 30) return "Loamy sand";
    if ((7 <= clay && clay <= 20 && sand > 52 && (silt + 2 * clay) >= 30) || (clay < 7 && silt < 50 && sand > 43)) return "Sandy loam";
    if (7 <= clay && clay <= 27 && 28 <= silt && silt <= 50 && sand <= 52) return "Loam";
    if ((silt >= 50 && 12 <= clay && clay <= 27) || (50 <= silt && silt <= 80 && clay < 12)) return "Silt loam";
    if (silt >= 80 && clay < 12) return "Silt";
    if (20 <= clay && clay <= 35 && silt < 28 && sand > 45) return "Sandy clay loam";
    if (27 <= clay && clay <= 40 && 20 < sand && sand <= 46) return "Clay loam";
    if (27 <= clay && clay <= 40 && sand <= 20) return "Silty clay loam";
    if (clay >= 35 && sand >= 45) return "Sandy clay";
    if (clay >= 40 && silt >= 40) return "Silty clay";
    if (clay >= 40 && sand <= 45 && silt < 40) return "Clay";

    return "Not classified";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('USDA Classification')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Enter Soil Sample Data (%):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _sandController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Sand'),
            ),
            TextField(
              controller: _clayController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Clay'),
            ),
            TextField(
              controller: _gravelController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Gravel (optional)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: classifySoil,
              child: const Text('Classify Soil'),
            ),
            const SizedBox(height: 20),
            Text(
              _result,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}

class AashtoClassificationPage extends StatefulWidget {
  const AashtoClassificationPage({super.key});

  @override
  State<AashtoClassificationPage> createState() => _AashtoClassificationPageState();
}

class _AashtoClassificationPageState extends State<AashtoClassificationPage> {
  final _llController = TextEditingController();
  final _piController = TextEditingController();
  final _pass10Controller = TextEditingController();
  final _pass40Controller = TextEditingController();
  final _pass200Controller = TextEditingController();

  String _result = '';

  void classifySoil() {
    double ll = double.tryParse(_llController.text) ?? 0.0;
    double pi = double.tryParse(_piController.text) ?? 0.0;
    double pass10 = double.tryParse(_pass10Controller.text) ?? 0.0;
    double pass40 = double.tryParse(_pass40Controller.text) ?? 0.0;
    double pass200 = double.tryParse(_pass200Controller.text) ?? 0.0;

    String classification = aashtoClassify(ll, pi, pass10, pass40, pass200);
    int gi = calculateGI(classification, ll, pi, pass200);

    setState(() {
      _result = "✅ The AASHTO soil classification is: $classification ($gi)";
    });
  }

  String aashtoClassify(double ll, double pi, double pass10, double pass40, double pass200) {
    if (pass200 <= 35) {
      if (pass200 <= 15 && pass10 <= 50 && pass40 <= 30 && pi <= 6) return "A-1-a";
      if (pass200 <= 25 && pass40 <= 50 && pi <= 6) return "A-1-b";
      if (pass200 <= 10 && pass40 >= 51) return "A-3";
      if (pass200 <= 35) {
        if (ll <= 40 && pi <= 10) return "A-2-4";
        if (ll >= 41 && pi <= 10) return "A-2-5";
        if (ll <= 40 && pi > 10) return "A-2-6";
        if (ll >= 41 && pi > 10) return "A-2-7";
      }
    } else {
      if (ll <= 40 && pi <= 10) return "A-4";
      if (ll >= 41 && pi <= 10) return "A-5";
      if (ll <= 40 && pi > 10) return "A-6";
      if (ll >= 41 && pi > 10) {
        if (pi <= ll - 30) return "A-7-5";
        return "A-7-6";
      }
    }
    return "Unclassified";
  }

  int calculateGI(String classification, double ll, double pi, double pass200) {
    int gi;
    if (["A-1-a", "A-1-b", "A-2-4", "A-2-5", "A-3", "Unclassified"].contains(classification)) {
      gi = 0;
    } else if (["A-2-6", "A-2-7"].contains(classification)) {
      gi = ((0.01 * (pass200 - 15) * (pi - 10)).round());
    } else {
      gi = ((pass200 - 35) * (0.2 + 0.005 * (ll - 40)) + 0.01 * (pass200 - 15) * (pi - 10)).round();
    }
    return gi < 0 ? 0 : gi;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AASHTO Classification')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Enter Soil Sample Data:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _llController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Liquid Limit (LL)'),
            ),
            TextField(
              controller: _piController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Plasticity Index (PI)'),
            ),
            TextField(
              controller: _pass10Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '% passing No. 10 sieve'),
            ),
            TextField(
              controller: _pass40Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '% passing No. 40 sieve'),
            ),
            TextField(
              controller: _pass200Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '% passing No. 200 sieve'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: classifySoil,
              child: const Text('Classify Soil'),
            ),
            const SizedBox(height: 20),
            Text(
              _result,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}


class UscsClassificationPage extends StatefulWidget {
  const UscsClassificationPage({super.key});

  @override
  State<UscsClassificationPage> createState() => _UscsClassificationPageState();
}

class _UscsClassificationPageState extends State<UscsClassificationPage> {
  final _pass200Controller = TextEditingController();
  final _llController = TextEditingController();
  final _plController = TextEditingController();
  final _gravelController = TextEditingController();
  final _sandController = TextEditingController();
  final _organicController = TextEditingController();
  final _d10Controller = TextEditingController();
  final _d30Controller = TextEditingController();
  final _d60Controller = TextEditingController();

  String _result = '';

  void classifySoil() {
    double? pass200 = double.tryParse(_pass200Controller.text);
    double? ll = double.tryParse(_llController.text);
    double? pl = double.tryParse(_plController.text);
    double? gravel = double.tryParse(_gravelController.text);
    double? sand = double.tryParse(_sandController.text);
    bool organic = _organicController.text.trim().toLowerCase() == "yes";
    double? d10 = double.tryParse(_d10Controller.text);
    double? d30 = double.tryParse(_d30Controller.text);
    double? d60 = double.tryParse(_d60Controller.text);

    if (pass200 == null || ll == null || pl == null || gravel == null) {
      setState(() {
        _result = "❌ Error: Missing required data.";
      });
      return;
    }

    double pi = ll - pl;
    sand ??= 100 - pass200 - gravel;

    String uscsSymbol = uscsClassify(pass200, ll, pl, gravel, d60, d10, d30, organic);
    String output = generateOutputText(uscsSymbol, gravel, sand, ll, organic, pi, pass200);

    setState(() {
      _result = output;
    });
  }

  bool checkALine(double ll, double pi) => pi >= 0.73 * (ll - 20);
  String getFineType(double ll, double pi) => checkALine(ll, pi) ? "C" : "M";

  String uscsClassify(double pass200, double ll, double pl, double gravel,
      double? d60, double? d10, double? d30, bool organic) {
    double pi = ll - pl;
    double fines = pass200;

    if (fines < 50) {
      bool gradationValid = d60 != null && d10 != null && d30 != null && d10 > 0 && d60 > 0 && d30 > 0;
      double? cu = gradationValid ? d60 / d10 : null;
      double? cc = gradationValid ? (d30 * d30) / (d10 * d60) : null;

      if (gravel > 50) {
        if (fines < 5) {
          if (gradationValid && cu! >= 4 && cc! >= 1 && cc <= 3) return "GW";
          if (gradationValid) return "GP";
          return "❌ Missing gradation data";
        } else if (fines <= 12) {
          return (gradationValid && cu! >= 4 && cc! >= 1 && cc <= 3)
              ? "GW-G${getFineType(ll, pi)}"
              : "GP-G${getFineType(ll, pi)}";
        } else if (pi >= 4 && pi <= 7) {
          return "GC-GM";
        } else {
          return "G${getFineType(ll, pi)}";
        }
      } else {
        if (fines < 5) {
          if (gradationValid && cu! >= 6 && cc! >= 1 && cc <= 3) return "SW";
          if (gradationValid) return "SP";
          return "❌ Missing gradation data";
        } else if (fines <= 12) {
          return (gradationValid && cu! >= 6 && cc! >= 1 && cc <= 3)
              ? "SW-S${getFineType(ll, pi)}"
              : "SP-S${getFineType(ll, pi)}";
        } else if (pi >= 4 && pi <= 7) {
          return "SC-SM";
        } else {
          return "S${getFineType(ll, pi)}";
        }
      }
    } else {
      if (organic) return ll < 50 ? "OL" : "OH";
      if (ll < 50) {
        if (pi > 7 && checkALine(ll, pi)) return "CL";
        if (pi < 4 && !checkALine(ll, pi)) return "ML";
        if (pi >= 4 && pi <= 7) return "CL-ML";
      } else {
        return checkALine(ll, pi) ? "CH" : "MH";
      }
    }
    return "❌ Unable to classify.";
  }

  String generateOutputText(String uscsSymbol, double gravel, double sand, double ll,
      bool organic, double pi, double pass200) {
    String description = "";

    if (["GW", "GP", "GW-GM", "GW-GC", "GP-GM", "GP-GC", "GM", "GC", "GC-GM"].contains(uscsSymbol)) {
      description = sand < 15
          ? "${_translateCode(uscsSymbol)}"
          : "${_translateCode(uscsSymbol)} with Sand";
    } else if (["SW", "SP", "SW-SM", "SW-SC", "SP-SM", "SP-SC", "SM", "SC", "SC-SM"].contains(uscsSymbol)) {
      description = gravel < 15
          ? "${_translateCode(uscsSymbol)}"
          : "${_translateCode(uscsSymbol)} with Gravel";
    } else if (["CL", "CL-ML", "ML", "CH", "MH", "OL", "OH"].contains(uscsSymbol)) {
      if (pass200 < 30) {
        if (pass200 < 15) {
          description = _translateCode(uscsSymbol);
        } else {
          description = sand >= gravel
              ? "${_translateCode(uscsSymbol)} with Sand"
              : "${_translateCode(uscsSymbol)} with Gravel";
        }
      } else {
        if (sand >= gravel) {
          description = gravel < 15
              ? "Sandy ${_translateCode(uscsSymbol)}"
              : "Sandy ${_translateCode(uscsSymbol)} with Gravel";
        } else {
          description = sand < 15
              ? "Gravelly ${_translateCode(uscsSymbol)}"
              : "Gravelly ${_translateCode(uscsSymbol)} with Sand";
        }
      }
    } else {
      description = "Unclassified";
    }

    return "✅ USCS classification result: $uscsSymbol ($description)";
  }

  String _translateCode(String code) {
    return {
      "GW": "Well-graded Gravel",
      "GP": "Poorly-graded Gravel",
      "GW-GM": "Well-graded Gravel with Silt",
      "GW-GC": "Well-graded Gravel with Clay",
      "GP-GM": "Poorly-graded Gravel with Silt",
      "GP-GC": "Poorly-graded Gravel with Clay",
      "GM": "Silty Gravel",
      "GC": "Clayey Gravel",
      "GC-GM": "Clayey Gravel with Silt",
      "SW": "Well-graded Sand",
      "SP": "Poorly-graded Sand",
      "SW-SM": "Well-graded Sand with Silt",
      "SW-SC": "Well-graded Sand with Clay",
      "SP-SM": "Poorly-graded Sand with Silt",
      "SP-SC": "Poorly-graded Sand with Clay",
      "SM": "Silty Sand",
      "SC": "Clayey Sand",
      "SC-SM": "Clayey Sand with Silt",
      "CL": "Lean Clay",
      "CL-ML": "Silty Clay",
      "ML": "Silt",
      "CH": "Fat Clay",
      "MH": "Elastic Silt",
      "OL": "Organic Clay",
      "OH": "Organic Silt",
    }[code] ?? "Unknown";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('USCS Classification')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Enter Soil Sample Data:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(controller: _pass200Controller, decoration: const InputDecoration(labelText: '% passing No. 200 sieve'), keyboardType: TextInputType.number),
          TextField(controller: _llController, decoration: const InputDecoration(labelText: 'Liquid Limit (LL)'), keyboardType: TextInputType.number),
          TextField(controller: _plController, decoration: const InputDecoration(labelText: 'Plastic Limit (PL)'), keyboardType: TextInputType.number),
          TextField(controller: _gravelController, decoration: const InputDecoration(labelText: '% Gravel'), keyboardType: TextInputType.number),
          TextField(controller: _sandController, decoration: const InputDecoration(labelText: '% Sand'), keyboardType: TextInputType.number),
          TextField(controller: _organicController, decoration: const InputDecoration(labelText: 'Organic? (yes/no)'), keyboardType: TextInputType.text),
          const SizedBox(height: 12),
          const Text('Optional Gradation Data (D10, D30, D60):', style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(controller: _d10Controller, decoration: const InputDecoration(labelText: 'D10'), keyboardType: TextInputType.number),
          TextField(controller: _d30Controller, decoration: const InputDecoration(labelText: 'D30'), keyboardType: TextInputType.number),
          TextField(controller: _d60Controller, decoration: const InputDecoration(labelText: 'D60'), keyboardType: TextInputType.number),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: classifySoil, child: const Text('Classify Soil')),
          const SizedBox(height: 20),
          Text(_result, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }
}
