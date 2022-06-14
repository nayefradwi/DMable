import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:country_codes/country_codes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:open_in_whatsapp/call_log_bloc.dart';

class DialPadScreen extends StatefulWidget {
  const DialPadScreen({Key? key}) : super(key: key);
  @override
  State<DialPadScreen> createState() => _DialPadScreenState();
}

class _DialPadScreenState extends State<DialPadScreen> {
  final TextEditingController _controller = TextEditingController();
  late final CallLogCubit _cubit;
  @override
  void initState() {
    _cubit = BlocProvider.of<CallLogCubit>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dial"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AutoSizeTextField(
            controller: _controller,
            fullwidth: false,
            minFontSize: 18,
            decoration: const InputDecoration(border: InputBorder.none),
            inputFormatters: [
              DialCodeFormatter(),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: DialpadGrid(
                onNumberTap: onNumberTapped,
                onDeleteClicked: onDeleteClicked,
                onDeleteLongPress: deleteAll,
              ),
            ),
          ),
          DmOptionsRow(
            onOptionTapped: sendDm,
          ),
          const SizedBox(height: 22)
        ],
      ),
    );
  }

  void onNumberTapped(String number) {
    setState(() {
      _controller.text += number;
    });
  }

  void onDeleteClicked() {
    if (_controller.text.isEmpty) return;
    setState(() {
      _controller.text =
          _controller.text.substring(0, _controller.text.length - 1);
    });
  }

  void deleteAll() {
    setState(() {
      _controller.clear();
    });
  }

  void sendDm(int option) {
    if (option == DmOptionsRow.whatsapp) {
      _cubit.openInWhatsapp(_controller.text);
    } else if (option == DmOptionsRow.telegram) {
      _cubit.openInTelegram(_controller.text);
    } else if (option == DmOptionsRow.sms) {
      _cubit.openInSms(_controller.text);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class DialpadGrid extends StatelessWidget {
  const DialpadGrid({
    Key? key,
    this.onNumberTap,
    this.onDeleteClicked,
    this.onDeleteLongPress,
  }) : super(key: key);
  final void Function(String number)? onNumberTap;
  final void Function()? onDeleteClicked, onDeleteLongPress;
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      children: [
        DialpadNumberButton(label: "1", onNumberTap: onNumberTap),
        DialpadNumberButton(label: "2", onNumberTap: onNumberTap),
        DialpadNumberButton(label: "3", onNumberTap: onNumberTap),
        DialpadNumberButton(label: "4", onNumberTap: onNumberTap),
        DialpadNumberButton(label: "5", onNumberTap: onNumberTap),
        DialpadNumberButton(label: "6", onNumberTap: onNumberTap),
        DialpadNumberButton(label: "7", onNumberTap: onNumberTap),
        DialpadNumberButton(label: "8", onNumberTap: onNumberTap),
        DialpadNumberButton(label: "9", onNumberTap: onNumberTap),
        DialpadNumberButton(label: "+", onNumberTap: onNumberTap),
        DialpadNumberButton(label: "0", onNumberTap: onNumberTap),
        DialpadDeleteButton(
          onTap: onDeleteClicked,
          onLongPress: onDeleteLongPress,
        ),
      ],
    );
  }
}

class DialpadNumberButton extends StatelessWidget {
  const DialpadNumberButton({
    Key? key,
    required this.label,
    this.onNumberTap,
  }) : super(key: key);
  final String label;
  final void Function(String number)? onNumberTap;
  @override
  Widget build(BuildContext context) {
    return DialpadButton(
      onTap: () {
        if (onNumberTap != null) onNumberTap!(label);
      },
      child: Text(label),
    );
  }
}

class DialpadDeleteButton extends StatelessWidget {
  const DialpadDeleteButton({
    Key? key,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);
  final void Function()? onTap, onLongPress;
  @override
  Widget build(BuildContext context) {
    return DialpadButton(
      onTap: onTap,
      onLongPress: onLongPress,
      child: const Icon(CupertinoIcons.back),
    );
  }
}

class DialpadButton extends StatelessWidget {
  const DialpadButton({
    Key? key,
    required this.child,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);
  final Widget child;
  final void Function()? onTap, onLongPress;
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Center(child: child),
      ),
    );
  }
}

class DmOptionsRow extends StatelessWidget {
  static const int whatsapp = 0;
  static const int telegram = 1;
  static const int sms = 2;
  const DmOptionsRow({
    Key? key,
    this.onOptionTapped,
  }) : super(key: key);
  final void Function(int option)? onOptionTapped;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        FloatingActionButton(
          heroTag: UniqueKey(),
          backgroundColor: Colors.blue[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          onPressed: () {
            onPressed(telegram);
          },
          child: const Icon(
            FontAwesomeIcons.telegram,
            color: Colors.white,
          ),
        ),
        FloatingActionButton(
          heroTag: UniqueKey(),
          backgroundColor: Colors.green[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          onPressed: () {
            onPressed(whatsapp);
          },
          child: const Icon(
            FontAwesomeIcons.whatsapp,
            color: Colors.white,
          ),
        ),
        FloatingActionButton(
          heroTag: UniqueKey(),
          backgroundColor: Colors.purple[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          onPressed: () {
            onPressed(sms);
          },
          child: const Icon(
            FontAwesomeIcons.message,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  void onPressed(int option) {
    if (onOptionTapped == null) return;
    onOptionTapped!(option);
  }
}
