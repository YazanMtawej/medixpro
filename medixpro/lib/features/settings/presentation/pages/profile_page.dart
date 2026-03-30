import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  @override
  void initState() {
    context.read<SettingsCubit>().loadProfile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),

      body: BlocBuilder<SettingsCubit,SettingsState>(
        builder:(context,state){

          if(state is SettingsLoading){
            return const Center(child: CircularProgressIndicator());
          }

          if(state is ProfileLoaded){

            final p = state.profile;

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [

                Text("Name: ${p.name}"),
                const SizedBox(height:10),

                Text("Email: ${p.email}"),
                const SizedBox(height:10),

                Text("Phone: ${p.phone}"),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}