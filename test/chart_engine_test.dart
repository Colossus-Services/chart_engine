import 'package:chart_engine/src/chart_engine_colors.dart';
import 'package:test/test.dart';

void main() {
  group('ColorPalette', () {

    setUp(() {});

    test('Basic palette', () {

      var colorPalette = ColorPalette.from( ['#ff0000','#00ff00','rgba(0,0,255, 0.5)'] ) ;

      expect(colorPalette.basicColors[0], equals( HTMLColor(255,0,0) ));
      expect(colorPalette.basicColors[1], equals( HTMLColor(0,255,0) ));
      expect(colorPalette.basicColors[2], equals( HTMLColor(0,0,255, 0.5) ));

      expect(colorPalette.generatePalette(1), equals( [HTMLColor(255,0,0)] ));
      expect(colorPalette.generatePalette(2), equals( [HTMLColor(255,0,0), HTMLColor(0,255,0)] ));
      expect(colorPalette.generatePalette(3), equals( [HTMLColor(255,0,0), HTMLColor(0,255,0), HTMLColor(0,0,255, 0.5)] ));

    });

    test('Generate palette', () {

      var colorPalette = ColorPalette.from( ['#ff0000','#00ff00'] ) ;

      expect(colorPalette.generateHTMLPalette(3), equals( ['#900000', '#ff0000', '#00ff00'] ));
      expect(colorPalette.generateHTMLPalette(4), equals( ['#900000', '#ff0000', '#00ff00', '#ff7070'] ));
      expect(colorPalette.generateHTMLPalette(5), equals( ['#900000', '#009000', '#ff0000', '#00ff00', '#ff7070'] ));
      expect(colorPalette.generateHTMLPalette(6), equals( ['#900000', '#009000', '#ff0000', '#00ff00', '#ff7070', '#70ff70'] ));
      expect(colorPalette.generateHTMLPalette(7), equals( ['#210000', '#900000', '#009000', '#ff0000', '#00ff00', '#ff7070', '#70ff70'] ));
      expect(colorPalette.generateHTMLPalette(8), equals( ['#210000', '#900000', '#009000', '#ff0000', '#00ff00', '#ff7070', '#70ff70', '#ffe0e0'] ));

    });

  });
}
