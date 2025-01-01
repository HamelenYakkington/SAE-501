import 'package:flutter/material.dart';
import 'package:sae_501/controller/verif_connexion.dart';
import 'package:sae_501/services/api_service.dart';
import 'package:sae_501/view/widget/header_custom.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sae_501/constants/view_constants.dart';

class Historique extends StatefulWidget {
  const Historique({Key? key}) : super(key: key);

  @override
  _Historique createState() => _Historique();
}

class _Historique extends State<Historique> {
  final ApiService _apiService = ApiService();
  List<dynamic> _userHistory = [];
  List<dynamic> _allUsersHistory = [];
  bool _isLoading = false;
  String? _token;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await checkConnexionToken(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('auth_token');
    });
    fetchUserHistory();
  }

  Future<void> fetchUserHistory() async {
    if (_token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur : Aucun token trouvé.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final history = await _apiService.get(
        '/api/user/history',
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );
      setState(() {
        _userHistory = history;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la récupération de l\'historique personnel: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchAllUsersHistory(int userId) async {
    if (_token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur : Aucun token trouvé.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final history = await _apiService.get(
        '/api/user/$userId/history',
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );
      setState(() {
        _allUsersHistory = history;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la récupération de l\'historique des utilisateurs: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildHistoryList(List<dynamic> history) {
    if (history.isEmpty) {
      return const Center(
        child: Text(
          'Aucun historique disponible',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            leading: item['pathImage'] != null
                ? Image.network(dotenv.env['BASE_URL']! + '/' + item['pathImage']!)
                : const Icon(Icons.image_not_supported),
            title: Text('Utilisateur: ${item['user']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date: ${item['date']}'),
                Text('Heure: ${item['time']}'),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ViewConstant.backgroundScalfold,
      body : Column(
        children: [
          const SizedBox(height: 25),
          customHeader(
              'KnightSight', 'assets/images/chess_lense_logo.webp'),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: fetchUserHistory,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text('Personal History'),
                ),
                ElevatedButton(
                  onPressed: () {
                    fetchAllUsersHistory(1);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('All Users History'),
                ),
              ],
            ),
          ),
          _isLoading
              ? const Center(
            child: CircularProgressIndicator(),
          ) :
          Expanded(
            child: _userHistory.isNotEmpty
                ? _buildHistoryList(_userHistory)
                : _allUsersHistory.isNotEmpty
                ? _buildHistoryList(_allUsersHistory)
                : const Center(
              child: Text(
                'Aucun historique à afficher.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
