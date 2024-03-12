import 'package:expense_manager/widgets/pdf_content.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/chat.dart';
import '../models/constants.dart';

class TransactionReport extends StatefulWidget {
  const TransactionReport(
      {super.key, required this.messages, required this.isIncome});

  final List<Message> messages;
  final bool isIncome;

  @override
  State<TransactionReport> createState() => _TransactionReportState();
}

class _TransactionReportState extends State<TransactionReport> {
  final user = FirebaseAuth.instance.currentUser;
  NumberFormat myFormat = NumberFormat.currency(
    locale: 'en_in',
    symbol: '\u{20B9}',
    decimalDigits: 2,
  );

  getTotal({bool isIncome = false}) {
    double value = 0.0;
    if (widget.messages.isEmpty) return myFormat.format(value);

    if (isIncome) {
      for (var message in widget.messages) {
        if (message.sender == user!.email) {
          for (var assignee in message.assignees) {
            if (assignee.email != user!.email && !assignee.status) {
              value += assignee.amount;
            }
          }
        }
      }
    } else {
      for (var message in widget.messages) {
        if (message.sender != user!.email) {
          for (var assignee in message.assignees) {
            if (assignee.email == user!.email && !assignee.status) {
              value += assignee.amount;
            }
          }
        }
      }
    }

    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: const Text('Preview Bill'),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: PdfPreview(
          previewPageMargin: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.1,
            vertical: 50,
          ),
          canChangeOrientation: false,
          pages: const [0],
          pageFormats: const {'A4': customPageFormat},
          pdfFileName: '${widget.isIncome ? 'Income' : 'Expense'}-report.pdf',
          build: (format) async {
            ByteData bytes = await rootBundle.load(
                'assets/font/XRXI3I6Li01BKofiOc5wtlZ2di8HDIkhRTM9jo7eTWk.ttf');
            final font = pw.TtfFont(
              bytes.buffer.asByteData(bytes.offsetInBytes, bytes.lengthInBytes),
              protect: false,
            );
            ByteData boldBytes = await rootBundle.load(
                'assets/font/XRXI3I6Li01BKofiOc5wtlZ2di8HDFwmRTM9jo7eTWk.ttf');
            final boldFont = pw.TtfFont(
              boldBytes.buffer
                  .asByteData(boldBytes.offsetInBytes, boldBytes.lengthInBytes),
              protect: false,
            );
            final pw.Document pdf = pw.Document();
            pdf.addPage(
              pw.Page(
                pageFormat: format,
                build: (pw.Context context) {
                  return PdfContent(
                    format: format,
                    googleFont: font,
                    googleBoldFont: boldFont,
                    incomeTotal: getTotal(isIncome: true),
                    expenseTotal: getTotal(isIncome: false),
                  );
                },
              ),
              index: 0,
            );
            return pdf.save();
          },
        ),
      ),
    );
  }
}
