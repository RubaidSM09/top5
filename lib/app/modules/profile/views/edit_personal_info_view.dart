import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:top5/common/widgets/custom_button.dart';
import 'package:top5/common/widgets/custom_text_field.dart';
import 'package:top5/common/app_colors.dart';
import 'package:top5/common/custom_fonts.dart';

import '../controllers/profile_controller.dart';
import 'personal_info_view.dart';

/// Small helper controller to keep TextEditingControllers and selected image
class _EditPersonalInfoFormController extends GetxController {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  final isSaving = false.obs;
  final pickedImage = Rx<File?>(null);

  late final ProfileController profile;

  @override
  void onInit() {
    super.onInit();
    profile = Get.find<ProfileController>();

    // Seed text fields with current values (after fetchProfileInfo completes).
    // Also react to later changes.
    void seed() {
      nameCtrl.text = profile.fullName.value;
      emailCtrl.text = profile.email.value;
      phoneCtrl.text = profile.phone.value;
    }

    // Seed immediately with whatever is there
    seed();

    // And listen for future updates (e.g., after API fetch)
    ever<String>(profile.fullName, (_) => nameCtrl.text = profile.fullName.value);
    ever<String>(profile.email,    (_) => emailCtrl.text = profile.email.value);
    ever<String>(profile.phone,    (_) => phoneCtrl.text = profile.phone.value);
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    super.onClose();
  }

  Future<void> pickAvatar() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x != null) {
      pickedImage.value = File(x.path);
    }
  }

  String? _validateEmail(String v) {
    if (v.trim().isEmpty) return 'Email is required';
    final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!re.hasMatch(v.trim())) return 'Enter a valid email';
    return null;
  }

  String? _validateName(String v) {
    if (v.trim().isEmpty) return 'Name is required';
    if (v.trim().length < 2) return 'Name is too short';
    return null;
  }

  String? _validatePhone(String v) {
    if (v.trim().isEmpty) return null; // optional
    final digits = v.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.length < 6) return 'Phone seems too short';
    return null;
  }

  Future<void> save() async {
    if (isSaving.value) return;

    final nameErr  = _validateName(nameCtrl.text);
    final emailErr = _validateEmail(emailCtrl.text);
    final phoneErr = _validatePhone(phoneCtrl.text);

    if (nameErr != null || emailErr != null || phoneErr != null) {
      Get.snackbar('Invalid input', (nameErr ?? emailErr ?? phoneErr)!);
      return;
    }

    isSaving.value = true;
    try {
      await profile.editProfile(
        nameCtrl.text.trim(),
        emailCtrl.text.trim(),
        phoneCtrl.text.trim(),
        pickedImage.value,
      );
      // Optionally go back after successful save
      // Get.back(result: true);
    } finally {
      isSaving.value = false;
    }
  }
}

class EditPersonalInfoView extends GetView {
  const EditPersonalInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure ProfileController exists
    final profile = Get.put(ProfileController(), permanent: true);
    final form = Get.put(_EditPersonalInfoFormController());

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: ProfileAppBar(appBarTitle: 'Edit Personal Info'.tr),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 21.w),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 17.h),
                  decoration: BoxDecoration(
                    color: AppColors.profileSearchBg,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Column(
                    children: [
                      Obx(() {
                        final local = form.pickedImage.value;
                        final net   = profile.image.value;

                        ImageProvider avatarProvider;
                        if (local != null) {
                          avatarProvider = FileImage(local);
                        } else if (net.isNotEmpty) {
                          avatarProvider = NetworkImage('https://backend.top5app.fr$net');
                        } else {
                          avatarProvider = const AssetImage('assets/images/home/profile_pic.jpg');
                        }

                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            GestureDetector(
                              onTap: form.pickAvatar,
                              child: CircleAvatar(
                                backgroundImage: avatarProvider,
                                radius: 35.r,
                              ),
                            ),
                            Positioned(
                              left: 62.w,
                              top: 45.h,
                              child: GestureDetector(
                                onTap: form.pickAvatar,
                                child: SvgPicture.asset('assets/images/profile/camera.svg'),
                              ),
                            )
                          ],
                        );
                      }),

                      SizedBox(height: 8.h),

                      Obx(() => Text(
                        profile.fullName.value.isEmpty ? 'Your Name' : profile.fullName.value,
                        style: h2.copyWith(
                          fontSize: 20.sp,
                          color: AppColors.profileBlack,
                        ),
                      )),

                      SizedBox(height: 12.h),

                      // Name
                      _Label('Name'.tr),
                      SizedBox(height: 4.h),
                      CustomTextField(
                        controller: form.nameCtrl,
                        hintText: 'Your full name',
                        hintTextColor: AppColors.profileBlack,
                        color: AppColors.profileWhite,
                        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 11.h),
                        borderColor: AppColors.top5Transparent,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.top5Black.withAlpha(64),
                            blurRadius: 2.r,
                          )
                        ],
                        isObscureText: false.obs,
                        onChanged: (v) => profile.updateFullName(v),
                      ),

                      SizedBox(height: 12.h),

                      // Email
                      _Label('E-mail'.tr),
                      SizedBox(height: 4.h),
                      CustomTextField(
                        controller: form.emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        hintText: 'name@example.com',
                        hintTextColor: AppColors.profileBlack,
                        color: AppColors.profileWhite,
                        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 11.h),
                        borderColor: AppColors.top5Transparent,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.top5Black.withAlpha(64),
                            blurRadius: 2.r,
                          )
                        ],
                        isObscureText: false.obs,
                        onChanged: (v) => profile.updateEmail(v),
                      ),

                      SizedBox(height: 12.h),

                      // Phone
                      _Label('Phone'.tr),
                      SizedBox(height: 4.h),
                      CustomTextField(
                        controller: form.phoneCtrl,
                        keyboardType: TextInputType.phone,
                        hintText: '+8801XXXXXXXXX',
                        hintTextColor: AppColors.profileBlack,
                        color: AppColors.profileWhite,
                        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 11.h),
                        borderColor: AppColors.top5Transparent,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.top5Black.withAlpha(64),
                            blurRadius: 2.r,
                          )
                        ],
                        isObscureText: false.obs,
                        onChanged: (v) => profile.updatePhone(v),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30.h),

                Obx(() => CustomButton(
                  text: form.isSaving.value ? 'Saving…'.tr : 'Save'.tr,
                  onTap: form.isSaving.value ? null : form.save,
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
          style: h3.copyWith(
            color: AppColors.profileGray,
            fontSize: 12.sp,
          ),
        )
      ],
    );
  }
}
