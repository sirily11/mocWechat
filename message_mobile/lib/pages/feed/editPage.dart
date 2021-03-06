import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:message_mobile/models/chatmodel.dart';
import 'package:message_mobile/pages/login/views/errorDialog.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:quill_delta/quill_delta.dart';
import 'package:zefyr/zefyr.dart';

class FullPageEditorScreen extends StatefulWidget {
  @override
  _FullPageEditorScreenState createState() => _FullPageEditorScreenState();
}

class _FullPageEditorScreenState extends State<FullPageEditorScreen> {
  final ZefyrController _controller = ZefyrController(NotusDocument());
  final FocusNode _focusNode = FocusNode();
  final GlobalKey<ScaffoldState> key = GlobalKey();
  List<File> images = [];

  @override
  void initState() {
    super.initState();
  }

  void _saveDocument(BuildContext context) async {
    try {
      var pr = ProgressDialog(context);
      pr.show();
      final content = jsonEncode(_controller.document);
      ChatModel model = Provider.of(context, listen: false);
      await model.writeFeed(content, images);
      await Future.delayed(Duration(milliseconds: 200));
      await pr.hide();
      Navigator.pop(context);
    } catch (err) {
      showDialog(
        context: context,
        builder: (c) => ErrorDialog(
          content: err,
          title: "Network Error",
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        title: Text("Edit Feed"),
        leading: BackButton(),
        actions: [
          IconButton(
            onPressed: () async {
              File file = await ImagePicker.pickImage(
                  source: ImageSource.gallery, imageQuality: kImageQuality);
              if (file != null) {
                setState(() {
                  images.add(file);
                });
              }
            },
            icon: Icon(Icons.image),
          ),
          IconButton(
            onPressed: () {
              _saveDocument(context);
            },
            icon: Icon(Icons.done),
          )
        ],
      ),
      body: ZefyrScaffold(
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 5,
              child: ZefyrEditor(
                controller: _controller,
                focusNode: _focusNode,
                mode: ZefyrMode.edit,
              ),
            ),
            Divider(),
            Expanded(
              flex: 7,
              child: Container(
                child: Wrap(
                  spacing: 10,
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  runAlignment: WrapAlignment.start,
                  children: images
                      .map(
                        (i) => Stack(
                          children: <Widget>[
                            Image.file(
                              i,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    images.remove(i);
                                  });
                                },
                                icon: Icon(
                                  Icons.clear,
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
