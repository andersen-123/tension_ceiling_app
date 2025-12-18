import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:tension_ceiling_app/models/estimate.dart';

class PdfService {
  static Future<Uint8List> generateEstimatePdf(Estimate estimate) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(30),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Шапка
              _buildHeader(estimate),
              pw.SizedBox(height: 30),
              
              // Информация о клиенте
              _buildClientInfo(estimate),
              pw.SizedBox(height: 20),
              
              // Таблица позиций
              _buildItemsTable(estimate),
              pw.SizedBox(height: 20),
              
              // Итоги
              _buildTotal(estimate),
              pw.SizedBox(height: 30),
              
              // Условия оплаты
              _buildPaymentTerms(),
              pw.SizedBox(height: 20),
              
              // Примечания
              if (estimate.notes.isNotEmpty)
                _buildNotes(estimate),
            ],
          );
        },
      ),
    );
    
    return pdf.save();
  }
  
  static pw.Widget _buildHeader(Estimate estimate) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'PotolokForLife',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue.shade800,
              ),
            ),
            pw.Text(
              'Натяжные потолки на всю жизнь',
              style: pw.TextStyle(fontSize: 12),
            ),
            pw.Text('Пушкино', style: pw.TextStyle(fontSize: 12)),
            pw.Text('Potolokforlife@yandex.ru', style: pw.TextStyle(fontSize: 12)),
            pw.Text('8(977)5311099, 8(977)7093843', style: pw.TextStyle(fontSize: 12)),
          ],
        ),
        
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Container(
              padding: pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey.shade400, width: 1),
                borderRadius: pw.BorderRadius.circular(5),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'СМЕТА №${estimate.number}',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Дата: ${_formatDate(estimate.createdAt)}',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  static pw.Widget _buildClientInfo(Estimate estimate) {
    return pw.Container(
      padding: pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey.shade100,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey.shade300, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Информация об объекте',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue.shade800,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _infoRow('Клиент:', estimate.clientName),
                  _infoRow('Адрес:', estimate.address),
                  _infoRow('Тип объекта:', estimate.objectType),
                ],
              ),
              pw.SizedBox(width: 50),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _infoRow('Помещений:', estimate.rooms.toString()),
                  _infoRow('Площадь:', '${estimate.area.toStringAsFixed(2)} м²'),
                  _infoRow('Периметр:', '${estimate.perimeter.toStringAsFixed(2)} м'),
                  _infoRow('Высота:', '${estimate.height.toStringAsFixed(2)} м'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  static pw.Widget _infoRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey.shade600,
          ),
        ),
        pw.SizedBox(width: 5),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(fontSize: 10),
          ),
        ),
      ],
    );
  }
  
  static pw.Widget _buildItemsTable(Estimate estimate) {
    final headers = ['№', 'Наименование', 'Ед.изм.', 'Кол-во', 'Цена, руб.', 'Сумма, руб.'];
    final columnWidths = {
      0: pw.FlexColumnWidth(0.5),
      1: pw.FlexColumnWidth(2.5),
      2: pw.FlexColumnWidth(0.8),
      3: pw.FlexColumnWidth(0.8),
      4: pw.FlexColumnWidth(1.2),
      5: pw.FlexColumnWidth(1.2),
    };
    
    return pw.TableHelper.fromTextArray(
      border: pw.TableBorder(
        top: pw.BorderSide(color: PdfColors.grey.shade400),
        bottom: pw.BorderSide(color: PdfColors.grey.shade400),
        left: pw.BorderSide(color: PdfColors.grey.shade400),
        right: pw.BorderSide(color: PdfColors.grey.shade400),
        horizontalInside: pw.BorderSide(color: PdfColors.grey.shade300),
        verticalInside: pw.BorderSide(color: PdfColors.grey.shade300),
      ),
      headerStyle: pw.TextStyle(
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: pw.BoxDecoration(color: PdfColors.blue.shade800),
      cellStyle: pw.TextStyle(fontSize: 9),
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
        4: pw.Alignment.centerRight,
        5: pw.Alignment.centerRight,
      },
      headerPadding: pw.EdgeInsets.all(8),
      cellPadding: pw.EdgeInsets.all(6),
      columnWidths: columnWidths,
      headers: headers,
      data: List<List<String>>.generate(
        estimate.items.length,
        (index) {
          final item = estimate.items[index];
          return [
            (index + 1).toString(),
            item.name,
            item.unit,
            item.quantity.toStringAsFixed(2),
            item.price.toStringAsFixed(2),
            item.total.toStringAsFixed(2),
          ];
        },
      ),
    );
  }
  
  static pw.Widget _buildTotal(Estimate estimate) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Container(
          padding: pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey.shade100,
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: PdfColors.grey.shade300, width: 1),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'ИТОГО',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey.shade600,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                '${estimate.total.toStringAsFixed(2)} руб.',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue.shade800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  static pw.Widget _buildPaymentTerms() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Порядок оплаты:',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue.shade800,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          '1. Предоплата 50% не позднее 3-х дней до планируемой даты выполнения монтажа 1-го этапа.',
          style: pw.TextStyle(fontSize: 10),
        ),
        pw.Text(
          '2. Окончательный расчет 50% в день завершения всех работ.',
          style: pw.TextStyle(fontSize: 10),
        ),
        pw.Text(
          'Оплата за материалы из раздела "Оборудование" производится из расчета 100% до начала выполнения работ.',
          style: pw.TextStyle(fontSize: 10),
        ),
      ],
    );
  }
  
  static pw.Widget _buildNotes(Estimate estimate) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Примечания:',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue.shade800,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          estimate.notes,
          style: pw.TextStyle(fontSize: 10),
        ),
      ],
    );
  }
  
  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
