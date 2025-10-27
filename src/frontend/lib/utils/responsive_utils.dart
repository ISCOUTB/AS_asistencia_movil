import 'package:flutter/material.dart';

/// Utilidades para hacer la aplicación responsive en todas las dimensiones
class ResponsiveUtils {
  /// Obtener el ancho de la pantalla
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Obtener el alto de la pantalla
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Verificar si el dispositivo está en modo horizontal
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Verificar si el dispositivo está en modo vertical
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Obtener el tipo de dispositivo basado en el ancho
  static DeviceType getDeviceType(BuildContext context) {
    double width = screenWidth(context);
    
    if (width < 600) {
      return DeviceType.mobile;
    } else if (width < 900) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// Verificar si es un dispositivo móvil
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  /// Verificar si es una tablet
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  /// Verificar si es desktop
  static bool isDesktop(BuildContext context) {
    return getDeviceType(context) == DeviceType.desktop;
  }

  /// Obtener padding horizontal responsive
  static double getHorizontalPadding(BuildContext context) {
    if (isLandscape(context)) {
      return screenWidth(context) * 0.08; // 8% en horizontal
    }
    
    double width = screenWidth(context);
    if (width < 360) {
      return 12.0; // Dispositivos muy pequeños
    } else if (width < 400) {
      return 16.0; // Dispositivos pequeños
    } else if (width < 600) {
      return 20.0; // Dispositivos normales
    } else {
      return width * 0.05; // Tablets y más grandes
    }
  }

  /// Obtener padding vertical responsive
  static double getVerticalPadding(BuildContext context) {
    if (isLandscape(context)) {
      return 8.0; // Menos padding vertical en horizontal
    }
    
    double height = screenHeight(context);
    if (height < 600) {
      return 8.0; // Dispositivos muy pequeños
    } else if (height < 700) {
      return 12.0; // Dispositivos pequeños
    } else {
      return 16.0; // Dispositivos normales y grandes
    }
  }

  /// Obtener tamaño de fuente responsive basado en el ancho
  static double getFontSize(BuildContext context, double baseSize) {
    double width = screenWidth(context);
    double scaleFactor;
    
    if (width < 360) {
      scaleFactor = 0.85; // Dispositivos muy pequeños
    } else if (width < 400) {
      scaleFactor = 0.95; // Dispositivos pequeños
    } else if (width < 600) {
      scaleFactor = 1.0; // Dispositivos normales
    } else if (width < 900) {
      scaleFactor = 1.1; // Tablets
    } else {
      scaleFactor = 1.2; // Desktop
    }
    
    return baseSize * scaleFactor;
  }

  /// Obtener número de columnas para un grid responsive
  static int getGridColumns(BuildContext context, {int? landscapeColumns}) {
    if (isLandscape(context)) {
      return landscapeColumns ?? 3; // Más columnas en horizontal
    }
    
    double width = screenWidth(context);
    if (width < 360) {
      return 1; // Una columna para dispositivos muy pequeños
    } else if (width < 600) {
      return 2; // Dos columnas para móviles normales
    } else if (width < 900) {
      return 3; // Tres columnas para tablets
    } else {
      return 4; // Cuatro columnas para desktop
    }
  }

  /// Obtener aspect ratio responsive para cards en grid
  static double getCardAspectRatio(BuildContext context) {
    if (isLandscape(context)) {
      return 1.5; // Cards más anchos en horizontal
    }
    
    double width = screenWidth(context);
    if (width < 360) {
      return 1.0; // Cards más cuadrados en dispositivos pequeños
    } else if (width < 600) {
      return 1.1; // Ligeramente más anchos
    } else {
      return 1.2; // Más anchos en tablets
    }
  }

  /// Obtener altura de card responsive
  static double getCardHeight(BuildContext context, double baseHeight) {
    if (isLandscape(context)) {
      return baseHeight * 0.7; // Cards más pequeños en horizontal
    }
    
    double height = screenHeight(context);
    if (height < 600) {
      return baseHeight * 0.8; // Más pequeños en pantallas cortas
    } else if (height < 700) {
      return baseHeight * 0.9;
    } else {
      return baseHeight; // Tamaño completo en pantallas grandes
    }
  }

  /// Obtener espaciado responsive entre elementos
  static double getSpacing(BuildContext context, double baseSpacing) {
    if (isLandscape(context)) {
      return baseSpacing * 0.7; // Menos espacio en horizontal
    }
    
    double width = screenWidth(context);
    if (width < 360) {
      return baseSpacing * 0.8;
    } else if (width < 400) {
      return baseSpacing * 0.9;
    } else {
      return baseSpacing;
    }
  }

  /// Obtener radio de bordes responsive
  static double getBorderRadius(BuildContext context, double baseRadius) {
    double width = screenWidth(context);
    if (width < 360) {
      return baseRadius * 0.8;
    } else {
      return baseRadius;
    }
  }

  /// Obtener tamaño de ícono responsive
  static double getIconSize(BuildContext context, double baseSize) {
    double width = screenWidth(context);
    if (width < 360) {
      return baseSize * 0.85;
    } else if (width < 400) {
      return baseSize * 0.95;
    } else {
      return baseSize;
    }
  }

  /// Obtener altura de AppBar responsive
  static double getAppBarHeight(BuildContext context) {
    if (isLandscape(context)) {
      return 48.0; // Más pequeña en horizontal
    }
    return kToolbarHeight; // Tamaño estándar en vertical
  }

  /// Obtener padding para contenido principal
  static EdgeInsets getContentPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: getHorizontalPadding(context),
      vertical: getVerticalPadding(context),
    );
  }

  /// Obtener padding para cards
  static EdgeInsets getCardPadding(BuildContext context) {
    double base = isLandscape(context) ? 12.0 : 16.0;
    double width = screenWidth(context);
    
    if (width < 360) {
      return EdgeInsets.all(base * 0.75);
    } else if (width < 400) {
      return EdgeInsets.all(base * 0.875);
    } else {
      return EdgeInsets.all(base);
    }
  }

  /// Obtener espaciado entre cards en listas
  static double getListItemSpacing(BuildContext context) {
    if (isLandscape(context)) {
      return 6.0;
    }
    
    double height = screenHeight(context);
    if (height < 600) {
      return 6.0;
    } else if (height < 700) {
      return 8.0;
    } else {
      return 10.0;
    }
  }

  /// Obtener máximo ancho para contenido (útil en tablets/desktop)
  static double getMaxContentWidth(BuildContext context) {
    double width = screenWidth(context);
    if (width > 900) {
      return 800.0; // Limitar ancho en pantallas muy grandes
    }
    return width;
  }

  /// Wrapper para centrar contenido en pantallas grandes
  static Widget constrainedContent(BuildContext context, Widget child) {
    double width = screenWidth(context);
    if (width > 900) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: getMaxContentWidth(context)),
          child: child,
        ),
      );
    }
    return child;
  }

  /// Obtener tamaño de botón responsive
  static Size getButtonSize(BuildContext context, {required ButtonSizeType type}) {
    double width = screenWidth(context);
    double scaleFactor = width < 360 ? 0.9 : 1.0;
    
    switch (type) {
      case ButtonSizeType.small:
        return Size(scaleFactor * 80, scaleFactor * 32);
      case ButtonSizeType.medium:
        return Size(scaleFactor * 120, scaleFactor * 40);
      case ButtonSizeType.large:
        return Size(scaleFactor * 200, scaleFactor * 48);
      case ButtonSizeType.fullWidth:
        return Size(double.infinity, scaleFactor * 48);
    }
  }

  /// Obtener altura de bottom navigation bar responsive
  static double getBottomNavHeight(BuildContext context) {
    if (isLandscape(context)) {
      return 60.0; // Más pequeño en horizontal
    }
    return 75.0; // Tamaño normal en vertical
  }

  /// Obtener configuración de grid responsive
  static GridConfig getGridConfig(BuildContext context) {
    bool landscape = isLandscape(context);
    double width = screenWidth(context);
    
    if (landscape) {
      return GridConfig(
        crossAxisCount: width < 600 ? 3 : 4,
        childAspectRatio: 1.3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      );
    }
    
    if (width < 360) {
      return GridConfig(
        crossAxisCount: 1,
        childAspectRatio: 2.5,
        crossAxisSpacing: 0,
        mainAxisSpacing: 8,
      );
    } else if (width < 600) {
      return GridConfig(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      );
    } else if (width < 900) {
      return GridConfig(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      );
    } else {
      return GridConfig(
        crossAxisCount: 4,
        childAspectRatio: 1.2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      );
    }
  }
}

