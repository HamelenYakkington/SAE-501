import 'package:flutter/material.dart';
import 'package:sae_501/controller/verif_connexion.dart';
import 'package:sae_501/services/historique_service.dart';
import 'package:sae_501/view/widget/button_return_custom.dart';
import 'package:sae_501/view/widget/header_custom.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sae_501/constants/view_constants.dart';
import 'package:sae_501/view/widget/button_custom_gradient.dart';

class Historique extends StatefulWidget {
  const Historique({Key? key}) : super(key: key);

  @override
  HistoriqueState createState() => HistoriqueState();
}

class HistoriqueState extends State<Historique> {
  final HistoryService _historyService = HistoryService();
  List<dynamic> _history = [];
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
          color: ViewConstant.backgroundButton,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            leading: item['pathImage'] != null
                ? Image.network(
              '${dotenv.env['BASE_URL']!}/${item['pathImage']!}',
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.image_not_supported, color: Colors.grey),
            )
                : const Icon(Icons.image_not_supported, color: Colors.grey),
            title: Text(
              '${item['date']} : ${item['time']}',
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Labels : ${item['labels'].join(', ')}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward, color: Colors.white),
              onPressed: () {
                _historyService.displayphoto(
                    item['pathImage'], item['pathLabel'], context);
              },
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
      body: Container(
        color: ViewConstant.backgroundApp,
        child: Stack(
          children: [
            SafeArea(child: Center( child:Column(
            children: [
              const SizedBox(height: 25),
              customHeader(
                  'History', 'assets/images/history.webp'),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    customGradientButton(
                      context: context,
                      text: "Personal History",
                      onPressed: fetchUserHistory,
                      gradient: const LinearGradient(
                        colors: [
                          ViewConstant.GradientColorLightBlue,
                          ViewConstant.GradientColorDarkBlue
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      textColor: Colors.white,
                    ),
                    const SizedBox(height: 16.0),
                    customGradientButton(
                      context: context,
                      text: "Knights Histories",
                      onPressed: fetchAllUsersHistory,
                      gradient: const LinearGradient(
                        colors: [
                          ViewConstant.ColorInput,
                          ViewConstant.ColorInput
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      textColor: Colors.black,
                    ),
                  ],
                ),
              ),
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Expanded(
                      child: _history.isNotEmpty
                          ? _buildHistoryList(_history)
                          : const Center(
                              child: Text(
                                'Aucun historique à afficher.',
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ),
                    ),
            ],
          ),),),customReturnButton(context),],
        ),
      ),
    );
  }

  Future<void> fetchAllUsersHistory() async {
    setState(() {
      _isLoading = true;
    });
    List? rez =  await _historyService.fetchAllUsersHistory(20, _token, context);
    if(rez != null) {
      setState(() {
        _history = rez;
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> fetchUserHistory() async {
    setState(() {
      _isLoading = true;
    });
    List? rez =  await _historyService.fetchUserHistory(_token, context);
    if(rez != null) {
      setState(() {
        _history = rez;
      });
    }
    setState(() {
      _isLoading = false;
    });
  }
}
