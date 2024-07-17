import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShowRadiusBottomSheet extends StatefulWidget {
  final double alertRadius;
  final Function(double) onRadiusChanged;
  final VoidCallback startOnPressed;
  final VoidCallback cancelOnPressed;
  final VoidCallback confirmOnPressed;
  final TextEditingController alarmNameController;

  final VoidCallback onPressedEntry;
  final VoidCallback onPressedExit;
  final bool isEntryMode;

  const ShowRadiusBottomSheet({
    super.key,
    required this.alertRadius,
    required this.onRadiusChanged,
    required this.startOnPressed,
    required this.cancelOnPressed,
    required this.onPressedEntry,
    required this.onPressedExit,
    required this.isEntryMode,
    required this.alarmNameController,
    required this.confirmOnPressed,
  });

  @override
  State<ShowRadiusBottomSheet> createState() => _ShowRadiusBottomSheetState();
}

class _ShowRadiusBottomSheetState extends State<ShowRadiusBottomSheet> {
  late double _currentRadius;
  final TextEditingController _radiusController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentRadius = widget.alertRadius;
    _radiusController.text = _currentRadius.toString();
  }

  void _onRadiusChanged(String value) {
    double? parsedValue = double.tryParse(value);
    if (parsedValue != null) {
      parsedValue = parsedValue.clamp(0.0, 1000.0);
      setState(() {
        _currentRadius = parsedValue ?? 50;
        widget.onRadiusChanged(_currentRadius);
        _radiusController.text = _currentRadius.toStringAsFixed(0);
        _radiusController.selection = TextSelection.fromPosition(
            TextPosition(offset: _radiusController.text.length));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              TextButton(
                  onPressed: widget.cancelOnPressed,
                  child: const Text('Cancel')),
              Expanded(child: Container()),
              TextButton(
                  onPressed: widget.confirmOnPressed,
                  child: const Text('Save')),
              TextButton(
                  onPressed: widget.startOnPressed, child: const Text('Start')),
            ]),
            Row(
              children: [
                Expanded(
                    child: ElevatedButton(
                        onPressed: widget.onPressedEntry,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue),
                        child: const Text(
                          "Entry",
                          style: TextStyle(color: Colors.white),
                        ))),
                SizedBox(width: 6.w),
                Expanded(
                    child: ElevatedButton(
                        onPressed: widget.onPressedExit,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange),
                        child: const Text(
                          "Exit",
                          style: TextStyle(color: Colors.white),
                        )))
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Slider(
                  value: _currentRadius,
                  min: 0.0,
                  max: 1000.0,
                  divisions: 100,
                  label: _currentRadius.round().toString(),
                  onChanged: (value) {
                    setState(() {
                      _currentRadius = value;
                      _radiusController.text = value.toStringAsFixed(0);
                    });
                    widget.onRadiusChanged(_currentRadius);
                  },
                ),
                Expanded(child: Container()),
                SizedBox(
                  width: 70.w,
                  child: TextField(
                    style: const TextStyle(fontSize: 12),
                    controller: _radiusController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                      labelText: 'Radius',
                    ),
                    onChanged: _onRadiusChanged,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            TextFormField(
              controller: widget.alarmNameController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(0),
                  labelText: 'Alarm Name'),
            )
          ],
        ),
      ),
    );
  }
}
