//CLASE UNIVERSAL DONDE  SE HACE LOS LLAMADOS
import 'core/http_client.dart';

// Endpoints
import 'endpoint/facilitador_endpoint.dart';
import 'endpoint/servicio_endpoint.dart';
import 'endpoint/sesion_endpoint.dart';
import 'endpoint/departamento_endpoint.dart';
import 'endpoint/asistencias_endpoint.dart';
import 'endpoint/persona_endpoint.dart';
// agrega los demás endpoints que vayas teniendo

class BackendApi {
  final HttpClient http;

  // Endpoints expuestos como propiedades
  late final FacilitadorEndpoint facilitador;
  late final ServicioEndpoint servicio;
  late final SesionEndpoint sesion;
  late final DepartamentoEndpoint departamento;
  late final AsistenciaEndpoint asistencia;
  late final PersonaEndpoint persona;
  // agrega más endpoints aquí

  BackendApi(String baseUrl)
      : http = HttpClient(baseUrl) {
    
    // Inicialización de endpoints reutilizando el mismo http
    facilitador = FacilitadorEndpoint(http);
    servicio = ServicioEndpoint(http);
    sesion = SesionEndpoint(http);
    departamento = DepartamentoEndpoint(http);
    asistencia = AsistenciaEndpoint(http);
    persona= PersonaEndpoint(http);
    // continúa con todos los endpoints que tengas
  }
}
