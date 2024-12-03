import 'package:flutter/material.dart';
import 'package:sae_501/view/widget/button_photo.dart';
import 'package:sae_501/view/widget/header_custom.dart';
import 'package:sae_501/view/widget/footer_custom.dart';
import 'package:sae_501/view/widget/button_return_custom.dart';
import 'package:sae_501/view/widget/button_add_album_custom.dart';
import 'package:sae_501/view/widget/button_album_custom.dart';
import 'package:sae_501/constants/view_constants.dart';
import 'package:sae_501/services/folder_service.dart';

class Album extends StatefulWidget {
  const Album({Key? key}) : super(key: key);

  @override
  _AlbumState createState() => _AlbumState();
}

class _AlbumState extends State<Album> {
  late Future<List<String>> folderFuture;

  @override
  void initState() {
    super.initState();
    folderFuture = loadAlbumFolders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ViewConstant.backgroundScalfold,
      body: Container(
        color: ViewConstant.backgroundApp,
        child: Stack(
          children: [
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 25),
                    customHeader('Album', 'assets/images/album_button.webp'),
                    const SizedBox(height: 25),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: FutureBuilder<List<String>>(
                          future: folderFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return const Center(
                                child: Text(
                                  "Error loading albums.",
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Center(
                                child: Text(
                                  "No albums found.",
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            }

                            final folders = snapshot.data!;
                            return ListView.builder(
                              itemCount: folders.length,
                              itemBuilder: (context, index) {
                                final folderName = folders[index];
                                return CustomFolderButton(
                                  folderName: folderName,
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/',
                                      arguments: folderName,
                                    );
                                  },
                                  isPrimary: index == 0, // First button will be primary
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    customButtonPhoto(),
                    customFooter(),
                  ],
                ),
              ),
            ),
            customReturnButton(context),
            customAddButton(context),
          ],
        ),
      ),
    );
  }
}
