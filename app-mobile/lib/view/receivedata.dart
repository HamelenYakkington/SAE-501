import 'package:flutter/material.dart';
import 'package:sae_501/constants/view_constants.dart';
import 'package:sae_501/services/download_service.dart';
import 'package:sae_501/view/widget/footer_custom.dart';
import 'package:sae_501/view/widget/header_custom.dart';

class ReceiveData extends StatefulWidget {

  const ReceiveData({Key? key}) : super(key: key);

  @override
  ReceiveDataState createState() => ReceiveDataState();
}

class ReceiveDataState extends State<ReceiveData> {
  bool _isUpdating = false;
  final DownloadService _downloadService = DownloadService();

  Future<void> _handleUpdate() async {
    setState(() {
      _isUpdating = true;
    });

    try {
      await _downloadService.checkAndUpdateModel();
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
      body: Container(
        color: ViewConstant.backgroundApp,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 25),
              customHeader('ReceiveData', 'assets/images/cloud_button.webp'),
              const SizedBox(height: 25),
              _isUpdating
                  ? const Expanded(child: Center(child: CircularProgressIndicator()))
                  : const SizedBox.shrink(),
              customFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
