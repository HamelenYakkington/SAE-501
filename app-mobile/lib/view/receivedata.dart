import 'package:flutter/material.dart';
import 'package:sae_501/constants/view_constants.dart';
import 'package:sae_501/services/download_service.dart';
import 'package:sae_501/view/widget/custom_background.dart';
import 'package:sae_501/view/widget/footer_custom.dart';
import 'package:sae_501/view/widget/header_custom.dart';

class ReceiveData extends StatefulWidget {
  const ReceiveData({Key? key}) : super(key: key);

  @override
  ReceiveDataState createState() => ReceiveDataState();
}

class ReceiveDataState extends State<ReceiveData> {
  bool _isUpdating = false;
  double _progress = 0.0;
  final DownloadService _downloadService = DownloadService();

  Future<void> _handleUpdate() async {
    setState(() {
      _isUpdating = true;
    });

    try {
      await _downloadService.checkAndUpdateModel((progress) {
        setState(() {
          _progress = progress;
        });
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mise à jour terminée avec succès !')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _handleUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ViewConstant.backgroundScalfold,
      body: customContainer(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 25),
              customHeader('Update AI', 'assets/images/cloud_button.webp'),
              const SizedBox(height: 25),
              _isUpdating
                  ? Column(
                children: [
                  LinearProgressIndicator(
                    value: _progress,
                    minHeight: 10,
                    backgroundColor: Colors.grey[300],
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${(_progress * 100).toStringAsFixed(2)}%',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
                  : const SizedBox.shrink(),
              const Spacer(),
              customFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
