import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

class PdfContent extends StatelessWidget {
  NumberFormat myFormat = NumberFormat.currency(
    locale: 'en_in',
    symbol: '\u{20B9}',
    decimalDigits: 2,
  );

  PdfContent({
    required this.format,
    required this.googleFont,
    required this.googleBoldFont,
    required this.incomeTotal,
    required this.expenseTotal,
  });

  final PdfPageFormat format;
  final Font googleFont;
  final Font googleBoldFont;
  final double incomeTotal;
  final double expenseTotal;

  @override
  Widget build(Context context) {
    return Container(
      width: format.availableWidth,
      decoration: BoxDecoration(
        border: Border.all(width: 1),
      ),
      child: Center(
          child: Padding(
        padding: const EdgeInsets.all(30),
        child: Chart(
          grid: PieGrid(),
          title: Text(
            'Group Expense Chart',
            style: TextStyle(
              fontSize: 35,
              font: googleFont,
            ),
          ),
          bottom: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(height: 30, width: 30, color: PdfColors.green),
                      Text(
                        '  Income ${myFormat.format(incomeTotal)}',
                        style: TextStyle(
                          fontSize: 25,
                          font: googleFont,
                        ),
                      ),
                    ]),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(height: 30, width: 30, color: PdfColors.red),
                    Text(
                      '  Expense ${myFormat.format(expenseTotal)}',
                      style: TextStyle(
                        fontSize: 25,
                        font: googleFont,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          datasets: [
            PieDataSet(
              value: incomeTotal.toInt(),
              color: PdfColors.green,
              innerRadius: 100,
            ),
            PieDataSet(
              value: expenseTotal.toInt(),
              color: PdfColors.red,
              innerRadius: 100,
            ),
          ],
        ),
      )),
    );
  }
}
