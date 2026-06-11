import 'dart:io';

import 'package:code/models/user.dart';
import 'package:code/presenters/profile_presenter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../models/LogoutResult.dart';
import '../models/resume_upload_result.dart';
import '../models/applied_job.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'job_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  final ApiService apiService;

  const ProfileScreen({
    super.key,
    required this.apiService,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> implements ProfileView {
  late ProfilePresenter presenter;

  bool isLoading = false;
  String? errorMessage;
  User? user;
  bool resumeUploaded = false;

  String? profileImagePath;

  List<AppliedJob> appliedJobs = [];
  String? appliedJobsError;

  final ImagePicker imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    presenter = ProfilePresenter(this, widget.apiService);
    presenter.loadProfile();
  }

  @override
  void showResumeStatus(bool isUploaded) {
    setState(() {
      resumeUploaded = isUploaded;
    });
  }

  @override
  void showLoading() {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
  }

  @override
  void hideLoading() {
    setState(() {
      isLoading = false;
    });
  }

  @override
  void showError(String message) {
    setState(() {
      errorMessage = message;
      user = null;
    });
  }

  @override
  void showProfile(User user) {
    setState(() {
      this.user = user;
      errorMessage = null;
    });
  }

  @override
  void showProfileImage(String? imagePath) {
    setState(() {
      profileImagePath = imagePath;
    });
  }

  @override
  Future<String?> pickProfileImageFromGallery() async {
    final XFile? pickedImage = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    return pickedImage?.path;
  }

  @override
  Future<String?> pickResumeFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null || result.files.single.path == null) {
      return null;
    }

    return result.files.single.path;
  }

  @override
  void showResumeUploadResult(ResumeUploadResult result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.success
              ? '${result.status} Score: ${result.score ?? "-"}'
              : 'Resume upload failed: ${result.status}',
        ),
      ),
    );
  }

  @override
  void showAppliedJobs(List<AppliedJob> jobs) {
    setState(() {
      appliedJobs = jobs;
      appliedJobsError = null;
    });
  }

  @override
  void showAppliedJobsError(String message) {
    setState(() {
      appliedJobsError = message;
    });
  }

  @override
  Future<bool> confirmDeleteResume() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Delete Resume'),
          content: const Text(
            'Are you sure you want to delete your uploaded resume?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  @override
  void showResumeDeleteResult(ResumeUploadResult result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.success
              ? '${result.status} Score: ${result.score ?? "-"}'
              : 'Resume delete failed: ${result.status}',
        ),
      ),
    );
  }

  Future<void> deleteResumePressed() async {
    await presenter.deleteResume();
  }

  void goBackToHome() {
    Navigator.pop(context);
  }

  Future<void> changeProfilePicturePressed() async {
    await presenter.changeProfileImage();
  }

  Future<void> uploadResumePressed() async {
    await presenter.uploadResume();
  }

  void openAppliedJob(AppliedJob job) {
    if (job.jobLink.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JobDetailScreen(
          detailUrl: job.jobLink,
          apiService: widget.apiService,
        ),
      ),
    );
  }

  Future<void> logoutPressed() async {
    LogoutResult result = await presenter.logout();

    if (result.success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
            (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong. Error: ${result.status}'),
        ),
      );
    }
  }

  ImageProvider? getProfileImageProvider() {
    if (profileImagePath == null || profileImagePath!.isEmpty) return null;

    final file = File(profileImagePath!);

    if (!file.existsSync()) return null;

    return FileImage(file);
  }

  Widget buildProfileAvatar() {
    final imageProvider = getProfileImageProvider();

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: imageProvider,
          child: imageProvider == null
              ? const Icon(Icons.person, size: 55)
              : null,
        ),
        InkWell(
          onTap: changeProfilePicturePressed,
          child: CircleAvatar(
            radius: 17,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildProfileInfoCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Full Name'),
            subtitle: Text(user!.name),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Email Address'),
            subtitle: Text(user!.email),
          ),
        ],
      ),
    );
  }

  Widget buildAppliedJobsSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Sent Resumes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: isLoading ? null : () => presenter.loadAppliedJobs(),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            if (appliedJobsError != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  appliedJobsError!,
                  style: const TextStyle(color: Colors.red),
                ),
              )
            else if (appliedJobs.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('No sent resumes found.'),
              )
            else
              Column(
                children: appliedJobs.map((job) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: job.logoUrl == null || job.logoUrl!.isEmpty
                        ? const Icon(Icons.business)
                        : Image.network(
                      job.logoUrl!,
                      width: 42,
                      height: 42,
                      errorBuilder: (_, __, ___) =>
                      const Icon(Icons.business),
                    ),
                    title: Text(job.title),
                    subtitle: Text(
                      '${job.companyName}\n${job.status}\n${job.createdAt}',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => openAppliedJob(job),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: goBackToHome,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back To Home'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : uploadResumePressed,
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload Resume PDF'),
          ),
        ),

        const SizedBox(height: 10),

        if (resumeUploaded)
          const Text(
            'Resume is uploaded',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: resumeUploaded && !isLoading ? deleteResumePressed : null,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete Uploaded Resume'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: isLoading ? null : logoutPressed,
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildProfileBody() {
    if (isLoading && user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    if (user == null) {
      return const Center(
        child: Text('No profile information found.'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await presenter.loadProfile();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (isLoading) const LinearProgressIndicator(),

            buildProfileAvatar(),

            const SizedBox(height: 12),

            TextButton.icon(
              onPressed: changeProfilePicturePressed,
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Choose Profile Picture'),
            ),

            const SizedBox(height: 12),

            Text(
              user!.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 6),

            Text(
              user!.email,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 28),

            buildProfileInfoCard(),

            const SizedBox(height: 16),

            buildAppliedJobsSection(),

            const SizedBox(height: 24),

            buildActionButtons(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jobinja Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: goBackToHome,
        ),
      ),
      body: buildProfileBody(),
    );
  }
}