/// Enum para tipos de dispositivo
enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// Enum para tipos de tamaño de botón
enum ButtonSizeType {
  small,
  medium,
  large,
  fullWidth,
}

/// Clase para configuración de grid
class GridConfig {
  final int crossAxisCount;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;

  GridConfig({
    required this.crossAxisCount,
    required this.childAspectRatio,
    required this.crossAxisSpacing,
    required this.mainAxisSpacing,
  });
}

/// Extension para facilitar el uso de responsive utils
extension ResponsiveContext on BuildContext {
  ResponsiveUtils get responsive => ResponsiveUtils();
  
  bool get isLandscape => ResponsiveUtils.isLandscape(this);
  bool get isPortrait => ResponsiveUtils.isPortrait(this);
  bool get isMobile => ResponsiveUtils.isMobile(this);
  bool get isTablet => ResponsiveUtils.isTablet(this);
  bool get isDesktop => ResponsiveUtils.isDesktop(this);
  
  double get screenWidth => ResponsiveUtils.screenWidth(this);
  double get screenHeight => ResponsiveUtils.screenHeight(this);
  
  double get horizontalPadding => ResponsiveUtils.getHorizontalPadding(this);
  double get verticalPadding => ResponsiveUtils.getVerticalPadding(this);
  
  EdgeInsets get contentPadding => ResponsiveUtils.getContentPadding(this);
  EdgeInsets get cardPadding => ResponsiveUtils.getCardPadding(this);
}
