import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
 Map<int, List> rotacion = {
  1: ['"B1 y B2"', '"B3 Y B4"', '"B1 Y B2"', '"B3 Y B4"', '"B1 Y B2"'],
  2: ['"B3 Y B4"', '"B1 Y B2"', '"B3 Y B4"', '"B1 Y B2"', '"B3 Y B4"'],
  3: ['"B1 y B2"', '"B3 Y B4"', '"B1 Y B2"', '"B3 Y B4"', '"B1 Y B2"'],
  4: ['"B3 Y B4"', '"B1 Y B2"', '"B3 Y B4"', '"B1 Y B2"', '"B3 Y B4"']
};

void main() async {
  await initializeDateFormatting('es_ES', null);
  var fechaInicial = DateTime(2024, 05, 1);
  var formattedDate = DateFormat('dd-MMMM-yyyy', 'es').format(fechaInicial);
  int contador = 1;
  for (var j = 0; j <= 100; j++,) {
    for (var i = 1;
        i < 5;
        i++,
        contador++,
        fechaInicial = fechaInicial.add(const Duration(days: 1)),
        formattedDate = DateFormat('dd-MMMM-yyyy', 'es').format(fechaInicial)) {
      print('"$formattedDate": ${rotacion[i]},');
    }
  }
}