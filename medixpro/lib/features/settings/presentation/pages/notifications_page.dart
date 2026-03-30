import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {

  @override
  void initState() {
    context.read<SettingsCubit>().loadNotifications();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),

      body: BlocBuilder<SettingsCubit,SettingsState>(
        builder:(context,state){

          if(state is SettingsLoading){
            return const Center(child: CircularProgressIndicator());
          }

          if(state is NotificationsLoaded){

            return ListView.builder(
              itemCount: state.notifications.length,
              itemBuilder:(context,index){

                final n = state.notifications[index];

                return ListTile(
                  title: Text(n.title),
                  subtitle: Text(n.message),
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}