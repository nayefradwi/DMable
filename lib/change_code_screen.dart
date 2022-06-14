import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_in_whatsapp/call_log_bloc.dart';
import 'package:open_in_whatsapp/home.dart';

class ChangeCodeScreen extends StatefulWidget {
  const ChangeCodeScreen({Key? key}) : super(key: key);

  @override
  State<ChangeCodeScreen> createState() => _ChangeCodeScreenState();
}

class _ChangeCodeScreenState extends State<ChangeCodeScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<CallLogCubit, CallLogCubitState>(
      listener: (context, state) {
        bool isSetup = BlocProvider.of<CallLogCubit>(context).isSetUp();
        if (!isSetup) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Change Country"),
        ),
        body: SelectCountryCodeWidget(
          onTap: BlocProvider.of<CallLogCubit>(context).setCountryCode,
        ),
      ),
    );
  }
}
