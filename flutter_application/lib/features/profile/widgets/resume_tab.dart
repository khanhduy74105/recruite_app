import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../models/resume_model.dart';

class ResumeState {
  final ResumeModel? resume;
  final bool isLoading;
  final String? error;

  ResumeState({
    this.resume,
    this.isLoading = false,
    this.error,
  });

  ResumeState copyWith({
    ResumeModel? resume,
    bool? isLoading,
    String? error,
  }) {
    return ResumeState(
      resume: resume ?? this.resume,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ResumeCubit extends Cubit<ResumeState> {
  final SupabaseClient supabase = Supabase.instance.client;

  ResumeCubit() : super(ResumeState()) {
    fetchResume();
  }

  Future<void> fetchResume() async {
    try {
      emit(state.copyWith(isLoading: true));
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        emit(state.copyWith(
          isLoading: false,
          error: 'User not authenticated',
        ));
        return;
      }

      final response = await supabase
          .from('resume')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        final resume = ResumeModel.fromJson(response);
        emit(state.copyWith(resume: resume, isLoading: false));
      } else {
        emit(state.copyWith(resume: null, isLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to fetch resume: $e',
      ));
    }
  }

  Future<void> uploadResume(File file) async {
    try {
      emit(state.copyWith(isLoading: true));
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        emit(state.copyWith(
          isLoading: false,
          error: 'User not authenticated',
        ));
        return;
      }

      final existingResume = await supabase
          .from('resume')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (existingResume != null) {
        final oldResume = ResumeModel.fromJson(existingResume);
        final oldFilePath = oldResume.url.split('/').last;
        await supabase.storage.from('resumes').remove([oldFilePath]);
        await supabase.from('resume').delete().eq('user_id', userId);
      }

      final fileName = '${userId}_${const Uuid().v4()}.pdf';
      final uploadResponse = await supabase.storage.from('resumes').upload(
            fileName,
            file,
            fileOptions: const FileOptions(contentType: 'application/pdf'),
          );

      if (uploadResponse.isEmpty) {
        emit(state.copyWith(
          isLoading: false,
          error: 'Failed to upload resume',
        ));
        return;
      }

      final publicUrl = supabase.storage.from('resumes').getPublicUrl(fileName);

      final newResume = ResumeModel(
        id: const Uuid().v4(),
        url: publicUrl,
      );

      await supabase.from('resume').insert({
        'id': newResume.id,
        'user_id': userId,
        'url': newResume.url,
      });

      emit(state.copyWith(
        resume: newResume,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to upload resume: $e',
      ));
    }
  }
}

class ResumeTab extends StatefulWidget {
  const ResumeTab({super.key});

  @override
  _ResumeTabState createState() => _ResumeTabState();
}

class _ResumeTabState extends State<ResumeTab> {
  String? _localFilePath;
  String? _currentResumeUrl;

  Future<void> _downloadAndSavePDF(String url) async {
    try {
      if (_currentResumeUrl == url) {
        return;
      }

      if (_localFilePath != null) {
        final oldFile = File(_localFilePath!);
        if (await oldFile.exists()) {
          await oldFile.delete();
        }
      }

      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('Failed to download PDF: ${response.statusCode}');
      }

      final tempDir = await getTemporaryDirectory();
      final uniqueFileName = 'resume_${const Uuid().v4()}.pdf';
      final tempFile = File('${tempDir.path}/$uniqueFileName');
      await tempFile.writeAsBytes(response.bodyBytes);

      setState(() {
        _localFilePath = tempFile.path;
        _currentResumeUrl = url;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ResumeCubit(),
      child: BlocConsumer<ResumeCubit, ResumeState>(
        listener: (context, state) {
          if (state.resume != null && state.resume!.url.isNotEmpty) {
            _downloadAndSavePDF(state.resume!.url);
          } else {
            setState(() {
              _localFilePath = null;
              _currentResumeUrl = null;
            });
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: state.isLoading
                      ? null
                      : () async {
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['pdf'],
                          );

                          if (result != null) {
                            if (kIsWeb) {
                              final bytes = result.files.single.bytes;
                              if (bytes != null) {
                                final tempFile = File('temp.pdf')
                                  ..writeAsBytesSync(bytes);
                                context
                                    .read<ResumeCubit>()
                                    .uploadResume(tempFile);
                              }
                            } else {
                              if (result.files.single.path != null) {
                                final file = File(result.files.single.path!);
                                context.read<ResumeCubit>().uploadResume(file);
                              }
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  child: state.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Upload CV (PDF)'),
                ),
                const SizedBox(height: 16),
                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      state.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: state.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _localFilePath != null
                            ? PDFView(
                                key: ValueKey(_localFilePath),
                                filePath: _localFilePath!,
                                fitPolicy: FitPolicy.BOTH,
                                enableSwipe: true,
                                swipeHorizontal: false,
                                autoSpacing: true,
                                pageFling: true,
                                onError: (error) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Failed to load PDF: $error')),
                                  );
                                },
                                onRender: (pages) {
                                  print("Rendered $pages pages");
                                },
                              )
                            : const Center(
                                child: Text(
                                  'No CV uploaded yet.\nPlease upload a PDF file.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                              ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
