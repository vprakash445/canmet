import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Language ─────────────────────────────────────────────────────────────────

class LanguageProvider extends ChangeNotifier {
  String _lang = 'en';

  String get lang => _lang;
  bool get isHindi => _lang == 'hi';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _lang = prefs.getString('lang') ?? 'en';
    notifyListeners();
  }

  Future<void> setLanguage(String l) async {
    if (_lang == l) return;
    _lang = l;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', l);
    notifyListeners();
  }

  void toggle() => setLanguage(_lang == 'en' ? 'hi' : 'en');
}

// ─── User ─────────────────────────────────────────────────────────────────────

class UserProvider extends ChangeNotifier {
  String _name = '';
  String _patientId = '';
  String _cancerType = '';
  String _age = '';
  String _gender = '';
  String _hospitalId = '';
  String _mobile = '';
  int _treatmentDay = 1;
  bool _isLoggedIn = false;

  String get name => _name;
  String get patientId => _patientId;
  String get cancerType => _cancerType;
  String get age => _age;
  String get gender => _gender;
  String get hospitalId => _hospitalId;
  String get mobile => _mobile;
  int get treatmentDay => _treatmentDay;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('logged_in') ?? false;
    _name = prefs.getString('name') ?? '';
    _patientId = prefs.getString('patient_id') ?? '';
    _cancerType = prefs.getString('cancer_type') ?? '';
    _age = prefs.getString('age') ?? '';
    _gender = prefs.getString('gender') ?? '';
    _hospitalId = prefs.getString('hospital_id') ?? '';
    _mobile = prefs.getString('mobile') ?? '';
    _treatmentDay = prefs.getInt('treatment_day') ?? 1;
    notifyListeners();
  }

  Future<void> login(String patientId) async {
    _patientId = patientId;
    _name = 'Patient';
    _isLoggedIn = true;
    _treatmentDay = 1;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('logged_in', true);
    await prefs.setString('patient_id', patientId);
    await prefs.setString('name', _name);
    await prefs.setInt('treatment_day', 1);
    notifyListeners();
  }

  Future<void> register({
    required String name,
    required String age,
    required String gender,
    required String cancerType,
    required String hospitalId,
    required String mobile,
  }) async {
    // Generate a patient ID
    final id =
        'CNM-${(DateTime.now().millisecondsSinceEpoch % 90000) + 10000}';
    _name = name;
    _patientId = id;
    _age = age;
    _gender = gender;
    _cancerType = cancerType;
    _hospitalId = hospitalId;
    _mobile = mobile;
    _treatmentDay = 1;
    _isLoggedIn = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('logged_in', true);
    await prefs.setString('name', name);
    await prefs.setString('patient_id', id);
    await prefs.setString('age', age);
    await prefs.setString('gender', gender);
    await prefs.setString('cancer_type', cancerType);
    await prefs.setString('hospital_id', hospitalId);
    await prefs.setString('mobile', mobile);
    await prefs.setInt('treatment_day', 1);
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _name = '';
    _patientId = '';
    _cancerType = '';
    _age = '';
    _gender = '';
    _hospitalId = '';
    _mobile = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('logged_in', false);
    notifyListeners();
  }
}

// ─── Tasks ────────────────────────────────────────────────────────────────────

class TaskProvider extends ChangeNotifier {
  // moduleId -> Set of completed task indices
  final Map<String, Set<int>> _done = {};

  bool isTaskDone(String moduleId, int index) =>
      _done[moduleId]?.contains(index) ?? false;

  void toggleTask(String moduleId, int index) {
    _done[moduleId] ??= {};
    if (_done[moduleId]!.contains(index)) {
      _done[moduleId]!.remove(index);
    } else {
      _done[moduleId]!.add(index);
    }
    notifyListeners();
  }

  int completedCount(String moduleId) => _done[moduleId]?.length ?? 0;
}
