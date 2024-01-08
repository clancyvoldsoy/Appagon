import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

late String message;
late String respuesta;

class SituacionDelSen {
  int situacionMW;
  String formattedDate;
  String linkWeb;
  bool actualizacion;
  String url;
  String situacion;
  SituacionDelSen()
      : situacionMW = 0,
        formattedDate = '',
        linkWeb = '',
        actualizacion = false,
        url = '',
        situacion = '';

  getResponse() async {
    await initializeDateFormatting('es', null);
    DateTime hoy = DateTime.now(); //FECHA
    String formattedDate = DateFormat('dd-MMMM-yyyy', 'es').format(hoy);
    String linkWeb = formattedDate.replaceAll('-', '-de-');
    String url =
        'https://www.minem.gob.cu/es/noticias/situacion-del-sen/situacion-del-sen-para-el-$linkWeb';

    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      if (response.body.contains('{title:"Situaci\\u00f3n del SEN')) {
        int inicio =
            response.body.indexOf(' /><meta name="abstract" content="');
        int fin =
            response.body.indexOf('/><meta name="robots" content="follow,');
        var scrapping = response.body.substring(inicio, fin);
        String situacion =
            scrapping.replaceAll(' /><meta name="abstract" content="', '');
        String respuesta = situacion;
        String encabezado =
            'Parte del SEN para el ${linkWeb.replaceAll('-', ' ')}:\n';
        if (respuesta.contains('disponibilidad')) {
          RegExp exp = RegExp(
              r'una disponibilidad de (\d+) MW|una demanda máxima de (\d+) MW');
          Iterable<Match> matches = exp.allMatches(situacion);
          List<int> intNumbers = [];
          for (Match match in matches) {
            String? number = match.group(1) ?? match.group(2);
            intNumbers.add(int.parse(number!));
          }

          int situacionMW = intNumbers.first - intNumbers.last;

          String message = situacionMW.toString();
          if (situacionMW < 0) {
            return "$encabezado\n$respuesta\n \nSe estima una un deficit de ${message.toString().replaceAll('-', '')} MW para el dia de hoy\nHay Probabilidades de Afectacion";
          } else {
            return "$encabezado\n$respuesta\n \nSe estima una reserva de ${message.toString().replaceAll('-', '')} MW para el dia de hoy\n\nNo Hay Probabilidades de Afectacion";
          }
        }
      } else {
        // Cambio de formato de fecha y reintento
        formattedDate = DateFormat('d-MMMM-yyyy', 'es').format(hoy);
        linkWeb = formattedDate.replaceAll('-', '-de-');
        url =
            'https://www.minem.gob.cu/es/noticias/situacion-del-sen/situacion-del-sen-para-el-$linkWeb';
        response = await http.get(Uri.parse(url));
        if (response.statusCode == 200 &&
            response.body.contains('{title:"Situaci\\u00f3n del SEN')) {
          // Procesar la respuesta como antes
          int inicio =
              response.body.indexOf(' /><meta name="abstract" content="');
          int fin =
              response.body.indexOf('/><meta name="robots" content="follow,');
          var scrapping = response.body.substring(inicio, fin);
          String situacion =
              scrapping.replaceAll(' /><meta name="abstract" content="', '');
          String respuesta = situacion;
          String encabezado =
              'Parte del SEN para el ${linkWeb.replaceAll('-', ' ')}:\n';
          if (respuesta.contains('disponibilidad')) {
            RegExp exp = RegExp(
                r'una disponibilidad de (\d+) MW|una demanda máxima de (\d+) MW');
            Iterable<Match> matches = exp.allMatches(situacion);
            List<int> intNumbers = [];
            for (Match match in matches) {
              String? number = match.group(1) ?? match.group(2);
              intNumbers.add(int.parse(number!));
            }

            this.situacionMW = intNumbers.first - intNumbers.last;

            String message = situacionMW.toString();
            if (this.situacionMW < 0) {
              return "$encabezado\n$respuesta\n \nSe estima una un deficit de ${message.toString().replaceAll('-', '')} MW para el dia de hoy\nHay Probabilidades de Afectacion";
            } else {
              return "$encabezado\n$respuesta\n \nSe estima una reserva de ${message.toString().replaceAll('-', '')} MW para el dia de hoy\n\nNo Hay Probabilidades de Afectacion";
            }
          }
        } else {
          return "No se ha actualizado el parte diario del SEN. Por favor, espere.";
        }
      }
    } else {
      return "No se ha recibido ninguna respuesta del servidor. Por favor, verifique su conexion a internet.";
    }
  }
}
