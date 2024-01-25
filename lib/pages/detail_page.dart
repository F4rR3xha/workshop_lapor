import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lapor_workshop/components/input_widget.dart';
import 'package:lapor_workshop/components/status_dialog.dart';
import 'package:lapor_workshop/components/styles.dart';
import 'package:lapor_workshop/models/akun.dart';
import 'package:lapor_workshop/models/laporan.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPage extends StatefulWidget {
  DetailPage({super.key});
  @override
  State<StatefulWidget> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool _isLoading = false;

  String? status;
  String? komentar;

  void statusDialog(Laporan laporan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatusDialog(
          laporan: laporan,
        );
      },
    );
  }

  Future launch(String uri) async {
    if (uri == '') return;
    if (!await launchUrl(Uri.parse(uri))) {
      throw Exception('Tidak dapat memanggil : $uri');
    }
  }

  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    Laporan laporan = arguments['laporan'];
    Akun akun = arguments['akun'];

    void addKomentar() async {
      CollectionReference transaksiCollection =
          _firestore.collection('laporan');
      try {
        await transaksiCollection.doc(laporan.docId).update({
          'komentar': FieldValue.arrayUnion([
            {
              'nama': akun.nama,
              'isi': komentar,
            }
          ])
        });
      } catch (e) {}
    }

    void statusKomentar() {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InputLayout(
                      'Tambah Komentar',
                      TextFormField(
                        onChanged: (value) {
                          setState(() {
                            komentar = value;
                          });
                        },
                        keyboardType: TextInputType.multiline,
                        minLines: 3,
                        maxLines: 5,
                        decoration: customInputDecoration('Komentar'),
                      ),
                    ),
                    Container(
                      width: 180,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            addKomentar();
                            Navigator.popAndPushNamed(context, '/dashboard');
                            // print(laporan.komentar?.length);
                          });
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text('Tambah Komentar'),
                      ),
                    )
                  ],
                ),
              ),
            );
          });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title:
            Text('Detail Laporan', style: headerStyle(level: 3, dark: false)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        laporan.judul,
                        style: headerStyle(level: 3),
                      ),
                      SizedBox(height: 15),
                      laporan.gambar != ''
                          ? Image.network(laporan.gambar!)
                          : Image.asset('assets/istock-default.jpg'),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          laporan.status == 'Posted'
                              ? textStatus(
                                  'Posted', Colors.yellow, Colors.black)
                              : laporan.status == 'Process'
                                  ? textStatus(
                                      'Process', Colors.green, Colors.white)
                                  : textStatus(
                                      'Done', Colors.blue, Colors.white),
                          textStatus(
                              laporan.instansi, Colors.white, Colors.black),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        leading: Icon(Icons.person),
                        title: const Center(child: Text('Nama Pelapor')),
                        subtitle: Center(
                          child: Text(laporan.nama),
                        ),
                        trailing: SizedBox(width: 45),
                      ),
                      ListTile(
                        leading: Icon(Icons.date_range),
                        title: Center(child: Text('Tanggal Laporan')),
                        subtitle: Center(
                            child: Text(DateFormat('dd MMMM yyyy')
                                .format(laporan.tanggal))),
                        trailing: IconButton(
                          icon: Icon(Icons.location_on),
                          onPressed: () {
                            launch(laporan.maps);
                          },
                        ),
                      ),
                      SizedBox(height: 50),
                      Text(
                        'Deskripsi Laporan',
                        style: headerStyle(level: 3),
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(laporan.deskripsi ?? ''),
                      ),
                      if (akun.role == 'admin')
                        Container(
                          width: 250,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                status = laporan.status;
                              });
                              statusDialog(laporan);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text('Ubah Status'),
                          ),
                        ),
                      SizedBox(
                        height: 20,
                      ),
                      // ListView.builder(
                      //   itemCount: laporan.komentar?.length,
                      //     itemBuilder: (BuildContext context, int index) {
                      //       return ListTile(
                      //         leading: Icon(Icons.person),
                      //   title: const Center(child: Text('Nama Pelapor')),
                      //   subtitle: Center(
                      //     child: Text(laporan.nama),
                      //   ),
                      //       );
                      //     }),
                      // ListView.builder(
                      //   itemCount: laporan.komentar?.length,
                      //   itemBuilder: (contex, index) {
                      //   return Container(
                      //     child: Column(
                      //       children: [
                      //         Text('Test')
                      //       ],
                      //     ),
                      //   );
                      // }),

                      if (laporan.komentar?.length != null)
                        Container(
                          height: 100,
                          width: double.maxFinite,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Komentar',
                                style: headerStyle(level: 3),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.person),
                                  Text('${laporan.komentar?.last.nama}'),
                                ],
                              ),
                              Align(
                                  alignment: Alignment.topLeft,
                                  child: Text('${laporan.komentar?.last.isi}')),
                            ],
                          ),
                        ),
                      SizedBox(
                        height: 20,
                      ),
                      // InputLayout(
                      //   'Tambah Komentar',
                      //   TextFormField(
                      //     onChanged: (value) {
                      //       setState(() {
                      //         komentar = value;
                      //       });
                      //     },
                      //     keyboardType: TextInputType.multiline,
                      //     minLines: 3,
                      //     maxLines: 5,
                      //     decoration: customInputDecoration('Komentar'),
                      //   ),
                      // ),
                      Container(
                        width: 250,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              statusKomentar();
                              // print(laporan.komentar?.length);
                            });
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text('Tambah Komentar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Container textStatus(String text, var bgcolor, var textcolor) {
    return Container(
      width: 150,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: bgcolor,
          border: Border.all(width: 1, color: primaryColor),
          borderRadius: BorderRadius.circular(25)),
      child: Text(
        text,
        style: TextStyle(color: textcolor),
      ),
    );
  }
}
