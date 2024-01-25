import 'package:flutter/material.dart';
import 'package:lapor_workshop/components/styles.dart';

List<String> dataStatus = ['Posted', 'Proses', 'Selesai'];
Map<String, Color> warnaStatus = {
  'Posted': dangerColor,
  'Process': warningColor,
  'Done': successColor
};
List<String> dataInstansi = ['Pembangunan', 'Jalanan', 'Pendidikan'];
