import 'package:flutter/material.dart';
import 'package:sae_501/view/widget/button_photo.dart';
import 'package:sae_501/view/widget/button_sub_album_custom.dart';
import 'package:sae_501/view/widget/header_custom.dart';
import 'package:sae_501/view/widget/footer_custom.dart';
import 'package:sae_501/view/widget/button_return_custom.dart';
import 'package:sae_501/view/widget/button_add_album_custom.dart';
import 'package:sae_501/constants/view_constants.dart';
import 'package:sae_501/services/folder_service.dart';

class SubAlbum extends StatefulWidget {
  const SubAlbum({Key? key}) : super(key: key);

  @override
  _SubAlbumState createState() => _SubAlbumState();
}

class _SubAlbumState extends State<SubAlbum> {
  late Future<List<SubFolder>> subFolderFuture;
  String? folderName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    folderName = ModalRoute.of(context)?.settings.arguments as String?;
    if (folderName != null) {
      subFolderFuture = getSubFolders(folderName!);
    }
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
                    customHeader('Album > $folderName', 'assets/images/album_button.webp'),
                    const SizedBox(height: 25),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: FutureBuilder<List<SubFolder>>(
                          future: subFolderFuture,
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
                                  "Error loading subfolders.",
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Center(
                                child: Text(
                                  "No subfolders found.",
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            }

                            final subFolders = snapshot.data!;
                            return GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10.0,
                                mainAxisSpacing: 10.0,
                                childAspectRatio: 1.0,
                              ),
                              itemCount: subFolders.length,
                              itemBuilder: (context, index) {
                                final subFolder = subFolders[index];

                                return FutureBuilder<String?>(
                                  future: getFirstImagePath(folderName!, subFolder.name),
                                  builder: (context, imageSnapshot) {
                                    String imagePath = imageSnapshot.data ??
                                        'assets/images/default_image.png';

                                    return SubAlbumButton(
                                      imagePath: imagePath,
                                      subAlbumName: subFolder.name,
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/',
                                          arguments: subFolder.name,
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    customButtonPhoto(context: context),
                    customFooter(),
                  ],
                ),
              ),
            ),
            customReturnButton(context, routeName: '/album'),
            customAddButton(context),
          ],
        ),
      ),
    );
  }
}
