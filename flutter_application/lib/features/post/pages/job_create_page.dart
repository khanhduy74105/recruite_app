import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_application/models/job_model.dart';

class JobCreatePage extends StatefulWidget {
  final JobModel? jobModel;

  const JobCreatePage({super.key, this.jobModel});

  @override
  State<JobCreatePage> createState() => _JobCreatePageState();
}

class _JobCreatePageState extends State<JobCreatePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController isRemoteController = TextEditingController();
  final TextEditingController postedDateController = TextEditingController();
  final List<File> selectedFiles = [];
  final _formKey = GlobalKey<FormState>();
  final JobModel jobModel = JobModel(
    id: '',
    title: '',
    creator: '',
    description: '',
    jdUrls: [],
    files: [],
    companyName: '',
    location: '',
    createdAt: DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    if (widget.jobModel != null) {
      jobModel.id = widget.jobModel!.id;
      jobModel.title = widget.jobModel!.title;
      jobModel.description = widget.jobModel!.description;
      jobModel.jdUrls = List.from(widget.jobModel!.jdUrls);
      jobModel.files = widget.jobModel!.files;
      jobModel.companyName = widget.jobModel!.companyName;
      jobModel.location = widget.jobModel!.location;
      jobModel.createdAt = widget.jobModel!.createdAt;

      titleController.text = jobModel.title;
      descriptionController.text = jobModel.description;
      companyNameController.text = jobModel.companyName;
      locationController.text = jobModel.location;
      selectedFiles.addAll([...(jobModel.files ?? [])]);
    }
  }

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        final newFiles = result.paths.whereType<String>().map((path) => File(path)).toList();
        selectedFiles.addAll(newFiles);
        jobModel.files = selectedFiles;
        jobModel.jdUrls.addAll(newFiles.map((file) => file.path.split('/').last));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No files were selected.')),
      );
    }
  }

  void _removeFile(int index) {
    setState(() {
      selectedFiles.removeAt(index);
    });
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (value.trim().length < 3) {
      return '$fieldName must be at least 3 characters';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Description is required';
    }
    if (value.trim().length < 10) {
      return 'Description must be at least 10 characters';
    }
    return null;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String key,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textAlign: TextAlign.start,
      decoration: InputDecoration(
        labelText: labelText,
        alignLabelWithHint: true,
        border: const OutlineInputBorder(),
        fillColor: ThemeData().inputDecorationTheme.fillColor,
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              controller.clear();
            });
          },
        )
            : null,
      ),
      validator: validator,
      onChanged: (value) {
        switch (key) {
          case 'title':
            jobModel.title = value;
            break;
          case 'description':
            jobModel.description = value;
            break;
          case 'company_name':
            jobModel.companyName = value;
            break;
          case 'location':
            jobModel.location = value;
            break;
        }
      },
    );
  }

  Widget _buildSelectedFiles() {
    return Column(
      children: List.generate(selectedFiles.length, (index) {
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  selectedFiles[index].path.split('/').last,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => _removeFile(index),
              ),
            ],
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Job'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.pop(context, jobModel);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fix the errors in the form')),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              top: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: titleController,
                  key: 'title',
                  labelText: 'Job Title',
                  validator: (value) => _validateRequired(value, 'Job Title'),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: descriptionController,
                  key: 'description',
                  labelText: 'Job Description',
                  maxLines: 4,
                  keyboardType: TextInputType.multiline,
                  validator: _validateDescription,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: companyNameController,
                  key: 'company_name',
                  labelText: 'Company Name',
                  validator: (value) => _validateRequired(value, 'Company Name'),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: locationController,
                  key: 'location',
                  labelText: 'Location',
                ),
                const SizedBox(height: 16),
                if (selectedFiles.isNotEmpty) _buildSelectedFiles(),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Attach Files'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}