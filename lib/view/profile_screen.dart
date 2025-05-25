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

class ProfileScreen extends StatelessWidget {
   ProfileScreen({super.key});

  final scaffoldKey = GlobalKey<ScaffoldState>();

  void _showEditNameDialog(BuildContext context, ProfileViewModel profileVM) {
    final controller = TextEditingController(text: capitalize(profileVM.currentUser?.name ?? ''));
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'New name'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                await profileVM.updateName(controller.text.trim());
                Navigator.pop(context);
              },
              child: const Text('Save'),
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
          Text("Settings", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 10.h),
          SwitchListTile(
            title: Text("Hide Online Status", style: TextStyle(fontSize: 14.sp)),
            value: profileVM.currentUser?.hideOnlineStatus ?? false,
            onChanged: (value) async {
              await profileVM.setHideOnlineStatus(context, value);
            },
          ),
          SwitchListTile(
            title: Text("Dark Theme", style: TextStyle(fontSize: 14.sp)),
            value: profileVM.isDarkMode,
            onChanged: (val) {
              profileVM.setDarkMode(val);
              print("isDarkMode: $val");
            }
          ),
          ListTile(
            leading: Icon(Icons.edit, size: 22.sp),
            title: Text("Edit Name", style: TextStyle(fontSize: 14.sp)),
            onTap: () {
              Navigator.pop(context);
              _showEditNameDialog(context, profileVM);
            },
          ),
          SizedBox(height: 10.h),
          DropdownButtonFormField<String>(
            value: phobiaVM.phobias.any((p) => p.routeName == pageVM.selectedPhobia)
                ? pageVM.selectedPhobia
                : null,
            decoration: InputDecoration(labelText: "Select Phobia"),
            items: phobiaVM.phobias.map((phobia) {
              return DropdownMenuItem(
                value: phobia.routeName,
                child: Text(phobia.name),
              );
            }).toList(),
            onChanged: (value) async {
              if (value != null) {
                await pageVM.updatePhobia(value);
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, size: 22.sp, color: Colors.red),
            title: Text("Logout", style: TextStyle(fontSize: 14.sp, color: Colors.red)),
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
        title: Text('Profile', style:
        TextStyle(
            fontSize: 18.sp,
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
          ? const Center(child: Text('Error loading profile.'))
          : Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 16.h),
            GestureDetector(
              onTap: () async {
                await profileVM.updateProfileImage(context);
              },
              child: CircleAvatar(
                radius: 50.r,
                backgroundImage: user.imageUrl != null && user.imageUrl!.isNotEmpty && user.imageUrl!.startsWith('https://')
                    ? NetworkImage(user.imageUrl!)
                    : null,
                backgroundColor: Colors.grey.shade400,
                child: user.imageUrl == null || user.imageUrl!.isEmpty
                    ? Text(
                  initials,
                  style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: Colors.white),
                )
                    : null,
              ),

            ),
            SizedBox(height: 12.h),
            Text(
              user.name,
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
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
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: profileVM.isDarkMode ? Colors.white54 : Colors.black54 ,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      GestureDetector(
                        onTap: () {
                          final pin = user.pin ;
                          Clipboard.setData(ClipboardData(text: pin));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("PIN copied to clipboard")),
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
                    // borderRadius: BorderRadius.circular(12.r),
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
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500
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
                              fontSize: 14.sp)
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
                          title: Text(req.name, style: TextStyle(fontSize: 14.sp)),
                          subtitle: Text('PIN: ${req.pin}', style: TextStyle(fontSize: 12.sp)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.check, color: Colors.green, size: 20.sp),
                                onPressed: () async {
                                  await vm.approveRequest(req);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${req.name} approved'),
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
                                      content: Text('${req.name} rejected'),
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
