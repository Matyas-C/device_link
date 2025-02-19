import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:device_link/ui/notifiers/file_transfer_progress_model.dart';
import 'package:device_link/ui/overlays/overlay_manager.dart';

class FileTransferProgressBar extends StatefulWidget {

  const FileTransferProgressBar({
    super.key,
  });

  @override
  State<FileTransferProgressBar> createState() => _FileTransferProgressBarState();
}

class _FileTransferProgressBarState extends State<FileTransferProgressBar> {
  final FileTransferProgressModel fileTransferProgressModel = GlobalOverlayManager().fileTransferProgressModel;

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
            child: ListenableBuilder(
              listenable: fileTransferProgressModel,
              builder: (BuildContext context, Widget? child) {
                return Container(
                  alignment: Alignment.center,
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
                              fileTransferProgressModel.filename,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                              ),
                              overflow: TextOverflow.fade,
                              maxLines: 1,
                              softWrap: false,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                getIcon(fileTransferProgressModel.isSender),
                                color: Colors.grey.shade300,
                                size: 20.0,
                              ),
                              Text(
                                "${fileTransferProgressModel.fileIndex} / ${fileTransferProgressModel.totalFiles}",
                                style: TextStyle(
                                  color: Colors.grey.shade300,
                                  fontSize: 16.0,
                                ),
                              ),
                            ]
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      LinearProgressIndicator(
                        value: fileTransferProgressModel.progress,
                        backgroundColor: Colors.grey.shade600,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                        borderRadius: BorderRadius.circular(10.0),
                        minHeight: 10.0,
                      ),
                      Text(
                        "${fileTransferProgressModel.bytesTransferredFormatted} / ${fileTransferProgressModel.fileSizeFormatted}",
                        style: TextStyle(
                          color: Colors.grey.shade300,
                          fontSize: 12.0,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  IconData? getIcon(bool isSender) {
    return isSender ? Icons.upload : Icons.download;
  }
}