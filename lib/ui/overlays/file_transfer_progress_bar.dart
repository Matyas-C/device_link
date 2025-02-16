import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:device_link/ui/listeners/file_transfer_progress_model.dart';

void main() {
  runApp(const MaterialApp(
    home: Scaffold(
      body: Center(
        child: FileTransferProgressBar(),
      ),
    ),
  ));
}


class FileTransferProgressBar extends StatefulWidget {

  const FileTransferProgressBar({super.key});

  @override
  State<FileTransferProgressBar> createState() => _FileTransferProgressBarState();
}

class _FileTransferProgressBarState extends State<FileTransferProgressBar> {
  final FileTransferProgressModel _fileTransferProgressModel = FileTransferProgressModel();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 5.0,
            sigmaY: 5.0,
          ),
          child: IntrinsicHeight(
            child: Container(
              alignment: Alignment.center,
              constraints: const BoxConstraints(maxWidth: 500),
              decoration: BoxDecoration(
                color: Colors.grey.shade800.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row (
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          _fileTransferProgressModel.filename,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                          ),
                          overflow: TextOverflow.fade,
                          maxLines: 1,
                          softWrap: false,
                        ),
                      ),
                      Text(
                        "${_fileTransferProgressModel.fileIndex} / ${_fileTransferProgressModel.totalFiles}",
                        style: TextStyle(
                          color: Colors.grey.shade300,
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  LinearProgressIndicator(
                    value: _fileTransferProgressModel.progress,
                    backgroundColor: Colors.grey.shade600,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    borderRadius: BorderRadius.circular(10.0),
                    minHeight: 10.0,
                  ),
                  Text(
                    "${_fileTransferProgressModel.bytesTransferredFormatted} / ${_fileTransferProgressModel.fileSizeFormatted}",
                    style: TextStyle(
                      color: Colors.grey.shade300,
                      fontSize: 12.0,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}