import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../utils/constant.dart';
import '../utils/routes/route_name.dart';
import '../viewModel/friend_requests_view_model.dart';
import '../viewModel/friends_view_model.dart';
import '../viewModel/page_view_model.dart';
import '../viewModel/phobia_view_model.dart';
import '../viewModel/profile_view_model.dart';
import 'full_screen_image_view.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class ProfileScreen extends StatelessWidget {
   ProfileScreen({super.key});

  final scaffoldKey = GlobalKey<ScaffoldState>();

  void _showEditNameDialog(BuildContext context, ProfileViewModel profileVM) {
    final controller = TextEditingController(text: capitalize(profileVM.currentUser?.name ?? ''));
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Name',
          style: TextStyle(
            fontFamily: 'Esteban',
          ),),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'New name',
            labelStyle: TextStyle(
              fontFamily: 'Esteban',
            )),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context),
                child: const Text('Cancel',
                style: TextStyle(
                  fontFamily: 'Esteban',
                ),)),
            TextButton(
              onPressed: () async {
                await profileVM.updateName(controller.text.trim());
                Navigator.pop(context);
              },
              child: const Text('Save',
              style: TextStyle(
                fontFamily: 'Esteban',
              ),),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingsDrawer(BuildContext context, ProfileViewModel profileVM) {
    final pageVM = Provider.of<PageViewModel>(context);
    final phobiaVM = Provider.of<PhobiaViewModel>(context);

    return Drawer(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20.r))),
      child: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          SizedBox(height: 35.h),
          Text("Settings", style: TextStyle(
              fontSize: 18.sp,
              fontFamily: 'Esteban',
              fontWeight: FontWeight.bold)),
          SizedBox(height: 10.h),
          SwitchListTile(
            title: Text("Hide Online Status", style: TextStyle(
              fontSize: 14.sp,
              fontFamily: 'Esteban',
            )),
            value: profileVM.currentUser?.hideOnlineStatus ?? false,
            onChanged: (value) async {
              await profileVM.setHideOnlineStatus(context, value);
            },
          ),
          SwitchListTile(
            title: Text("Dark Theme", style: TextStyle(
              fontSize: 14.sp,
              fontFamily: 'Esteban',
            )),
            value: profileVM.isDarkMode,
            onChanged: (val) {
              profileVM.setDarkMode(val);
              print("isDarkMode: $val");
            }
          ),
          ListTile(
            leading: Icon(Icons.edit, size: 22.sp),
            title: Text("Edit Name", style: TextStyle(
                fontSize: 14.sp,
                fontFamily: 'Esteban'
            )),
            onTap: () {
              Navigator.pop(context);
              _showEditNameDialog(context, profileVM);
            },
          ),
          SizedBox(height: 10.h),
          ListTile(
            leading: Icon(Icons.logout, size: 22.sp, color: Colors.red),
            title: Text("Logout", style: TextStyle(
                fontSize: 14.sp,
                fontFamily: 'Esteban',
                color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(child: CircularProgressIndicator()),
              );

              try {
                // Logout logic
                await profileVM.logout(context);
                profileVM.resetProfile();
                Provider.of<FriendsViewModel>(context, listen: false).clear();
                pageVM.resetPhobia();

                if (context.mounted) {
                  Navigator.pop(context); // remove loading dialog
                  Navigator.pushNamedAndRemoveUntil(context, RouteName.login, (_) => false);
                }
              } catch (e) {
                if (context.mounted) Navigator.pop(context); // remove loading dialog
              }
            },
          ),
          SizedBox(height: 10.h),
          DropdownButtonFormField2<String>(
            value: phobiaVM.phobias.any((p) => p.routeName == pageVM.selectedPhobia)
                ? pageVM.selectedPhobia
                : null,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: "Select Phobia",
              labelStyle: const TextStyle(
                fontFamily: 'Esteban',
                fontSize: 18,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            style: const TextStyle(fontFamily: 'Esteban', fontSize: 16),
            dropdownStyleData: DropdownStyleData(
              maxHeight: 250,
              offset: const Offset(0, 9), // 👈 offsets dropdown from the field
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white70,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
            iconStyleData: const IconStyleData(
              icon: Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
            ),
            items: phobiaVM.phobias.map((phobia) {
              return DropdownMenuItem<String>(
                value: phobia.routeName,
                child: Text(
                  phobia.name,
                  style: const TextStyle(fontFamily: 'Esteban', color: Colors.black54),
                ),
              );
            }).toList(),
            onChanged: (value) async {
              if (value != null) {
                await pageVM.updatePhobia(value);
              }
            },
          ),


        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileVM = Provider.of<ProfileViewModel>(context);
    final user = profileVM.currentUser;
    final initials = (user?.name.isNotEmpty ?? false) ? user!.name.trim()[0].toUpperCase() : '?';

    return Scaffold(
      key: scaffoldKey,
      endDrawer: _buildSettingsDrawer(context, profileVM),
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: Colors.white
        ),
        title: Text('Profile', style:
        TextStyle(
            fontSize: 25.sp,
            fontFamily: 'Esteban',
            color: Colors.white
        )),
        actions: [
          IconButton(
            icon: Icon(
                Icons.settings,
                size: 22.sp,
                color: Colors.white),
            onPressed: () => scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      body: profileVM.isLoadingProfile
          ? const Center(child: CircularProgressIndicator())
          : user == null
          ?  Center(child: Text('Error loading profile.',
      style: TextStyle(
        fontFamily: 'Esteban',
        fontSize: 20.sp,
      ),))
          : Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 16.h),
            GestureDetector(
              onTap: () async {
                if (user.imageUrl != null && user.imageUrl!.isNotEmpty && user.imageUrl!.startsWith('https://')) {
                  showModalBottomSheet(
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                    ),
                    builder: (context) {
                      return Wrap(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.image),
                            title:  Text('View Profile Image',
                              style: TextStyle(fontFamily: 'Esteban', fontSize: 25.sp),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FullscreenImageView(imageUrl: user.imageUrl!),
                                ),
                              );
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.edit),
                            title:  Text('Change Profile Photo',
                              style: TextStyle(fontFamily: 'Esteban' , fontSize: 25.sp),
                            ),
                            onTap: () async {
                              Navigator.pop(context);
                              await profileVM.updateProfileImage(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  // No profile image yet – just allow to update
                  await profileVM.updateProfileImage(context);
                }
              },
              child: CircleAvatar(
                radius: 50.r,
                backgroundImage: user.imageUrl != null &&
                    user.imageUrl!.isNotEmpty &&
                    user.imageUrl!.startsWith('https://')
                    ? NetworkImage(user.imageUrl!)
                    : null,
                backgroundColor: Colors.grey.shade400,
                child: user.imageUrl == null || user.imageUrl!.isEmpty
                    ? Text(
                  initials,
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontFamily: 'Esteban',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
                    : null,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              user.name,
              style: TextStyle(
                  fontSize: 30.sp,
                  fontFamily: 'Esteban',
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "PIN: #${user.pin}",
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Esteban',
                          color: profileVM.isDarkMode ? Colors.white54 : Colors.black54 ,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      GestureDetector(
                        onTap: () {
                          final pin = user.pin ;
                          Clipboard.setData(ClipboardData(text: pin));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("PIN copied to clipboard",
                            style: TextStyle(
                              fontFamily: 'Esteban',
                            ),)),
                          );
                        },
                        child: Icon(Icons.copy, size: 18.sp, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Add Friends Card
            GestureDetector(
              onTap: (){
                Navigator.pushNamed(context, RouteName.addFriend);
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                              Icons.add,
                              color:profileVM.isDarkMode ? Colors.white54 : Colors.black54 ,
                              size: 20.sp
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            "add friends",
                            style: TextStyle(
                              color: profileVM.isDarkMode ? Colors.white54 : Colors.black54,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Esteban',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Consumer<FriendRequestViewModel>(
                builder: (context, vm, _) {

                  final requests = vm.requests;

                  if (requests.isEmpty) {
                    return Center(
                      child: Text('No incoming requests',
                          style: TextStyle(
                            color:  profileVM.isDarkMode ? Colors.white54 : Colors.black54,
                            fontSize: 18.sp,
                            fontFamily: 'Esteban',
                          )
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.all(12.w),
                    itemCount: requests.length,
                    itemBuilder: (_, i) {
                      final req = requests[i];
                      return Card(
                        margin: EdgeInsets.only(bottom: 10.h),
                        child: ListTile(
                          tileColor: profileVM.isDarkMode ? Colors.black12 : Colors.white60,
                          title: Text(req.name, style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'Esteban',
                          )),
                          subtitle: Text('PIN: ${req.pin}', style: TextStyle(
                            fontSize: 12.sp,
                            fontFamily: 'Esteban',
                          )),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.check, color: Colors.green, size: 20.sp),
                                onPressed: () async {
                                  await vm.approveRequest(req);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${req.name} approved',
                                      style: TextStyle(
                                        fontFamily: 'Esteban',
                                      ),),
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.red, size: 20.sp),
                                onPressed: () async {
                                  await vm.rejectRequest(req.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${req.name} rejected',
                                      style: TextStyle(
                                        fontFamily: 'Esteban',
                                      ),),
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
